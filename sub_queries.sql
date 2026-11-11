-- ==============================================================================
-- SECTION 8: SUBQUERIES (Questions 56 - 65)
-- ==============================================================================

-- 56. Find highest selling product (by total units sold).
SELECT 
    p.product_id,
    p.product_name,
    sales.total_units_sold
FROM PRODUCTS p
JOIN (
    SELECT product_id, SUM(quantity) AS total_units_sold
    FROM ORDER_ITEMS
    GROUP BY product_id
    ORDER BY total_units_sold DESC
    LIMIT 1
) sales ON p.product_id = sales.product_id;

-- 57. Find second highest selling product.
SELECT 
    p.product_id,
    p.product_name,
    sales.total_units_sold
FROM PRODUCTS p
JOIN (
    SELECT product_id, SUM(quantity) AS total_units_sold
    FROM ORDER_ITEMS
    GROUP BY product_id
    ORDER BY total_units_sold DESC
    LIMIT 1 OFFSET 1
) sales ON p.product_id = sales.product_id;

-- 58. Find third highest selling product.
SELECT 
    p.product_id,
    p.product_name,
    sales.total_units_sold
FROM PRODUCTS p
JOIN (
    SELECT product_id, SUM(quantity) AS total_units_sold
    FROM ORDER_ITEMS
    GROUP BY product_id
    ORDER BY total_units_sold DESC
    LIMIT 1 OFFSET 2
) sales ON p.product_id = sales.product_id;

-- 59. Find customer with highest spending.
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    spending.total_spent
FROM CUSTOMERS c
JOIN (
    SELECT customer_id, SUM(total_amount) AS total_spent
    FROM ORDERS
    WHERE order_status != 'Cancelled'
    GROUP BY customer_id
    ORDER BY total_spent DESC
    LIMIT 1
) spending ON c.customer_id = spending.customer_id;

-- 60. Find customers spending above average.
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(o.total_amount) AS customer_spending
FROM CUSTOMERS c
JOIN ORDERS o ON c.customer_id = o.customer_id
WHERE o.order_status != 'Cancelled'
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.total_amount) > (
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(total_amount) AS total_spent
        FROM ORDERS
        WHERE order_status != 'Cancelled'
        GROUP BY customer_id
    ) customer_totals
)
ORDER BY customer_spending DESC;

-- 61. Find products priced above average.
SELECT 
    product_id,
    product_name,
    price,
    ROUND((SELECT AVG(price) FROM PRODUCTS), 2) AS catalog_avg_price
FROM PRODUCTS
WHERE price > (SELECT AVG(price) FROM PRODUCTS)
ORDER BY price DESC;

-- 62. Find suppliers supplying highest number of products.
SELECT 
    s.supplier_id,
    s.supplier_name,
    supp_counts.product_count
FROM SUPPLIERS s
JOIN (
    SELECT supplier_id, COUNT(*) AS product_count
    FROM PRODUCTS
    GROUP BY supplier_id
    HAVING COUNT(*) = (
        SELECT MAX(cnt)
        FROM (SELECT COUNT(*) AS cnt FROM PRODUCTS GROUP BY supplier_id) sub
    )
) supp_counts ON s.supplier_id = supp_counts.supplier_id;

-- 63. Find category generating maximum revenue.
SELECT 
    c.category_id,
    c.category_name,
    cat_rev.total_revenue
FROM CATEGORIES c
JOIN (
    SELECT p.category_id, SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM PRODUCTS p
    JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id
    JOIN ORDERS o ON oi.order_id = o.order_id
    WHERE o.order_status != 'Cancelled'
    GROUP BY p.category_id
    ORDER BY total_revenue DESC
    LIMIT 1
) cat_rev ON c.category_id = cat_rev.category_id;

-- 64. Find customers who ordered every product in a category (Relational Division).
SELECT 
    c.customer_id,
    c.customer_name,
    cat.category_id,
    cat.category_name
FROM CUSTOMERS c
JOIN ORDERS o ON c.customer_id = o.customer_id
JOIN ORDER_ITEMS oi ON o.order_id = oi.order_id
JOIN PRODUCTS p ON oi.product_id = p.product_id
JOIN CATEGORIES cat ON p.category_id = cat.category_id
GROUP BY c.customer_id, c.customer_name, cat.category_id, cat.category_name
HAVING COUNT(DISTINCT p.product_id) = (
    SELECT COUNT(*) 
    FROM PRODUCTS p2 
    WHERE p2.category_id = cat.category_id
);

-- 65. Find products never purchased.
SELECT 
    product_id,
    product_name,
    price,
    stock_quantity
FROM PRODUCTS
WHERE product_id NOT IN (
    SELECT DISTINCT product_id 
    FROM ORDER_ITEMS
);
