-- SQL Retail Sales Analysis - P1
CREATE DATABASE sql_project_p2;


-- create TABLE
CREATE TABLE retail_sales
            (
               transactions_id INT PRIMARY KEY,
			   sale_date DATE,
			   sale_time TIME,
			   customer_id INT,
			   gender VARCHAR(15),
			   age INT,
			   category VARCHAR(15),
			   quantiy INT,
			   price_per_unit FLOAT,
			   cogs  FLOAT,
			   total_sale FLOAT,

            );

-- DATA CLEANING

SELECT *
FROM retail_sales
WHERE 
      transactions_id is null
      or 
	  sale_date is null
	  or
	  sale_time is null
	  or 
	  gender is null
	  or 
	  category is null
	  or 
      quantiy is null
	  or 
	  cogs is null
	  or
	  total_sale is null;


DELETE
FROM retail_sales
WHERE 
      transactions_id is null
      or 
	  sale_date is null
	  or
	  sale_time is null
	  or 
	  gender is null
	  or 
	  category is null
	  or 
      quantiy is null
	  or 
	  cogs is null
	  or
	  total_sale is null;

-- DATA EXPLORATION

-- HOW MANY SALES WE HAVE?

SELECT count(*) as total_sale FROM retail_Sales


-- HOW MANY CUSTOMERS WE HAVE?

SELECT COUNT(DISTINCT customer_id) as total_customers FROM retail_Sales;


-- HOW MANY CATEGORIES WE HAVE?

SELECT COUNT(DISTINCT category) FROM retail_sales;


-- DATA ANALYSIS & BUISENESS KEY PROBLEMS & ANSWERS

-- WRITE A SQL QUERY TO RETRIEVE ALL COLUMNS FOR SALES MADE ON '2022-11-05'

SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';

-- WRITE A SQL QUERY TO RETRIEVE ALL TRANSACTIONS WHERE THE CATEGORY IS 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022 

SELECT * FROM retail_Sales
WHERE category = 'Clothing'
and
quantiy >= 4
and
sale_date >= DATE '2022-11-01'
and sale_date < DATE '2022-12-01'

-- WRITE A SQL QUERY TO CALCULATE THE TOTAL SALES (total_sale) for each category

SELECT
    category,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category
ORDER BY category;

-- Q.4. WRITE A SQL QUERY TO FIND THE AVERAGE AGE OF CUSTOMERS WHO PURCHASED ITEMS FROM THE 'Beauty' CATEGORY

SELECT
    ROUND (AVG(age), 2) AS avg_age
FROM retail_Sales 	
WHERE category = 'Beauty';

-- Q.5. WRITE A SQL QUERY TO FIND ALL TRANSACTIONS WHERE THE total_sale IS GREATER THAN 1000

SELECT * FROM retail_sales
WHERE total_sale> 1000;
    
-- Q.6. WRITE A SQL QUERY TO FIND THE TOTAL NUMBER OF TRANSACTIONS (transaction_id) MADE BY EACH GENDER IN EACH CATEGORY.

SELECT
     category,
	 gender,
	 COUNT (*) as total_trans
FROM retail_Sales
GROUP BY category,
         gender;

-- Q.7. WRITE A SQL QUERY TO CALCULATE THE AVERAGE SALE FOR EACH MONTH. FIND OUT BEST SELLING MONTH IN EACH YEAR.

WITH monthly_avg AS (
SELECT
     EXTRACT(YEAR FROM sale_date)  AS year,
     EXTRACT(MONTH FROM sale_date) AS month,
     AVG(total_sale)               AS avg_sale
     FROM retail_sales
     GROUP BY 1, 2
)
SELECT *
FROM (
SELECT *,
         RANK() OVER (PARTITION BY year ORDER BY avg_sale DESC) AS rank
FROM monthly_avg
) t
WHERE rank = 1;

-- Q.8. WRITE A SQL QUERY TO FIND THE TOP 5 CUSTOMERS BASED ON THE HIGHEST TOTAL SALES.

SELECT 
    customer_id,
	SUM(total_Sale) AS total_sales
FROM retail_Sales
GROUP BY customer_id 
ORDER BY total_Sales DESC
LIMIT 5;

-- Q.9. WRITE A SQL QUERY TO FIND THE NUMBER OF UNIQUE CUSTOMERS WHO PURCHASED ITEMS FROM EACH CATEGORY.

SELECT
    category,
    COUNT(DISTINCT customer_id)
FROM retail_Sales
GROUP BY CATEGORY;

-- Q.10. WRITE A SQL QUERY TO CREATE EACH SHIFT OF NUMBERS AND ORDERS (EXAMPLE MORNING <= 12), AFTERNOON BETWEEN 12 & 17, EVENING . 17)

WITH hourly_sale
AS
(
SELECT *,
     CASE
	    WHEN EXTRACT (HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT (HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
     END AS shift
FROM retail_sales
)
SELECT
     shift,
     COUNT(*) AS total_orders
FROM hourly_Sale
GROUP BY shift;

-- END OF PROJECT




