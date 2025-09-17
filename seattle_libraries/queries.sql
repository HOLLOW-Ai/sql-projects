-- ======================================================
-- Top 10 Items Checked Out Overall
-- ======================================================

-- Grouping items and getting a count of the # of times it has been checked out
WITH grp_bibnum AS (
	SELECT
		  bibnum
		, COUNT(*) AS num_checkouts
	FROM ##checkouts
	GROUP BY bibnum
),
-- Joining the CTE to Inventory table to get the title of the item, and ranking the items by # of times it has been checked out
ranked_count AS (
	SELECT
		  G.bibnum
		, I.title
		, I.author	-- Is it faster to have all the authors listed here when first joining to Inventory, or join at the end when only 10 authors should populate?
		, G.num_checkouts
		, DENSE_RANK() OVER (ORDER BY G.num_checkouts DESC) AS rnk
	FROM grp_bibnum AS G
	INNER JOIN ##inventory I
		ON G.bibnum = I.bibnum
)
SELECT
	  bibnum
	, title
	, author
	, num_checkouts
	, rnk
FROM ranked_count
WHERE rnk <= 10
ORDER BY rnk ASC
;


-- ======================================================
-- Top Checked out _Books_ Each Month - Change in Ranking Column? Based on Year, Month
-- ======================================================



-- ======================================================
-- Most Popular Item Types + Most Popular Item
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
	, rnk
FROM cte2 C
INNER JOIN gold.dim_item_type I
	ON C.type_key = I.type_key
WHERE rnk <= 5
ORDER BY rnk ASC
;


-- ======================================================
-- Most Checked Out Item for Each Type (Over Time, with % Change and Ranking Change)
-- ======================================================

-- Find out how many times an item has been checked out
-- Joining on Bibnum and Type Key
-- Join to the Item Type table
-- Join to Inventory table to get title
SELECT TOP 100 *
FROM ##checkouts C
LEFT JOIN gold.dim_item_type I
	ON C.type_key = I.type_key
;
-- Execution Plan recommends to create a NCL index on type_key INCLUDE bibnum in ##checkouts
/*
USE [tempdb]
GO
CREATE NONCLUSTERED INDEX [idx_type_bib_ncl]
ON [dbo].[##checkouts] ([type_key])
INCLUDE ([bibnum])
GO
*/
-- Takes it from ~1:50 to 3 seconds
-- Consider how much cte2 is necessary

-- How many of titles belong to each Item Type
-- How many times has each item been checked out (do not mix: bibnums can be classified as different types and should not be included in others)

WITH cte1 AS (
	SELECT
		  bibnum
		, type_key
		, COUNT(*) AS num_checkouts
	FROM ##checkouts
	GROUP BY bibnum, type_key
),
cte2 AS (
	SELECT
		  type_key
		, COUNT(DISTINCT bibnum) AS num_items
	FROM cte1
	GROUP BY type_key
)
SELECT
	  I.type_key
	, I.code
	, I.description
	, COALESCE(cte2.num_items, 0) AS num_items
	, 
FROM gold.dim_item_type I
LEFT JOIN cte2
	ON I.type_key = cte2.type_key
;


-- ======================================================
-- Most Checkouts by Collections
-- ======================================================

WITH cte1 AS (
	SELECT
		  col_key
		, COUNT(*) AS num_checkouts
		, DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
	FROM ##checkouts
	GROUP BY col_key
)
SELECT
	  I.code
	, I.description
	, COALESCE(cte1.num_checkouts, 0)
	, COALESCE(cte1.rnk, 99999) AS rnk		-- This is so that NULL ranks are pushed to the bottom, alternatively I add a filter in a WHERE clause
FROM gold.dim_item_collection I
LEFT JOIN cte1
	ON I.col_key = cte1.col_key
ORDER BY rnk ASC
;

-- ======================================================
-- Collection Overlap - How much do Bibnums overlap in other collections?
-- ======================================================

-- Checking if the existence of an item in a collection also exists in another collection
-- Finding what collection is has the highest overlap with, and by how much

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS;



-- ======================================================
-- Most Popular Authors
-- ======================================================

-- Many authors listed are items by the US Government
WITH grp_authors AS (
	SELECT
		  author
		, COUNT(bibnum) AS titles_published
		, DENSE_RANK() OVER (ORDER BY COUNT(bibnum) DESC) AS rnk
	FROM ##inventory
	WHERE author IS NOT NULL
	GROUP BY author
)
SELECT
	  author
	, titles_published
FROM grp_authors
ORDER BY rnk ASC;

SELECT *
FROM ##inventory
WHERE author = 'United States. Congress. House. Committee on Rules';

-- ======================================================
-- Most Popular Publishers, although may vary
-- ======================================================

-- You can see the different ways users inputted publishers with different formatting
WITH grp_publishers AS (
	SELECT
		  publisher
		, COUNT(bibnum) AS titles_published
		, DENSE_RANK() OVER (ORDER BY COUNT(bibnum) DESC) AS rnk
	FROM ##inventory
	WHERE publisher IS NOT NULL
	GROUP BY publisher
)
SELECT
	  publisher
	, titles_published
FROM grp_publishers
ORDER BY rnk ASC;


-- ======================================================
-- Items with the Oldest Report Date + Record where it was last checked out
-- ======================================================

-- This is one particular example using the oldest report date of the item in the catalog
-- This could be modifier to see the latest report date and checkout dates of items if it skips a month
-- In the below query, we can see that 2,167 items have not been recently updated to be shown in the catalog of Seattle libraries, or were taken out and then
-- put back in.
SET STATISTICS TIME ON;
WITH least_updated AS (
SELECT
	bibnum
	, 
FROM ##inventory
WHERE latest_report_date = (SELECT MIN(latest_report_date) FROM ##inventory)
)
SELECT
	C.*
	, U.latest_report_date
FROM ##checkouts C
INNER JOIN least_updated U
	ON C.bibnum = U.bibnum
	AND C.checkout_datetime >= DATEADD(MONTH, 1, U.latest_report_date)
;
SET STATISTICS TIME OFF;

WITH cte1 AS (
	SELECT
		  bibnum
		, title
		, author
		, isbn
		, pub_year
		, publisher
		, latest_report_date
	FROM ##inventory
	WHERE latest_report_date = (SELECT MIN(latest_report_date) FROM ##inventory)
), cte2 AS (
SELECT
	  cte1.bibnum
	, title
	, author
	, publisher
	, cte1.latest_report_date
	, C.checkout_datetime
	, C.checkout_id
	, MAX(checkout_datetime) OVER (PARTITION BY cte1.bibnum) AS latest_checkout_date
FROM cte1
INNER JOIN ##checkouts C
	ON cte1.bibnum = C.bibnum
)
SELECT
	  bibnum
	, title
	, author
	, publisher
	, latest_report_date
	, CAST(latest_checkout_date AS DATE) AS latest_checkout_date
FROM cte2
WHERE latest_checkout_date >= DATEADD(MONTH, 1, latest_report_date)
GROUP BY bibnum, title, author, publisher, latest_report_date, latest_checkout_date
;
