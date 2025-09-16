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
-- Query #: Top Checked out _Books_ Each Month
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




-- ======================================================
-- Most Popular Collections
-- ======================================================



-- ======================================================
-- Collection Overlap - How much do Bibnums overlap in other collections?
-- ======================================================

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS;



-- ======================================================
-- Most Popular Authors
-- ======================================================

-- ======================================================
-- Most Popular Publishers, although may vary
-- ======================================================


-- ======================================================
-- Items with the Oldest Report Date + Record where it was last checked out
-- ======================================================
