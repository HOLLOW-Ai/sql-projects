/*
===============================================================================
Change Over Time
===============================================================================
*/

-- Change in Number of Orders Year-by-Year
-- The dataset page says that the data should be from 2018-2022
-- The article the dataset was collected for was published in April 2024
WITH previous_year AS (
	SELECT
		  YEAR(order_date) AS order_year
		, COUNT(*) AS num_orders
		, LAG(COUNT(*)) OVER (ORDER BY YEAR(order_date)) AS last_year_orders
	FROM silver.amazon_purchases
	GROUP BY YEAR(order_date)
)
-- I could've probably done it in one query, but I don't want to keep typing the window function
SELECT
	  order_year
	, num_orders
	, ISNULL(CAST(ROUND(100.0 * (num_orders - last_year_orders) / last_year_orders, 2) AS DECIMAL(5, 2)), 0) AS pct_change
FROM previous_year
ORDER BY order_year
;



-- Number of Orders by Month and Year
SELECT
	  FORMAT(order_date, 'yyyy-MMM') AS year_month
	, COUNT(*) AS num_orders
FROM silver.amazon_purchases
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM')
;

SELECT
	  FORMAT(order_date, 'MMM') AS order_month
	, FORMAT(order_date, 'yyyy') AS order_year
	, COUNT(*) AS num_orders
	, AVG(purchase_price_per_unit * quantity)
FROM silver.amazon_purchases
GROUP BY  MONTH(order_date), FORMAT(order_date, 'MMM'),  FORMAT(order_date, 'yyyy')
ORDER BY MONTH(order_date), order_year
;
