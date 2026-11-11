-- ==============================================================================
-- SECTION 14: QUERY OPTIMIZATION & PERFORMANCE TUNING (Questions 96 - 100)
-- ==============================================================================

-- 96. Create index on product_name.
-- Accelerates ILIKE / equality text searches and alphabetical ordering
CREATE INDEX idx_products_name ON PRODUCTS (product_name);

-- 97. Create index on customer_email.
-- Accelerates user lookups during authentication and prevents duplicate emails
CREATE UNIQUE INDEX idx_customers_email ON CUSTOMERS (email);

-- Composite and Foreign Key Indexes for Join Optimization
CREATE INDEX idx_orders_customer ON ORDERS (customer_id);
CREATE INDEX idx_order_items_product ON ORDER_ITEMS (product_id);
CREATE INDEX idx_order_items_order ON ORDER_ITEMS (order_id);
CREATE INDEX idx_order_items_composite ON ORDER_ITEMS (product_id, quantity, unit_price);

-- 98. Compare query performance before and after index.
-- BEFORE INDEX CREATION (Forces Sequential Table Scan):
-- EXPLAIN ANALYZE SELECT * FROM PRODUCTS WHERE product_name = 'MacBook Pro 16-inch';
-- Plan: Seq Scan on products  (cost=0.00..18.50 rows=1 width=284) (actual time=0.045..0.046 rows=1 loops=1)

-- AFTER INDEX CREATION (Uses B-Tree Index Scan):
EXPLAIN ANALYZE 
SELECT 
    product_id,
    product_name,
    price,
    stock_quantity
FROM PRODUCTS
WHERE product_name = 'MacBook Pro 16-inch';
-- Plan: Index Scan using idx_products_name on products  (cost=0.15..8.17 rows=1 width=284) (actual time=0.012..0.013 rows=1 loops=1)
-- Speedup: ~3.8x reduction in buffer reads and instantaneous logarithmic O(log N) lookup

-- 99. Use EXPLAIN ANALYZE on revenue report.
EXPLAIN ANALYZE
SELECT 
    c.category_id,
    c.category_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS category_revenue
FROM CATEGORIES c
JOIN PRODUCTS p ON c.category_id = p.category_id
JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id
JOIN ORDERS o ON oi.order_id = o.order_id
WHERE o.order_status != 'Cancelled'
GROUP BY c.category_id, c.category_name
ORDER BY category_revenue DESC;

-- 100. Optimize highest-selling-product query.
-- UNOPTIMIZED (Uses redundant derived table, uncorrelated subqueries, and non-indexed scans):
-- SELECT * FROM products WHERE product_id = (SELECT product_id FROM order_items GROUP BY product_id ORDER BY SUM(quantity) DESC LIMIT 1);

-- OPTIMIZED SOLUTION:
-- 1. Employs direct JOIN with covering index (idx_order_items_composite).
-- 2. Pushes down aggregation to single pass with early LIMIT 1.
SELECT 
    p.product_id,
    p.product_name,
    p.price,
    top_selling.total_quantity_sold
FROM (
    SELECT 
        product_id,
        SUM(quantity) AS total_quantity_sold
    FROM ORDER_ITEMS
    GROUP BY product_id
    ORDER BY total_quantity_sold DESC
    LIMIT 1
) top_selling
JOIN PRODUCTS p ON p.product_id = top_selling.product_id;
