-- ==============================================================================
-- E-COMMERCE MANAGEMENT SYSTEM SEED DATA
-- Comprehensive dataset covering all test cases and edge cases
-- ==============================================================================

-- 1. CATEGORIES (Multi-level Hierarchy)
INSERT INTO CATEGORIES (category_id, category_name, parent_category_id) VALUES
(1, 'Electronics', NULL),
(2, 'Computers & Laptops', 1),
(3, 'Smartphones & Tablets', 1),
(4, 'Audio & Accessories', 1),
(5, 'Home Appliances', NULL),
(6, 'Kitchen Appliances', 5),
(7, 'Fashion & Apparel', NULL),
(8, 'Men Fashion', 7),
(9, 'Women Fashion', 7),
(10, 'Books & Media', NULL);

-- 2. SUPPLIERS
INSERT INTO SUPPLIERS (supplier_id, supplier_name, email, phone) VALUES
(1, 'Apex Tech Distribution', 'contact@apextech.com', '+91-9876543210'),
(2, 'Nexus Electronics Ltd', 'sales@nexuselec.com', '+91-9876543211'),
(3, 'Zenith Lifestyle Goods', 'zenith@lifestyle.com', '+91-9876543212'),
(4, 'Pinnacle Kitchen Corp', 'support@pinnacle.com', '+91-9876543213'),
(5, 'Vanguard Media Group', 'media@vanguard.com', '+91-9876543214');

-- 3. PRODUCTS
-- Notice: Product 12 has stock < 10, Product 13 and 14 are never ordered, Product 15 has no reviews
INSERT INTO PRODUCTS (product_id, product_name, description, price, stock_quantity, category_id, supplier_id) VALUES
(101, 'MacBook Pro 16-inch', 'Apple M2 Pro chip, 16GB RAM, 512GB SSD', 199900.00, 25, 2, 1),
(102, 'Dell XPS 15', 'Intel Core i9, 32GB RAM, 1TB SSD', 145000.00, 15, 2, 1),
(103, 'iPhone 15 Pro Max', 'Titanium design, A17 Pro chip, 256GB', 134900.00, 30, 3, 2),
(104, 'Samsung Galaxy S24 Ultra', 'AI-powered flagship, 12GB RAM, 256GB', 119999.00, 18, 3, 2),
(105, 'Sony WH-1000XM5', 'Industry Leading Wireless Noise Cancelling Headphones', 29990.00, 45, 4, 1),
(106, 'AirPods Pro 2nd Gen', 'Active Noise Cancellation, USB-C case', 24900.00, 60, 4, 2),
(107, 'Smart Microwave Oven 28L', 'Convection oven with auto cook menus', 14500.00, 8, 6, 4),
(108, 'Air Fryer Digital 4L', 'Rapid air circulation technology', 6499.00, 5, 6, 4),
(109, 'Leather Formal Shoes', 'Handcrafted genuine Italian leather', 4899.00, 40, 8, 3),
(110, 'Designer Silk Saree', 'Traditional pure Kanchipuram silk', 12500.00, 20, 9, 3),
(111, 'Smart LED TV 55-inch 4K', 'Dolby Vision & Atmos UHD Smart TV', 42999.00, 12, 1, 2),
(112, 'Mechanical Gaming Keyboard', 'RGB Hot-swappable tactile switches', 3899.00, 4, 2, 1),
(113, 'Ergonomic Office Chair', 'Adjustable lumbar support breathable mesh', 8999.00, 0, 5, 3), -- Never ordered
(114, 'Vintage Turntable Player', 'Hi-Fi vinyl record player with speakers', 11200.00, 7, 4, 1), -- Never ordered
(115, 'Database Internals Book', 'A deep dive into distributed storage engines', 2850.00, 50, 10, 5);

-- 4. CUSTOMERS
-- Customer 11 has no orders (for LEFT JOIN test)
-- Customer 12 has no address (for LEFT JOIN test)
INSERT INTO CUSTOMERS (customer_id, customer_name, email, phone, registration_date) VALUES
(1, 'Aarav Sharma', 'aarav.sharma@example.com', '9820011223', '2024-01-10 10:15:00'),
(2, 'Priya Patel', 'priya.patel@example.com', '9820022334', '2024-01-15 14:20:00'),
(3, 'Rohan Verma', 'rohan.verma@example.com', '9820033445', '2024-02-01 09:30:00'),
(4, 'Ananya Iyer', 'ananya.iyer@example.com', '9820044556', '2024-02-18 16:45:00'),
(5, 'Vikram Malhotra', 'vikram.m@example.com', '9820055667', '2024-03-05 11:10:00'),
(6, 'Neha Kulkarni', 'neha.k@example.com', '9820066778', '2024-03-22 17:00:00'),
(7, 'Aditya Singh', 'aditya.singh@example.com', '9820077889', '2024-04-02 12:40:00'),
(8, 'Sneha Reddy', 'sneha.reddy@example.com', '9820088990', '2024-04-14 18:25:00'),
(9, 'Kabir Mehta', 'kabir.mehta@example.com', '9820099001', '2024-04-28 08:50:00'),
(10, 'Ishita Roy', 'ishita.roy@example.com', '9820000112', '2024-05-01 13:15:00'),
(11, 'Siddharth Joshi', 'siddharth.j@example.com', '9820011335', '2024-05-05 15:30:00'), -- No orders
(12, 'Pooja Nair', 'pooja.nair@example.com', '9820022446', '2024-05-08 19:10:00');      -- No address

