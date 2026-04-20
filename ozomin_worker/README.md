# Ozomin Worker — Cloudflare Workers Backend

Quick-commerce backend API built on Cloudflare Workers + D1 + KV.

## Project Structure

```
ozomin_worker/
├── wrangler.toml          # Cloudflare configuration
├── schema.sql             # D1 database schema
├── seed.sql               # Sample products/services
├── package.json
└── src/
    ├── index.js           # Main entry point (router)
    ├── middleware/
    │   ├── cors.js        # CORS headers
    │   ├── rateLimit.js   # KV-based rate limiting
    │   └── adminAuth.js   # Admin session auth
    ├── routes/
    │   ├── products.js    # Product CRUD
    │   ├── orders.js      # Order placement + OTP flow
    │   ├── customers.js   # Customer profiles
    │   ├── ecoPoints.js   # Eco Points balance + ledger
    │   ├── admin.js       # Admin panel APIs
    │   ├── purchaseOrders.js  # Supplier POs
    │   └── webhooks.js    # Razorpay webhook
    └── lib/
        ├── email.js       # Resend email templates
        └── razorpay.js    # Razorpay Payment Links API
```

## Setup & Deploy

### 1. Install Wrangler
```bash
npm install
```

### 2. Authenticate with Cloudflare
```bash
npx wrangler login
```

### 3. Create D1 Database
```bash
npx wrangler d1 create ozomin-db
# Copy the database_id into wrangler.toml
```

### 4. Create KV Namespace
```bash
npx wrangler kv namespace create STORE_KV
# Copy the id into wrangler.toml
```

### 5. Set Secrets
```bash
npx wrangler secret put RESEND_API_KEY
npx wrangler secret put RAZORPAY_KEY_ID
npx wrangler secret put RAZORPAY_KEY_SECRET
npx wrangler secret put WEBHOOK_SECRET
npx wrangler secret put ADMIN_EMAIL
npx wrangler secret put ADMIN_API_KEY
npx wrangler secret put ANTHROPIC_API_KEY
```

### 6. Initialize Database
```bash
# Apply schema
npm run db:init

# Load seed data
npm run db:seed
```

### 7. Run Locally
```bash
npm run dev
# API available at http://localhost:8787
```

### 8. Deploy to Cloudflare
```bash
npm run deploy
```

## API Reference

### Public Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/products` | List products (filter: `?category=Grocery&q=search`) |
| GET | `/api/products/:id` | Get product details |
| POST | `/api/orders` | Place a new order |
| POST | `/api/orders/:ref/verify` | Verify OTP |
| POST | `/api/orders/:ref/resend-otp` | Resend OTP |
| GET | `/api/orders/:ref` | Get order status |
| GET | `/api/customers/:id` | Get customer profile |
| GET | `/api/eco-points/:customerId` | Eco Points balance + ledger |
| GET | `/api/eco-points/:customerId/check?amount=500` | Max redeemable points |

### Admin Endpoints (require `X-Admin-Email` + `X-Admin-Key` headers + OTP session)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/admin/auth/request-otp` | Step 1: Request admin OTP |
| POST | `/admin/auth/verify-otp` | Step 2: Verify OTP (session valid 8h) |
| GET | `/admin/orders` | List all orders |
| POST | `/admin/orders/:ref/accept` | Accept order → create Razorpay link |
| POST | `/admin/orders/:ref/ship` | Mark shipped (delivery orders) |
| POST | `/admin/orders/:ref/ready` | Mark ready for pickup |
| POST | `/admin/orders/:ref/deliver` | Mark delivered |
| POST | `/admin/orders/:ref/reject` | Reject order (auto-refunds points) |
| GET | `/admin/dashboard` | Today's stats + low stock alerts |
| POST | `/api/purchase-orders` | Create supplier PO |
| PATCH | `/api/purchase-orders/:id` | Update PO status |

### Webhooks

| Method | Path | Description |
|--------|------|-------------|
| POST | `/webhooks/razorpay` | Payment confirmation + Eco Points crediting |

## Eco Points Rules

- **Earn:** 1 point per ₹10 spent (credited on payment)
- **Redeem:** 1 point = ₹1 discount (max 20% of order total)
- **Refund:** Points auto-refunded on order rejection

## Order Flow

```
Customer places order → OTP sent
         ↓
Customer verifies OTP → status: verified
         ↓
Admin accepts → Razorpay payment link created (1hr expiry)
         ↓
Customer pays → Razorpay webhook → status: paid → Eco Points credited
         ↓
Admin ships (delivery) → status: shipped
      OR
Admin marks ready (pickup) → status: ready
         ↓
Admin marks delivered → status: delivered
```
