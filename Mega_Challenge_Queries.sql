-- ==============================================================================
-- SECTION 15: MEGA CHALLENGE QUERIES (INTERVIEW LEVEL) (Questions 101 - 110)
-- Production Grade Analytical SQL with CTEs, Window Functions, and Advanced Joins
-- ==============================================================================

-- 101. Generate Amazon-style Sales Dashboard.
WITH SalesMetrics AS (
    SELECT 
        COUNT(DISTINCT o.order_id) AS total_orders,
        COUNT(DISTINCT o.customer_id) AS unique_purchasers,
        SUM(oi.quantity) AS total_units_sold,
        SUM(oi.quantity * oi.unit_price) AS gross_merchandise_value,
        ROUND(AVG(o.total_amount), 2) AS average_order_value
    FROM ORDERS o
    JOIN ORDER_ITEMS oi ON o.order_id = oi.order_id
    WHERE o.order_status != 'Cancelled'
),
FulfillmentMetrics AS (
    SELECT 
        COUNT(CASE WHEN order_status = 'Completed' OR order_status = 'Delivered' THEN 1 END) AS successful_orders,
        COUNT(CASE WHEN order_status = 'Cancelled' THEN 1 END) AS cancelled_orders,
        COUNT(CASE WHEN order_status IN ('Pending', 'Processing', 'Shipped') THEN 1 END) AS active_pipeline_orders
    FROM ORDERS
)
SELECT 
    sm.gross_merchandise_value,
    sm.total_orders,
    sm.unique_purchasers,
    sm.total_units_sold,
    sm.average_order_value,
    fm.successful_orders,
    fm.cancelled_orders,
    fm.active_pipeline_orders,
    ROUND((fm.successful_orders::DECIMAL / NULLIF(sm.total_orders, 0)) * 100, 2) AS fulfillment_success_rate_pct
FROM SalesMetrics sm
CROSS JOIN FulfillmentMetrics fm;


-- 102. Generate Top 10 Products Report.
WITH ProductSalesSummary AS (
    SELECT 
        p.product_id,
        p.product_name,
        c.category_name,
        s.supplier_name,
        p.price AS current_retail_price,
        p.stock_quantity AS current_stock,
        SUM(oi.quantity) AS total_units_sold,
        SUM(oi.quantity * oi.unit_price) AS product_gross_revenue
    FROM PRODUCTS p
    JOIN CATEGORIES c ON p.category_id = c.category_id
    JOIN SUPPLIERS s ON p.supplier_id = s.supplier_id
    JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id
    JOIN ORDERS o ON oi.order_id = o.order_id
    WHERE o.order_status != 'Cancelled'
    GROUP BY p.product_id, p.product_name, c.category_name, s.supplier_name, p.price, p.stock_quantity
)
SELECT 
    DENSE_RANK() OVER (ORDER BY product_gross_revenue DESC) AS rank,
    product_id,
    product_name,
    category_name,
    supplier_name,
    total_units_sold,
    product_gross_revenue,
    ROUND((product_gross_revenue / SUM(product_gross_revenue) OVER ()) * 100, 2) AS revenue_share_pct,
    current_stock
FROM ProductSalesSummary
ORDER BY rank ASC
LIMIT 10;


-- 103. Generate Customer Lifetime Value (CLV / LTV) Report.
WITH CustomerAggregates AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.email,
        c.registration_date,
        COUNT(o.order_id) AS total_orders,
        COALESCE(SUM(o.total_amount), 0.00) AS total_spent,
        ROUND(COALESCE(AVG(o.total_amount), 0.00), 2) AS avg_order_value,
        MIN(o.order_date) AS first_order_date,
        MAX(o.order_date) AS last_order_date
    FROM CUSTOMERS c
    LEFT JOIN ORDERS o ON c.customer_id = o.customer_id AND o.order_status != 'Cancelled'
    GROUP BY c.customer_id, c.customer_name, c.email, c.registration_date
)
SELECT 
    customer_id,
    customer_name,
    email,
    total_orders,
    total_spent,
    avg_order_value,
    first_order_date,
    last_order_date,
    EXTRACT(DAY FROM (COALESCE(last_order_date, registration_date) - registration_date)) AS tenure_days,
    DENSE_RANK() OVER (ORDER BY total_spent DESC) AS clv_rank,
    CASE 
        WHEN total_spent >= 150000 THEN 'Diamond Elite'
        WHEN total_spent >= 50000 THEN 'Gold Preferred'
        WHEN total_spent > 0 THEN 'Standard Active'
        ELSE 'Prospect / Lead'
    END AS customer_value_segment
FROM CustomerAggregates
ORDER BY total_spent DESC;


