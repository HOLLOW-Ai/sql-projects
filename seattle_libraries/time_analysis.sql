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
	CREATE CLUSTERED INDEX idx_bibnum ON ##inventory (bibnum);
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

-- Actually, should I just divide it by 5-6 because it's dependent on the time range of the dataset; 2025 ends in September?
-- Come back and redo this
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

-- How many days of the week has it been
-- How many data were Tuesday, for example, and then divide the sum total of checkouts by however many time it was Tuesday in total

-- One part is finding out how many days in the time range were a specific weekday, and how many checkouts occurred in total on those weekdays


-- PU time = 4984 ms,  elapsed time = 5307 ms.

--CPU time = 10172 ms,  elapsed time = 11056 ms.
--SET STATISTICS TIME ON;

---- This count how many checkouts occurred in total on each weekday from every year
--WITH checkout_count aS (
--	SELECT
--		  DATENAME(dw, checkout_datetime) AS day_of_week
--		, COUNT(*) AS num_count -- You could swap out for checkout_id since each row has a unique one, but * is better performance-wise
--	FROM ##checkouts
--	GROUP BY DATENAME(dw, checkout_datetime)
--),
---- This CTE should be counting how many times the day has occurred (Distinctly) in the dataset
--weekday_count AS (
--	SELECT
--		  DATENAME(dw, checkout_datetime) AS day_of_week
--		, COUNT(DISTINCT CAST(checkout_datetime AS DATE)) AS appearance
--	FROM ##checkouts
--	GROUP BY DATENAME(dw, checkout_datetime)
--)
--SELECT
--	  C.day_of_week
--	, ROUND(1.0 * num_count / appearance, 2) AS avg_checkout_count
--FROM checkout_count C
--INNER JOIN weekday_count W
--	ON C.day_of_week = W.day_of_week
--;
--SET STATISTICS TIME OFF;




SET STATISTICS TIME ON;

-- This count how many checkouts occurred in total on each weekday from every year
WITH checkout_count aS (
	SELECT
		  DATENAME(dw, checkout_datetime) AS day_of_week
		, COUNT(*) AS num_count -- You could swap out for checkout_id since each row has a unique one, but * is better performance-wise
		, COUNT(DISTINCT CAST(checkout_datetime AS DATE)) AS appearance
	FROM ##checkouts
	GROUP BY DATENAME(dw, checkout_datetime)
)
SELECT
	  day_of_week
	, ROUND(1.0 * num_count / appearance, 2) AS avg_checkout_count
FROM checkout_count
ORDER BY (CASE day_of_week
			WHEN 'Monday' THEN 1
			WHEN 'Tuesday' THEN 2
			WHEN 'Wednesday' THEN 3
			WHEN 'Thursday' THEN 4
			WHEN 'Friday' THEN 5
			WHEN 'Saturday' THEN 6
			WHEN 'Sunday' THEN 7
		END) ASC
;
SET STATISTICS TIME OFF;


-- ======================================================
-- Query 7: Checkouts Broken Down by Hour
-- ======================================================


-- ======================================================
-- Top 5 Most Active Days
-- ======================================================
