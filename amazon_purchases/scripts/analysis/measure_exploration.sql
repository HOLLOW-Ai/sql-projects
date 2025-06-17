/*
===============================================================================
Measure Exploration
===============================================================================
*/
-- Total Sales
SELECT SUM(purchase_price_per_unit * quantity)
FROM silver.amazon_purchases;

-- Total Orders
SELECT
	COUNT(*) AS total_orders
FROM silver.amazon_purchases;

-- Total Units Sold
SELECT
	SUM(quantity) AS total_quantity
FROM silver.amazon_purchases;

-- Average Unit Price
SELECT
	AVG(purchase_price_per_unit) AS avg_price
FROM silver.amazon_purchases;

-- Average Orders per Person
SELECT
	1.0 * COUNT(*) / COUNT(DISTINCT response_id)
FROM silver.amazon_purchases;


-- Duplicate Rows
-- Without a timestamp or unique order number, I can't say for certainty if these are duplicate orders or if they are separate orders
-- Gift Cards seem to be the biggest offender of duplicate orders
WITH dupes AS (
	SELECT
		  order_date
		, purchase_price_per_unit
		, quantity
		, shipping_address_state
		, title
		, product_code
		, category
		, response_id
		, COUNT(*) AS num_repeats
	FROM silver.amazon_purchases
	GROUP BY
		  order_date
		, purchase_price_per_unit
		, quantity
		, shipping_address_state
		, title
		, product_code
		, category
		, response_id
	HAVING COUNT(*) > 1
)
SELECT
	  category
	, SUM(num_repeats) AS total_repeats
FROM dupes
GROUP BY category
ORDER BY SUM(num_repeats) DESC
;
