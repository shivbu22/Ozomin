// =====================================================
// Products Route Handler
// =====================================================

import { jsonResponse } from '../index.js';
import { requireAdmin } from '../middleware/adminAuth.js';

export async function handleProducts(request, env, url) {
  const method = request.method;
  const segments = url.pathname.replace('/api/products', '').split('/').filter(Boolean);
  const productId = segments[0];

  // GET /api/products — list all (with optional filters)
  if (method === 'GET' && !productId) {
    const category = url.searchParams.get('category');
    const activeOnly = url.searchParams.get('active') !== '0';
    const search = url.searchParams.get('q');
    const page = parseInt(url.searchParams.get('page') || '1');
    const limit = Math.min(parseInt(url.searchParams.get('limit') || '20'), 100);
    const offset = (page - 1) * limit;

    let query = 'SELECT * FROM products WHERE 1=1';
    const params = [];

    if (activeOnly) { query += ' AND active = 1'; }
    if (category) { query += ' AND category = ?'; params.push(category); }
    if (search) { query += ' AND (name LIKE ? OR sku LIKE ?)'; params.push(`%${search}%`, `%${search}%`); }

    query += ` ORDER BY created_at DESC LIMIT ? OFFSET ?`;
    params.push(limit, offset);

    const [rows, countRow] = await Promise.all([
      env.DB.prepare(query).bind(...params).all(),
      env.DB.prepare('SELECT COUNT(*) as total FROM products WHERE active = 1').first(),
    ]);

    return jsonResponse({
      products: rows.results.map(formatProduct),
      pagination: { page, limit, total: countRow.total },
    });
  }

  // GET /api/products/:id
  if (method === 'GET' && productId) {
    const product = await env.DB.prepare('SELECT * FROM products WHERE id = ?').bind(productId).first();
    if (!product) return jsonResponse({ error: 'Product not found' }, 404);
    return jsonResponse({ product: formatProduct(product) });
  }

  // POST /api/products — admin only
  if (method === 'POST') {
    const authError = await requireAdmin(request, env);
    if (authError) return authError;

    const body = await request.json();
    const { name, sku, category, description, price, cost_price, stock_qty, min_qty,
            max_daily_qty, supplier_name, supplier_contact, supplier_email,
            is_service, active, image_url } = body;

    if (!name || !sku || !category || !price || !cost_price) {
      return jsonResponse({ error: 'Missing required fields: name, sku, category, price, cost_price' }, 400);
    }

    // price in rupees from client, store as paise
    const result = await env.DB.prepare(`
      INSERT INTO products (name, sku, category, description, price, cost_price, stock_qty, min_qty,
        max_daily_qty, supplier_name, supplier_contact, supplier_email, is_service, active, image_url)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `).bind(
      name, sku, category, description || '',
      Math.round(price * 100), Math.round(cost_price * 100),
      stock_qty || 0, min_qty || 1, max_daily_qty || 10,
      supplier_name || '', supplier_contact || '', supplier_email || '',
      is_service ? 1 : 0, active !== false ? 1 : 0, image_url || ''
    ).run();

    const product = await env.DB.prepare('SELECT * FROM products WHERE id = ?')
      .bind(result.meta.last_row_id).first();
    return jsonResponse({ product: formatProduct(product), message: 'Product created' }, 201);
  }

  // PUT /api/products/:id — admin only
  if (method === 'PUT' && productId) {
    const authError = await requireAdmin(request, env);
    if (authError) return authError;

    const body = await request.json();
    const existing = await env.DB.prepare('SELECT * FROM products WHERE id = ?').bind(productId).first();
    if (!existing) return jsonResponse({ error: 'Product not found' }, 404);

    const updated = {
      name: body.name ?? existing.name,
      category: body.category ?? existing.category,
      description: body.description ?? existing.description,
      price: body.price !== undefined ? Math.round(body.price * 100) : existing.price,
      cost_price: body.cost_price !== undefined ? Math.round(body.cost_price * 100) : existing.cost_price,
      stock_qty: body.stock_qty ?? existing.stock_qty,
      min_qty: body.min_qty ?? existing.min_qty,
      max_daily_qty: body.max_daily_qty ?? existing.max_daily_qty,
      supplier_name: body.supplier_name ?? existing.supplier_name,
      supplier_contact: body.supplier_contact ?? existing.supplier_contact,
      supplier_email: body.supplier_email ?? existing.supplier_email,
      is_service: body.is_service !== undefined ? (body.is_service ? 1 : 0) : existing.is_service,
      active: body.active !== undefined ? (body.active ? 1 : 0) : existing.active,
      image_url: body.image_url ?? existing.image_url,
    };

    await env.DB.prepare(`
      UPDATE products SET name=?, category=?, description=?, price=?, cost_price=?,
        stock_qty=?, min_qty=?, max_daily_qty=?, supplier_name=?, supplier_contact=?,
        supplier_email=?, is_service=?, active=?, image_url=?, updated_at=datetime('now')
      WHERE id=?
    `).bind(
      updated.name, updated.category, updated.description, updated.price, updated.cost_price,
      updated.stock_qty, updated.min_qty, updated.max_daily_qty, updated.supplier_name,
      updated.supplier_contact, updated.supplier_email, updated.is_service, updated.active,
      updated.image_url, productId
    ).run();

    const product = await env.DB.prepare('SELECT * FROM products WHERE id = ?').bind(productId).first();
    return jsonResponse({ product: formatProduct(product), message: 'Product updated' });
  }

  // DELETE /api/products/:id — soft delete (admin only)
  if (method === 'DELETE' && productId) {
    const authError = await requireAdmin(request, env);
    if (authError) return authError;

    await env.DB.prepare(`UPDATE products SET active=0, updated_at=datetime('now') WHERE id=?`)
      .bind(productId).run();
    return jsonResponse({ message: 'Product deactivated' });
  }

  return jsonResponse({ error: 'Method not allowed' }, 405);
}

function formatProduct(p) {
  return {
    ...p,
    price: p.price / 100,       // paise → rupees
    cost_price: p.cost_price / 100,
    is_service: p.is_service === 1,
    active: p.active === 1,
  };
}
