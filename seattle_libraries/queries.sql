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

-- Creating a Temp table to store the results of cte5
CREATE TABLE ##cte5 (
	type_key INT,
	titles_overlapped INT,
	unique_titles INT
);

WITH combos AS (
	-- Total of 474,789 rows
	-- Check 3959380, 724463, 3482508

	-- Get the unique combos of Bibnum and Type
	SELECT bibnum, type_key
	FROM ##checkouts
	GROUP BY bibnum, type_key
)

, repeated_items AS (
	
	-- Filter down to a list of items that are assigned more than 1 type key
	SELECT
		  bibnum
		, COUNT(DISTINCT type_key) AS key_count
	FROM combos
	GROUP BY bibnum
	HAVING COUNT(*) > 1

)

, flagged_items AS (

	-- Flag for each item that is in repeated_items CTE with 1, otherwise 0
	SELECT
		  C.bibnum
		, C.type_key
		, CASE WHEN R.key_count IS NOT NULL THEN 1 ELSE 0 END AS marker -- Will want to SUM() this later
	FROM combos C
	LEFT JOIN repeated_items R
		ON C.bibnum = R.bibnum

)
, grp_types AS (
	
	-- Get the items classified as each type, and a sum of the marker
	SELECT
		  type_key
		, SUM(marker) AS sum_total
		, COUNT(DISTINCT bibnum) AS titles
	FROM flagged_items
	GROUP BY type_key
)
, generate_vals AS (
	SELECT value -- This is being made to avoid doing a LEFT JOIN because that dramatically slows the entire query
	FROM GENERATE_SERIES((SELECT MIN(type_key) FROM gold.dim_item_type), 
						(SELECT MAX(type_key) FROM gold.dim_item_type))
), cte5 AS (
	SELECT
		  value AS type_key
		, COALESCE(sum_total, 0) AS titles_overlapped
		, COALESCe(titles, 0) AS unique_titles
	FROM generate_vals
	LEFT JOIN grp_types
		ON generate_vals.value = grp_types.type_key
)
INSERT INTO ##cte5 (type_key, titles_overlapped, unique_titles)
	SELECT type_key, titles_overlapped, unique_titles
	FROM cte5;

-- Running this again with temp table
-- Barely takes a second to run
SELECT
	  code
	, description
	, titles_overlapped
	, unique_titles
FROM ##cte5 C
INNER JOIN gold.dim_item_type T
	ON C.type_key = T.type_key

--SELECT *
--FROM cte5;


-- Getting the results from cte5 takes 4 seconds to run to return 111 rows

-- Running it with the JOIN query at the end has it take 2:05m to run
-- Execution plan does indicate that the silver.dictionary table does use the NCL test index
-- It also recommend to create a new NCL that would impact the query 47.59%

/*
Missing Index Details from SQLQuery4.sql - DESKTOP-MVR5P9J\SQLEXPRESS.library (DESKTOP-MVR5P9J\Mary Huynh (61))
The Query Processor estimates that implementing the following index could improve the query cost by 47.5869%.
*/

/*
USE [tempdb]
GO
CREATE NONCLUSTERED INDEX idx_type_bibnum
ON [dbo].[##checkouts] ([type_key])
INCLUDE ([bibnum])
GO
*/

--DROP INDEX idx_type_bibnum ON ##checkouts;

-- In fact, creating the above query makes the query take LONGER. Takes 3:43m. But this is with not include the USE [tempdb]
-- Swithced to [tempdb], created the index, switched back the library db to run the query


CREATE TABLE ##item_col_pairs (bibnum INT, col_key INT);
INSERT INTO ##item_col_pairs (bibnum, col_key)
	SELECT bibnum, col_key
		FROM ##checkouts
		GROUP BY bibnum, col_key;
SELECT
	  col_key
	, 
	(SELECT col_key
	FROM (
		SELECT col_key, COUNT(*) AS test, ROW_NUMBER() OVER (ORDER BY COUNT(*)) AS rnk
		FROM 
			(
				SELECT bibnum, col_key
				FROM ##item_col_pairs T3
				WHERE EXISTS (
								SELECT 1 FROM
									(
									SELECT bibnum
									FROM ##item_col_pairs T2
									WHERE T1.col_key = T2.col_key
									) t
								WHERE T3.bibnum = t.bibnum
							)
				AND T3.col_key != T1.col_key
			) T4
		GROUP BY col_key
		) T5
		WHERE rnk = 1
		)

		
FROM ##item_col_pairs T1
GROUP BY T1.col_key



	
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
