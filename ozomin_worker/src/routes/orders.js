// =====================================================
// Orders Route Handler — Full flow with OTP + Razorpay
// =====================================================

import { jsonResponse } from '../index.js';
import { sendOTPEmail, sendPaymentLinkEmail, sendOrderConfirmationEmail,
         sendShippingEmail, sendRejectionEmail, sendReadyForPickupEmail } from '../lib/email.js';
import { createRazorpayLink } from '../lib/razorpay.js';

const MAX_OTP_ATTEMPTS = 5;
const MAX_OTP_RESENDS = 3;
const OTP_TTL = 600;        // 10 minutes
const RESEND_COOLDOWN = 60; // 60 seconds

function generateOrderRef() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let ref = 'OZO-';
  for (let i = 0; i < 5; i++) ref += chars[Math.floor(Math.random() * chars.length)];
  return ref;
}

function generateOTP() {
  return String(Math.floor(100000 + Math.random() * 900000));
}

export async function handleOrders(request, env, url) {
  const method = request.method;
  const segments = url.pathname.replace('/api/orders', '').split('/').filter(Boolean);
  const orderId = segments[0];
  const action = segments[1];

  // ── POST /api/orders — Place new order
  if (method === 'POST' && !orderId) {
    const body = await request.json();
    const { customer, items, delivery_type, delivery_address, delivery_notes,
            scheduled_date, scheduled_time_slot, eco_points_to_use } = body;

    if (!customer?.email || !customer?.name || !customer?.phone) {
      return jsonResponse({ error: 'Customer name, email, and phone are required' }, 400);
    }
    if (!items?.length) {
      return jsonResponse({ error: 'Order must have at least one item' }, 400);
    }

    // Find or create customer
    let cust = await env.DB.prepare('SELECT * FROM customers WHERE email = ?')
      .bind(customer.email).first();

    if (!cust) {
      const res = await env.DB.prepare(
        'INSERT INTO customers (name, email, phone, address) VALUES (?, ?, ?, ?)'
      ).bind(customer.name, customer.email, customer.phone,
             JSON.stringify(delivery_address || {})).run();
      cust = await env.DB.prepare('SELECT * FROM customers WHERE id = ?')
        .bind(res.meta.last_row_id).first();
    }

    // Validate stock and build order items
    let subtotal = 0;
    const resolvedItems = [];

    for (const item of items) {
      const product = await env.DB.prepare(
        'SELECT * FROM products WHERE id = ? AND active = 1'
      ).bind(item.product_id).first();

      if (!product) {
        return jsonResponse({ error: `Product ${item.product_id} not found or inactive` }, 400);
      }
      if (!product.is_service && product.stock_qty < item.quantity) {
        return jsonResponse({ error: `Insufficient stock for "${product.name}". Available: ${product.stock_qty}` }, 400);
      }
      if (item.quantity < product.min_qty) {
        return jsonResponse({ error: `Minimum quantity for "${product.name}" is ${product.min_qty}` }, 400);
      }
      if (item.quantity > product.max_daily_qty) {
        return jsonResponse({ error: `Maximum daily quantity for "${product.name}" is ${product.max_daily_qty}` }, 400);
      }

      const lineTotal = product.price * item.quantity;
      subtotal += lineTotal;
      resolvedItems.push({ product, quantity: item.quantity, unit_price: product.price, total_price: lineTotal });
    }

    // Eco Points redemption
    let ecoPointsUsed = 0;
    let ecoDiscount = 0;

    if (eco_points_to_use && eco_points_to_use > 0) {
      const maxDiscount = Math.floor(subtotal * 0.20); // max 20% of subtotal
      const requestedDiscount = eco_points_to_use * 100; // 1 point = ₹1 = 100 paise
      ecoDiscount = Math.min(requestedDiscount, maxDiscount, cust.eco_points_balance * 100);
      ecoPointsUsed = Math.floor(ecoDiscount / 100);
    }

    const totalAmount = Math.max(0, subtotal - ecoDiscount);

    // Generate OTP
    const otp = generateOTP();
    const otpKey = `otp:${customer.email}`;
    const resendKey = `otp_resend:${customer.email}`;

    await env.STORE_KV.put(otpKey, JSON.stringify({
      otp,
      attempts: 0,
      resends: 0,
      email: customer.email,
    }), { expirationTtl: OTP_TTL });

    // Create order
    let orderRef;
    let orderResult;
    // Retry in case of ref collision
    for (let i = 0; i < 5; i++) {
      orderRef = generateOrderRef();
      try {
        orderResult = await env.DB.prepare(`
          INSERT INTO orders (order_ref, customer_id, status, delivery_type, delivery_address,
            delivery_notes, scheduled_date, scheduled_time_slot, subtotal,
            eco_points_used, eco_discount, total_amount, eco_points_earned)
          VALUES (?, ?, 'pending', ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)
        `).bind(orderRef, cust.id,
          delivery_type || 'delivery',
          JSON.stringify(delivery_address || {}),
          delivery_notes || '',
          scheduled_date || null,
          scheduled_time_slot || null,
          subtotal, ecoPointsUsed, ecoDiscount, totalAmount
        ).run();
        break;
      } catch (e) {
        if (!e.message.includes('UNIQUE')) throw e;
      }
    }

    const orderId = orderResult.meta.last_row_id;

    // Insert order items & deduct stock
    for (const item of resolvedItems) {
      await env.DB.prepare(
        'INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price, product_name, product_sku) VALUES (?, ?, ?, ?, ?, ?, ?)'
      ).bind(orderId, item.product.id, item.quantity, item.unit_price, item.total_price,
             item.product.name, item.product.sku).run();

      if (!item.product.is_service) {
        await env.DB.prepare('UPDATE products SET stock_qty = stock_qty - ? WHERE id = ?')
          .bind(item.quantity, item.product.id).run();
      }
    }

    // Store OTP → orderRef mapping
    await env.STORE_KV.put(`otp:${customer.email}`, JSON.stringify({
      otp, attempts: 0, resends: 0, orderRef,
    }), { expirationTtl: OTP_TTL });

    // Send OTP email
    await sendOTPEmail(env, {
      to: customer.email,
      name: customer.name,
      otp,
      orderRef,
      delivery_type: delivery_type || 'delivery',
      delivery_notes,
      totalAmount,
      subtotal,
      ecoDiscount,
    });

    return jsonResponse({
      message: 'Order placed. OTP sent to your email.',
      order_ref: orderRef,
      total_amount: totalAmount / 100,
      eco_points_used: ecoPointsUsed,
      eco_discount: ecoDiscount / 100,
    }, 201);
  }

  // ── POST /api/orders/:ref/verify — Verify OTP
  if (method === 'POST' && orderId && action === 'verify') {
    const body = await request.json();
    const { otp } = body;

    const order = await env.DB.prepare('SELECT * FROM orders WHERE order_ref = ?')
      .bind(orderId).first();
    if (!order) return jsonResponse({ error: 'Order not found' }, 404);
    if (order.status !== 'pending') {
      return jsonResponse({ error: `Order is already ${order.status}` }, 400);
    }

    const cust = await env.DB.prepare('SELECT * FROM customers WHERE id = ?')
      .bind(order.customer_id).first();

    const otpKey = `otp:${cust.email}`;
    const otpData = await env.STORE_KV.get(otpKey, { type: 'json' });

    if (!otpData) {
      return jsonResponse({ error: 'OTP expired. Please request a new one.' }, 400);
    }
    if (otpData.attempts >= MAX_OTP_ATTEMPTS) {
      return jsonResponse({ error: 'Too many failed attempts. Please request a new OTP.' }, 429);
    }
    if (otpData.otp !== String(otp)) {
      otpData.attempts++;
      await env.STORE_KV.put(otpKey, JSON.stringify(otpData), { expirationTtl: OTP_TTL });
      return jsonResponse({
        error: 'Invalid OTP',
        attempts_remaining: MAX_OTP_ATTEMPTS - otpData.attempts,
      }, 400);
    }

    // OTP correct — mark verified
    await env.DB.prepare(`UPDATE orders SET status='verified', otp_verified=1, updated_at=datetime('now') WHERE order_ref=?`)
      .bind(orderId).run();
    await env.STORE_KV.delete(otpKey);

    return jsonResponse({ message: 'Order verified successfully', order_ref: orderId, status: 'verified' });
  }

  // ── POST /api/orders/:ref/resend-otp
  if (method === 'POST' && orderId && action === 'resend-otp') {
    const order = await env.DB.prepare('SELECT * FROM orders WHERE order_ref = ?')
      .bind(orderId).first();
    if (!order) return jsonResponse({ error: 'Order not found' }, 404);
    if (order.status !== 'pending') {
      return jsonResponse({ error: 'Can only resend OTP for pending orders' }, 400);
    }

    const cust = await env.DB.prepare('SELECT * FROM customers WHERE id = ?')
      .bind(order.customer_id).first();
    const otpKey = `otp:${cust.email}`;
    const resendKey = `resend:${cust.email}`;

    // Check resend cooldown
    const cooldown = await env.STORE_KV.get(resendKey);
    if (cooldown) {
      return jsonResponse({ error: 'Please wait 60 seconds before requesting another OTP' }, 429);
    }

    const otpData = await env.STORE_KV.get(otpKey, { type: 'json' }) || { resends: 0 };
    if (otpData.resends >= MAX_OTP_RESENDS) {
      return jsonResponse({ error: 'Maximum OTP resends reached' }, 429);
    }

    const otp = generateOTP();
    await env.STORE_KV.put(otpKey, JSON.stringify({
      otp, attempts: 0, resends: (otpData.resends || 0) + 1, orderRef: orderId,
    }), { expirationTtl: OTP_TTL });
    await env.STORE_KV.put(resendKey, '1', { expirationTtl: RESEND_COOLDOWN });

    await sendOTPEmail(env, {
      to: cust.email, name: cust.name, otp, orderRef: orderId,
      delivery_type: order.delivery_type,
      delivery_notes: order.delivery_notes,
      totalAmount: order.total_amount,
    });

    return jsonResponse({ message: 'New OTP sent to your email' });
  }

  // ── GET /api/orders/:ref — Get order details
  if (method === 'GET' && orderId && !action) {
    const order = await env.DB.prepare('SELECT * FROM orders WHERE order_ref = ?')
      .bind(orderId).first();
    if (!order) return jsonResponse({ error: 'Order not found' }, 404);

    const items = await env.DB.prepare(
      'SELECT * FROM order_items WHERE order_id = ?'
    ).bind(order.id).all();

    const cust = await env.DB.prepare('SELECT id, name, email, phone FROM customers WHERE id = ?')
      .bind(order.customer_id).first();

    return jsonResponse({ order: formatOrder(order), items: items.results, customer: cust });
  }

  // ── GET /api/orders — List orders (admin)
  if (method === 'GET' && !orderId) {
    const status = url.searchParams.get('status');
    const page = parseInt(url.searchParams.get('page') || '1');
    const limit = Math.min(parseInt(url.searchParams.get('limit') || '20'), 100);
    const offset = (page - 1) * limit;

    let query = 'SELECT o.*, c.name as customer_name, c.email as customer_email FROM orders o JOIN customers c ON o.customer_id = c.id WHERE 1=1';
    const params = [];

    if (status) { query += ' AND o.status = ?'; params.push(status); }
    query += ' ORDER BY o.created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    const rows = await env.DB.prepare(query).bind(...params).all();
    return jsonResponse({ orders: rows.results.map(formatOrder) });
  }

  return jsonResponse({ error: 'Route not found' }, 404);
}

function formatOrder(o) {
  return {
    ...o,
    subtotal: o.subtotal / 100,
    eco_discount: o.eco_discount / 100,
    total_amount: o.total_amount / 100,
    delivery_address: (() => { try { return JSON.parse(o.delivery_address); } catch { return {}; } })(),
  };
}
