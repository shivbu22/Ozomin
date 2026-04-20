// =====================================================
// Admin Route Handler — Auth, Order Management, Dashboard
// =====================================================

import { jsonResponse } from '../index.js';
import { requireAdmin } from '../middleware/adminAuth.js';
import { createRazorpayLink } from '../lib/razorpay.js';
import { sendPaymentLinkEmail, sendShippingEmail, sendRejectionEmail,
         sendReadyForPickupEmail, sendOrderConfirmationEmail,
         sendTestEmail } from '../lib/email.js';

const OTP_TTL = 600;

function generateOTP() {
  return String(Math.floor(100000 + Math.random() * 900000));
}

export async function handleAdmin(request, env, url) {
  const method = request.method;
  const path = url.pathname.replace('/admin', '');

  // ── POST /admin/auth/request-otp — Step 1
  if (method === 'POST' && path === '/auth/request-otp') {
    const body = await request.json();
    const { email, api_key } = body;

    if (email !== env.ADMIN_EMAIL || api_key !== env.ADMIN_API_KEY) {
      return jsonResponse({ error: 'Invalid credentials' }, 401);
    }

    const otp = generateOTP();
    const sessionKey = `admin:session:${email}`;
    await env.STORE_KV.put(sessionKey, JSON.stringify({ otp, verified: false }), { expirationTtl: OTP_TTL });

    // Send OTP email
    const { sendAdminOTPEmail } = await import('../lib/email.js');
    await sendAdminOTPEmail(env, { to: email, otp });

    return jsonResponse({ message: 'OTP sent to admin email' });
  }

  // ── POST /admin/auth/verify-otp — Step 2
  if (method === 'POST' && path === '/auth/verify-otp') {
    const body = await request.json();
    const { email, otp } = body;

    const sessionKey = `admin:session:${email}`;
    const session = await env.STORE_KV.get(sessionKey, { type: 'json' });

    if (!session) return jsonResponse({ error: 'OTP expired or not found' }, 400);
    if (session.otp !== String(otp)) return jsonResponse({ error: 'Invalid OTP' }, 400);

    // Mark verified, extend session to 8 hours
    await env.STORE_KV.put(sessionKey, JSON.stringify({ verified: true }), { expirationTtl: 28800 });
    return jsonResponse({ message: 'Admin authenticated successfully' });
  }

  // All routes below require valid admin session
  const authError = await requireAdmin(request, env);
  if (authError) return authError;

  // ── GET /admin/test-email
  if (method === 'GET' && path === '/test-email') {
    try {
      const result = await sendTestEmail(env);
      return jsonResponse({ message: 'Test email sent successfully', result });
    } catch (error) {
      return jsonResponse({ error: 'Failed to send test email', details: error.message }, 500);
    }
  }

  // ── GET /admin/orders — List all orders with filters
  if (method === 'GET' && path === '/orders') {
    const status = url.searchParams.get('status');
    const date = url.searchParams.get('date');
    const page = parseInt(url.searchParams.get('page') || '1');
    const limit = Math.min(parseInt(url.searchParams.get('limit') || '20'), 100);
    const offset = (page - 1) * limit;

    let query = `SELECT o.*, c.name as customer_name, c.email as customer_email, c.phone as customer_phone
      FROM orders o JOIN customers c ON o.customer_id = c.id WHERE 1=1`;
    const params = [];

    if (status) { query += ' AND o.status = ?'; params.push(status); }
    if (date) { query += ' AND DATE(o.created_at) = ?'; params.push(date); }
    query += ' ORDER BY o.created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    const rows = await env.DB.prepare(query).bind(...params).all();
    return jsonResponse({ orders: rows.results });
  }

  // ── POST /admin/orders/:ref/accept — Accept → Create Razorpay link
  if (method === 'POST' && path.match(/^\/orders\/[A-Z0-9-]+\/accept$/)) {
    const orderRef = path.split('/')[2];
    const order = await env.DB.prepare('SELECT * FROM orders WHERE order_ref = ?').bind(orderRef).first();
    if (!order) return jsonResponse({ error: 'Order not found' }, 404);
    if (order.status !== 'verified') {
      return jsonResponse({ error: 'Only verified orders can be accepted' }, 400);
    }

    const cust = await env.DB.prepare('SELECT * FROM customers WHERE id = ?').bind(order.customer_id).first();
    const body = await request.json().catch(() => ({}));

    // Create Razorpay payment link
    const paymentLink = await createRazorpayLink(env, {
      amount: order.total_amount,    // already in paise
      orderRef,
      customerName: cust.name,
      customerEmail: cust.email,
      customerPhone: cust.phone,
      description: `Ozomin Order ${orderRef}`,
      expireBy: Math.floor(Date.now() / 1000) + 3600, // 1 hour
    });

    await env.DB.prepare(`
      UPDATE orders SET status='accepted', razorpay_payment_link_id=?, razorpay_payment_link_url=?,
        payment_link_expires_at=datetime('now', '+1 hour'), admin_notes=?, updated_at=datetime('now')
      WHERE order_ref=?
    `).bind(
      paymentLink.id, paymentLink.short_url,
      body.admin_notes || null, orderRef
    ).run();

    // Fetch order items for email
    const items = await env.DB.prepare('SELECT * FROM order_items WHERE order_id = ?').bind(order.id).all();

    await sendPaymentLinkEmail(env, {
      to: cust.email,
      name: cust.name,
      orderRef,
      paymentUrl: paymentLink.short_url,
      totalAmount: order.total_amount,
      delivery_type: order.delivery_type,
      delivery_notes: order.delivery_notes,
      items: items.results,
    });

    return jsonResponse({ message: 'Order accepted, payment link sent', payment_url: paymentLink.short_url });
  }

  // ── POST /admin/orders/:ref/ship — Ship order (delivery)
  if (method === 'POST' && path.match(/^\/orders\/[A-Z0-9-]+\/ship$/)) {
    const orderRef = path.split('/')[2];
    const order = await env.DB.prepare('SELECT * FROM orders WHERE order_ref = ?').bind(orderRef).first();
    if (!order) return jsonResponse({ error: 'Order not found' }, 404);
    if (order.status !== 'paid') return jsonResponse({ error: 'Only paid orders can be shipped' }, 400);
    if (order.delivery_type !== 'delivery') return jsonResponse({ error: 'Use /ready for pickup orders' }, 400);

    const body = await request.json();
    const cust = await env.DB.prepare('SELECT * FROM customers WHERE id = ?').bind(order.customer_id).first();

    await env.DB.prepare(`
      UPDATE orders SET status='shipped', tracking_number=?, courier_name=?,
        shipped_at=datetime('now'), updated_at=datetime('now') WHERE order_ref=?
    `).bind(body.tracking_number || null, body.courier_name || null, orderRef).run();

    await sendShippingEmail(env, {
      to: cust.email, name: cust.name, orderRef,
      trackingNumber: body.tracking_number,
      courierName: body.courier_name,
      delivery_type: order.delivery_type,
    });

    return jsonResponse({ message: 'Order marked as shipped, customer notified' });
  }

  // ── POST /admin/orders/:ref/ready — Pickup ready
  if (method === 'POST' && path.match(/^\/orders\/[A-Z0-9-]+\/ready$/)) {
    const orderRef = path.split('/')[2];
    const order = await env.DB.prepare('SELECT * FROM orders WHERE order_ref = ?').bind(orderRef).first();
    if (!order) return jsonResponse({ error: 'Order not found' }, 404);
    if (order.status !== 'paid') return jsonResponse({ error: 'Only paid orders can be marked ready' }, 400);

    const cust = await env.DB.prepare('SELECT * FROM customers WHERE id = ?').bind(order.customer_id).first();

    await env.DB.prepare(`UPDATE orders SET status='ready', updated_at=datetime('now') WHERE order_ref=?`)
      .bind(orderRef).run();

    await sendReadyForPickupEmail(env, {
      to: cust.email, name: cust.name, orderRef, delivery_notes: order.delivery_notes,
    });

    return jsonResponse({ message: 'Order marked as ready for pickup' });
  }

  // ── POST /admin/orders/:ref/deliver — Mark delivered
  if (method === 'POST' && path.match(/^\/orders\/[A-Z0-9-]+\/deliver$/)) {
    const orderRef = path.split('/')[2];
    await env.DB.prepare(`
      UPDATE orders SET status='delivered', delivered_at=datetime('now'), updated_at=datetime('now')
      WHERE order_ref=?
    `).bind(orderRef).run();
    return jsonResponse({ message: 'Order marked as delivered' });
  }

  // ── POST /admin/orders/:ref/reject
  if (method === 'POST' && path.match(/^\/orders\/[A-Z0-9-]+\/reject$/)) {
    const orderRef = path.split('/')[2];
    const body = await request.json();
    const order = await env.DB.prepare('SELECT * FROM orders WHERE order_ref = ?').bind(orderRef).first();
    if (!order) return jsonResponse({ error: 'Order not found' }, 404);

    const cust = await env.DB.prepare('SELECT * FROM customers WHERE id = ?').bind(order.customer_id).first();

    // Restore stock for physical items
    const items = await env.DB.prepare('SELECT * FROM order_items WHERE order_id = ?').bind(order.id).all();
    for (const item of items.results) {
      const product = await env.DB.prepare('SELECT is_service FROM products WHERE id = ?').bind(item.product_id).first();
      if (product && !product.is_service) {
        await env.DB.prepare('UPDATE products SET stock_qty = stock_qty + ? WHERE id = ?')
          .bind(item.quantity, item.product_id).run();
      }
    }

    // Refund Eco Points if they were used
    if (order.eco_points_used > 0) {
      await creditEcoPoints(env, cust.id, null, order.eco_points_used, 'order_refund');
    }

    await env.DB.prepare(`
      UPDATE orders SET status='rejected', rejection_reason=?, updated_at=datetime('now') WHERE order_ref=?
    `).bind(body.reason || 'Order rejected by admin', orderRef).run();

    await sendRejectionEmail(env, {
      to: cust.email, name: cust.name, orderRef,
      reason: body.reason || 'Your order could not be fulfilled at this time.',
      ecoPointsRefunded: order.eco_points_used,
    });

    return jsonResponse({ message: 'Order rejected, customer notified' });
  }

  // ── GET /admin/dashboard
  if (method === 'GET' && path === '/dashboard') {
    const today = new Date().toISOString().split('T')[0];
    const [orderStats, revenueRow, lowStock, recentOrders] = await Promise.all([
      env.DB.prepare(`
        SELECT status, COUNT(*) as count FROM orders WHERE DATE(created_at) = ? GROUP BY status
      `).bind(today).all(),
      env.DB.prepare(`
        SELECT SUM(total_amount) as revenue FROM orders WHERE DATE(created_at) = ? AND status NOT IN ('rejected','cancelled')
      `).bind(today).first(),
      env.DB.prepare(`
        SELECT id, name, sku, stock_qty, min_qty FROM products WHERE stock_qty <= min_qty AND active = 1 AND is_service = 0
      `).all(),
      env.DB.prepare(`
        SELECT o.*, c.name as customer_name FROM orders o
        JOIN customers c ON o.customer_id = c.id
        ORDER BY o.created_at DESC LIMIT 10
      `).all(),
    ]);

    const statusMap = {};
    for (const row of orderStats.results) statusMap[row.status] = row.count;

    return jsonResponse({
      date: today,
      order_stats: statusMap,
      today_revenue: (revenueRow.revenue || 0) / 100,
      low_stock_alerts: lowStock.results,
      recent_orders: recentOrders.results,
    });
  }

  return jsonResponse({ error: 'Admin route not found' }, 404);
}

async function creditEcoPoints(env, customerId, orderId, points, reason) {
  const cust = await env.DB.prepare('SELECT eco_points_balance FROM customers WHERE id = ?')
    .bind(customerId).first();
  const newBalance = (cust?.eco_points_balance || 0) + points;
  await env.DB.prepare('UPDATE customers SET eco_points_balance = ? WHERE id = ?')
    .bind(newBalance, customerId).run();
  await env.DB.prepare(
    'INSERT INTO eco_points_ledger (customer_id, order_id, points_delta, balance_after, reason) VALUES (?, ?, ?, ?, ?)'
  ).bind(customerId, orderId, points, newBalance, reason).run();
}
