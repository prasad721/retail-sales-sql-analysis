# Retail Sales Analysis with SQL

This beginner portfolio project uses SQL Server to identify the strongest sales month, compare product categories, and find products that earned at least $100 in revenue.

## Run the project

1. Open SQL Server Management Studio (SSMS) and create a new practice database.
2. Select that database in SSMS and run [setup.sql](setup.sql) once to create and populate the tables.
3. Run [analysis.sql](analysis.sql) in the same database. SSMS displays four result grids.

## Dataset and metrics

The synthetic dataset covers January through March 2026. `Products` contains five products and their categories. Each row in `Sales` represents one transaction for one product. Revenue is quantity multiplied by the sale-time unit price in USD. Costs, taxes, and returns are outside the dataset.

## Results

| Metric | Result |
| --- | ---: |
| Total revenue | $485.00 |
| Units sold | 41 |
| Transactions | 10 |
| January revenue | $125.00 |
| February revenue | $138.00 |
| March revenue | $222.00 |
| Electronics revenue | $367.00 |
| Stationery revenue | $118.00 |
| Home Office revenue | $0.00 |

March had the highest revenue. The Keyboard generated $262 and the Mouse generated $105, so both exceeded the $100 threshold. The Desk Lamp had no transactions. The category query uses a `LEFT JOIN` to keep Home Office visible with zero revenue.

## SQL skills demonstrated

Joins, aggregate functions, date grouping, `GROUP BY`, `HAVING`, and handling missing matches with `COALESCE`.
