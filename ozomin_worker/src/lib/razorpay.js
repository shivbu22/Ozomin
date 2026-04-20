// =====================================================
// Razorpay Integration — Payment Links API
// =====================================================

export async function createRazorpayLink(env, { amount, orderRef, customerName, customerEmail, customerPhone, description, expireBy }) {
  const auth = btoa(`${env.RAZORPAY_KEY_ID}:${env.RAZORPAY_KEY_SECRET}`);

  const payload = {
    amount,                   // already in paise
    currency: 'INR',
    accept_partial: false,
    description,
    reference_id: orderRef,
    expire_by: expireBy,
    customer: {
      name: customerName,
      email: customerEmail,
      contact: customerPhone,
    },
    notify: {
      sms: false,
      email: false,           // We send our own branded email
    },
    reminder_enable: false,
    notes: {
      order_ref: orderRef,
      platform: 'ozomin',
    },
    callback_url: `https://ozomin.in/payment/success?order=${orderRef}`,
    callback_method: 'get',
  };

  const response = await fetch('https://api.razorpay.com/v1/payment_links', {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${auth}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const err = await response.text();
    throw new Error(`Razorpay error: ${response.status} — ${err}`);
  }

  return response.json();
}

export async function getRazorpayLink(env, linkId) {
  const auth = btoa(`${env.RAZORPAY_KEY_ID}:${env.RAZORPAY_KEY_SECRET}`);
  const response = await fetch(`https://api.razorpay.com/v1/payment_links/${linkId}`, {
    headers: { 'Authorization': `Basic ${auth}` },
  });
  return response.json();
}
