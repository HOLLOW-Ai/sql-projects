USE library;

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS;

SELECT TOP 1000
	ROW_NUMBER() OVER (ORDER BY bibnum ASC, item_type ASC) AS inv_key
	, bibnum
	, title
	, author
	, isbn
	, pub_year
	, publisher
	, item_type
	, report_date AS latest_report_date
FROM silver.inventory;


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
WITH data_check AS (
	SELECT *
	FROM silver.checkout_records R
	WHERE NOT EXISTS
		(SELECT 1 FROM silver.inventory I WHERE I.bibnum = R.bibnum)
)
SELECT bibnum
FROM data_check
GROUP BY bibnum;

SELECT *
FROM silver.inventory
WHERE bibnum = 3999220;

--SELECT TOP 1000
--	  code
--	, description
--	, code_type
--	, format_group
--	, format_subgroup
--	, cat_group
--	, cat_subgroup
--	, age_group
--FROM silver.dictionary
--WHERE TRIM(code_type) = 'Location';

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

-- You have NULL format_group values, so what does 'Other' constitute as?
-- cat_group also has NULL values, so what does 'Miscellaneous' mean?
-- Perhaps impute cat_subgroup with 'N/A' value?
SELECT
	  code
	, description
	--, code_type
	, COALESCE(format_group, 'Other') AS format_group	-- 1 NULL value, will impute with 'Other' since it exists
	, COALESCE(format_subgroup, 'Other') AS format_subgroup
	, COALESCE(cat_group, 'Miscellaneous') AS cat_group
	, COALESCE(cat_subgroup, 'N/A') AS cat_subgroup -- Only 1 value that has a subgroup
	, COALESCE(age_group, 'N/A') AS age_group -- 1 NULL value, going with N/A
FROM silver.dictionary
WHERE TRIM(code_type) = 'ItemType';

SELECT DISTINCT code_type
FROM silver.dictionary;

-- Add Row_Number() as a surrogate key



/*
	====================================================
	Create Dimension View: gold.dim_item_type
	====================================================
*/
IF OBJECT_ID ('gold.dim_item_type') IS NOT NULL
	DROP VIEW gold.dim_item_type
GO

CREATE SCHEMA gold;
GO

CREATE VIEW gold.dim_item_type AS
SELECT
	  code
	, description
	, COALESCE(format_group, 'Other') AS format_group
	, COALESCE(format_subgroup, 'Other') AS format_subgroup
	, COALESCE(cat_group, 'Miscellaneous') AS cat_group
	, COALESCE(cat_subgroup, 'N/A') AS cat_subgroup
	, COALESCE(age_group, 'N/A') AS age_group
FROM silver.dictionary
WHERE TRIM(code_type) = 'ItemCollection';
GO
