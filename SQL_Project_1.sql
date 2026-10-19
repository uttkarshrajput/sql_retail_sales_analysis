-- Retail Sales Analysis (PostgreSQL)
-- Author: Uttkarsh Singh
-- Data: 2,000 retail transactions, Jan 2022 to Dec 2023

CREATE DATABASE p1_retail_db;

-- 1. TABLE SETUP
-- The CSV header spells this column "quantiy". The import maps columns by position,
-- so the table uses the correct name "quantity".

DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date       DATE,
    sale_time       TIME,
    customer_id     INT,
    gender          VARCHAR(15),
    age             INT,
    category        VARCHAR(15),
    quantity        INT,
    price_per_unit  FLOAT,
    cogs            FLOAT,
    total_sale      FLOAT
);


-- 2. DATA CLEANING
-- Find rows with missing values. Age is left out on purpose: a sale with an unknown
-- age is still a valid sale, and AVG(age) ignores NULLs anyway.

SELECT *
FROM retail_sales
WHERE sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR category IS NULL
   OR quantity IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;

-- 3 rows have no quantity, price, cost or sale amount, so they are removed (2,000 -> 1,997).
DELETE FROM retail_sales
WHERE sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR category IS NULL
   OR quantity IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;


-- 3. DATA EXPLORATION

-- How many sales do we have?
SELECT COUNT(*) AS total_transactions FROM retail_sales;

-- How many unique customers?
SELECT COUNT(DISTINCT customer_id) AS total_customers FROM retail_sales;

-- Which categories?
SELECT DISTINCT category FROM retail_sales;


-- 4. BUSINESS QUESTIONS

-- Q.1. Retrieve all columns for sales made on 2022-11-05.
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q.2. Retrieve all Clothing transactions with a quantity of 4 or more in November 2022.
-- (Quantity ranges from 1 to 4 in this data, so "more than 4" would always return nothing.)
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
  AND quantity >= 4
  AND sale_date >= DATE '2022-11-01'
  AND sale_date <  DATE '2022-12-01';

-- Q.3. Total sales and number of orders for each category.
SELECT
    category,
    SUM(total_sale) AS total_sales,
    COUNT(*)        AS total_orders
FROM retail_sales
GROUP BY category
ORDER BY total_sales DESC;

-- Q.4. Average age of customers who bought from the Beauty category.
SELECT
    ROUND(AVG(age)::NUMERIC, 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- Q.5. All transactions where total_sale is greater than 1000.
SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- Q.6. Number of transactions by each gender in each category.
SELECT
    category,
    gender,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category, gender;

-- Q.7. Average sale for each month, and the best month in each year.
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
    SELECT *,
           RANK() OVER (PARTITION BY year ORDER BY avg_sale DESC) AS rnk
    FROM monthly_avg
) t
WHERE rnk = 1;

-- Q.8. Top 5 customers by total sales.
SELECT
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Q.9. Number of unique customers who bought from each category.
SELECT
    category,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;

-- Q.10. Orders by shift: Morning (before 12), Afternoon (12 to 17), Evening (after 17).
WITH hourly_sale AS (
    SELECT *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT
    shift,
    COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift
ORDER BY total_orders DESC;

-- Q.11. Each category's share of total revenue (window function over the grouped result).
SELECT
    category,
    SUM(total_sale) AS total_sales,
    ROUND((100 * SUM(total_sale) / SUM(SUM(total_sale)) OVER ())::NUMERIC, 1) AS pct_of_revenue
FROM retail_sales
GROUP BY category
ORDER BY total_sales DESC;

-- END
