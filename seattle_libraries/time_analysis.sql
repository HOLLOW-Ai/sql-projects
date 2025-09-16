/*
	====================================================================
	Time-Based Queries
	====================================================================
	
	Run the procedures prior to running the below queries:
	- gold.temp_inv_heap
	- gold.temp_checkout_heap

	Alternatively, you could the views in the Gold schema but it will take forever to run.

	Optional: Create an index on ##checkouts and ##inventory:
	CREATE CLUSTERED INDEX idx_checkout_id ON ##checkouts (checkout_id);
	CREATE CLUSTERED INDEX idx_checkout_id ON ##inventory (bibnum);
*/

--	==================================
--	Checkouts Over Time (Years)
--	==================================

-- CTE to group checkout records by year
WITH grp_years AS (
	SELECT 
		  YEAR(checkout_datetime)  AS year
		, COUNT(*) AS num_checkouts		-- Opted to use COUNT(*) instead of COUNT(checkout_id) because each record has a distinct checkout_id and performance is better
	FROM ##checkouts
	GROUP BY YEAR(checkout_datetime)
)
-- Adding in 'perc_change' column to calculate the percent change in number of checkouts from the previous year
SELECT
	  year
	, num_checkouts
	, CAST(
		ROUND(
			100.0 * (num_checkouts - LAG(num_checkouts) OVER (ORDER BY year)) / LAG(num_checkouts) OVER (ORDER BY year)
			, 2) 
		AS DECIMAL(5, 2)) AS perc_change
FROM grp_years
ORDER BY year ASC
;


-- ======================================================
-- Average Monthly Checkouts
-- ======================================================

-- To find avg checkouts per month, you would need a CTE to group by year and month, and the following CTE to AVG that
WITH months AS (
	SELECT
		  YEAR(checkout_datetime) AS ch_year
		, MONTH(checkout_datetime) AS ch_month
		, COUNT(*) AS num_checkouts	
	FROM ##checkouts
	GROUP BY YEAR(checkout_datetime), MONTH(checkout_datetime)
),
monthly_avg AS (
	SELECT
		  ch_month
		, AVG(num_checkouts) AS avg_checkouts
	FROM months
	GROUP BY ch_month
)
SELECT
	  ch_month
	, avg_checkouts
	, DENSE_RANK() OVER (ORDER BY avg_checkouts DESC) AS rnk
FROM monthly_avg
;

--SELECT *
--FROM ##checkouts
--WHERE checkout_datetime >= '2020-04-01' AND checkout_datetime < '2020-08-01';



-- ======================================================
-- Query #: Checkouts Broken Down by Day of Week
-- ======================================================
SELECT TOP 50 *, DATENAME(dw, checkout_datetime)
FROM ##checkouts;

-- ======================================================
-- Query 7: Checkouts Broken Down by Hour
-- ======================================================


-- ======================================================
-- Top 5 Most Active Days
-- ======================================================