-- 5. ADDRESSES
INSERT INTO ADDRESSES (address_id, customer_id, address_type, city, state, pincode) VALUES
(1, 1, 'Home', 'Mumbai', 'Maharashtra', '400001'),
(2, 1, 'Office', 'Mumbai', 'Maharashtra', '400051'),
(3, 2, 'Home', 'Bengaluru', 'Karnataka', '560001'),
(4, 3, 'Home', 'Delhi', 'Delhi', '110001'),
(5, 4, 'Home', 'Chennai', 'Tamil Nadu', '600001'),
(6, 5, 'Home', 'Bengaluru', 'Karnataka', '560034'),
(7, 6, 'Home', 'Pune', 'Maharashtra', '411001'),
(8, 7, 'Office', 'Hyderabad', 'Telangana', '500001'),
(9, 8, 'Home', 'Hyderabad', 'Telangana', '500081'),
(10, 9, 'Home', 'Kolkata', 'West Bengal', '700001'),
(11, 10, 'Home', 'Mumbai', 'Maharashtra', '400050'),
(12, 11, 'Home', 'Ahmedabad', 'Gujarat', '380001');

-- 6. ORDERS
-- Order 1008 has no payment (for LEFT JOIN test)
INSERT INTO ORDERS (order_id, customer_id, order_date, order_status, total_amount) VALUES
(1001, 1, '2024-01-12 11:00:00', 'Completed', 199900.00),
(1002, 2, '2024-01-20 15:30:00', 'Completed', 159890.00),
(1003, 3, '2024-02-05 10:20:00', 'Completed', 134900.00),
(1004, 1, '2024-02-14 18:00:00', 'Completed', 24900.00),
(1005, 4, '2024-03-01 12:15:00', 'Completed', 14500.00),
(1006, 5, '2024-03-10 14:45:00', 'Completed', 126498.00),
(1007, 6, '2024-03-25 16:10:00', 'Shipped', 12500.00),
(1008, 7, '2024-04-05 09:40:00', 'Pending', 42999.00),   -- No payment
(1009, 8, '2024-04-15 17:50:00', 'Completed', 10398.00),
(1010, 1, '2024-04-20 11:30:00', 'Processing', 3899.00),
(1011, 2, '2024-05-02 13:00:00', 'Completed', 29990.00),
(1012, 9, '2024-05-06 19:20:00', 'Processing', 2850.00),
(1013, 10, '2024-05-09 10:05:00', 'Delivered', 6499.00),
(1014, 1, '2024-05-10 14:00:00', 'Completed', 12500.00);

-- 7. ORDER_ITEMS
INSERT INTO ORDER_ITEMS (order_item_id, order_id, product_id, quantity, unit_price) VALUES
(501, 1001, 101, 1, 199900.00),
(502, 1002, 102, 1, 145000.00),
(503, 1002, 107, 1, 14890.00),
(504, 1003, 103, 1, 134900.00),
(505, 1004, 106, 1, 24900.00),
(506, 1005, 107, 1, 14500.00),
(507, 1006, 104, 1, 119999.00),
(508, 1006, 108, 1, 6499.00),
(509, 1007, 110, 1, 12500.00),
(510, 1008, 111, 1, 42999.00),
(511, 1009, 109, 1, 4899.00),
(512, 1009, 108, 1, 5499.00),
(513, 1010, 112, 1, 3899.00),
(514, 1011, 105, 1, 29990.00),
(515, 1012, 115, 1, 2850.00),
(516, 1013, 108, 1, 6499.00),
(517, 1014, 110, 1, 12500.00);

-- 8. PAYMENTS
INSERT INTO PAYMENTS (payment_id, order_id, payment_date, payment_method, payment_status, amount) VALUES
(201, 1001, '2024-01-12 11:05:00', 'Credit Card', 'Completed', 199900.00),
(202, 1002, '2024-01-20 15:32:00', 'Net Banking', 'Completed', 159890.00),
(203, 1003, '2024-02-05 10:22:00', 'UPI', 'Completed', 134900.00),
(204, 1004, '2024-02-14 18:02:00', 'UPI', 'Completed', 24900.00),
(205, 1005, '2024-03-01 12:18:00', 'Debit Card', 'Completed', 14500.00),
(206, 1006, '2024-03-10 14:48:00', 'Credit Card', 'Completed', 126498.00),
(207, 1007, '2024-03-25 16:15:00', 'UPI', 'Completed', 12500.00),
(208, 1009, '2024-04-15 17:55:00', 'Cash on Delivery', 'Completed', 10398.00),
(209, 1010, '2024-04-20 11:35:00', 'Wallet', 'Completed', 3899.00),
(210, 1011, '2024-05-02 13:05:00', 'Credit Card', 'Completed', 29990.00),
(211, 1012, '2024-05-06 19:22:00', 'UPI', 'Completed', 2850.00),
(212, 1013, '2024-05-09 10:10:00', 'Credit Card', 'Completed', 6499.00),
(213, 1014, '2024-05-10 14:05:00', 'Net Banking', 'Completed', 12500.00);

