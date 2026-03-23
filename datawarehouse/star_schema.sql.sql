USE dw_assignment;
-- =========================================
-- STEP 0: CHECK DATA
-- =========================================
SELECT * FROM retail_transactions LIMIT 5;

-- =========================================
-- STEP 1: DROP TABLES
-- =========================================
DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_store;
DROP TABLE IF EXISTS dim_product;

-- =========================================
-- STEP 2: CREATE DIMENSIONS
-- =========================================

-- 🔹 DATE DIMENSION (SAFE - NO ERRORS)
CREATE TABLE dim_date (
    date_id INT AUTO_INCREMENT PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    day INT
);

INSERT INTO dim_date (full_date, year, month, day)
SELECT DISTINCT
    parsed_date,
    YEAR(parsed_date),
    MONTH(parsed_date),
    DAY(parsed_date)
FROM (
    SELECT 
        STR_TO_DATE(REPLACE(date, '/', '-'), '%d-%m-%Y') AS parsed_date
    FROM retail_transactions
) t
WHERE parsed_date IS NOT NULL;


-- 🔹 STORE DIMENSION
CREATE TABLE dim_store (
    store_id INT AUTO_INCREMENT PRIMARY KEY,
    store_name VARCHAR(100),
    store_city VARCHAR(100)
);

INSERT INTO dim_store (store_name, store_city)
SELECT DISTINCT
    store_name,
    store_city
FROM retail_transactions;


-- 🔹 PRODUCT DIMENSION
CREATE TABLE dim_product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50)
);

INSERT INTO dim_product (product_name, category)
SELECT DISTINCT
    product_name,
    UPPER(category)
FROM retail_transactions;


-- =========================================
-- STEP 3: FACT TABLE
-- =========================================

CREATE TABLE fact_sales (
    sales_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(20),
    date_id INT,
    store_id INT,
    product_id INT,
    units_sold INT,
    unit_price DECIMAL(10,2),
    total_revenue DECIMAL(12,2),

    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (store_id) REFERENCES dim_store(store_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);

-- =========================================
-- STEP 4: LOAD FACT TABLE (SAFE ETL)
-- =========================================

INSERT INTO fact_sales (
    transaction_id,
    date_id,
    store_id,
    product_id,
    units_sold,
    unit_price,
    total_revenue
)

SELECT 
    r.transaction_id,
    d.date_id,
    s.store_id,
    p.product_id,

    COALESCE(r.units_sold, 0),
    COALESCE(r.unit_price, 0),

    COALESCE(r.units_sold, 0) * COALESCE(r.unit_price, 0)

FROM retail_transactions r

JOIN (
    SELECT 
        date,
        STR_TO_DATE(REPLACE(date, '/', '-'), '%d-%m-%Y') AS parsed_date
    FROM retail_transactions
) dt
ON r.date = dt.date

JOIN dim_date d 
ON dt.parsed_date = d.full_date

JOIN dim_store s 
ON r.store_name = s.store_name
AND r.store_city = s.store_city

JOIN dim_product p 
ON r.product_name = p.product_name
AND UPPER(r.category) = p.category;

-- =========================================
-- STEP 5: VERIFY
-- =========================================
SELECT * FROM fact_sales LIMIT 10;