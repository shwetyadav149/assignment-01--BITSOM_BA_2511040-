import sys
!{sys.executable} -m pip install duckdb pandas
import duckdb
import pandas as pd
import duckdb
print("DuckDB installed successfully")
# Create connection
con = duckdb.connect()
# FILE PATHS (YOUR PATH)
# =========================================
customers_path = 'D:/bits course/assigenment 2/customers.csv'
orders_path = 'D:/bits course/assigenment 2/orders.json'
products_path = 'D:/bits course/assigenment 2/products.parquet'
# Q1: Total orders per customer
# =========================================
q1 = f"""
SELECT 
    c.customer_id,
    c.name,
    COUNT(o.order_id) AS total_orders
FROM read_csv_auto('{customers_path}') c
LEFT JOIN read_json_auto('{orders_path}') o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_orders DESC;
"""

df1 = con.execute(q1).df()
print("Q1 Output")
display(df1)
# Q2: Top 3 customers by total order value
# =========================================
q2 = f"""
SELECT 
    c.customer_id,
    c.name,
    SUM(o.total_amount) AS total_spent
FROM read_csv_auto('{customers_path}') c
JOIN read_json_auto('{orders_path}') o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC
LIMIT 3;
"""

df2 = con.execute(q2).df()
print("Q2 Output")
display(df2)
# Q3: Products purchased by Bangalore customers
# ======
q3 = f"""
SELECT DISTINCT
    p.product_name
FROM read_csv_auto('{customers_path}') c
JOIN read_json_auto('{orders_path}') o
ON c.customer_id = o.customer_id
JOIN read_parquet('{products_path}') p
ON o.order_id = p.order_id
WHERE LOWER(c.city) = 'bangalore';
"""

df3 = con.execute(q3).df()
print("Q3 Output")
display(df3)
# Q4: Join all three files
# =========================================
q4 = f"""
SELECT 
    c.name,
    o.order_date,
    p.product_name,
    p.quantity
FROM read_csv_auto('{customers_path}') c
JOIN read_json_auto('{orders_path}') o
ON c.customer_id = o.customer_id
JOIN read_parquet('{products_path}') p
ON o.order_id = p.order_id
ORDER BY o.order_date;
"""

df4 = con.execute(q4).df()
print("Q4 Output")
display(df4)