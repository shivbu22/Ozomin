/* ==============================
   OZOMINS — APP SCRIPTS
   Customer App interactivity
   ============================== */

'use strict';

// ─── TOAST ──────────────────────
function showToast(icon, msg, duration = 3000) {
  const toast = document.getElementById('toast');
  if (!toast) return;
  document.getElementById('toast-icon').textContent = icon;
  document.getElementById('toast-msg').textContent = msg;
  toast.style.transform = 'translateX(-50%) translateY(0)';
  setTimeout(() => {
    toast.style.transform = 'translateX(-50%) translateY(120px)';
  }, duration);
}

// ─── SERVICE CATEGORY SWITCH ────
const serviceCats = document.querySelectorAll('.service-cat');
const panelPicks  = document.querySelectorAll('.service-pick');

const servicePrices = {
  cleaning:     149,
  garbage:       89,
  recycling:    'Earn ₹50+',
  transport:    399,
  emergency:    299,
  subscription: 999,
};

function selectService(service) {
  // Update phone side
  serviceCats.forEach(c => c.classList.toggle('active', c.dataset.service === service));
  // Update panel side
  panelPicks.forEach(p => p.classList.toggle('active', p.dataset.service === service));
  // Update price
  const priceEl = document.getElementById('price-amount');
  if (priceEl) {
    const price = servicePrices[service];
    priceEl.textContent = typeof price === 'string' ? price : `₹ ${price}`;
  }
  // Update panel title
  const titles = {
    cleaning: 'Book Cleaning',
    garbage: 'Book Garbage Pickup',
    recycling: 'Book Recycling',
    transport: 'Book Transport',
    emergency: '🚨 Emergency Service',
    subscription: 'Set Up Subscription',
  };
  const ptitle = document.getElementById('panel-title');
  if (ptitle) ptitle.textContent = titles[service] || 'Book a Service';
}

serviceCats.forEach(c => {
  c.addEventListener('click', () => selectService(c.dataset.service));
});

panelPicks.forEach(p => {
  p.addEventListener('click', () => selectService(p.dataset.service));
});

// ─── WORKER CARD CLICK ──────────
const workerCards = document.querySelectorAll('.worker-card');

workerCards.forEach(card => {
  card.addEventListener('click', () => {
    const workerNames = { rajan: 'Rajan Kumar', priya: 'Priya Devi', suresh: 'Suresh Babu', meena: 'Meena Krishnan' };
    const name = workerNames[card.dataset.worker] || 'Worker';

    // Highlight selected
    workerCards.forEach(c => {
      c.style.borderColor = '';
      c.style.background = '';
    });
    card.style.borderColor = 'rgba(0,200,83,0.4)';
    card.style.background = 'rgba(0,200,83,0.06)';

    // Show in panel
    const addrEl = document.getElementById('booking-address');
    if (addrEl && !addrEl.dataset.set) {
      addrEl.dataset.set = '1';
    }

    showToast('👷', `${name} selected`);
  });
});

// ─── BOOK NOW BUTTON ────────────
const bookBtn = document.getElementById('book-now-btn');
if (bookBtn) {
  bookBtn.addEventListener('click', () => {
    bookBtn.textContent = '⏳ Finding worker...';
    bookBtn.disabled = true;
    bookBtn.style.opacity = '0.7';

    setTimeout(() => {
      bookBtn.textContent = '✅ Booking Confirmed!';
      bookBtn.style.background = 'linear-gradient(135deg, #00E676, #00C853)';
      bookBtn.style.opacity = '1';

      // Show tracker
      const tracker = document.getElementById('tracker-card');
      if (tracker) {
        tracker.classList.add('show');
        tracker.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }

      showToast('🎉', 'Rajan Kumar is on his way!', 5000);
    }, 2000);
  });
}

// ─── BOTTOM NAV ─────────────────
const navItems = document.querySelectorAll('.bottom-nav__item');

