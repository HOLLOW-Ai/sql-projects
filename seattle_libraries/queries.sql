-- ======================================================
-- Query #: NULL Checks
-- ======================================================
-- Union ALL Report of Null Values in Each Table

-- Structure: inventory_null_checks (column_name, num_null_values, total_rows, perc_null)
-- Few ways to find Nulls, use SET STATISTICS and Execution Plan to check performance
-- Need to figure out how to pivot the column names into rows
SELECT
	  COUNT(*) - COUNT(column_name) AS nulls_for_column
FROM ##inventory

-- ======================================================
-- Query 1: Checkouts per year + % Change Over Time
-- ======================================================

-- This query is more inefficient than the 2nd one because it has to do 2 Hash Matches
-- Changing the COUNT DISTINCT to COUNT (*) drastically reduces the time

-- No Index
-- CPU time = 3687 ms, elapsed = 3784 ms
-- With Index
-- COUNT(*): CPU = 16 + 3625 ms, elapsed = 16 + 3758 ms
-- COUNT(DISTINCT checkout_id): CPU time = 15188 ms,  elapsed time = 15695 ms. (Does 2 Hash matches)
-- COUNT(checkout_id): CPU time = 3829 ms,  elapsed time = 4171 ms.

-- Finding out that I can't delete the query (session) that I made the temp tables in or it will delete the temp tables too lmao
--EXEC gold.temp_checkout_heap;
--EXEC gold.temp_inv_heap;

SET STATISTICS TIME ON;
SELECT
	  YEAR(checkout_datetime) AS checkout_year
	, COUNT(checkout_id)
FROM ##checkouts
GROUP BY YEAR(checkout_datetime)
ORDER BY checkout_year;
SET STATISTICS TIME OFF;

-- With Index
-- COUNT(*): CPU time = 3500 ms,  elapsed time = 3704 ms.
-- After adding perc_change: CPU time = 3546 ms,  elapsed time = 3656 ms.
SET STATISTICS TIME ON;
WITH cte AS (
	SELECT
		  YEAR(checkout_datetime) AS checkout_year
		, checkout_id
	FROM ##checkouts
), cte2 AS (
SELECT
	  checkout_year
	, COUNT(*) AS checkouts_per_year	-- Switch to * to see difference
FROM cte
GROUP BY checkout_year
)
SELECT
	  checkout_year
	, checkouts_per_year
	, CAST(ROUND(1.0 * (checkouts_per_year - LAG(checkouts_per_year) OVER (ORDER BY checkout_year)) / LAG(checkouts_per_year) OVER (ORDER BY checkout_year), 2) AS DECIMAL(5, 2)) AS perc_change
FROM cte2
ORDER BY checkout_year;
SET STATISTICS TIME OFF;
-- Was considering indexing on the temp tables, but Brent Ozar's blog has made me reconsider but let's try it any

-- CPU = 13766 ms, elapsed = 15932 ms
-- The Clustered Columnstore Index needs to be created in the same batch as the table creation, otherwise you get an error
SET STATISTICS TIME ON;
CREATE CLUSTERED INDEX idx_checkout_id ON ##checkouts (checkout_id);
SET STATISTICS TIME OFF;

DROP INDEX idx_checkout_id ON ##checkouts;


-- ======================================================
-- Query 6: Checkouts Broken Down by Month (Focus on Most Popular Year)
-- ======================================================

-- ======================================================
-- Query #: Checkouts Broken Down by Day
-- ======================================================

-- ======================================================
-- Query #: Checkouts Broken Down by Day of Week
-- ======================================================

-- ======================================================
-- Query 7: Checkouts Broken Down by Hour
-- ======================================================

-- ======================================================
-- Query 2: Top 10 Items Checked Out Overall
-- ======================================================

-- No Index on Bibnum: CPU time = 4593 ms,  elapsed time = 4921 ms.
-- Index created: CPU time = 1938 ms,  elapsed time = 2070 ms.
SET STATISTICS TIME ON;
SELECT TOP 1000
	  bibnum
	, COUNT(*) AS num_checkouts
FROM ##checkouts AS C
GROUP BY bibnum
ORDER BY 2 DESC;
SET STATISTICS TIME OFF;

-- CPU time = 25062 ms,  elapsed time = 25236 ms.
SET STATISTICS TIME ON;
CREATE NONCLUSTERED INDEX idx_bibnum ON ##checkouts (bibnum);
SET STATISTICS TIME OFF;



-- ======================================================
-- Query 3: Most Checked Out Item Overall
-- ======================================================

SET STATISTICS TIME ON;
CREATE CLUSTERED INDEX idx_bibnum_inv ON ##inventory (bibnum);
SET STATISTICS TIME OFF;

DROP INDEX idx_bibnum_inv ON ##inventory;


-- Takes 5 seconds to run w/ no index
-- 2 Seconds with Index using Nonclustered; still does a Table Scan of Inventory
-- Created new CLustered index on inventory (bibnum) so it avoids the Table Scan
WITH cte1 AS (
	SELECT
		  bibnum
		, COUNT(*) AS num_checkouts
		, DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
	FROM ##checkouts
	GROUP BY bibnum
)
SELECT
	  C.bibnum
	, C.num_checkouts
	, I.title
	, I.author
	, I.pub_year
	, I.publisher
FROM cte1 C
INNER JOIN ##inventory I -- Inventory doesn't really need a temp table, but this is just for storage purposes
	ON C.bibnum = I.bibnum
WHERE rnk = 1;


-- ======================================================
-- Query #: Top Checked out _Books_ Each Month
-- ======================================================

-- ======================================================
-- Query 4: Top 10 Most Popular Item Types
-- ======================================================

WITH cte2 AS (
	SELECT
		  type_key
		, COUNT(*) AS num_checkouts
		, DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
	FROM ##checkouts
	GROUP BY type_key
)
SELECT
	  I.code
	, I.description
	, C.num_checkouts
FROM cte2 C
INNER JOIN gold.dim_item_type I
	ON C.type_key = I.type_key
WHERE rnk <= 10;


-- ======================================================
-- Query 5: Most Checked Out Item for Each Type (Over Time, with % Change and Ranking Change)
-- ======================================================




-- ======================================================
-- Query 8: Most Popular Collection
-- ======================================================



-- ======================================================
-- Query 9: Collection Overlap
-- ======================================================

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS;
