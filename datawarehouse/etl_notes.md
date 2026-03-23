## ETL Decisions

### Decision 1 — Date Cleaning and Standardization
Problem: The dataset had inconsistent date formats and invalid values.
Resolution: Used REPLACE() and STR_TO_DATE() inside a subquery and filtered NULL values to ensure only valid dates were loaded.

### Decision 2 — Category Normalization
Problem: Category values had inconsistent casing.
Resolution: Used UPPER() to standardize category values.

### Decision 3 — Handling NULL Values
Problem: Some records had NULL values in units_sold and unit_price.
Resolution: Used COALESCE() to replace NULL values with 0 and calculated total_revenue.