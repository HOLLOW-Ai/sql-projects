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
