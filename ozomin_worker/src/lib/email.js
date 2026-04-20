// =====================================================
// Ozomin — Transactional Emails via Resend SDK
// =====================================================
// ⚠️  Set your real API key via Wrangler secret:
//     wrangler secret put RESEND_API_KEY
//     Then paste your key (starts with re_...) when prompted.
// =====================================================

import { Resend } from 'resend';

// Initialise Resend with the API key from Worker secrets
function getResend(env) {
  // ↓ Replace 're_xxxxxxxxx' with your real key ONLY for local testing.
  // In production always use env.RESEND_API_KEY (set via `wrangler secret put`).
  return new Resend(env.RESEND_API_KEY || 're_xxxxxxxxx');
}

const BRAND_SECONDARY = '#0d9941';
const BRAND_DARK = '#0a1628';

function baseTemplate(content, preheader = '') {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>Ozomin</title>
  <style>
    body { margin:0; padding:0; background:#f4f6f8; font-family:'Segoe UI',Arial,sans-serif; }
    .wrapper { max-width:600px; margin:32px auto; background:#ffffff; border-radius:12px; overflow:hidden; box-shadow:0 2px 16px rgba(0,0,0,0.08); }
    .header { background:${BRAND_DARK}; padding:28px 32px; text-align:center; }
    .header img { height:36px; }
    .header h1 { color:#ffffff; margin:8px 0 0; font-size:22px; font-weight:700; letter-spacing:-0.5px; }
    .header span { color:${BRAND_COLOR}; }
    .body { padding:32px; color:#333; font-size:15px; line-height:1.6; }
    .body h2 { font-size:20px; margin-top:0; color:${BRAND_DARK}; }
    .badge { display:inline-block; padding:4px 12px; border-radius:20px; font-size:12px; font-weight:700; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:16px; }
    .badge-delivery { background:#e8f4fd; color:#1a73e8; }
    .badge-pickup { background:#fef3e2; color:#e67700; }
    .otp-box { background:${BRAND_DARK}; border-radius:8px; padding:20px; text-align:center; margin:24px 0; }
    .otp-box .otp { font-size:40px; font-weight:800; color:${BRAND_COLOR}; letter-spacing:10px; font-family:monospace; }
    .otp-box small { color:#aaa; font-size:12px; display:block; margin-top:8px; }
    .btn { display:inline-block; background:${BRAND_COLOR}; color:#fff !important; text-decoration:none; padding:14px 32px; border-radius:8px; font-weight:700; font-size:15px; margin:20px 0; }
    .table { width:100%; border-collapse:collapse; margin:16px 0; }
    .table th { background:#f8f9fa; color:#555; font-size:12px; text-transform:uppercase; letter-spacing:0.5px; padding:10px 12px; text-align:left; border-bottom:2px solid #eee; }
    .table td { padding:10px 12px; border-bottom:1px solid #f0f0f0; font-size:14px; }
    .total-row td { font-weight:700; font-size:15px; background:#f8f9fa; }
    .points-box { background:linear-gradient(135deg,${BRAND_COLOR}15,${BRAND_COLOR}30); border:1px solid ${BRAND_COLOR}40; border-radius:8px; padding:16px 20px; margin:16px 0; }
    .points-box .pts { font-size:28px; font-weight:800; color:${BRAND_SECONDARY}; }
    .info-row { display:flex; justify-content:space-between; border-bottom:1px solid #f0f0f0; padding:8px 0; font-size:14px; }
    .info-row:last-child { border-bottom:none; }
    .info-label { color:#888; }
    .footer { background:#f8f9fa; padding:20px 32px; text-align:center; font-size:12px; color:#aaa; }
    .footer a { color:${BRAND_COLOR}; text-decoration:none; }
  </style>
</head>
<body>
  ${preheader ? `<div style="display:none;max-height:0;overflow:hidden;">${preheader}</div>` : ''}
  <div class="wrapper">
    <div class="header">
      <h1>Ozo<span>min</span></h1>
    </div>
    <div class="body">
      ${content}
    </div>
    <div class="footer">
      <p>© 2025 Ozomin. All rights reserved.</p>
      <p>Quick commerce, delivered with care 🌿</p>
    </div>
  </div>
</body>
</html>`;
}

function deliveryBadge(deliveryType) {
  const cls = deliveryType === 'pickup' ? 'badge-pickup' : 'badge-delivery';
  const label = deliveryType === 'pickup' ? '🏪 Store Pickup' : '🚚 Home Delivery';
  return `<span class="badge ${cls}">${label}</span>`;
}

function formatAmount(paise) {
  return `₹${(paise / 100).toLocaleString('en-IN', { minimumFractionDigits: 2 })}`;
}

function itemsTable(items) {
  const rows = items.map(i =>
    `<tr><td>${i.product_name}</td><td style="text-align:center">${i.quantity}</td><td style="text-align:right">${formatAmount(i.total_price)}</td></tr>`
  ).join('');
  return `<table class="table">
    <thead><tr><th>Item</th><th style="text-align:center">Qty</th><th style="text-align:right">Amount</th></tr></thead>
    <tbody>${rows}</tbody>
  </table>`;
}

// ── Core sender — uses official Resend SDK
async function sendEmail(env, { to, subject, html }) {
  const resend = getResend(env);

  const { data, error } = await resend.emails.send({
    from: 'Ozomin <orders@ozomin.in>',
    to: Array.isArray(to) ? to : [to],
    subject,
    html,
  });

  if (error) {
    console.error('[Resend] Send failed:', error);
    throw new Error(`Email failed: ${JSON.stringify(error)}`);
  }

  console.log('[Resend] Email sent:', data?.id);
  return data;
}

// ── Test / Onboarding Email
// Call this from any route to verify your Resend API key is working.
// Example: GET /admin/test-email
export async function sendTestEmail(env) {
  const resend = getResend(env);

  const { data, error } = await resend.emails.send({
    from: 'onboarding@resend.dev',        // use this until your domain is verified
    to: 'ozominsupport@gmail.com',        // ← your support inbox
    subject: 'Hello World',
    html: '<p>Congrats on sending your <strong>first email</strong>! — Ozomin 🌿</p>',
  });

  if (error) throw new Error(JSON.stringify(error));
  return data;
}



// ── OTP Email (Customer)
export async function sendOTPEmail(env, { to, name, otp, orderRef, delivery_type, delivery_notes, totalAmount, subtotal, ecoDiscount }) {
  const html = baseTemplate(`
    <h2>Verify Your Order</h2>
    ${deliveryBadge(delivery_type)}
    <p>Hi <strong>${name}</strong>, your Ozomin order <strong>${orderRef}</strong> is almost confirmed!</p>
    <p>Use the OTP below to verify your order:</p>
    <div class="otp-box">
      <div class="otp">${otp}</div>
      <small>Valid for 10 minutes · Do not share this OTP</small>
    </div>
    ${subtotal && ecoDiscount ? `<div class="info-row"><span class="info-label">Eco Points Discount</span><span style="color:${BRAND_COLOR}">−${formatAmount(ecoDiscount)}</span></div>` : ''}
    ${totalAmount ? `<div class="info-row" style="font-weight:700"><span>Total Payable</span><span>${formatAmount(totalAmount)}</span></div>` : ''}
    ${delivery_notes ? `<p style="color:#888;font-size:13px;margin-top:16px;">📝 Delivery note: ${delivery_notes}</p>` : ''}
    <p style="font-size:13px;color:#aaa;">If you didn't place this order, please ignore this email.</p>
  `, `Your OTP for Ozomin order ${orderRef}`);

  return sendEmail(env, { to, subject: `${otp} — Your Ozomin Order OTP`, html });
}

// ── Admin OTP Email
export async function sendAdminOTPEmail(env, { to, otp }) {
  const html = baseTemplate(`
    <h2>Admin Login OTP</h2>
    <p>Use the following OTP to complete your Ozomin admin login:</p>
    <div class="otp-box">
      <div class="otp">${otp}</div>
      <small>Valid for 10 minutes · Do not share</small>
    </div>
    <p style="font-size:13px;color:#aaa;">If you didn't request this, please secure your admin account immediately.</p>
  `, 'Your Ozomin admin OTP');

  return sendEmail(env, { to, subject: `${otp} — Ozomin Admin OTP`, html });
}

// ── Payment Link Email
export async function sendPaymentLinkEmail(env, { to, name, orderRef, paymentUrl, totalAmount, delivery_type, delivery_notes, items }) {
  const html = baseTemplate(`
    <h2>Your Payment Link is Ready!</h2>
    ${deliveryBadge(delivery_type)}
    <p>Hi <strong>${name}</strong>, your order <strong>${orderRef}</strong> has been accepted!</p>
    <p>Please complete your payment within <strong>1 hour</strong> to confirm your order.</p>
    <div style="text-align:center;margin:24px 0;">
      <a href="${paymentUrl}" class="btn">Pay ${formatAmount(totalAmount)}</a>
    </div>
    ${items?.length ? itemsTable(items) : ''}
    <p style="font-size:13px;color:#888;">Payment link expires in 1 hour. After expiry, please contact us to get a new link.</p>
    ${delivery_notes ? `<p style="color:#888;font-size:13px;">📝 ${delivery_notes}</p>` : ''}
  `, `Pay ${formatAmount(totalAmount)} for Ozomin order ${orderRef}`);

  return sendEmail(env, { to, subject: `Action Required: Pay for Ozomin Order ${orderRef}`, html });
}

// ── Order Confirmation Email (post-payment)
export async function sendOrderConfirmationEmail(env, { to, name, orderRef, totalAmount, ecoPointsEarned, newPointsBalance, delivery_type, delivery_notes, delivery_address, items }) {
  const addrObj = (() => { try { return typeof delivery_address === 'string' ? JSON.parse(delivery_address) : delivery_address; } catch { return {}; } })();
  const addrLine = addrObj.line1 ? `${addrObj.line1}, ${addrObj.city || ''}` : '';

  const html = baseTemplate(`
    <h2>✅ Payment Confirmed!</h2>
    ${deliveryBadge(delivery_type)}
    <p>Hi <strong>${name}</strong>, thank you! Your order <strong>${orderRef}</strong> has been paid and is being prepared.</p>
    ${items?.length ? itemsTable(items) : ''}
    <div class="info-row"><span class="info-label">Total Paid</span><span style="font-weight:700">${formatAmount(totalAmount)}</span></div>
    ${addrLine ? `<div class="info-row"><span class="info-label">Delivery To</span><span>${addrLine}</span></div>` : ''}
    ${delivery_notes ? `<div class="info-row"><span class="info-label">Note</span><span>${delivery_notes}</span></div>` : ''}
    ${ecoPointsEarned > 0 ? `
    <div class="points-box">
      <p style="margin:0 0 4px;font-size:13px;color:#555;">🌿 Eco Points Earned</p>
      <div class="pts">+${ecoPointsEarned} pts</div>
      <p style="margin:4px 0 0;font-size:13px;color:#555;">Your balance: <strong>${newPointsBalance} pts</strong></p>
    </div>` : ''}
    <p style="font-size:13px;color:#888;">We'll notify you when your order is on the way. You can track it using order ref: <strong>${orderRef}</strong></p>
  `, `Order ${orderRef} confirmed — ${ecoPointsEarned > 0 ? `+${ecoPointsEarned} Eco Points earned!` : 'Thank you!'}`);

  return sendEmail(env, { to, subject: `✅ Order ${orderRef} Confirmed — Ozomin`, html });
}

// ── Shipping Notification Email
export async function sendShippingEmail(env, { to, name, orderRef, trackingNumber, courierName, delivery_type }) {
  const html = baseTemplate(`
    <h2>🚚 Your Order is on the Way!</h2>
    ${deliveryBadge(delivery_type)}
    <p>Hi <strong>${name}</strong>, great news! Your Ozomin order <strong>${orderRef}</strong> has been shipped.</p>
    ${trackingNumber ? `
    <div style="background:#f8f9fa;border-radius:8px;padding:16px 20px;margin:16px 0;">
      <p style="margin:0 0 4px;font-size:12px;color:#888;text-transform:uppercase;letter-spacing:0.5px;">Tracking Number</p>
      <p style="margin:0;font-size:20px;font-weight:700;color:${BRAND_DARK};font-family:monospace;">${trackingNumber}</p>
      ${courierName ? `<p style="margin:4px 0 0;font-size:13px;color:#888;">via ${courierName}</p>` : ''}
    </div>` : ''}
    <p style="font-size:13px;color:#888;">Expected delivery: 1–3 business days. We'll notify you once delivered.</p>
  `, `Your Ozomin order ${orderRef} is on the way!`);

  return sendEmail(env, { to, subject: `🚚 Order ${orderRef} Shipped — Ozomin`, html });
}

// ── Ready for Pickup Email
export async function sendReadyForPickupEmail(env, { to, name, orderRef, delivery_notes }) {
  const html = baseTemplate(`
    <h2>🏪 Your Order is Ready for Pickup!</h2>
    ${deliveryBadge('pickup')}
    <p>Hi <strong>${name}</strong>, your Ozomin order <strong>${orderRef}</strong> is ready and waiting for you!</p>
    <div style="background:#f8f9fa;border-radius:8px;padding:16px 20px;margin:16px 0;">
      <p style="margin:0;font-weight:700;">📍 Pickup Location</p>
      <p style="margin:8px 0 0;color:#555;">Ozomin Store, Main Branch<br/>Please bring this order ref: <strong>${orderRef}</strong></p>
    </div>
    ${delivery_notes ? `<p style="color:#888;font-size:13px;">📝 ${delivery_notes}</p>` : ''}
    <p style="font-size:13px;color:#888;">Store hours: 9 AM – 9 PM, Mon–Sat</p>
  `, `Your Ozomin order ${orderRef} is ready for pickup!`);

  return sendEmail(env, { to, subject: `🏪 Order ${orderRef} Ready for Pickup — Ozomin`, html });
}

// ── Rejection Email
export async function sendRejectionEmail(env, { to, name, orderRef, reason, ecoPointsRefunded }) {
  const html = baseTemplate(`
    <h2>Order Update</h2>
    <p>Hi <strong>${name}</strong>, unfortunately we were unable to process your order <strong>${orderRef}</strong>.</p>
    <div style="background:#fff5f5;border:1px solid #ffcccc;border-radius:8px;padding:16px 20px;margin:16px 0;">
      <p style="margin:0;color:#cc0000;font-weight:600;">Reason</p>
      <p style="margin:8px 0 0;color:#555;">${reason}</p>
    </div>
    ${ecoPointsRefunded > 0 ? `
    <div class="points-box">
      <p style="margin:0 0 4px;font-size:13px;color:#555;">🌿 Eco Points Refunded</p>
      <div class="pts">+${ecoPointsRefunded} pts</div>
      <p style="margin:4px 0 0;font-size:13px;color:#555;">Your points have been restored to your account.</p>
    </div>` : ''}
    <p>We apologize for the inconvenience. Please feel free to place a new order or contact us if you have questions.</p>
    <div style="text-align:center;margin:24px 0;">
      <a href="https://ozomin.in" class="btn">Shop Again</a>
    </div>
  `, `Update on your Ozomin order ${orderRef}`);

  return sendEmail(env, { to, subject: `Update on Your Ozomin Order ${orderRef}`, html });
}
