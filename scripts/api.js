// =====================================================
// Ozomin API Client — connects frontend to CF Worker
// =====================================================

const API = {
  get base() {
    return (window.OZOMIN_CONFIG && window.OZOMIN_CONFIG.API_BASE) || '';
  },

  async request(method, path, body = null) {
    const url = `${this.base}${path}`;
    const opts = {
      method,
      headers: { 'Content-Type': 'application/json' },
    };
    if (body) opts.body = JSON.stringify(body);
    try {
      const res = await fetch(url, opts);
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
      return data;
    } catch (err) {
      console.error(`[Ozomin API] ${method} ${path} failed:`, err.message);
      throw err;
    }
  },

  // ── Products
  getProducts(params = {}) {
    const qs = new URLSearchParams(params).toString();
    return this.request('GET', `/api/products${qs ? '?' + qs : ''}`);
  },
  getProduct(id) {
    return this.request('GET', `/api/products/${id}`);
  },

  // ── Orders
  placeOrder(payload) {
    return this.request('POST', '/api/orders', payload);
  },
  verifyOTP(orderRef, otp) {
    return this.request('POST', `/api/orders/${orderRef}/verify`, { otp });
  },
  resendOTP(orderRef) {
    return this.request('POST', `/api/orders/${orderRef}/resend-otp`);
  },
  getOrder(orderRef) {
    return this.request('GET', `/api/orders/${orderRef}`);
  },

  // ── Eco Points
  getEcoPoints(customerId) {
    return this.request('GET', `/api/eco-points/${customerId}`);
  },
  checkRedeemable(customerId, orderAmountRupees) {
    return this.request('GET', `/api/eco-points/${customerId}/check?amount=${orderAmountRupees}`);
  },

  // ── Admin
  adminRequestOTP(email, apiKey) {
    return this.request('POST', '/admin/auth/request-otp', { email, api_key: apiKey });
  },
  adminVerifyOTP(email, otp) {
    return this.request('POST', '/admin/auth/verify-otp', { email, otp });
  },
};

// Global UI helpers
window.OzominAPI = API;

// ── Book Now button handler (wires booking form → real API)
document.addEventListener('DOMContentLoaded', () => {
  const bookBtn = document.getElementById('book-now-btn');
  if (!bookBtn) return;

  bookBtn.addEventListener('click', async () => {
    const name     = document.getElementById('booking-name')?.value || 'Guest';
    const email    = document.getElementById('booking-email')?.value;
    const phone    = document.getElementById('booking-phone')?.value;
    const address  = document.getElementById('booking-address')?.value || '';
    const desc     = document.getElementById('booking-desc')?.value || '';
    const timeSlot = document.getElementById('booking-time')?.value || 'now';

    // Get selected service from active picker
    const activePick = document.querySelector('.service-pick.active');
    const serviceType = activePick?.dataset.service || 'cleaning';

    // Map service to product_id (SVC-001 = cleaning, etc.)
    const serviceProductMap = {
      cleaning:     'SVC-001',
      'ac-service': 'SVC-002',
      plumbing:     'SVC-003',
    };

    if (!email || !phone) {
      showToast('⚠️', 'Please enter your email and phone number');
      // Show inline input modal if fields not visible
      promptContactInfo(async (contactEmail, contactPhone, contactName) => {
        await submitOrder({
          name: contactName, email: contactEmail, phone: contactPhone,
          address, desc, timeSlot, serviceType,
        });
      });
      return;
    }

    await submitOrder({ name, email, phone, address, desc, timeSlot, serviceType });
  });
});

