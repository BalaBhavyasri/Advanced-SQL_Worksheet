-- ==============================================================================
-- SECTION 13: TRANSACTION MANAGEMENT & ACID COMPLIANCE (Questions 91 - 95)
-- ==============================================================================

-- 91. Place an order with payment and shipment inside one transaction.
BEGIN;

-- Step 1: Create Order Header
INSERT INTO ORDERS (order_id, customer_id, order_date, order_status, total_amount)
VALUES (1020, 1, CURRENT_TIMESTAMP, 'Processing', 199900.00);

-- Step 2: Add Order Line Item
INSERT INTO ORDER_ITEMS (order_item_id, order_id, product_id, quantity, unit_price)
VALUES (520, 1020, 101, 1, 199900.00);

-- Step 3: Record Payment
INSERT INTO PAYMENTS (payment_id, order_id, payment_date, payment_method, payment_status, amount)
VALUES (220, 1020, CURRENT_TIMESTAMP, 'Credit Card', 'Completed', 199900.00);

-- Step 4: Dispatch Initial Shipment Record
INSERT INTO SHIPMENTS (shipment_id, order_id, shipment_date, delivery_date, shipment_status)
VALUES (320, 1020, CURRENT_TIMESTAMP, NULL, 'Active');

-- Step 5: Atomically Finalize
COMMIT;


-- 92. Rollback failed payment transaction.
BEGIN;

-- Step 1: Create Order Header
INSERT INTO ORDERS (order_id, customer_id, order_date, order_status, total_amount)
VALUES (1021, 2, CURRENT_TIMESTAMP, 'Pending', 145000.00);

-- Step 2: Attempt Payment via Gateway
INSERT INTO PAYMENTS (payment_id, order_id, payment_date, payment_method, payment_status, amount)
VALUES (221, 1021, CURRENT_TIMESTAMP, 'Credit Card', 'Failed', 145000.00);

-- Payment failure detected (e.g., Insufficient funds or gateway timeout)
-- Entire transaction is rolled back, leaving database untouched
ROLLBACK;


-- 93. Use SAVEPOINT during checkout process.
BEGIN;

-- Step 1: Initialize Order and Order Items
INSERT INTO ORDERS (order_id, customer_id, order_date, order_status, total_amount)
VALUES (1022, 3, CURRENT_TIMESTAMP, 'Pending', 24900.00);

INSERT INTO ORDER_ITEMS (order_item_id, order_id, product_id, quantity, unit_price)
VALUES (521, 1022, 106, 1, 24900.00);

-- Set intermediate checkpoint before payment attempt
SAVEPOINT before_payment;

-- Step 2: Attempt First Payment Method (UPI)
INSERT INTO PAYMENTS (payment_id, order_id, payment_date, payment_method, payment_status, amount)
VALUES (222, 1022, CURRENT_TIMESTAMP, 'UPI', 'Failed', 24900.00);

-- UPI Failed: Rollback only to checkpoint without losing order lines
ROLLBACK TO SAVEPOINT before_payment;

-- Step 3: Fallback to Alternative Payment Method (Credit Card)
INSERT INTO PAYMENTS (payment_id, order_id, payment_date, payment_method, payment_status, amount)
VALUES (223, 1022, CURRENT_TIMESTAMP, 'Credit Card', 'Completed', 24900.00);

-- Update order status to Completed
UPDATE ORDERS SET order_status = 'Completed' WHERE order_id = 1022;

COMMIT;


-- 94. Demonstrate COMMIT after successful order.
BEGIN;

-- Insert order
INSERT INTO ORDERS (order_id, customer_id, order_date, order_status, total_amount)
VALUES (1023, 4, CURRENT_TIMESTAMP, 'Completed', 14500.00);

-- Verify constraints & integrity checks
-- Persist permanently to durable WAL storage
COMMIT;


-- 95. Handle stock deduction transaction with concurrency check (Pessimistic Locking).
BEGIN;

-- Step 1: Lock the targeted product row against concurrent updates
SELECT stock_quantity 
FROM PRODUCTS 
WHERE product_id = 107 
FOR UPDATE;

-- Step 2: Ensure sufficient inventory exists, then deduct stock atomically
UPDATE PRODUCTS
SET stock_quantity = stock_quantity - 1
WHERE product_id = 107 AND stock_quantity >= 1;

-- Step 3: Record the order confirmation
INSERT INTO ORDERS (order_id, customer_id, order_date, order_status, total_amount)
VALUES (1024, 5, CURRENT_TIMESTAMP, 'Processing', 14500.00);

INSERT INTO ORDER_ITEMS (order_item_id, order_id, product_id, quantity, unit_price)
VALUES (522, 1024, 107, 1, 14500.00);

COMMIT;
