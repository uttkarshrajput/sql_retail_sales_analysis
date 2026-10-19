# Retail Sales Analysis (SQL)

SQL analysis of 2,000 retail transactions (January 2022 to December 2023) in PostgreSQL. I set up the table, cleaned out incomplete rows, explored the data and answered 11 business questions on categories, customers, seasonality and time of day.

**Tools:** PostgreSQL, pgAdmin 4
**SQL used:** DDL, NULL handling, GROUP BY, CTEs, CASE, window functions (RANK, SUM() OVER), date and time functions

## At a glance

| Metric | Value |
|---|---|
| Transactions (after cleaning) | 1,997 |
| Customers | 155 |
| Categories | Clothing, Electronics, Beauty |
| Total sales | 911,720 |
| Period | Jan 2022 to Dec 2023 |

## Workflow

**1. Table setup.** Created `retail_sales` with proper types (DATE, TIME, INT, FLOAT) and `transactions_id` as the primary key. The source CSV spells one column `quantiy`; the table uses the correct name `quantity`.

**2. Cleaning.** Checked every column for NULLs:
- 3 rows had no quantity, price, cost or sale amount. They were deleted because a sale without an amount is not usable.
- 10 rows had no age. I **kept** them: the sale itself is valid, and `AVG(age)` skips NULLs anyway. Deleting them would have dropped real revenue.

**3. Exploration.** Row count, distinct customers and the list of categories.

**4. Analysis.** 11 business questions, all in [`SQL_Project_1.sql`](SQL_Project_1.sql).

## Business questions

1. All sales on a given day (2022-11-05).
2. Clothing orders with a quantity of 4 or more in November 2022. Quantity only goes from 1 to 4 here, so "more than 4" would always return nothing.
3. Total sales and orders by category.
4. Average customer age in the Beauty category.
5. Transactions above 1,000.
6. Transactions by gender within each category.
7. Best month of each year by average sale (CTE plus `RANK() OVER (PARTITION BY year ...)`).
8. Top 5 customers by total sales.
9. Unique customers per category.
10. Orders by shift: morning, afternoon and evening (`CASE` on `EXTRACT(HOUR ...)`).
11. Each category's share of revenue (`SUM(SUM(total_sale)) OVER ()`).

Example, the best month in each year:

```sql
WITH monthly_avg AS (
    SELECT
        EXTRACT(YEAR FROM sale_date)  AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale)               AS avg_sale
    FROM retail_sales
    GROUP BY 1, 2
)
SELECT year, month, ROUND(avg_sale::NUMERIC, 2) AS avg_sale
FROM (
    SELECT *, RANK() OVER (PARTITION BY year ORDER BY avg_sale DESC) AS rnk
    FROM monthly_avg
) t
WHERE rnk = 1;
```

## Findings

- **Revenue is evenly split across categories.** Electronics 34.4% (313,810), Clothing 34.1% (311,070) and Beauty 31.5% (286,840). Clothing has the most orders (701).
- **Evening is the busiest time.** 1,062 of 1,997 orders (53%) came after 5 pm, against 558 in the morning and 377 in the afternoon. Staffing and promotions should follow the evening peak.
- **Sales were flat year on year.** 452,825 in 2022 and 458,895 in 2023 (+1.3%).
- **Best months by average sale:** July in 2022 (541.34) and February in 2023 (535.53). The best month changed between years, so there is no fixed peak season.
- **Large orders matter.** 306 transactions (15%) were above 1,000.
- **A few customers spend far more than the rest.** The top customer (ID 3) spent 38,440; the top 5 together spent 148,470, which is 16% of all sales from 5 of 155 customers.
- **Beauty buyers average 40 years old** (40.42). Female customers made 54% of Beauty transactions (330 of 612), while Clothing and Electronics are close to even.

## How to run

1. Create a database in PostgreSQL and run the `CREATE TABLE` statement from `SQL_Project_1.sql`.
2. Import `SQL - Retail Sales Analysis_utf .csv` into `retail_sales` (pgAdmin: right-click the table, Import/Export Data, header on).
3. Run the cleaning step, then the queries in order.

## Author

**Uttkarsh Singh**, Data Analyst
[LinkedIn](https://www.linkedin.com/in/uttkarshsinghdata) · [GitHub](https://github.com/uttkarshrajput)