async function submitOrder({ name, email, phone, address, desc, timeSlot, serviceType }) {
  const bookBtn = document.getElementById('book-now-btn');
  if (bookBtn) {
    bookBtn.disabled = true;
    bookBtn.textContent = '⏳ Placing Order...';
  }

  try {
    const result = await window.OzominAPI.placeOrder({
      customer: { name, email, phone },
      items: [{ product_id: 1, quantity: 1 }],  // default to first service
      delivery_type: 'delivery',
      delivery_address: { line1: address, city: 'Bengaluru' },
      delivery_notes: desc,
      scheduled_time_slot: timeSlot,
    });

    // Store order ref for OTP verification
    sessionStorage.setItem('ozomin_order_ref', result.order_ref);
    sessionStorage.setItem('ozomin_order_email', email);

    showToast('✅', `Booking placed! OTP sent to ${email}`);
    showOTPModal(result.order_ref, email);

  } catch (err) {
    showToast('❌', err.message || 'Booking failed. Please try again.');
  } finally {
    if (bookBtn) {
      bookBtn.disabled = false;
      bookBtn.innerHTML = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12l5 5L20 7"/></svg> Confirm Booking`;
    }
  }
}

function showOTPModal(orderRef, email) {
  // Create OTP modal dynamically
  const existing = document.getElementById('otp-modal');
  if (existing) existing.remove();

  const modal = document.createElement('div');
  modal.id = 'otp-modal';
  modal.style.cssText = `
    position:fixed;inset:0;background:rgba(0,0,0,0.7);backdrop-filter:blur(8px);
    display:flex;align-items:center;justify-content:center;z-index:99999;padding:20px;
  `;
  modal.innerHTML = `
    <div style="background:#0a1628;border:1px solid rgba(29,185,84,0.3);border-radius:16px;
      padding:32px;max-width:400px;width:100%;text-align:center;box-shadow:0 20px 60px rgba(0,0,0,0.5);">
      <div style="font-size:2.5rem;margin-bottom:12px;">📧</div>
      <h3 style="color:#fff;font-family:'Outfit',sans-serif;margin:0 0 8px;">Verify Your Order</h3>
      <p style="color:#aaa;font-size:0.9rem;margin:0 0 24px;">Enter the 6-digit OTP sent to<br/><strong style="color:#1DB954;">${email}</strong></p>
      <div style="display:flex;gap:8px;justify-content:center;margin-bottom:20px;">
        ${[1,2,3,4,5,6].map(i =>
          `<input id="otp-d${i}" type="text" maxlength="1" inputmode="numeric"
            style="width:44px;height:52px;background:#1a2540;border:2px solid rgba(29,185,84,0.3);
            border-radius:8px;color:#fff;font-size:1.4rem;font-weight:700;text-align:center;outline:none;
            font-family:'Outfit',sans-serif;" />`
        ).join('')}
      </div>
      <button id="otp-verify-btn" style="width:100%;background:#1DB954;color:#000;border:none;padding:14px;
        border-radius:8px;font-weight:700;font-size:1rem;cursor:pointer;font-family:'Outfit',sans-serif;">
        Verify OTP
      </button>
      <button id="otp-resend-btn" style="background:none;border:none;color:#1DB954;cursor:pointer;
        margin-top:12px;font-size:0.85rem;display:block;width:100%;">Resend OTP (wait 60s)</button>
      <button id="otp-close-btn" style="background:none;border:none;color:#666;cursor:pointer;
        margin-top:8px;font-size:0.8rem;display:block;width:100%;">Cancel</button>
    </div>
  `;
  document.body.appendChild(modal);

  // Auto-advance OTP inputs
  [1,2,3,4,5,6].forEach(i => {
    const inp = document.getElementById(`otp-d${i}`);
    inp.addEventListener('input', () => {
      if (inp.value && i < 6) document.getElementById(`otp-d${i+1}`).focus();
    });
    inp.addEventListener('keydown', e => {
      if (e.key === 'Backspace' && !inp.value && i > 1) document.getElementById(`otp-d${i-1}`).focus();
    });
    inp.addEventListener('focus', () => inp.style.borderColor = '#1DB954');
    inp.addEventListener('blur', () => inp.style.borderColor = 'rgba(29,185,84,0.3)');
  });

  document.getElementById('otp-verify-btn').addEventListener('click', async () => {
    const otp = [1,2,3,4,5,6].map(i => document.getElementById(`otp-d${i}`).value).join('');
    if (otp.length < 6) { showToast('⚠️', 'Enter all 6 digits'); return; }

    const verifyBtn = document.getElementById('otp-verify-btn');
    verifyBtn.textContent = 'Verifying...';
    verifyBtn.disabled = true;

    try {
      await window.OzominAPI.verifyOTP(orderRef, otp);
      modal.remove();
      showToast('🎉', `Order ${orderRef} confirmed! You'll receive updates via email.`);
    } catch (err) {
      verifyBtn.textContent = 'Verify OTP';
      verifyBtn.disabled = false;
      showToast('❌', err.message || 'Invalid OTP');
    }
  });

  document.getElementById('otp-resend-btn').addEventListener('click', async () => {
    try {
      await window.OzominAPI.resendOTP(orderRef);
      showToast('📧', 'New OTP sent!');
    } catch (err) {
      showToast('❌', err.message);
    }
  });

  document.getElementById('otp-close-btn').addEventListener('click', () => modal.remove());
  document.getElementById('otp-d1').focus();
}