-- 104. Generate Product Recommendation Query (Market Basket Analysis: "Frequently Bought Together").
WITH PairedPurchases AS (
    SELECT 
        oi1.product_id AS base_product_id,
        oi2.product_id AS recommended_product_id,
        COUNT(*) AS frequency_bought_together
    FROM ORDER_ITEMS oi1
    JOIN ORDER_ITEMS oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
    JOIN ORDERS o ON oi1.order_id = o.order_id
    WHERE o.order_status != 'Cancelled'
    GROUP BY oi1.product_id, oi2.product_id
)
SELECT 
    p1.product_name AS base_product,
    p2.product_name AS recommended_cross_sell,
    pp.frequency_bought_together,
    DENSE_RANK() OVER (
        PARTITION BY pp.base_product_id 
        ORDER BY pp.frequency_bought_together DESC
    ) AS affinity_rank
FROM PairedPurchases pp
JOIN PRODUCTS p1 ON pp.base_product_id = p1.product_id
JOIN PRODUCTS p2 ON pp.recommended_product_id = p2.product_id
ORDER BY pp.frequency_bought_together DESC, base_product ASC;


-- 105. Generate Repeat Customer Analysis.
WITH CustomerOrderStats AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS orders_count,
        SUM(total_amount) AS customer_revenue
    FROM ORDERS
    WHERE order_status != 'Cancelled'
    GROUP BY customer_id
),
PurchaseIntervals AS (
    SELECT 
        customer_id,
        order_date,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date
    FROM ORDERS
    WHERE order_status != 'Cancelled'
),
MeanIntervals AS (
    SELECT 
        customer_id,
        ROUND(AVG(EXTRACT(EPOCH FROM (order_date - prev_order_date)) / 86400.0), 1) AS avg_days_between_purchases
    FROM PurchaseIntervals
    WHERE prev_order_date IS NOT NULL
    GROUP BY customer_id
)
SELECT 
    COUNT(c.customer_id) AS total_customers,
    COUNT(CASE WHEN cos.orders_count = 1 THEN 1 END) AS one_time_buyers,
    COUNT(CASE WHEN cos.orders_count > 1 THEN 1 END) AS repeat_buyers,
    ROUND((COUNT(CASE WHEN cos.orders_count > 1 THEN 1 END)::DECIMAL / NULLIF(COUNT(cos.customer_id), 0)) * 100, 2) AS repeat_buyer_rate_pct,
    ROUND(AVG(mi.avg_days_between_purchases), 1) AS platform_avg_reorder_cycle_days
FROM CUSTOMERS c
LEFT JOIN CustomerOrderStats cos ON c.customer_id = cos.customer_id
LEFT JOIN MeanIntervals mi ON c.customer_id = mi.customer_id;


-- 106. Generate Inventory Aging Report.
WITH ProductLastActivity AS (
    SELECT 
        p.product_id,
        p.product_name,
        c.category_name,
        p.price,
        p.stock_quantity,
        (p.price * p.stock_quantity) AS tied_up_capital,
        COALESCE(MAX(o.order_date), '2024-01-01 00:00:00') AS last_purchased_date
    FROM PRODUCTS p
    JOIN CATEGORIES c ON p.category_id = c.category_id
    LEFT JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id
    LEFT JOIN ORDERS o ON oi.order_id = o.order_id
    GROUP BY p.product_id, p.product_name, c.category_name, p.price, p.stock_quantity
)
SELECT 
    product_id,
    product_name,
    category_name,
    stock_quantity,
    tied_up_capital,
    last_purchased_date,
    ROUND(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - last_purchased_date)) / 86400.0, 0) AS days_since_last_sale,
    CASE 
        WHEN stock_quantity = 0 THEN 'Out of Stock'
        WHEN EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - last_purchased_date)) / 86400.0 <= 30 THEN 'Fast Moving (0-30 Days)'
        WHEN EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - last_purchased_date)) / 86400.0 <= 60 THEN 'Moderate (31-60 Days)'
        WHEN EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - last_purchased_date)) / 86400.0 <= 90 THEN 'Slow Moving (61-90 Days)'
        ELSE 'Dead Stock (> 90 Days)'
    END AS inventory_aging_category
FROM ProductLastActivity
ORDER BY tied_up_capital DESC;


-- 107. Generate Supplier Performance Dashboard.
WITH SupplierSales AS (
    SELECT 
        s.supplier_id,
        s.supplier_name,
        COUNT(DISTINCT p.product_id) AS total_skus,
        COALESCE(SUM(p.stock_quantity), 0) AS total_warehouse_stock,
        COALESCE(SUM(oi.quantity), 0) AS total_units_sold,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0.00) AS total_revenue_generated
    FROM SUPPLIERS s
    JOIN PRODUCTS p ON s.supplier_id = p.supplier_id
    LEFT JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id
    LEFT JOIN ORDERS o ON oi.order_id = o.order_id AND o.order_status != 'Cancelled'
    GROUP BY s.supplier_id, s.supplier_name
),
SupplierRatings AS (
    SELECT 
        p.supplier_id,
        ROUND(AVG(r.rating), 2) AS supplier_avg_rating,
        COUNT(r.review_id) AS total_reviews_count
    FROM PRODUCTS p
    JOIN REVIEWS r ON p.product_id = r.product_id
    GROUP BY p.supplier_id
)
SELECT 
    ss.supplier_id,
    ss.supplier_name,
    ss.total_skus,
    ss.total_warehouse_stock,
    ss.total_units_sold,
    ss.total_revenue_generated,
    COALESCE(sr.supplier_avg_rating, 0.00) AS avg_product_rating,
    COALESCE(sr.total_reviews_count, 0) AS review_volume,
    DENSE_RANK() OVER (ORDER BY ss.total_revenue_generated DESC) AS supplier_revenue_rank
