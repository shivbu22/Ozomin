// =====================================================
// Admin Authentication Middleware
// =====================================================

import { jsonResponse } from '../index.js';

export async function adminAuth(request, env) {
  const adminEmail = request.headers.get('X-Admin-Email');
  const adminKey = request.headers.get('X-Admin-Key');

  if (!adminEmail || !adminKey) {
    return jsonResponse({ error: 'Admin credentials required' }, 401);
  }

  if (adminEmail !== env.ADMIN_EMAIL || adminKey !== env.ADMIN_API_KEY) {
    return jsonResponse({ error: 'Invalid admin credentials' }, 401);
  }

  // Check for active session in KV
  const sessionKey = `admin:session:${adminEmail}`;
  const session = await env.STORE_KV.get(sessionKey, { type: 'json' });

  if (!session || session.verified !== true) {
    return jsonResponse({ error: 'Admin session not verified. Please complete OTP verification.' }, 403);
  }

  return null; // Authorized
}

export async function requireAdmin(request, env) {
  const result = await adminAuth(request, env);
  return result; // null = ok, Response = error
}
