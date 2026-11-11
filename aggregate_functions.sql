-- ==============================================================================
-- SECTION 2: AGGREGATE FUNCTIONS (Questions 11 - 20)
-- ==============================================================================

-- 11. Find total customers.
SELECT COUNT(*) AS total_customers 
FROM CUSTOMERS;

-- 12. Find total products.
SELECT COUNT(*) AS total_products 
FROM PRODUCTS;

-- 13. Find average product price.
SELECT ROUND(AVG(price), 2) AS average_product_price 
FROM PRODUCTS;

-- 14. Find highest priced product.
SELECT 
    MAX(price) AS highest_product_price,
    (SELECT product_name FROM PRODUCTS WHERE price = (SELECT MAX(price) FROM PRODUCTS) LIMIT 1) AS highest_product_name
FROM PRODUCTS;

-- 15. Find lowest priced product.
SELECT 
    MIN(price) AS lowest_product_price,
    (SELECT product_name FROM PRODUCTS WHERE price = (SELECT MIN(price) FROM PRODUCTS) LIMIT 1) AS lowest_product_name
FROM PRODUCTS;

-- 16. Find total revenue generated.
-- Revenue from all non-cancelled orders
SELECT COALESCE(SUM(total_amount), 0.00) AS total_revenue_generated 
FROM ORDERS
WHERE order_status != 'Cancelled';

-- 17. Find total orders placed.
SELECT COUNT(*) AS total_orders_placed 
FROM ORDERS;

-- 18. Find total stock available across all warehouse inventory.
SELECT SUM(stock_quantity) AS total_stock_available 
FROM PRODUCTS;

-- 19. Find average order value (AOV).
SELECT ROUND(AVG(total_amount), 2) AS average_order_value 
FROM ORDERS
WHERE order_status != 'Cancelled';

-- 20. Find total payment received.
-- Total payments that have successfully completed
SELECT COALESCE(SUM(amount), 0.00) AS total_payment_received 
FROM PAYMENTS
WHERE payment_status = 'Completed';
