USE dw_assignment;
-- Q1: Revenue by category per month
SELECT 
    d.year,
    d.month,
    p.category,
    SUM(f.total_revenue) AS total_revenue
FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY d.year, d.month, p.category
ORDER BY d.year, d.month;

-- Q2: Top 2 stores
SELECT 
    s.store_name,
    SUM(f.total_revenue) AS total_revenue
FROM fact_sales f
JOIN dim_store s ON f.store_id = s.store_id
GROUP BY s.store_name
ORDER BY total_revenue DESC
LIMIT 2;

-- Q3: Month-over-month trend
SELECT 
    d.year,
    d.month,
    SUM(f.total_revenue) AS monthly_sales
FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.month
ORDER BY d.year, d.month;