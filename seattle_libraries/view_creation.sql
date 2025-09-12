/*
	====================================================
	Create Dimension View: gold.dim_item_collection
	====================================================

	Join the code from the dictionary, filtered to 'ItemCollection', and then join in to the Checkout Records and then replace it with the Key column
	Notes:
	- Should double-check if I want to impute a value for a NULL in a text column, or just leave it as NULL instead

	====================================================
*/
IF OBJECT_ID ('gold.dim_item_collection') IS NOT NULL
	DROP VIEW gold.dim_item_collection;
GO

-- I probably should've done this when I was transferring this from Bronze to Silver
CREATE VIEW gold.dim_item_collection AS
SELECT
	ROW_NUMBER() OVER (ORDER BY code) AS col_key
	, code
	, description
	, COALESCE(format_group, 'Other') AS format_group
	, COALESCE(format_subgroup, 'Other') AS format_subgroup
	, COALESCE(cat_group, 'Miscellaneous') AS cat_group
	, COALESCE(cat_subgroup, 'N/A') AS cat_subgroup
	, COALESCE(age_group, 'N/A') AS age_group
FROM silver.dictionary
WHERE TRIM(code_type) = 'ItemCollection';
GO

--SELECT
--	  code
--	, description
--	--, code_type
--	, COALESCE(format_group, 'Other') AS format_group	-- To get rid of NULLs, I'll say it will be imputed with 'Other'
--	, COALESCE(format_subgroup, 'Other') AS format_subgroup
--	, COALESCE(cat_group, 'Miscellaneous') AS cat_group		-- Since this already has 'Miscellaneous' as a Category Group, I'll use that because there isn't a dictionary for these terms on the data page
--	, COALESCE(cat_subgroup, 'N/A') AS cat_subgroup		-- The subgroups are mostly NULL, so I think I'll put 'N/A' for now because this is a specialized category
--	, COALESCE(age_group, 'N/A') AS age_group	-- There's also NULLs here, so I'll put 'N/A'
--FROM silver.dictionary
--WHERE TRIM(code_type) = 'ItemCollection';


/*
	====================================================
	Create Dimension View: gold.dim_item_type
	====================================================

	Notes:
	- Should double-check if I want to impute a value for a NULL in a text column, or just leave it as NULL instead
*/

IF OBJECT_ID ('gold.dim_item_type') IS NOT NULL
	DROP VIEW gold.dim_item_type;
GO

CREATE VIEW gold.dim_item_type AS
SELECT
	  ROW_NUMBER() OVER (ORDER BY code) AS type_key
	,  code
	, description
	, COALESCE(format_group, 'Other') AS format_group	-- 1 NULL value, will impute with 'Other' since it exists
	, COALESCE(format_subgroup, 'Other') AS format_subgroup
	, COALESCE(cat_group, 'Miscellaneous') AS cat_group
	, COALESCE(cat_subgroup, 'N/A') AS cat_subgroup -- Only 1 value that has a subgroup
	, COALESCE(age_group, 'N/A') AS age_group -- 1 NULL value, going with N/A
FROM silver.dictionary
WHERE TRIM(code_type) = 'ItemType';
GO



/*
	====================================================
	Create Dimension View: gold.dim_inventory
	====================================================

	Notes:
	- 'item_type' column is removed because it will be reconnected back in the Fact table
	- For the rows that still have NULL in the 'isbn' column, then it will be imputed with 'N/A'
	- There are some records in Checkout where it has a title, but the associated BibNum in the Inventory table has a record that exists but no title
*/

IF OBJECT_ID ('gold.dim_inventory') IS NOT NULL
	DROP VIEW gold.dim_inventory;
GO

CREATE VIEW gold.dim_inventory AS
WITH impute_titles AS (
	SELECT
		  bibnum
		, item_type
		, item_title
	FROM silver.checkout_records R
	WHERE EXISTS
		(SELECT 1 FROM silver.inventory I WHERE R.bibnum = I.bibnum AND I.title IS NULL AND R.item_title IS NOT NULL)
)
SELECT
	  ROW_NUMBER() OVER (ORDER BY I.bibnum ASC, I.item_type ASC) AS inv_key
	, I.bibnum
	, COALESCE(I.title, T.item_title) AS title
	, author
	, isbn
	, pub_year
	, publisher
	, report_date AS latest_report_date
FROM silver.inventory AS I
LEFT JOIN impute_titles AS T
	ON I.bibnum = T.bibnum
	AND I.item_type = T.item_type
;
GO

-- Testing queries
SELECT *
FROM silver.checkout_records
WHERE bibnum = 439801;

SELECT *
FROM silver.inventory
WHERE author IS NULL
AND title IS NULL
AND isbn IS NULL
;

SELECT
	  bibnum
	, item_type
	, item_title
FROM silver.checkout_records R
WHERE EXISTS
	(SELECT 1 FROM silver.inventory I WHERE R.bibnum = I.bibnum AND I.title IS NULL AND R.item_title IS NOT NULL)
;

SELECT *
FROM silver.inventory I
WHERE EXISTS 
	(SELECT 1 FROM silver.checkout_records R WHERE R.bibnum = I.bibnum AND I.author IS NULL AND I.title IS NULL AND isbn IS NULL)


/*
	====================================================
	Create Fact View: gold.fact_checkouts
	====================================================

	Notes:
	- This view should be created last after creating the dimension tables
*/

SELECT TOP 1000
	  id AS checkout_id	-- ID cannot be cast as BIGINT because the values are too big they overflow
	, checkout_year
	, bibnum
	, item_type
	, collection AS item_collection
	, item_title
	, checkout_datetime
FROM silver.checkout_records;

-- Interesting that 19,966 items have BibNums that have been checked out but are not reported in the library inventory
-- Even after checking the full inventory dataset uploaded on the City's site, these items do not have a BibNum in the data
-- To follow that Dimension-Fact model, these rows will not be included in the Views because ideally the FKs in a Fact table should be referencing something

-- After filtering, should expect there to be 76,970 less rows in the checkout table (Should be an expected 16,537,540 rows)
-- This works correctly, use this to create the view
WITH counts AS (
SELECT *
FROM silver.checkout_records R
WHERE EXISTS
	(SELECT 1 FROM silver.inventory I WHERE I.bibnum = R.bibnum)
)
SELECT COUNT(*)
FROM counts;

-- Every checkout ID is distinct
SELECT COUNT(DISTINCT id)
FROM silver.checkout_records;

-- Checking for duplicate Checkout IDs
WITH cte AS (
SELECT id
FROM silver.checkout_records
GROUP BY id
HAVING COUNT(*) > 1
)
SELECT *
FROM silver.checkout_records R
WHERE EXISTS (
				SELECT 1 FROM cte WHERE cte.id = R.id
			);

SELECT *
FROM silver.inventory
WHERE bibnum = 3999220;

SELECT 16614510 - 76970;

SELECT *
FROM INFORMATION_SCHEMA.VIEWS;
