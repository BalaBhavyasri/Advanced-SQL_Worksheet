-- ==============================================================================
-- SECTION 11: COMMON TABLE EXPRESSIONS (CTEs) (Questions 81 - 85)
-- ==============================================================================

-- 81. Find category-wise revenue using CTE.
WITH CategoryRevenueCTE AS (
    SELECT 
        c.category_id,
        c.category_name,
        oi.quantity * oi.unit_price AS item_revenue
    FROM CATEGORIES c
    JOIN PRODUCTS p ON c.category_id = p.category_id
    JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id
    JOIN ORDERS o ON oi.order_id = o.order_id
    WHERE o.order_status != 'Cancelled'
)
SELECT 
    category_id,
    category_name,
    SUM(item_revenue) AS total_revenue,
    ROUND(AVG(item_revenue), 2) AS avg_item_sale
FROM CategoryRevenueCTE
GROUP BY category_id, category_name
ORDER BY total_revenue DESC;

-- 82. Find customer spending summary using CTE.
WITH CustomerSummaryCTE AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.email,
        COUNT(o.order_id) AS order_count,
        COALESCE(SUM(o.total_amount), 0.00) AS total_spending,
        COALESCE(AVG(o.total_amount), 0.00) AS avg_spending
    FROM CUSTOMERS c
    LEFT JOIN ORDERS o ON c.customer_id = o.customer_id AND o.order_status != 'Cancelled'
    GROUP BY c.customer_id, c.customer_name, c.email
)
SELECT 
    customer_id,
    customer_name,
    email,
    order_count,
    ROUND(total_spending, 2) AS total_spending,
    ROUND(avg_spending, 2) AS avg_order_value,
    CASE 
        WHEN total_spending >= 100000 THEN 'Platinum VIP'
        WHEN total_spending >= 25000 THEN 'Gold Member'
        WHEN total_spending > 0 THEN 'Silver Member'
        ELSE 'Inactive'
    END AS customer_tier
FROM CustomerSummaryCTE
ORDER BY total_spending DESC;

-- 83. Find top 10 customers using CTE.
WITH RankedCustomerCTE AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.email,
        SUM(o.total_amount) AS total_spent,
        DENSE_RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS rank_pos
    FROM CUSTOMERS c
    JOIN ORDERS o ON c.customer_id = o.customer_id
    WHERE o.order_status != 'Cancelled'
    GROUP BY c.customer_id, c.customer_name, c.email
)
SELECT 
    rank_pos,
    customer_id,
    customer_name,
    email,
    total_spent
FROM RankedCustomerCTE
WHERE rank_pos <= 10
ORDER BY rank_pos ASC;

-- 84. Find top products using CTE.
WITH ProductPerformanceCTE AS (
    SELECT 
        p.product_id,
        p.product_name,
        c.category_name,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS product_gross_revenue
    FROM PRODUCTS p
    JOIN CATEGORIES c ON p.category_id = c.category_id
    JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id
    JOIN ORDERS o ON oi.order_id = o.order_id
    WHERE o.order_status != 'Cancelled'
    GROUP BY p.product_id, p.product_name, c.category_name
)
SELECT 
    product_id,
    product_name,
    category_name,
    units_sold,
    product_gross_revenue,
    DENSE_RANK() OVER (ORDER BY product_gross_revenue DESC) AS sales_rank
FROM ProductPerformanceCTE
ORDER BY product_gross_revenue DESC;

-- 85. Find supplier performance report using CTE.
WITH SupplierMetricsCTE AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(DISTINCT p.product_id) AS catalog_skus,
        COALESCE(SUM(oi.quantity), 0) AS total_units_shipped,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_supplier_revenue
    FROM SUPPLIERS s
    LEFT JOIN PRODUCTS p ON s.supplier_id = p.supplier_id
    LEFT JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id
    LEFT JOIN ORDERS o ON oi.order_id = o.order_id AND o.order_status != 'Cancelled'
    GROUP BY s.supplier_id, s.supplier_name
)
SELECT 
    supplier_id,
    supplier_name,
    catalog_skus,
    total_units_shipped,
    total_supplier_revenue,
    ROUND(total_supplier_revenue / NULLIF(total_units_shipped, 0), 2) AS avg_unit_selling_price
FROM SupplierMetricsCTE
ORDER BY total_supplier_revenue DESC;
