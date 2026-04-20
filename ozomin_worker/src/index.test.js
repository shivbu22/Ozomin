import { describe, it, expect } from 'vitest';
import worker from './index.js';

describe('Ozomin Worker API', () => {
  it('should return 200 for health check', async () => {
    const request = new Request('http://localhost/health');
    const response = await worker.fetch(request, {}, {});
    
    expect(response.status).toBe(200);
    
    const data = await response.json();
    expect(data.status).toBe('ok');
    expect(data.service).toBe('Ozomin Worker API');
  });

  it('should handle CORS OPTIONS requests', async () => {
    const request = new Request('http://localhost/api/products', {
      method: 'OPTIONS',
    });
    const response = await worker.fetch(request, {}, {});
    
    expect(response.status).toBe(200);
    expect(response.headers.get('Access-Control-Allow-Origin')).toBe('*');
  });

  it('should return 404 for unknown routes', async () => {
    const request = new Request('http://localhost/unknown-route');
    const response = await worker.fetch(request, {}, {});
    
    expect(response.status).toBe(404);
  });
});
