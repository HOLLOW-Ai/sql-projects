/*
	======================================================
	NULL Check
	======================================================
	This is a procedure used to create a result set of the number of null values in a column from a particular table and the percentage of nulls out of the total rows in that particular table.

	Notes:
	- Perhaps I could look into finding a more dynamic way of generating a null report using variables
*/

--CREATE OR ALTER PROCEDURE gold.null_report AS
--BEGIN

-- CTE to count NULL values in Inventory table
WITH null_report AS (
	SELECT
		  COUNT(*) - COUNT(bibnum) AS bibnum -- should be 0
		, COUNT(*) - COUNT(title) AS title
		, COUNT(*) - COUNT(author) AS author
		, COUNT(*) - COUNT(isbn) AS isbn
		, COUNT(*) - COUNT(pub_year) AS pub_year
		, COUNT(*) - COUNT(publisher) AS publisher
		, COUNT(*) - COUNT(latest_report_date) AS latest_report_date -- should be 0
		, COUNT(*) AS num_rows
	FROM ##inventory
), 

-- CTE to count NULL values in Checkouts table
checkout_nulls AS (
	SELECT
		  COUNT(*) - COUNT(checkout_id) AS checkout_id
		, COUNT(*) - COUNT(bibnum) AS bibnum
		, COUNT(*) - COUNT(type_Key) AS type_key
		, COUNT(*) - COUNT(col_key) AS col_key
		, COUNT(*) - COUNT(checkout_datetime) AS checkout_datetime
		, COUNT(*) AS num_rows
	FROM ##checkouts
), 

-- CTE to count NULL values in Item Collections table
collection_nulls AS (
	SELECT
		  COUNT(*) - COUNT(col_key) AS col_key
		, COUNT(*) - COUNT(code) AS code
		, COUNT(*) - COUNT(description) AS description
		, COUNT(*) - COUNT(format_group) AS format_group
		, COUNT(*) - COUNT(format_subgroup) AS format_subgroup
		, COUNT(*) - COUNT(cat_group) AS cat_group
		, COUNT(*) - COUNT(cat_subgroup) AS cat_subgroup
		, COUNT(*) - COUNT(age_group) AS age_group
		, COUNT(*) AS num_rows
	FROM gold.dim_item_collection
), 

-- CTE to count NULL values in Item Types table
type_nulls AS (
	SELECT
		  COUNT(*) - COUNT(type_key) AS type_key
		, COUNT(*) - COUNT(code) AS code
		, COUNT(*) - COUNT(description) AS description
		, COUNT(*) - COUNT(format_group) AS format_group
		, COUNT(*) - COUNT(format_subgroup) AS format_subgroup
		, COUNT(*) - COUNT(cat_group) AS cat_group
		, COUNT(*) - COUNT(cat_subgroup) AS cat_subgroup
		, COUNT(*) - COUNT(age_group) AS age_group
		, COUNT(*) AS num_rows
	FROM gold.dim_item_type
)

-- Unpivot Inventory
SELECT 'Inventory' AS table_name, column_name, num_nulls, num_rows, CAST(ROUND((100.0 * num_nulls / num_rows), 2) AS DECIMAL(5, 2)) AS perc_null
FROM (
		SELECT
			  bibnum
			, title
			, author
			, isbn
			, pub_year
			, publisher
			, latest_report_date
			, num_rows
		FROM null_report
	) P_inv
UNPIVOT
	(num_nulls FOR column_name IN (bibnum, title, author, isbn, pub_year, publisher, latest_report_date)
) AS U_inv

UNION ALL

-- Unpivot Checkouts
SELECT 'Checkouts', column_name, num_nulls, num_rows, CAST(ROUND((100.0 * num_nulls / num_rows), 2) AS DECIMAL(5, 2)) AS perc_null
FROM (
		SELECT
			  checkout_id
			, bibnum
			, type_key
			, col_key
			, checkout_datetime
			, num_rows
		FROM checkout_nulls
	) P_chk
UNPIVOT
	(num_nulls FOR column_name IN (checkout_id, bibnum, type_key, col_key, checkout_datetime)
) AS U_chk

UNION

-- Unpivot Item Collection
SELECT 'Item Collection', column_name, num_nulls, num_rows, CAST(ROUND((100.0 * num_nulls / num_rows), 2) AS DECIMAL(5, 2)) AS perc_null
FROM (
		SELECT
			  col_key
			, code
			, description
			, format_group
			, format_subgroup
			, cat_group
			, cat_subgroup
			, age_group
			, num_rows
		FROM collection_nulls
	) P_col
UNPIVOT
	(num_nulls FOR column_name IN (col_key, code, description, format_group, format_subgroup, cat_group, cat_subgroup, age_group)
) AS U_col

UNION

-- Unpivot Item Type
SELECT 'Item Type', column_name, num_nulls, num_rows, CAST(ROUND((100.0 * num_nulls / num_rows), 2) AS DECIMAL(5, 2)) AS perc_null
FROM (
		SELECT
			  type_key
			, code
			, description
			, format_group
			, format_subgroup
			, cat_group
			, cat_subgroup
			, age_group
			, num_rows
		FROM type_nulls
	) P_type
UNPIVOT
	(num_nulls FOR column_name IN (type_key, code, description, format_group, format_subgroup, cat_group, cat_subgroup, age_group)
) AS U_type

ORDER BY table_name
;
--END
--GO

EXEC gold.null_report;