function promptContactInfo(callback) {
  const existing = document.getElementById('contact-modal');
  if (existing) existing.remove();

  const modal = document.createElement('div');
  modal.id = 'contact-modal';
  modal.style.cssText = `
    position:fixed;inset:0;background:rgba(0,0,0,0.7);backdrop-filter:blur(8px);
    display:flex;align-items:center;justify-content:center;z-index:99998;padding:20px;
  `;
  modal.innerHTML = `
    <div style="background:#0a1628;border:1px solid rgba(29,185,84,0.3);border-radius:16px;
      padding:32px;max-width:400px;width:100%;">
      <h3 style="color:#fff;font-family:'Outfit',sans-serif;margin:0 0 20px;">Contact Details</h3>
      <input id="ci-name" type="text" placeholder="Full Name" style="width:100%;background:#1a2540;border:1.5px solid rgba(29,185,84,0.2);border-radius:8px;padding:12px;color:#fff;font-size:0.95rem;margin-bottom:12px;box-sizing:border-box;outline:none;" />
      <input id="ci-email" type="email" placeholder="Email Address" style="width:100%;background:#1a2540;border:1.5px solid rgba(29,185,84,0.2);border-radius:8px;padding:12px;color:#fff;font-size:0.95rem;margin-bottom:12px;box-sizing:border-box;outline:none;" />
      <input id="ci-phone" type="tel" placeholder="Phone Number (10 digits)" style="width:100%;background:#1a2540;border:1.5px solid rgba(29,185,84,0.2);border-radius:8px;padding:12px;color:#fff;font-size:0.95rem;margin-bottom:20px;box-sizing:border-box;outline:none;" />
      <button id="ci-submit" style="width:100%;background:#1DB954;color:#000;border:none;padding:14px;border-radius:8px;font-weight:700;font-size:1rem;cursor:pointer;">Continue →</button>
      <button id="ci-cancel" style="background:none;border:none;color:#666;cursor:pointer;margin-top:10px;font-size:0.8rem;display:block;width:100%;text-align:center;">Cancel</button>
    </div>
  `;
  document.body.appendChild(modal);

  document.getElementById('ci-submit').addEventListener('click', () => {
    const n = document.getElementById('ci-name').value.trim();
    const e = document.getElementById('ci-email').value.trim();
    const p = document.getElementById('ci-phone').value.trim();
    if (!n || !e || !p) { showToast('⚠️', 'All fields required'); return; }
    modal.remove();
    callback(e, p, n);
  });
  document.getElementById('ci-cancel').addEventListener('click', () => modal.remove());
}

function showToast(icon, msg) {
  const toast = document.getElementById('toast');
  const toastMsg = document.getElementById('toast-msg');
  const toastIcon = document.getElementById('toast-icon');
  if (!toast) return;
  if (toastMsg) toastMsg.textContent = msg;
  if (toastIcon) toastIcon.textContent = icon;
  toast.style.transform = 'translateX(-50%) translateY(0)';
  clearTimeout(window._toastTimer);
  window._toastTimer = setTimeout(() => {
    toast.style.transform = 'translateX(-50%) translateY(100px)';
  }, 4000);
}
