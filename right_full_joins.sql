-- ==============================================================================
-- SECTION 7: RIGHT AND FULL OUTER JOINS (Questions 51 - 55)
-- ==============================================================================

-- 51. Find all products and corresponding reviews.
-- (FULL OUTER JOIN ensures products without reviews AND reviews without products are included)
SELECT 
    p.product_id,
    p.product_name,
    p.price,
    r.review_id,
    r.rating,
    r.review_text
FROM PRODUCTS p
FULL OUTER JOIN REVIEWS r ON p.product_id = r.product_id
ORDER BY p.product_id ASC;

-- 52. Find all customers and their orders.
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    o.order_id,
    o.order_date,
    o.order_status,
    o.total_amount
FROM CUSTOMERS c
FULL OUTER JOIN ORDERS o ON c.customer_id = o.customer_id
ORDER BY c.customer_id ASC, o.order_date DESC;

-- 53. Find all suppliers and products.
-- Demonstrating RIGHT JOIN: keeps all products even if supplier mapping is unassigned
SELECT 
    s.supplier_id,
    s.supplier_name,
    s.email AS supplier_email,
    p.product_id,
    p.product_name,
    p.price,
    p.stock_quantity
FROM SUPPLIERS s
RIGHT JOIN PRODUCTS p ON s.supplier_id = p.supplier_id
ORDER BY s.supplier_id ASC, p.product_name ASC;

-- 54. Find all categories and products.
SELECT 
    c.category_id,
    c.category_name,
    p.product_id,
    p.product_name,
    p.price
FROM CATEGORIES c
FULL OUTER JOIN PRODUCTS p ON c.category_id = p.category_id
ORDER BY c.category_id ASC, p.product_name ASC;

-- 55. Find all orders and shipments.
SELECT 
    o.order_id,
    o.order_date,
    o.order_status,
    o.total_amount,
    s.shipment_id,
    s.shipment_status,
    s.shipment_date,
    s.delivery_date
FROM ORDERS o
FULL OUTER JOIN SHIPMENTS s ON o.order_id = s.order_id
ORDER BY o.order_id ASC;
