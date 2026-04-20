// =====================================================
// Rate Limiting Middleware — KV-based per IP per route
// =====================================================

const RATE_LIMITS = {
  '/api/orders':          { max: 10,  window: 60  },   // 10 orders/min
  '/api/orders/verify':   { max: 5,   window: 60  },   // 5 OTP attempts/min
  '/api/orders/resend':   { max: 3,   window: 300 },   // 3 resends/5min
  '/api/customers':       { max: 20,  window: 60  },
  '/api/products':        { max: 60,  window: 60  },
  'default':              { max: 30,  window: 60  },
};

function getClientIP(request) {
  return (
    request.headers.get('CF-Connecting-IP') ||
    request.headers.get('X-Forwarded-For')?.split(',')[0].trim() ||
    '0.0.0.0'
  );
}

function getRouteKey(pathname) {
  for (const route of Object.keys(RATE_LIMITS)) {
    if (route !== 'default' && pathname.includes(route)) return route;
  }
  return 'default';
}

export async function rateLimit(request, env) {
  const ip = getClientIP(request);
  const url = new URL(request.url);
  const routeKey = getRouteKey(url.pathname);
  const { max, window: windowSecs } = RATE_LIMITS[routeKey];

  const kvKey = `rl:${routeKey}:${ip}`;
  const now = Math.floor(Date.now() / 1000);

  let data = await env.STORE_KV.get(kvKey, { type: 'json' });

  if (!data || data.resetAt <= now) {
    data = { count: 1, resetAt: now + windowSecs };
    await env.STORE_KV.put(kvKey, JSON.stringify(data), { expirationTtl: windowSecs });
    return false;
  }

  if (data.count >= max) {
    return true; // RATE LIMITED
  }

  data.count++;
  const ttl = data.resetAt - now;
  await env.STORE_KV.put(kvKey, JSON.stringify(data), { expirationTtl: ttl > 0 ? ttl : 1 });
  return false;
}
