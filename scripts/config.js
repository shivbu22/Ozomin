// =====================================================
// Ozomin — API Configuration
// Replace WORKER_URL with your deployed Cloudflare Worker URL
// after running: wrangler deploy
// =====================================================

const OZOMIN_CONFIG = {
  // ── Set this to your deployed Cloudflare Worker URL ──
  // Example: 'https://ozomin-worker.your-account.workers.dev'
  // Leave as empty string to use Vercel API proxy (vercel.json routes)
  WORKER_URL: 'https://ozomin-worker.ozominsupport.workers.dev',

  // Computed: resolves to either the direct Worker URL or same-origin proxy
  get API_BASE() {
    return this.WORKER_URL
      ? `${this.WORKER_URL}`
      : '';   // uses vercel.json proxy → /api/... forwarded to Worker
  },
};

// Attach to window for global access
window.OZOMIN_CONFIG = OZOMIN_CONFIG;
