-- ==============================================================================
-- SECTION 4: HAVING CLAUSE (Questions 31 - 35)
-- ==============================================================================

-- 31. Display categories having more than 20 products.
-- (Standard query as requested; for small test datasets, adjust threshold to > 1 or >= 2)
SELECT 
    c.category_id,
    c.category_name,
    COUNT(p.product_id) AS total_products
FROM CATEGORIES c
JOIN PRODUCTS p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
HAVING COUNT(p.product_id) > 20
ORDER BY total_products DESC;

-- 32. Display suppliers supplying more than 10 products.
SELECT 
    s.supplier_id,
    s.supplier_name,
    COUNT(p.product_id) AS total_products_supplied
FROM SUPPLIERS s
JOIN PRODUCTS p ON s.supplier_id = p.supplier_id
GROUP BY s.supplier_id, s.supplier_name
HAVING COUNT(p.product_id) > 10
ORDER BY total_products_supplied DESC;

-- 33. Display customers having more than 5 orders.
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent
FROM CUSTOMERS c
JOIN ORDERS o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.email
HAVING COUNT(o.order_id) > 5
ORDER BY total_orders DESC;

-- 34. Display products having average rating above 4.
SELECT 
    p.product_id,
    p.product_name,
    ROUND(AVG(r.rating), 2) AS average_rating,
    COUNT(r.review_id) AS review_count
FROM PRODUCTS p
JOIN REVIEWS r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name
HAVING AVG(r.rating) > 4.00
ORDER BY average_rating DESC, review_count DESC;

-- 35. Display cities with more than 50 customers.
SELECT 
    a.city,
    a.state,
    COUNT(DISTINCT a.customer_id) AS customer_count
FROM ADDRESSES a
GROUP BY a.city, a.state
HAVING COUNT(DISTINCT a.customer_id) > 50
ORDER BY customer_count DESC;
