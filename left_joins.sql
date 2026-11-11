-- ==============================================================================
-- SECTION 6: LEFT JOINS / ANTI-JOINS (Questions 46 - 50)
-- ==============================================================================

-- 46. Find customers who never placed orders.
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    c.registration_date
FROM CUSTOMERS c
LEFT JOIN ORDERS o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 47. Find products never ordered.
SELECT 
    p.product_id,
    p.product_name,
    p.price,
    p.stock_quantity
FROM PRODUCTS p
LEFT JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;

-- 48. Find products with no reviews.
SELECT 
    p.product_id,
    p.product_name,
    p.price,
    p.stock_quantity
FROM PRODUCTS p
LEFT JOIN REVIEWS r ON p.product_id = r.product_id
WHERE r.review_id IS NULL;

-- 49. Find customers without addresses.
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    c.phone
FROM CUSTOMERS c
LEFT JOIN ADDRESSES a ON c.customer_id = a.customer_id
WHERE a.address_id IS NULL;

-- 50. Find orders without payments.
SELECT 
    o.order_id,
    o.customer_id,
    o.order_date,
    o.order_status,
    o.total_amount
FROM ORDERS o
LEFT JOIN PAYMENTS py ON o.order_id = py.order_id
WHERE py.payment_id IS NULL;
