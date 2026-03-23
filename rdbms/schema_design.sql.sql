DROP DATABASE IF EXISTS assignment_db;
CREATE DATABASE assignment_db;
USE assignment_db;
-- 1. Customers Table (FIRST)
CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL
);

-- 2. Products Table
CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price INT NOT NULL
);

-- 3. Orders Table
CREATE TABLE orders (
    order_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 4. Order Items Table
CREATE TABLE order_items (
    order_id VARCHAR(10),
    product_id VARCHAR(10),
    quantity INT NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
INSERT INTO customers (customer_id, customer_name, city)
SELECT DISTINCT 
    customer_id,
    customer_name,
    customer_city
FROM orders_flat;
INSERT INTO products (product_id, product_name, price)
SELECT DISTINCT 
    product_id,
    product_name,
    unit_price
FROM orders_flat;
INSERT INTO orders (order_id, customer_id, order_date)
SELECT DISTINCT 
    order_id,
    customer_id,
    STR_TO_DATE(order_date, '%Y-%m-%d')
FROM orders_flat;
INSERT INTO order_items (order_id, product_id, quantity)
SELECT 
    order_id,
    product_id,
    quantity
FROM orders_flat;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
