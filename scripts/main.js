/* ==============================
   OZOMINS — MAIN SCRIPTS
   Landing page interactivity
   ============================== */

'use strict';

// ─── NAVBAR SCROLL ──────────────
const nav = document.getElementById('nav');
if (nav) {
  window.addEventListener('scroll', () => {
    nav.classList.toggle('scrolled', window.scrollY > 50);
  }, { passive: true });
}

// ─── SCROLL REVEAL ──────────────
const revealEls = document.querySelectorAll('.reveal');

const revealObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
    }
  });
}, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' });

revealEls.forEach(el => revealObserver.observe(el));

// ─── COUNTER ANIMATION ──────────
function animateCounter(el, target, suffix = '') {
  const duration = 2000;
  const step = duration / target;
  let current = 0;

  const update = () => {
    current = Math.min(current + Math.ceil(target / 60), target);
    el.textContent = current.toLocaleString() + suffix;
    if (current < target) requestAnimationFrame(update);
  };

  requestAnimationFrame(update);
}

const statsObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const target = parseInt(entry.target.dataset.target, 10);
      const suffix = entry.target.id === 'stat-rating' ? '%' : (entry.target.id === 'stat-tons' ? '' : '');
      animateCounter(entry.target, target, suffix);
      statsObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.5 });

['stat-jobs', 'stat-workers', 'stat-tons', 'stat-rating'].forEach(id => {
  const el = document.getElementById(id);
  if (el) statsObserver.observe(el);
});

// ─── MOBILE NAV BURGER ──────────
const burger = document.getElementById('nav-burger');
const navLinks = document.getElementById('nav-links');

if (burger && navLinks) {
  burger.addEventListener('click', () => {
    const isOpen = navLinks.style.display === 'flex';
    navLinks.style.display = isOpen ? '' : 'flex';
    navLinks.style.flexDirection = isOpen ? '' : 'column';
    navLinks.style.position = isOpen ? '' : 'absolute';
    navLinks.style.top = isOpen ? '' : '70px';
    navLinks.style.left = isOpen ? '' : '0';
    navLinks.style.right = isOpen ? '' : '0';
    navLinks.style.background = isOpen ? '' : 'rgba(10,13,10,0.97)';
    navLinks.style.padding = isOpen ? '' : '20px';
    navLinks.style.gap = isOpen ? '' : '20px';
    navLinks.style.zIndex = isOpen ? '' : '999';
    navLinks.style.borderBottom = isOpen ? '' : '1px solid var(--eco-border)';
    navLinks.style.backdropFilter = isOpen ? '' : 'blur(20px)';
  });
}

// ─── WORKER JOB ACCEPT HANDLER ──
function initWorkerCard(acceptId, rejectId, cardId) {
  const acceptBtn = document.getElementById(acceptId);
  const rejectBtn = document.getElementById(rejectId);
  const card = document.getElementById(cardId);

  if (!acceptBtn || !rejectBtn || !card) return;

  acceptBtn.addEventListener('click', () => {
    card.style.transition = 'all 0.3s ease';
    card.style.borderColor = 'rgba(0,200,83,0.5)';
    card.style.background = 'rgba(0,200,83,0.08)';
    acceptBtn.textContent = '✅ Accepted';
    acceptBtn.disabled = true;
    rejectBtn.style.display = 'none';
    showToast('✅', 'Job accepted!');
  });

  rejectBtn.addEventListener('click', () => {
    card.style.transition = 'all 0.4s ease';
    card.style.opacity = '0';
    card.style.transform = 'translateX(-20px)';
    setTimeout(() => { card.style.display = 'none'; }, 400);
  });
}

initWorkerCard('job-accept-1', 'job-reject-1', 'worker-job-1');
initWorkerCard('job-accept-2', 'job-reject-2', 'worker-job-2');

// ─── TOAST UTIL ─────────────────
function showToast(icon, msg, duration = 3000) {
  const toast = document.getElementById('toast');
  if (!toast) return;
  document.getElementById('toast-icon').textContent = icon;
  document.getElementById('toast-msg').textContent = msg;
  toast.style.transform = 'translateX(-50%) translateY(0)';
  setTimeout(() => {
    toast.style.transform = 'translateX(-50%) translateY(100px)';
  }, duration);
}

// ─── SERVICE CAT CLICK (index) ──
const appServices = document.querySelectorAll('.app__service');
appServices.forEach(s => {
  s.addEventListener('click', () => {
    appServices.forEach(x => x.classList.remove('app__service--active'));
    s.classList.add('app__service--active');
  });
});

// ─── SMOOTH SCROLL ──────────────
document.querySelectorAll('a[href^="#"]').forEach(a => {
  a.addEventListener('click', e => {
    const id = a.getAttribute('href').slice(1);
    const target = document.getElementById(id);
    if (target) {
      e.preventDefault();
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  });
});

// ─── SCROLL HINT CLICK ──────────
const scrollHint = document.getElementById('hero-scroll');
if (scrollHint) {
  scrollHint.addEventListener('click', () => {
    document.getElementById('services')?.scrollIntoView({ behavior: 'smooth' });
  });
}

// ─── PARALLAX HERO ──────────────
const hero = document.getElementById('hero');
if (hero) {
  window.addEventListener('scroll', () => {
    const scrolled = window.scrollY;
    hero.querySelectorAll('.orb').forEach((orb, i) => {
      const speed = 0.1 + i * 0.05;
      orb.style.transform = `translateY(${scrolled * speed}px)`;
    });
  }, { passive: true });
}

console.log('🌿 Ozomins — Eco services delivered in minutes');
