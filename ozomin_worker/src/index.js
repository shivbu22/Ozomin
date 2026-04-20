// =====================================================
// OZOMIN — Cloudflare Worker Entry Point
// =====================================================

import { handleCORS, corsHeaders } from './middleware/cors.js';
import { rateLimit } from './middleware/rateLimit.js';
import { adminAuth } from './middleware/adminAuth.js';

import { handleProducts } from './routes/products.js';
import { handleOrders } from './routes/orders.js';
import { handleCustomers } from './routes/customers.js';
import { handleEcoPoints } from './routes/ecoPoints.js';
import { handleAdmin } from './routes/admin.js';
import { handleWebhooks } from './routes/webhooks.js';
import { handlePurchaseOrders } from './routes/purchaseOrders.js';

export default {
  async fetch(request, env, ctx) {
    // CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    const url = new URL(request.url);
    const pathname = url.pathname;

    try {
      // Webhooks — skip rate limit, raw body needed
      if (pathname.startsWith('/webhooks/')) {
        return await handleWebhooks(request, env, ctx);
      }

      // Rate limiting (skip for admin routes)
      if (!pathname.startsWith('/admin/')) {
        const limited = await rateLimit(request, env);
        if (limited) {
          return jsonResponse({ error: 'Too many requests. Please try again later.' }, 429);
        }
      }

      // Route dispatch
      if (pathname.startsWith('/api/products')) {
        return await handleProducts(request, env, url);
      }
      if (pathname.startsWith('/api/orders')) {
        return await handleOrders(request, env, url);
      }
      if (pathname.startsWith('/api/customers')) {
        return await handleCustomers(request, env, url);
      }
      if (pathname.startsWith('/api/eco-points')) {
        return await handleEcoPoints(request, env, url);
      }
      if (pathname.startsWith('/admin/')) {
        return await handleAdmin(request, env, url);
      }
      if (pathname.startsWith('/api/purchase-orders')) {
        return await handlePurchaseOrders(request, env, url);
      }

      // Health check
      if (pathname === '/' || pathname === '/health') {
        return jsonResponse({
          service: 'Ozomin Worker API',
          status: 'ok',
          version: '1.0.0',
          timestamp: new Date().toISOString(),
        });
      }

      return jsonResponse({ error: 'Route not found' }, 404);
    } catch (err) {
      console.error('Unhandled error:', err);
      return jsonResponse({ error: 'Internal server error', detail: err.message }, 500);
    }
  },
};

export function jsonResponse(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json', ...corsHeaders },
  });
}
