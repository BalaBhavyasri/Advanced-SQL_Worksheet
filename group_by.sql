-- ==============================================================================
-- SECTION 3: GROUP BY (Questions 21 - 30)
-- ==============================================================================

-- 21. Find number of products category-wise.
SELECT 
    c.category_id,
    c.category_name,
    COUNT(p.product_id) AS total_products
FROM CATEGORIES c
LEFT JOIN PRODUCTS p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_products DESC;

-- 22. Find total sales category-wise.
SELECT 
    c.category_id,
    c.category_name,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_sales
FROM CATEGORIES c
JOIN PRODUCTS p ON c.category_id = p.category_id
JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id
JOIN ORDERS o ON oi.order_id = o.order_id
WHERE o.order_status != 'Cancelled'
GROUP BY c.category_id, c.category_name
ORDER BY total_sales DESC;

-- 23. Find total revenue supplier-wise.
SELECT 
    s.supplier_id,
    s.supplier_name,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_revenue
FROM SUPPLIERS s
JOIN PRODUCTS p ON s.supplier_id = p.supplier_id
JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id
JOIN ORDERS o ON oi.order_id = o.order_id
WHERE o.order_status != 'Cancelled'
GROUP BY s.supplier_id, s.supplier_name
ORDER BY total_revenue DESC;

-- 24. Find customer count city-wise.
SELECT 
    a.city,
    COUNT(DISTINCT a.customer_id) AS total_customers
FROM ADDRESSES a
GROUP BY a.city
ORDER BY total_customers DESC, a.city ASC;

-- 25. Find order count status-wise.
SELECT 
    order_status,
    COUNT(*) AS total_orders,
    ROUND(SUM(total_amount), 2) AS status_revenue
FROM ORDERS
GROUP BY order_status
ORDER BY total_orders DESC;

-- 26. Find average rating product-wise.
SELECT 
    p.product_id,
    p.product_name,
    ROUND(AVG(r.rating), 2) AS average_rating,
    COUNT(r.review_id) AS total_reviews
FROM PRODUCTS p
JOIN REVIEWS r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name
ORDER BY average_rating DESC, total_reviews DESC;

-- 27. Find total products supplier-wise.
SELECT 
    s.supplier_id,
    s.supplier_name,
    COUNT(p.product_id) AS total_products_supplied
FROM SUPPLIERS s
LEFT JOIN PRODUCTS p ON s.supplier_id = p.supplier_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY total_products_supplied DESC;

-- 28. Find shipment count status-wise.
SELECT 
    shipment_status,
    COUNT(*) AS shipment_count
FROM SHIPMENTS
GROUP BY shipment_status
ORDER BY shipment_count DESC;

-- 29. Find total payments method-wise.
SELECT 
    payment_method,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount_received
FROM PAYMENTS
WHERE payment_status = 'Completed'
GROUP BY payment_method
ORDER BY total_amount_received DESC;

-- 30. Find monthly sales report.
SELECT 
    TO_CHAR(order_date, 'YYYY-MM') AS sales_month,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS monthly_revenue,
    ROUND(AVG(total_amount), 2) AS average_order_value
FROM ORDERS
WHERE order_status != 'Cancelled'
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY sales_month ASC;
