/* Napolitani Investments — main.js */

// ── Nav scroll effect ──
const nav = document.getElementById('nav');
window.addEventListener('scroll', () => {
  nav.classList.toggle('scrolled', window.scrollY > 40);
}, { passive: true });

// ── Mobile burger ──
const burger = document.getElementById('burger');
const mobileMenu = document.getElementById('mobileMenu');

burger.addEventListener('click', () => {
  const open = mobileMenu.classList.toggle('open');
  burger.classList.toggle('open', open);
  burger.setAttribute('aria-label', open ? 'Close menu' : 'Open menu');
});

// Close mobile menu when a link is clicked
mobileMenu.querySelectorAll('a').forEach(link => {
  link.addEventListener('click', () => {
    mobileMenu.classList.remove('open');
    burger.classList.remove('open');
    burger.setAttribute('aria-label', 'Open menu');
  });
});

// ── Scroll fade-in animations ──
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
      observer.unobserve(entry.target);
    }
  });
}, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });

document.querySelectorAll([
  '.section__text',
  '.section__visual',
  '.stats__item',
  '.property-card',
  '.pillar',
  '.contact-block',
  '.apply-frame__header',
].join(',')).forEach(el => {
  el.classList.add('fade-up');
  observer.observe(el);
});

// Stagger property cards
document.querySelectorAll('.property-card').forEach((card, i) => {
  card.style.transitionDelay = `${i * 0.1}s`;
});

// ── Application form submit ──
const form = document.getElementById('applyForm');
const successMsg = document.getElementById('formSuccess');

form.addEventListener('submit', (e) => {
  e.preventDefault();

  // Basic validation
  let valid = true;
  form.querySelectorAll('[required]').forEach(field => {
    if (!field.value.trim()) {
      field.style.borderColor = 'rgba(194,104,56,0.8)';
      valid = false;
    } else {
      field.style.borderColor = '';
    }
  });
  if (!valid) return;

  // Show success (in production, replace with actual form submission)
  successMsg.classList.add('visible');

  // Scroll to success
  form.scrollIntoView({ behavior: 'smooth', block: 'center' });
});

// Clear field error highlight on input
form.querySelectorAll('[required]').forEach(field => {
  field.addEventListener('input', () => {
    field.style.borderColor = '';
  });
});

// ── Smooth scroll offset for fixed nav ──
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', (e) => {
    const target = document.querySelector(anchor.getAttribute('href'));
    if (!target) return;
    e.preventDefault();
    const offset = 80;
    const top = target.getBoundingClientRect().top + window.scrollY - offset;
    window.scrollTo({ top, behavior: 'smooth' });
  });
});
