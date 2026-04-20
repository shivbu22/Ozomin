-- =====================================================
-- OZOMIN DATABASE SCHEMA
-- =====================================================

-- Customers
CREATE TABLE IF NOT EXISTS customers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT NOT NULL,
  address TEXT DEFAULT '{}',      -- JSON: {line1, line2, city, state, pincode}
  eco_points_balance INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_customers_email ON customers(email);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON customers(phone);

-- Products & Services
CREATE TABLE IF NOT EXISTS products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  sku TEXT NOT NULL UNIQUE,
  category TEXT NOT NULL,
  description TEXT,
  price INTEGER NOT NULL,           -- in paise (₹1 = 100)
  cost_price INTEGER NOT NULL,      -- in paise
  stock_qty INTEGER NOT NULL DEFAULT 0,
  min_qty INTEGER NOT NULL DEFAULT 1,
  max_daily_qty INTEGER NOT NULL DEFAULT 10,
  supplier_name TEXT,
  supplier_contact TEXT,
  supplier_email TEXT,
  is_service INTEGER NOT NULL DEFAULT 0,  -- 1 = service, 0 = physical product
  active INTEGER NOT NULL DEFAULT 1,
  image_url TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_products_sku ON products(sku);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_active ON products(active);

-- Orders
CREATE TABLE IF NOT EXISTS orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_ref TEXT NOT NULL UNIQUE,   -- OZO-XXXXX format
  customer_id INTEGER NOT NULL REFERENCES customers(id),
  status TEXT NOT NULL DEFAULT 'pending',
  -- status flow: pending → verified → accepted → paid → shipped/ready → delivered → rejected/cancelled

  -- Delivery
  delivery_type TEXT NOT NULL DEFAULT 'delivery',  -- 'delivery' or 'pickup'
  delivery_address TEXT DEFAULT '{}',  -- JSON snapshot at order time
  delivery_notes TEXT,
  scheduled_date TEXT,
  scheduled_time_slot TEXT,

  -- Pricing
  subtotal INTEGER NOT NULL DEFAULT 0,        -- in paise
  eco_points_used INTEGER NOT NULL DEFAULT 0, -- points applied as discount
  eco_discount INTEGER NOT NULL DEFAULT 0,    -- paise discount from points
  total_amount INTEGER NOT NULL DEFAULT 0,    -- final amount in paise

  -- Eco Points
  eco_points_earned INTEGER NOT NULL DEFAULT 0,

  -- Payment
  payment_status TEXT DEFAULT 'pending',
  razorpay_payment_link_id TEXT,
  razorpay_payment_link_url TEXT,
  razorpay_payment_id TEXT,
  payment_link_expires_at TEXT,

  -- OTP
  otp_verified INTEGER NOT NULL DEFAULT 0,
  otp_attempts INTEGER NOT NULL DEFAULT 0,

  -- Admin / AI
  admin_notes TEXT,
  rejection_reason TEXT,
  ai_recommendation TEXT,

  -- Shipping (for delivery type)
  tracking_number TEXT,
  courier_name TEXT,
  shipped_at TEXT,
  delivered_at TEXT,

  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_orders_order_ref ON orders(order_ref);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);

-- Order Items
CREATE TABLE IF NOT EXISTS order_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER NOT NULL REFERENCES orders(id),
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL,
  unit_price INTEGER NOT NULL,   -- in paise, snapshot at order time
  total_price INTEGER NOT NULL,  -- in paise
  product_name TEXT NOT NULL,    -- snapshot
  product_sku TEXT NOT NULL      -- snapshot
);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);

-- Eco Points Ledger
CREATE TABLE IF NOT EXISTS eco_points_ledger (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER NOT NULL REFERENCES customers(id),
  order_id INTEGER REFERENCES orders(id),
  points_delta INTEGER NOT NULL,   -- positive = earned, negative = spent
  balance_after INTEGER NOT NULL,
  reason TEXT NOT NULL,            -- 'order_earned', 'order_redeemed', 'admin_adjustment'
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_ledger_customer_id ON eco_points_ledger(customer_id);
CREATE INDEX IF NOT EXISTS idx_ledger_order_id ON eco_points_ledger(order_id);

-- Purchase Orders (Supplier)
CREATE TABLE IF NOT EXISTS purchase_orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  po_ref TEXT NOT NULL UNIQUE,   -- PO-XXXXX
  supplier_name TEXT NOT NULL,
  supplier_email TEXT,
  status TEXT NOT NULL DEFAULT 'draft',  -- draft, sent, received
  items TEXT NOT NULL DEFAULT '[]',      -- JSON array [{product_id, name, qty, unit_cost}]
  total_cost INTEGER NOT NULL DEFAULT 0, -- in paise
  notes TEXT,
  expected_delivery TEXT,
  sent_at TEXT,
  received_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Daily Summaries
CREATE TABLE IF NOT EXISTS daily_summaries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  summary_date TEXT NOT NULL UNIQUE,   -- YYYY-MM-DD
  total_orders INTEGER NOT NULL DEFAULT 0,
  verified_orders INTEGER NOT NULL DEFAULT 0,
  accepted_orders INTEGER NOT NULL DEFAULT 0,
  paid_orders INTEGER NOT NULL DEFAULT 0,
  delivered_orders INTEGER NOT NULL DEFAULT 0,
  rejected_orders INTEGER NOT NULL DEFAULT 0,
  total_revenue INTEGER NOT NULL DEFAULT 0,      -- in paise
  eco_points_issued INTEGER NOT NULL DEFAULT 0,
  eco_points_redeemed INTEGER NOT NULL DEFAULT 0,
  low_stock_data TEXT DEFAULT '[]',   -- JSON
  ai_insights TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
