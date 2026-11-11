-- ==============================================================================
-- SECTION 10: WINDOW FUNCTIONS (Questions 71 - 80)
-- ==============================================================================

-- 71. Rank products by revenue.
SELECT 
    p.product_id,
    p.product_name,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_revenue,
    DENSE_RANK() OVER (ORDER BY COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) DESC) AS revenue_rank
FROM PRODUCTS p
LEFT JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id
LEFT JOIN ORDERS o ON oi.order_id = o.order_id AND o.order_status != 'Cancelled'
GROUP BY p.product_id, p.product_name
ORDER BY revenue_rank ASC;

-- 72. Rank customers by spending.
SELECT 
    c.customer_id,
    c.customer_name,
    COALESCE(SUM(o.total_amount), 0.00) AS total_spent,
    DENSE_RANK() OVER (ORDER BY COALESCE(SUM(o.total_amount), 0.00) DESC) AS spending_rank
FROM CUSTOMERS c
LEFT JOIN ORDERS o ON c.customer_id = o.customer_id AND o.order_status != 'Cancelled'
GROUP BY c.customer_id, c.customer_name
ORDER BY spending_rank ASC;

-- 73. Rank suppliers by sales.
SELECT 
    s.supplier_id,
    s.supplier_name,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_sales,
    DENSE_RANK() OVER (ORDER BY COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) DESC) AS sales_rank
FROM SUPPLIERS s
LEFT JOIN PRODUCTS p ON s.supplier_id = p.supplier_id
LEFT JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id
LEFT JOIN ORDERS o ON oi.order_id = o.order_id AND o.order_status != 'Cancelled'
GROUP BY s.supplier_id, s.supplier_name
ORDER BY sales_rank ASC;

-- 74. Find top 3 products per category.
WITH RankedProducts AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category_id,
        c.category_name,
        p.price,
        ROW_NUMBER() OVER (
            PARTITION BY p.category_id 
            ORDER BY p.price DESC
        ) AS rank_in_cat
    FROM PRODUCTS p
    JOIN CATEGORIES c ON p.category_id = c.category_id
)
SELECT 
    category_id,
    category_name,
    product_id,
    product_name,
    price,
    rank_in_cat
FROM RankedProducts
WHERE rank_in_cat <= 3
ORDER BY category_id, rank_in_cat;

-- 75. Find top 5 customers per city.
WITH CityCustomerSpend AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        a.city,
        COALESCE(SUM(o.total_amount), 0.00) AS total_spent,
        ROW_NUMBER() OVER (
            PARTITION BY a.city 
            ORDER BY COALESCE(SUM(o.total_amount), 0.00) DESC
        ) AS rank_in_city
    FROM CUSTOMERS c
    JOIN ADDRESSES a ON c.customer_id = a.customer_id
    LEFT JOIN ORDERS o ON c.customer_id = o.customer_id AND o.order_status != 'Cancelled'
    GROUP BY c.customer_id, c.customer_name, a.city
)
SELECT 
    city,
    rank_in_city,
    customer_id,
    customer_name,
    total_spent
FROM CityCustomerSpend
WHERE rank_in_city <= 5
ORDER BY city, rank_in_city;

-- 76. Find running total revenue.
SELECT 
    order_id,
    customer_id,
    order_date,
    total_amount,
    SUM(total_amount) OVER (
        ORDER BY order_date ASC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_revenue
FROM ORDERS
WHERE order_status != 'Cancelled'
ORDER BY order_date ASC;

-- 77. Find cumulative monthly sales.
WITH MonthlyTotals AS (
    SELECT 
        TO_CHAR(order_date, 'YYYY-MM') AS sales_month,
        SUM(total_amount) AS month_sales
    FROM ORDERS
    WHERE order_status != 'Cancelled'
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT 
    sales_month,
    month_sales,
    SUM(month_sales) OVER (
        ORDER BY sales_month ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_sales
FROM MonthlyTotals
ORDER BY sales_month ASC;

-- 78. Find highest order per customer.
WITH RankedOrders AS (
    SELECT 
        order_id,
        customer_id,
        order_date,
        total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY total_amount DESC, order_date DESC
        ) AS rank_order
    FROM ORDERS
    WHERE order_status != 'Cancelled'
)
SELECT 
    r.customer_id,
    c.customer_name,
    r.order_id,
    r.total_amount AS highest_order_amount,
    r.order_date
FROM RankedOrders r
JOIN CUSTOMERS c ON r.customer_id = c.customer_id
WHERE r.rank_order = 1
ORDER BY r.highest_order_amount DESC;

-- 79. Find latest order per customer.
WITH LatestOrders AS (
    SELECT 
        order_id,
        customer_id,
        order_date,
        order_status,
        total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY order_date DESC
        ) AS recency_rank
    FROM ORDERS
)
SELECT 
    lo.customer_id,
    c.customer_name,
    lo.order_id,
    lo.order_date AS latest_order_date,
    lo.order_status,
    lo.total_amount
FROM LatestOrders lo
JOIN CUSTOMERS c ON lo.customer_id = c.customer_id
WHERE lo.recency_rank = 1
ORDER BY lo.order_date DESC;

-- 80. Find top-rated product in each category.
WITH RankedRatings AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category_id,
        c.category_name,
        ROUND(AVG(r.rating), 2) AS avg_rating,
        COUNT(r.review_id) AS total_reviews,
        ROW_NUMBER() OVER (
            PARTITION BY p.category_id 
            ORDER BY AVG(r.rating) DESC, COUNT(r.review_id) DESC
        ) AS rating_rank
    FROM PRODUCTS p
    JOIN CATEGORIES c ON p.category_id = c.category_id
    JOIN REVIEWS r ON p.product_id = r.product_id
    GROUP BY p.product_id, p.product_name, p.category_id, c.category_name
)
SELECT 
    category_id,
    category_name,
    product_id,
    product_name,
    avg_rating,
    total_reviews
FROM RankedRatings
WHERE rating_rank = 1
ORDER BY category_id ASC;
