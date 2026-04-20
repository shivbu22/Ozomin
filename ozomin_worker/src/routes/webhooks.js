// =====================================================
// Razorpay Webhook Handler
// =====================================================

import { jsonResponse } from '../index.js';
import { sendOrderConfirmationEmail } from '../lib/email.js';

const POINTS_PER_100_PAISE = 1; // 1 point per ₹1 (100 paise) spent

export async function handleWebhooks(request, env, ctx) {
  const url = new URL(request.url);
  const path = url.pathname.replace('/webhooks', '');

  if (path === '/razorpay') {
    return handleRazorpayWebhook(request, env);
  }

  return jsonResponse({ error: 'Webhook not found' }, 404);
}

async function handleRazorpayWebhook(request, env) {
  const body = await request.text();
  const signature = request.headers.get('X-Razorpay-Signature');

  // Verify HMAC SHA256 signature
  const isValid = await verifyRazorpaySignature(body, signature, env.WEBHOOK_SECRET);
  if (!isValid) {
    return jsonResponse({ error: 'Invalid webhook signature' }, 401);
  }

  const event = JSON.parse(body);
  const { event: eventType, payload } = event;

  if (eventType === 'payment_link.paid') {
    const paymentLinkId = payload.payment_link?.entity?.id;
    const paymentId = payload.payment?.entity?.id;
    const amount = payload.payment?.entity?.amount; // in paise

    if (!paymentLinkId) {
      return jsonResponse({ error: 'Missing payment link ID' }, 400);
    }

    // Find the order by razorpay_payment_link_id
    const order = await env.DB.prepare(
      'SELECT * FROM orders WHERE razorpay_payment_link_id = ?'
    ).bind(paymentLinkId).first();

    if (!order) {
      console.error('Order not found for payment link:', paymentLinkId);
      return jsonResponse({ message: 'Order not found, but webhook acknowledged' });
    }

    if (order.status === 'paid') {
      return jsonResponse({ message: 'Order already processed' });
    }

    // Calculate Eco Points earned: 1 point per ₹10 = 1 point per 1000 paise
    const paidAmount = amount || order.total_amount;
    const ecoPointsEarned = Math.floor(paidAmount / 1000);

    // Update order to paid
    await env.DB.prepare(`
      UPDATE orders SET
        status = 'paid',
        payment_status = 'paid',
        razorpay_payment_id = ?,
        eco_points_earned = ?,
        updated_at = datetime('now')
      WHERE id = ?
    `).bind(paymentId, ecoPointsEarned, order.id).run();

    const cust = await env.DB.prepare('SELECT * FROM customers WHERE id = ?')
      .bind(order.customer_id).first();

    // Deduct redeemed points first (if not already done via order placement)
    if (order.eco_points_used > 0) {
      const newBal = Math.max(0, cust.eco_points_balance - order.eco_points_used);
      await env.DB.prepare('UPDATE customers SET eco_points_balance = ? WHERE id = ?')
        .bind(newBal, cust.id).run();
      await env.DB.prepare(
        'INSERT INTO eco_points_ledger (customer_id, order_id, points_delta, balance_after, reason) VALUES (?, ?, ?, ?, ?)'
      ).bind(cust.id, order.id, -order.eco_points_used, newBal, 'order_redeemed').run();
    }

    // Credit earned points
    if (ecoPointsEarned > 0) {
      const freshCust = await env.DB.prepare('SELECT eco_points_balance FROM customers WHERE id = ?')
        .bind(cust.id).first();
      const earnedBalance = (freshCust.eco_points_balance || 0) + ecoPointsEarned;
      await env.DB.prepare('UPDATE customers SET eco_points_balance = ? WHERE id = ?')
        .bind(earnedBalance, cust.id).run();
      await env.DB.prepare(
        'INSERT INTO eco_points_ledger (customer_id, order_id, points_delta, balance_after, reason) VALUES (?, ?, ?, ?, ?)'
      ).bind(cust.id, order.id, ecoPointsEarned, earnedBalance, 'order_earned').run();
    }

    // Fetch items for email
    const items = await env.DB.prepare('SELECT * FROM order_items WHERE order_id = ?')
      .bind(order.id).all();

    // Send confirmation email
    await sendOrderConfirmationEmail(env, {
      to: cust.email,
      name: cust.name,
      orderRef: order.order_ref,
      totalAmount: paidAmount,
      ecoPointsEarned,
      newPointsBalance: (cust.eco_points_balance - order.eco_points_used + ecoPointsEarned),
      delivery_type: order.delivery_type,
      delivery_notes: order.delivery_notes,
      delivery_address: order.delivery_address,
      items: items.results,
    });

    return jsonResponse({ message: 'Payment processed successfully' });
  }

  // Acknowledge other events
  return jsonResponse({ message: `Event ${eventType} received` });
}

async function verifyRazorpaySignature(body, signature, secret) {
  try {
    const encoder = new TextEncoder();
    const key = await crypto.subtle.importKey(
      'raw', encoder.encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']
    );
    const sigBytes = await crypto.subtle.sign('HMAC', key, encoder.encode(body));
    const expected = Array.from(new Uint8Array(sigBytes))
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');
    return expected === signature;
  } catch {
    return false;
  }
}