-- 9. SHIPMENTS
INSERT INTO SHIPMENTS (shipment_id, order_id, shipment_date, delivery_date, shipment_status) VALUES
(301, 1001, '2024-01-13 09:00:00', '2024-01-15 16:00:00', 'Delivered'),
(302, 1002, '2024-01-21 10:00:00', '2024-01-24 14:00:00', 'Delivered'),
(303, 1003, '2024-02-06 08:30:00', '2024-02-09 18:00:00', 'Delivered'),
(304, 1004, '2024-02-15 11:00:00', '2024-02-17 12:00:00', 'Delivered'),
(305, 1005, '2024-03-02 10:15:00', '2024-03-04 15:30:00', 'Delivered'),
(306, 1006, '2024-03-11 09:00:00', '2024-03-14 17:00:00', 'Delivered'),
(307, 1007, '2024-03-26 14:00:00', NULL, 'In Transit'),
(308, 1009, '2024-04-16 11:30:00', '2024-04-18 13:00:00', 'Delivered'),
(309, 1010, '2024-04-21 10:00:00', NULL, 'Active'),
(310, 1011, '2024-05-03 12:00:00', '2024-05-05 16:30:00', 'Delivered'),
(311, 1013, '2024-05-09 18:00:00', '2024-05-11 11:00:00', 'Delivered');

-- 10. REVIEWS
INSERT INTO REVIEWS (review_id, customer_id, product_id, rating, review_text) VALUES
(401, 1, 101, 5, 'Exceptional performance and stunning display. Best pro laptop!'),
(402, 2, 102, 4, 'Great build quality and display, fans get a bit loud under load.'),
(403, 3, 103, 5, 'Camera system is unbeatable, battery lasts all day.'),
(404, 1, 106, 5, 'ANC is top notch and fits comfortably in ears.'),
(405, 4, 107, 4, 'Heats evenly, very convenient pre-programmed options.'),
(406, 5, 104, 5, 'S-pen and anti-reflective screen are huge upgrades.'),
(407, 6, 110, 5, 'Pure silk and vibrant colors. Highly recommended for weddings.'),
(408, 2, 105, 4, 'Best noise cancelling headphones for travel.'),
(409, 8, 109, 3, 'Looks classy but sole is slightly stiff initially.'),
(410, 10, 108, 5, 'Crispy fries with 80% less oil! Very easy to clean.');

-- 11. WISHLIST
INSERT INTO WISHLIST (wishlist_id, customer_id, product_id) VALUES
(601, 1, 104),
(602, 2, 106),
(603, 3, 101),
(604, 4, 110),
(605, 5, 105),
(606, 6, 103),
(607, 7, 102);

-- 12. CART & CART_ITEMS
INSERT INTO CART (cart_id, customer_id) VALUES
(701, 1),
(702, 2),
(703, 3),
(704, 7),
(705, 11);

INSERT INTO CART_ITEMS (cart_item_id, cart_id, product_id, quantity) VALUES
(801, 701, 105, 1),
(802, 701, 115, 2),
(803, 702, 111, 1),
(804, 703, 108, 1),
(805, 704, 106, 1),
(806, 705, 101, 1);

-- 13. EMPLOYEES (Management Hierarchy)
-- 1 (CEO) -> 2, 3 (VPs) -> 4, 5 (Directors) -> 6, 7 (Managers) -> 8, 9, 10 (Engineers / Specialists)
INSERT INTO EMPLOYEES (employee_id, employee_name, manager_id, salary, designation) VALUES
(1, 'Vikramaditya Roy', NULL, 350000.00, 'Chief Executive Officer'),
(2, 'Shalini Menon', 1, 240000.00, 'VP of Engineering'),
(3, 'Rajesh Kaushik', 1, 220000.00, 'VP of Operations'),
(4, 'Deepak Shenoy', 2, 160000.00, 'Director of Software'),
(5, 'Meera Nair', 3, 150000.00, 'Director of Logistics'),
(6, 'Amit Bansal', 4, 110000.00, 'Engineering Manager'),
(7, 'Sunita Deshmukh', 5, 95000.00, 'Operations Manager'),
(8, 'Karan Taneja', 6, 75000.00, 'Senior Database Engineer'),
(9, 'Pooja Kulkarni', 6, 65000.00, 'Full Stack Developer'),
(10, 'Sameer Khan', 7, 50000.00, 'Logistics Lead');
