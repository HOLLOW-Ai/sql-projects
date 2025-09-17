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

-- Find:
	-- Number of Checkouts belonging to an Item Type
	-- For each Item in that Type, the number of checkouts it has --> Eventually we just want the item with the highest checkouts

-- If I keep the ties, then the type_key in the final query can show up multiple times if somehow the item with the most checkouts is tied

-- Execution Plan recommends to create a NCL index on type_key INCLUDE bibnum in ##checkouts
/*
USE [tempdb]
GO
CREATE NONCLUSTERED INDEX [idx_type_bib_ncl]
ON [dbo].[##checkouts] ([type_key])
INCLUDE ([bibnum])
GO
*/
WITH cte2 AS (
	SELECT
		  type_key
		, COUNT(*) AS total_checkouts
		, COUNT(DISTINCT bibnum) AS num_titles
		, DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS rnk
	FROM ##checkouts
	GROUP BY type_key
),
cte3 AS (
	SELECT
		  bibnum
		, type_key
		, COUNT(*) AS item_checkouts
		, DENSE_RANK() OVER (PARTITION BY type_key ORDER BY COUNT(*) DESC) AS rnk
	FROM ##checkouts
	GROUP BY bibnum, type_Key
),
cte4 AS (
SELECT
	  C2.type_key
	, total_checkouts
	, num_titles
	, C3.bibnum
	, item_checkouts
FROM cte2 C2
INNER JOIN cte3 C3
	ON C2.type_key = C3.type_key
	AND C3.rnk = 1
)
SELECT
	  T.code
	, T.description
	, C4.total_checkouts	-- Add COALESCE() later
	, C4.num_titles
	, C4.bibnum
	, I.title
	, C4.item_checkouts
FROM gold.dim_item_type T
LEFT JOIN cte4 C4
	ON T.type_key = C4.type_key
LEFT JOIN ##inventory I
	ON C4.bibnum = I.bibnum
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
-- Collection/Item Overlap - How much do Bibnums overlap in other collections?
-- ======================================================

-- Checking if the existence of an item in a collection also exists in another collection
-- Finding what collection is has the highest overlap with, and by how much

-- General Idea:
	-- Thinking group by group by type/collection + bibnum, and then a CASE WHEN COUNT(*)/SUM() situation where for each row, it checks if there exists
	-- the same bibnum and a != key and then either put 1 or 0; whatever rule I do
	-- Can WHERE EXISTS work here?

-- A quick way to check if a bibnum is assigned multiple types is to do a distinct of bibnum and type_key, and then have a cte based off that
-- to do another group by bibnum and do HAVING COUNT(*) > 1

WITH cte1 AS (
	SELECT
		  bibnum
		, type_key
		, LAG(type_key) OVER (PARTITION BY bibnum ORDER BY type_key) AS lag_type
		, LEAD(type_key) OVER (PARTITION BY bibnum ORDER BY type_key) AS lead_type
	FROM ##checkouts
	GROUP BY bibnum, type_key
),
cte2 AS (
	SELECT
		  bibnum
		, type_key
		, CASE
			WHEN lag_type IS NOT NULL OR lead_type IS NOT NULL THEN 1
			ELSE 0
		  END AS marker
	FROM cte1
),
cte3 AS (
	SELECT
		type_key
		, COUNT(DISTINCT bibnum) AS unique_items
		, SUM(marker) AS flag_total
	FROM cte2
	GROUP BY type_key
), cte4 AS (
-- Columns: Code, Code Description, # of Titles identified as the Code, % of Items that Overlap as Other Types/Collections
-- At the 8 min mark of the query somehow
SELECT
	  T.code
	, T.type_key
	, T.description
	--, C3.unique_items -- Add COALESCE()
	, C3.flag_total -- This column slowing down the entire query somehow
FROM gold.dim_item_type T
INNER JOIN cte3 C3 -- If I choose to keep the flag_total, then changing LEFT JOIN to INNER JOIN will actually compute the query in 5 seconds
	ON T.type_key = C3.type_key
)
SELECT *
FROM cte4;




-- Does a Bibnum appear more than once
WITH combos AS (
	-- Total of 474,789 rows
	SELECT bibnum, type_key
	FROM ##checkouts
	GROUP BY bibnum, type_key
)
, flag_items AS(
	SELECT
		bibnum
		, COUNT(*) AS appearance
	FROM combos
	GROUP BY bibnum
)
, flag_totals AS (
SELECT
	  type_key
	, SUM(CASE WHEN appearance > 1 THEN 1 ELSE 0 END) AS flag
FROM combos C
INNER JOIN flag_items F
	ON C.bibnum = F.bibnum
GROUP BY type_key
)
-- CPU time = 213797 ms,  elapsed time = 214230 ms.; 3:34 to run
SELECT
	I.type_key
	, COALESCE(flag, 0)
FROM gold.dim_item_type I
LEFT JOIN flag_totals F -- Spending all of the time in the Nested Loops (LEFT JOIN) step
	ON I.type_key = F.type_key

-- From the execution plan and Stack Overflow

--SELECT
--	  type_key
--	, C.bibnum
--	--, appearance
--	, CASE WHEN appearance > 1 THEN 1 ELSE 0 END AS flag
--FROM combos C
--INNER JOIN flag_items F
--	ON C.bibnum = F.bibnum


-- ======================================================
-- Most Author Appearances
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
