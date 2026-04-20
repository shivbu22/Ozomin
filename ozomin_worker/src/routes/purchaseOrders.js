// =====================================================
// Purchase Orders Route Handler (Supplier POs)
// =====================================================

import { jsonResponse } from '../index.js';
import { requireAdmin } from '../middleware/adminAuth.js';

function generatePORef() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let ref = 'PO-';
  for (let i = 0; i < 5; i++) ref += chars[Math.floor(Math.random() * chars.length)];
  return ref;
}

export async function handlePurchaseOrders(request, env, url) {
  const authError = await requireAdmin(request, env);
  if (authError) return authError;

  const method = request.method;
  const segments = url.pathname.replace('/api/purchase-orders', '').split('/').filter(Boolean);
  const poId = segments[0];

  // GET — list all
  if (method === 'GET' && !poId) {
    const status = url.searchParams.get('status');
    let query = 'SELECT * FROM purchase_orders WHERE 1=1';
    const params = [];
    if (status) { query += ' AND status = ?'; params.push(status); }
    query += ' ORDER BY created_at DESC LIMIT 50';

    const rows = await env.DB.prepare(query).bind(...params).all();
    return jsonResponse({ purchase_orders: rows.results });
  }

  // GET /:id
  if (method === 'GET' && poId) {
    const po = await env.DB.prepare('SELECT * FROM purchase_orders WHERE id = ?').bind(poId).first();
    if (!po) return jsonResponse({ error: 'PO not found' }, 404);
    return jsonResponse({ purchase_order: { ...po, items: JSON.parse(po.items) } });
  }

  // POST — create PO
  if (method === 'POST' && !poId) {
    const body = await request.json();
    const { supplier_name, supplier_email, items, notes, expected_delivery } = body;

    if (!supplier_name || !items?.length) {
      return jsonResponse({ error: 'supplier_name and items are required' }, 400);
    }

    // Calculate total cost from items
    let totalCost = 0;
    for (const item of items) {
      totalCost += (item.unit_cost || 0) * item.qty;
    }

    let poRef;
    let result;
    for (let i = 0; i < 5; i++) {
      poRef = generatePORef();
      try {
        result = await env.DB.prepare(`
          INSERT INTO purchase_orders (po_ref, supplier_name, supplier_email, items, total_cost, notes, expected_delivery)
          VALUES (?, ?, ?, ?, ?, ?, ?)
        `).bind(poRef, supplier_name, supplier_email || '',
                JSON.stringify(items), Math.round(totalCost * 100),
                notes || '', expected_delivery || null).run();
        break;
      } catch (e) {
        if (!e.message.includes('UNIQUE')) throw e;
      }
    }

    return jsonResponse({ message: 'Purchase order created', po_ref: poRef }, 201);
  }

  // PATCH /:id/status — update status
  if (method === 'PATCH' && poId) {
    const body = await request.json();
    const { status } = body;
    const validStatuses = ['draft', 'sent', 'received'];

    if (!validStatuses.includes(status)) {
      return jsonResponse({ error: `Invalid status. Use: ${validStatuses.join(', ')}` }, 400);
    }

    let extra = '';
    if (status === 'sent') extra = `, sent_at=datetime('now')`;
    if (status === 'received') {
      extra = `, received_at=datetime('now')`;
      // Update stock for received items
      const po = await env.DB.prepare('SELECT * FROM purchase_orders WHERE id = ?').bind(poId).first();
      if (po) {
        const items = JSON.parse(po.items);
        for (const item of items) {
          if (item.product_id) {
            await env.DB.prepare('UPDATE products SET stock_qty = stock_qty + ? WHERE id = ?')
              .bind(item.qty, item.product_id).run();
          }
        }
      }
    }

    await env.DB.prepare(`UPDATE purchase_orders SET status=?${extra}, updated_at=datetime('now') WHERE id=?`)
      .bind(status, poId).run();

    return jsonResponse({ message: `PO status updated to ${status}` });
  }

  return jsonResponse({ error: 'Route not found' }, 404);
}
