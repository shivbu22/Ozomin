// =====================================================
// Customers Route Handler
// =====================================================

import { jsonResponse } from '../index.js';
import { requireAdmin } from '../middleware/adminAuth.js';

export async function handleCustomers(request, env, url) {
  const method = request.method;
  const segments = url.pathname.replace('/api/customers', '').split('/').filter(Boolean);
  const customerId = segments[0];

  // GET /api/customers/:id — Customer profile + points balance
  if (method === 'GET' && customerId) {
    const cust = await env.DB.prepare('SELECT * FROM customers WHERE id = ?')
      .bind(customerId).first();
    if (!cust) return jsonResponse({ error: 'Customer not found' }, 404);
    return jsonResponse({ customer: formatCustomer(cust) });
  }

  // GET /api/customers — List (admin only)
  if (method === 'GET') {
    const authError = await requireAdmin(request, env);
    if (authError) return authError;

    const search = url.searchParams.get('q');
    const page = parseInt(url.searchParams.get('page') || '1');
    const limit = Math.min(parseInt(url.searchParams.get('limit') || '20'), 100);
    const offset = (page - 1) * limit;

    let query = 'SELECT * FROM customers WHERE 1=1';
    const params = [];
    if (search) {
      query += ' AND (name LIKE ? OR email LIKE ? OR phone LIKE ?)';
      params.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }
    query += ' ORDER BY created_at DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    const rows = await env.DB.prepare(query).bind(...params).all();
    return jsonResponse({ customers: rows.results.map(formatCustomer) });
  }

  // PUT /api/customers/:id — Update customer info
  if (method === 'PUT' && customerId) {
    const body = await request.json();
    const cust = await env.DB.prepare('SELECT * FROM customers WHERE id = ?').bind(customerId).first();
    if (!cust) return jsonResponse({ error: 'Customer not found' }, 404);

    await env.DB.prepare(`
      UPDATE customers SET name=?, phone=?, address=?, updated_at=datetime('now') WHERE id=?
    `).bind(
      body.name || cust.name,
      body.phone || cust.phone,
      body.address ? JSON.stringify(body.address) : cust.address,
      customerId
    ).run();

    const updated = await env.DB.prepare('SELECT * FROM customers WHERE id = ?').bind(customerId).first();
    return jsonResponse({ customer: formatCustomer(updated) });
  }

  return jsonResponse({ error: 'Route not found' }, 404);
}

function formatCustomer(c) {
  return {
    ...c,
    address: (() => { try { return JSON.parse(c.address); } catch { return {}; } })(),
  };
}
