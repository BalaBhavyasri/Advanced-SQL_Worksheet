-- ==============================================================================
-- SECTION 9: CORRELATED SUBQUERIES (Questions 66 - 70)
-- ==============================================================================

-- 66. Find products costing above category average.
SELECT 
    p1.product_id,
    p1.product_name,
    p1.category_id,
    p1.price,
    ROUND((
        SELECT AVG(p2.price) 
        FROM PRODUCTS p2 
        WHERE p2.category_id = p1.category_id
    ), 2) AS category_avg_price
FROM PRODUCTS p1
WHERE p1.price > (
    SELECT AVG(p2.price) 
    FROM PRODUCTS p2 
    WHERE p2.category_id = p1.category_id
)
ORDER BY p1.category_id, p1.price DESC;

-- 67. Find customers spending above city average.
WITH CustomerSpending AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        a.city,
        COALESCE(SUM(o.total_amount), 0.00) AS total_spent
    FROM CUSTOMERS c
    JOIN ADDRESSES a ON c.customer_id = a.customer_id
    LEFT JOIN ORDERS o ON c.customer_id = o.customer_id AND o.order_status != 'Cancelled'
    GROUP BY c.customer_id, c.customer_name, a.city
)
SELECT 
    cs1.customer_id,
    cs1.customer_name,
    cs1.city,
    cs1.total_spent,
    ROUND((
        SELECT AVG(cs2.total_spent)
        FROM CustomerSpending cs2
        WHERE cs2.city = cs1.city
    ), 2) AS city_avg_spent
FROM CustomerSpending cs1
WHERE cs1.total_spent > (
    SELECT AVG(cs2.total_spent)
    FROM CustomerSpending cs2
    WHERE cs2.city = cs1.city
)
ORDER BY cs1.city, cs1.total_spent DESC;

-- 68. Find suppliers with revenue above supplier average.
WITH SupplierRevenue AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS supplier_rev
    FROM SUPPLIERS s
    JOIN PRODUCTS p ON s.supplier_id = p.supplier_id
    JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id
    JOIN ORDERS o ON oi.order_id = o.order_id
    WHERE o.order_status != 'Cancelled'
    GROUP BY s.supplier_id, s.supplier_name
)
SELECT 
    sr1.supplier_id,
    sr1.supplier_name,
    sr1.supplier_rev,
    ROUND((SELECT AVG(sr2.supplier_rev) FROM SupplierRevenue sr2), 2) AS avg_supplier_revenue
FROM SupplierRevenue sr1
WHERE sr1.supplier_rev > (
    SELECT AVG(sr2.supplier_rev)
    FROM SupplierRevenue sr2
)
ORDER BY sr1.supplier_rev DESC;

-- 69. Find orders larger than customer average.
SELECT 
    o1.order_id,
    o1.customer_id,
    o1.order_date,
    o1.total_amount,
    ROUND((
        SELECT AVG(o2.total_amount)
        FROM ORDERS o2
        WHERE o2.customer_id = o1.customer_id
          AND o2.order_status != 'Cancelled'
    ), 2) AS customer_avg_order_amount
FROM ORDERS o1
WHERE o1.order_status != 'Cancelled'
  AND o1.total_amount > (
      SELECT AVG(o2.total_amount)
      FROM ORDERS o2
      WHERE o2.customer_id = o1.customer_id
        AND o2.order_status != 'Cancelled'
  )
ORDER BY o1.customer_id, o1.total_amount DESC;

-- 70. Find products with reviews above product average.
SELECT 
    p.product_id,
    p.product_name,
    ROUND(AVG(r.rating), 2) AS product_avg_rating,
    ROUND((SELECT AVG(rating) FROM REVIEWS), 2) AS global_avg_rating
FROM PRODUCTS p
JOIN REVIEWS r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name
HAVING AVG(r.rating) > (
    SELECT AVG(rating) 
    FROM REVIEWS
)
ORDER BY product_avg_rating DESC;
