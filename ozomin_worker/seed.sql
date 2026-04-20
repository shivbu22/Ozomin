-- =====================================================
-- OZOMIN SEED DATA — Sample Indian Products & Services
-- =====================================================

INSERT INTO products (name, sku, category, description, price, cost_price, stock_qty, min_qty, max_daily_qty, supplier_name, supplier_email, is_service, active, image_url) VALUES
-- Grocery
('Organic Basmati Rice 5kg', 'GRC-001', 'Grocery', 'Premium aged basmati rice, sourced from Dehradun farms', 72500, 55000, 150, 1, 20, 'Dehradun Organics Pvt Ltd', 'orders@dehradunorganics.in', 0, 1, 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400'),
('Cold Pressed Coconut Oil 1L', 'GRC-002', 'Grocery', 'Pure virgin coconut oil, cold pressed, no additives', 44900, 32000, 80, 1, 15, 'Kerala Naturals', 'supply@keralanaturals.in', 0, 1, 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400'),
('Turmeric Powder 500g', 'GRC-003', 'Grocery', 'Pure Erode turmeric, high curcumin content, lab tested', 18900, 12000, 200, 1, 30, 'Spice Route India', 'bulk@spiceroute.in', 0, 1, 'https://images.unsplash.com/photo-1615485500704-8e990f9900f7?w=400'),

-- Personal Care
('Neem & Tulsi Handmade Soap', 'PC-001', 'Personal Care', 'Handcrafted with neem extract and tulsi, ideal for Indian skin', 14900, 8000, 300, 1, 25, 'AyurCraft Workshop', 'sales@ayurcraft.in', 0, 1, 'https://images.unsplash.com/photo-1607006344380-b6775a0824a7?w=400'),
('Charcoal Face Wash 100ml', 'PC-002', 'Personal Care', 'Deep cleansing bamboo charcoal face wash, sulphate free', 24900, 16000, 120, 1, 20, 'Pure Earth Cosmetics', 'orders@pureearth.in', 0, 1, 'https://images.unsplash.com/photo-1556228852-6d35a585d566?w=400'),

-- Home & Kitchen
('Copper Water Bottle 1L', 'HK-001', 'Home & Kitchen', 'Pure copper, hand-hammered, Ayurvedic benefits, leak-proof', 89900, 62000, 60, 1, 10, 'Coppersmith India', 'trade@coppersmith.in', 0, 1, 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400'),
('Steel Lunch Box 3-Tier', 'HK-002', 'Home & Kitchen', 'Food grade stainless steel tiffin, leak-proof with handle', 54900, 35000, 90, 1, 15, 'MetalCraft Industries', 'b2b@metalcraft.in', 0, 1, 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400'),

-- Services
('Home Deep Cleaning (2BHK)', 'SVC-001', 'Services', 'Professional deep cleaning for 2BHK — 4 hours, all supplies included', 199900, 120000, 99999, 1, 5, 'Ozomin Services Team', 'services@ozomin.in', 1, 1, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'),
('AC Service & Gas Refill', 'SVC-002', 'Services', 'Split AC servicing + gas top-up, 1-year service warranty', 249900, 150000, 99999, 1, 3, 'Ozomin Services Team', 'services@ozomin.in', 1, 1, 'https://images.unsplash.com/photo-1621905251918-48416bd8575a?w=400'),
('Plumbing Emergency Fix', 'SVC-003', 'Services', 'Emergency plumbing repair, 30-min response within 5km', 99900, 50000, 99999, 1, 8, 'Ozomin Services Team', 'services@ozomin.in', 1, 1, 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=400');