navItems.forEach(item => {
  item.addEventListener('click', () => {
    navItems.forEach(n => n.classList.remove('bottom-nav__item--active'));
    item.classList.add('bottom-nav__item--active');

    const id = item.id;
    if (id === 'nav-book') {
      // Scroll booking form into view (panel on desktop)
      document.getElementById('book-now-btn')?.scrollIntoView({ behavior: 'smooth' });
      showToast('📝', 'Fill in your booking details →');
    } else if (id === 'nav-track') {
      const tracker = document.getElementById('tracker-card');
      if (tracker && tracker.classList.contains('show')) {
        tracker.scrollIntoView({ behavior: 'smooth' });
      } else {
        showToast('📍', 'No active job to track yet');
      }
    } else if (id === 'nav-history') {
      showToast('📋', 'You have 7 completed jobs');
    } else if (id === 'nav-profile') {
      showToast('👤', 'Profile: Aditya · ⭐ 4.9 rating');
    }
  });
});

// ─── CANCEL JOB ─────────────────
const cancelBtn = document.getElementById('cancel-job-btn');
if (cancelBtn) {
  cancelBtn.addEventListener('click', () => {
    const tracker = document.getElementById('tracker-card');
    if (tracker) {
      tracker.style.transition = 'all 0.3s ease';
      tracker.style.opacity = '0';
      setTimeout(() => {
        tracker.classList.remove('show');
        tracker.style.opacity = '1';
      }, 300);
    }

    const bookBtn2 = document.getElementById('book-now-btn');
    if (bookBtn2) {
      bookBtn2.textContent = 'Confirm Booking';
      bookBtn2.disabled = false;
      bookBtn2.style.opacity = '1';
      bookBtn2.style.background = '';
    }

    showToast('❌', 'Booking cancelled');
  });
}

// ─── CALL WORKER ────────────────
document.getElementById('call-worker-btn')?.addEventListener('click', () => {
  showToast('📞', 'Calling Rajan Kumar...');
});

// ─── PHOTO UPLOAD ────────────── 
document.getElementById('photo-upload-btn')?.addEventListener('click', () => {
  showToast('📷', 'Photo upload coming soon!');
});

// ─── PROMO CLAIM ────────────────
document.getElementById('promo-claim-btn')?.addEventListener('click', () => {
  const promo = document.getElementById('promo-banner');
  if (promo) {
    promo.style.borderColor = 'rgba(0,200,83,0.5)';
    promo.style.background = 'linear-gradient(135deg, #002005, #0A3510)';
    promo.querySelector('.promo-banner__title').textContent = '🎉 FREE credits applied!';
    promo.querySelector('.promo-banner__sub').textContent = '3 free bookings unlocked ✅';
    const btn = document.getElementById('promo-claim-btn');
    if (btn) { btn.textContent = 'Claimed!'; btn.disabled = true; }
  }
  showToast('🎁', '3 free credits added!');
});

// ─── TRACKER ETA COUNTDOWN ──────
function updateTrackerEta() {
  const etaEl = document.getElementById('tracker-eta');
  if (!etaEl) return;
  const times = ['🚶 2 min away', '🚶 1 min away', '🏃 Arriving now!', '✅ Arrived!'];
  let idx = 0;
  setInterval(() => {
    if (idx < times.length - 1) {
      idx++;
      etaEl.textContent = times[idx];
    }
  }, 8000);
}
updateTrackerEta();

// ─── BOOKING TIME CHANGE ────────
document.getElementById('booking-time')?.addEventListener('change', (e) => {
  const hints = {
    now: 'We\'ll find you a worker right now.',
    '30min': 'Worker will arrive in ~30 minutes.',
    '1hr': 'Worker will arrive in ~1 hour.',
    today: 'We\'ll schedule for this afternoon.',
    tomorrow: 'We\'ll confirm before tomorrow.',
    custom: 'Pick your preferred time slot.',
  };
  // Could show a tooltip here
});

console.log('🌿 Ozomins Customer App loaded');
