## Anomaly Analysis

### Insert Anomaly
In the given dataset, product and customer information are stored together with order details in a single table. This creates an insert anomaly because a new product cannot be added unless there is an associated order.

For example, product details (product_id, product_name, price) only exist along with order_id. If a new product is introduced but no customer has ordered it yet, there is no way to store that product in the table without creating a fake order entry.

---

### Update Anomaly
Customer information is repeated across multiple rows, leading to redundancy and potential inconsistency.

For example:
- Row 14 → customer_id = CUST004, city = Mumbai  
- Row 23 → customer_id = CUST004, city = Mumbai  
- Row 25 → customer_id = CUST004, city = Mumbai 

If the customer moves to another city (e.g., Delhi), we must update all rows where this customer appears. If even one row is missed, it will lead to inconsistent data in the database.

---

### Delete Anomaly
Deleting an order record may result in unintended loss of important data such as customer or product information.

For example:
If customer_id = CUST010 appears only once in the dataset (say Row 40), and that row is deleted, then all information about that customer is permanently lost. Similarly, if a product appears in only one order and that order is deleted, the product data will also be lost.

This leads to loss of critical business information.