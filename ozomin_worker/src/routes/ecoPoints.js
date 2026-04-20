// =====================================================
// Eco Points Route Handler
// =====================================================

import { jsonResponse } from '../index.js';
import { requireAdmin } from '../middleware/adminAuth.js';

export async function handleEcoPoints(request, env, url) {
  const method = request.method;
  const segments = url.pathname.replace('/api/eco-points', '').split('/').filter(Boolean);
  const customerId = segments[0];
  const action = segments[1];

  // GET /api/eco-points/:customerId — Balance + ledger
  if (method === 'GET' && customerId && !action) {
    const cust = await env.DB.prepare(
      'SELECT id, name, email, eco_points_balance FROM customers WHERE id = ?'
    ).bind(customerId).first();
    if (!cust) return jsonResponse({ error: 'Customer not found' }, 404);

    const page = parseInt(url.searchParams.get('page') || '1');
    const limit = Math.min(parseInt(url.searchParams.get('limit') || '20'), 50);
    const offset = (page - 1) * limit;

    const ledger = await env.DB.prepare(`
      SELECT l.*, o.order_ref FROM eco_points_ledger l
      LEFT JOIN orders o ON l.order_id = o.id
      WHERE l.customer_id = ?
      ORDER BY l.created_at DESC LIMIT ? OFFSET ?
    `).bind(customerId, limit, offset).all();

    return jsonResponse({
      customer_id: cust.id,
      name: cust.name,
      eco_points_balance: cust.eco_points_balance,
      ledger: ledger.results,
    });
  }

  // GET /api/eco-points/:customerId/check?amount=500 — Check max redeemable
  if (method === 'GET' && customerId && action === 'check') {
    const orderAmount = parseInt(url.searchParams.get('amount') || '0') * 100; // rupees → paise
    const cust = await env.DB.prepare(
      'SELECT eco_points_balance FROM customers WHERE id = ?'
    ).bind(customerId).first();
    if (!cust) return jsonResponse({ error: 'Customer not found' }, 404);

    const maxByBalance = cust.eco_points_balance;
    const maxByPercent = Math.floor(orderAmount * 0.20 / 100); // 20% of order, in points
    const maxRedeemable = Math.min(maxByBalance, maxByPercent);

    return jsonResponse({
      balance: cust.eco_points_balance,
      max_redeemable: maxRedeemable,
      max_discount_rupees: maxRedeemable,
    });
  }

  // POST /api/eco-points/:customerId/adjust — Admin manual adjustment
  if (method === 'POST' && customerId && action === 'adjust') {
    const authError = await requireAdmin(request, env);
    if (authError) return authError;

    const body = await request.json();
    const { points, reason } = body;

    if (!points || !reason) {
      return jsonResponse({ error: 'points and reason are required' }, 400);
    }

    const cust = await env.DB.prepare('SELECT * FROM customers WHERE id = ?').bind(customerId).first();
    if (!cust) return jsonResponse({ error: 'Customer not found' }, 404);

    const newBalance = Math.max(0, cust.eco_points_balance + points);
    await env.DB.prepare('UPDATE customers SET eco_points_balance = ? WHERE id = ?')
      .bind(newBalance, customerId).run();
    await env.DB.prepare(
      'INSERT INTO eco_points_ledger (customer_id, points_delta, balance_after, reason) VALUES (?, ?, ?, ?)'
    ).bind(customerId, points, newBalance, `admin_adjustment: ${reason}`).run();

    return jsonResponse({ message: 'Points adjusted', new_balance: newBalance });
  }

  return jsonResponse({ error: 'Route not found' }, 404);
}
