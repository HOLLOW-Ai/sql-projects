/*
===============================================================================
Measure Exploration (Key Metrics)
===============================================================================
*/
-- Total Sales
SELECT SUM(purchase_price_per_unit * quantity)
FROM silver.amazon_purchases;

-- Total orders made
SELECT
	COUNT(*) AS total_orders
FROM silver.amazon_purchases;

-- How many items sold
SELECT
	SUM(quantity) AS total_quantity
FROM silver.amazon_purchases;

-- Average Unit Price
SELECT
	AVG(purchase_price_per_unit) AS avg_price
FROM silver.amazon_purchases;
