-- ==============================================================================
-- SECTION 5: INNER JOINS (Questions 36 - 45)
-- ==============================================================================

-- 36. Display customer names with order details.
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    o.order_id,
    o.order_date,
    o.order_status,
    o.total_amount
FROM CUSTOMERS c
INNER JOIN ORDERS o ON c.customer_id = o.customer_id
ORDER BY o.order_date DESC;

-- 37. Display order details with products.
SELECT 
    o.order_id,
    o.order_date,
    p.product_id,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM ORDERS o
INNER JOIN ORDER_ITEMS oi ON o.order_id = oi.order_id
INNER JOIN PRODUCTS p ON oi.product_id = p.product_id
ORDER BY o.order_id ASC, oi.order_item_id ASC;

-- 38. Display product names with category names.
SELECT 
    p.product_id,
    p.product_name,
    p.price,
    c.category_id,
    c.category_name
FROM PRODUCTS p
INNER JOIN CATEGORIES c ON p.category_id = c.category_id
ORDER BY c.category_name ASC, p.product_name ASC;

-- 39. Display product names with supplier names.
SELECT 
    p.product_id,
    p.product_name,
    p.price,
    s.supplier_id,
    s.supplier_name,
    s.email AS supplier_email
FROM PRODUCTS p
INNER JOIN SUPPLIERS s ON p.supplier_id = s.supplier_id
ORDER BY s.supplier_name ASC, p.product_name ASC;

-- 40. Display reviews with customer names.
SELECT 
    r.review_id,
    p.product_name,
    c.customer_name,
    r.rating,
    r.review_text
FROM REVIEWS r
INNER JOIN CUSTOMERS c ON r.customer_id = c.customer_id
INNER JOIN PRODUCTS p ON r.product_id = p.product_id
ORDER BY r.rating DESC;

-- 41. Display payment details with customer names.
SELECT 
    py.payment_id,
    c.customer_name,
    c.email,
    py.order_id,
    py.payment_date,
    py.payment_method,
    py.payment_status,
    py.amount
FROM PAYMENTS py
INNER JOIN ORDERS o ON py.order_id = o.order_id
INNER JOIN CUSTOMERS c ON o.customer_id = c.customer_id
ORDER BY py.payment_date DESC;

-- 42. Display shipment details with order details.
SELECT 
    s.shipment_id,
    s.shipment_status,
    s.shipment_date,
    s.delivery_date,
    o.order_id,
    o.order_date,
    o.order_status,
    o.total_amount
FROM SHIPMENTS s
INNER JOIN ORDERS o ON s.order_id = o.order_id
ORDER BY s.shipment_date DESC;

-- 43. Display cart items with product names.
SELECT 
    ci.cart_item_id,
    cr.customer_id,
    c.customer_name,
    p.product_id,
    p.product_name,
    p.price AS unit_price,
    ci.quantity,
    (ci.quantity * p.price) AS subtotal
FROM CART_ITEMS ci
INNER JOIN CART cr ON ci.cart_id = cr.cart_id
INNER JOIN CUSTOMERS c ON cr.customer_id = c.customer_id
INNER JOIN PRODUCTS p ON ci.product_id = p.product_id
ORDER BY c.customer_id ASC;

-- 44. Display wishlist items with product names.
SELECT 
    w.wishlist_id,
    c.customer_id,
    c.customer_name,
    p.product_id,
    p.product_name,
    p.price,
    p.stock_quantity
FROM WISHLIST w
INNER JOIN CUSTOMERS c ON w.customer_id = c.customer_id
INNER JOIN PRODUCTS p ON w.product_id = p.product_id
ORDER BY c.customer_id ASC;

-- 45. Display customer addresses with customer names.
SELECT 
    a.address_id,
    c.customer_id,
    c.customer_name,
    a.address_type,
    a.city,
    a.state,
    a.pincode
FROM ADDRESSES a
INNER JOIN CUSTOMERS c ON a.customer_id = c.customer_id
ORDER BY c.customer_id ASC, a.address_type ASC;
