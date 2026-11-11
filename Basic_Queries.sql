-- ==============================================================================
-- SECTION 1: BASIC QUERIES (Questions 1 - 10)
-- ==============================================================================

-- 1. Display all customers.
SELECT 
    customer_id,
    customer_name,
    email,
    phone,
    registration_date
FROM CUSTOMERS;

-- 2. Display all products costing above ₹5000.
SELECT 
    product_id,
    product_name,
    price,
    stock_quantity
FROM PRODUCTS
WHERE price > 5000.00
ORDER BY price ASC;

-- 3. Display products with stock less than 10.
SELECT 
    product_id,
    product_name,
    stock_quantity,
    price
FROM PRODUCTS
WHERE stock_quantity < 10
ORDER BY stock_quantity ASC;

-- 4. Display all suppliers.
SELECT 
    supplier_id,
    supplier_name,
    email,
    phone
FROM SUPPLIERS;

-- 5. Display all completed orders.
SELECT 
    order_id,
    customer_id,
    order_date,
    order_status,
    total_amount
FROM ORDERS
WHERE order_status = 'Completed'
ORDER BY order_date DESC;

-- 6. Display orders placed this month.
-- Compatible with PostgreSQL (CURRENT_DATE) & MySQL (CURDATE() / NOW())
SELECT 
    order_id,
    customer_id,
    order_date,
    order_status,
    total_amount
FROM ORDERS
WHERE EXTRACT(YEAR FROM order_date) = EXTRACT(YEAR FROM CURRENT_TIMESTAMP)
  AND EXTRACT(MONTH FROM order_date) = EXTRACT(MONTH FROM CURRENT_TIMESTAMP);

-- 7. Display customers registered in the last 30 days.
SELECT 
    customer_id,
    customer_name,
    email,
    phone,
    registration_date
FROM CUSTOMERS
WHERE registration_date >= CURRENT_TIMESTAMP - INTERVAL '30' DAY;

-- 8. Display products sorted by price descending.
SELECT 
    product_id,
    product_name,
    price,
    stock_quantity
FROM PRODUCTS
ORDER BY price DESC;

-- 9. Display top 10 expensive products.
SELECT 
    product_id,
    product_name,
    price,
    stock_quantity
FROM PRODUCTS
ORDER BY price DESC
LIMIT 10;

-- 10. Display all active shipments.
SELECT 
    shipment_id,
    order_id,
    shipment_date,
    delivery_date,
    shipment_status
FROM SHIPMENTS
WHERE shipment_status IN ('Active', 'In Transit', 'Out for Delivery')
ORDER BY shipment_date DESC;