FROM SupplierSales ss
LEFT JOIN SupplierRatings sr ON ss.supplier_id = sr.supplier_id
ORDER BY ss.total_revenue_generated DESC;


-- 108. Generate Monthly Growth Report (MoM Revenue & Order Growth %).
WITH MonthlyAggregates AS (
    SELECT 
        TO_CHAR(order_date, 'YYYY-MM') AS report_month,
        COUNT(order_id) AS total_orders,
        SUM(total_amount) AS current_month_revenue
    FROM ORDERS
    WHERE order_status != 'Cancelled'
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT 
    report_month,
    total_orders,
    current_month_revenue,
    LAG(current_month_revenue) OVER (ORDER BY report_month ASC) AS previous_month_revenue,
    ROUND(
        (current_month_revenue - LAG(current_month_revenue) OVER (ORDER BY report_month ASC)) 
        / NULLIF(LAG(current_month_revenue) OVER (ORDER BY report_month ASC), 0) * 100, 
        2
    ) AS mom_revenue_growth_pct,
    LAG(total_orders) OVER (ORDER BY report_month ASC) AS previous_month_orders,
    ROUND(
        (total_orders - LAG(total_orders) OVER (ORDER BY report_month ASC))::DECIMAL 
        / NULLIF(LAG(total_orders) OVER (ORDER BY report_month ASC), 0) * 100, 
        2
    ) AS mom_order_growth_pct
FROM MonthlyAggregates
ORDER BY report_month ASC;


-- 109. Generate Revenue Forecast Dataset Query (Moving Averages & Trend).
WITH MonthlyRevenueSeries AS (
    SELECT 
        TO_CHAR(order_date, 'YYYY-MM') AS sales_month,
        SUM(total_amount) AS actual_revenue
    FROM ORDERS
    WHERE order_status != 'Cancelled'
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT 
    sales_month,
    actual_revenue,
    ROUND(
        AVG(actual_revenue) OVER (
            ORDER BY sales_month ASC 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS three_month_moving_avg,
    ROUND(
        LAG(actual_revenue, 1) OVER (ORDER BY sales_month ASC) * 0.5 +
        LAG(actual_revenue, 2) OVER (ORDER BY sales_month ASC) * 0.3 +
        LAG(actual_revenue, 3) OVER (ORDER BY sales_month ASC) * 0.2, 
        2
    ) AS weighted_forecast_estimate
FROM MonthlyRevenueSeries
ORDER BY sales_month ASC;


-- 110. Generate Complete Business KPI Dashboard using CTEs + Window Functions + Joins.
WITH AllTimeFinancials AS (
    SELECT 
        COALESCE(SUM(total_amount), 0.00) AS all_time_gmv,
        COUNT(DISTINCT order_id) AS total_orders_all_time,
        ROUND(AVG(total_amount), 2) AS platform_aov
    FROM ORDERS
    WHERE order_status != 'Cancelled'
),
CustomerBaseStats AS (
    SELECT 
        COUNT(DISTINCT customer_id) AS total_registered_users,
        COUNT(DISTINCT CASE WHEN registration_date >= CURRENT_TIMESTAMP - INTERVAL '90' DAY THEN customer_id END) AS new_users_last_90d
    FROM CUSTOMERS
),
TopCategoryKPI AS (
    SELECT 
        c.category_name AS top_category_name,
        SUM(oi.quantity * oi.unit_price) AS top_category_sales,
        ROW_NUMBER() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS rnk
    FROM CATEGORIES c
    JOIN PRODUCTS p ON c.category_id = p.category_id
    JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id
    JOIN ORDERS o ON oi.order_id = o.order_id
    WHERE o.order_status != 'Cancelled'
    GROUP BY c.category_name
),
FulfillmentHealth AS (
    SELECT 
        ROUND((COUNT(CASE WHEN shipment_status = 'Delivered' THEN 1 END)::DECIMAL / NULLIF(COUNT(*), 0)) * 100, 2) AS on_time_delivery_rate_pct
    FROM SHIPMENTS
)
SELECT 
    atf.all_time_gmv,
    atf.total_orders_all_time,
    atf.platform_aov,
    cbs.total_registered_users,
    cbs.new_users_last_90d,
    tck.top_category_name,
    tck.top_category_sales,
    fh.on_time_delivery_rate_pct
FROM AllTimeFinancials atf
CROSS JOIN CustomerBaseStats cbs
CROSS JOIN (SELECT top_category_name, top_category_sales FROM TopCategoryKPI WHERE rnk = 1) tck
CROSS JOIN FulfillmentHealth fh;
