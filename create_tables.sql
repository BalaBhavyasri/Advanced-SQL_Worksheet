-- ==============================================================================
-- E-COMMERCE MANAGEMENT SYSTEM
-- Advanced SQL Database Schema (Relationships Heavy)
-- Compatible with PostgreSQL, MySQL 8.0+, SQLite 3.35+
-- ==============================================================================

-- Drop tables if they already exist (in reverse dependency order)
DROP TABLE IF EXISTS REVIEWS;
DROP TABLE IF EXISTS WISHLIST;
DROP TABLE IF EXISTS CART_ITEMS;
DROP TABLE IF EXISTS CART;
DROP TABLE IF EXISTS SHIPMENTS;
DROP TABLE IF EXISTS PAYMENTS;
DROP TABLE IF EXISTS ORDER_ITEMS;
DROP TABLE IF EXISTS ORDERS;
DROP TABLE IF EXISTS PRODUCTS;
DROP TABLE IF EXISTS SUPPLIERS;
DROP TABLE IF EXISTS CATEGORIES;
DROP TABLE IF EXISTS ADDRESSES;
DROP TABLE IF EXISTS CUSTOMERS;
DROP TABLE IF EXISTS EMPLOYEES;

-- 1. CUSTOMERS TABLE
CREATE TABLE CUSTOMERS (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    registration_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. ADDRESSES TABLE
CREATE TABLE ADDRESSES (
    address_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    address_type VARCHAR(20) NOT NULL CHECK (address_type IN ('Home', 'Office', 'Billing', 'Shipping')),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    pincode VARCHAR(20) NOT NULL,
    CONSTRAINT fk_addresses_customer FOREIGN KEY (customer_id) 
        REFERENCES CUSTOMERS(customer_id) ON DELETE CASCADE
);

-- 3. CATEGORIES TABLE (Self-referencing for Category Hierarchy)
CREATE TABLE CATEGORIES (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INT NULL,
    CONSTRAINT fk_categories_parent FOREIGN KEY (parent_category_id) 
        REFERENCES CATEGORIES(category_id) ON DELETE SET NULL
);

-- 4. SUPPLIERS TABLE
CREATE TABLE SUPPLIERS (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL
);

-- 5. PRODUCTS TABLE
CREATE TABLE PRODUCTS (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(12, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    category_id INT NOT NULL,
    supplier_id INT NOT NULL,
    CONSTRAINT fk_products_category FOREIGN KEY (category_id) 
        REFERENCES CATEGORIES(category_id) ON DELETE RESTRICT,
    CONSTRAINT fk_products_supplier FOREIGN KEY (supplier_id) 
        REFERENCES SUPPLIERS(supplier_id) ON DELETE RESTRICT
);

-- 6. ORDERS TABLE
CREATE TABLE ORDERS (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_status VARCHAR(30) NOT NULL CHECK (order_status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Completed')),
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) 
        REFERENCES CUSTOMERS(customer_id) ON DELETE CASCADE
);

-- 7. ORDER_ITEMS TABLE
CREATE TABLE ORDER_ITEMS (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(12, 2) NOT NULL CHECK (unit_price >= 0),
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) 
        REFERENCES ORDERS(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) 
        REFERENCES PRODUCTS(product_id) ON DELETE RESTRICT
);

-- 8. PAYMENTS TABLE
CREATE TABLE PAYMENTS (
    payment_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(30) NOT NULL CHECK (payment_method IN ('Credit Card', 'Debit Card', 'UPI', 'Net Banking', 'Cash on Delivery', 'Wallet')),
    payment_status VARCHAR(30) NOT NULL CHECK (payment_status IN ('Completed', 'Pending', 'Failed', 'Refunded')),
    amount DECIMAL(12, 2) NOT NULL CHECK (amount >= 0),
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id) 
        REFERENCES ORDERS(order_id) ON DELETE CASCADE
);

-- 9. SHIPMENTS TABLE
CREATE TABLE SHIPMENTS (
    shipment_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    shipment_date TIMESTAMP NULL,
    delivery_date TIMESTAMP NULL,
    shipment_status VARCHAR(30) NOT NULL CHECK (shipment_status IN ('Active', 'In Transit', 'Out for Delivery', 'Delivered', 'Failed', 'Returned')),
    CONSTRAINT fk_shipments_order FOREIGN KEY (order_id) 
        REFERENCES ORDERS(order_id) ON DELETE CASCADE
);

-- 10. REVIEWS TABLE
CREATE TABLE REVIEWS (
    review_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    CONSTRAINT fk_reviews_customer FOREIGN KEY (customer_id) 
        REFERENCES CUSTOMERS(customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_reviews_product FOREIGN KEY (product_id) 
        REFERENCES PRODUCTS(product_id) ON DELETE CASCADE
);

-- 11. WISHLIST TABLE
CREATE TABLE WISHLIST (
    wishlist_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    CONSTRAINT fk_wishlist_customer FOREIGN KEY (customer_id) 
        REFERENCES CUSTOMERS(customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_wishlist_product FOREIGN KEY (product_id) 
        REFERENCES PRODUCTS(product_id) ON DELETE CASCADE
);

-- 12. CART TABLE
CREATE TABLE CART (
    cart_id INT PRIMARY KEY,
    customer_id INT NOT NULL UNIQUE,
    CONSTRAINT fk_cart_customer FOREIGN KEY (customer_id) 
        REFERENCES CUSTOMERS(customer_id) ON DELETE CASCADE
);

-- 13. CART_ITEMS TABLE
CREATE TABLE CART_ITEMS (
    cart_item_id INT PRIMARY KEY,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    CONSTRAINT fk_cart_items_cart FOREIGN KEY (cart_id) 
        REFERENCES CART(cart_id) ON DELETE CASCADE,
    CONSTRAINT fk_cart_items_product FOREIGN KEY (product_id) 
        REFERENCES PRODUCTS(product_id) ON DELETE CASCADE
);

-- 14. EMPLOYEES TABLE (Self-referencing for Management Hierarchy)
CREATE TABLE EMPLOYEES (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    manager_id INT NULL,
    salary DECIMAL(12, 2) NOT NULL CHECK (salary >= 0),
    designation VARCHAR(100) NOT NULL,
    CONSTRAINT fk_employees_manager FOREIGN KEY (manager_id) 
        REFERENCES EMPLOYEES(employee_id) ON DELETE SET NULL
);
