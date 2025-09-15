USE library;

--EXEC gold.temp_checkout_heap;

--EXEC gold.temp_inv_heap;

-- ======================================================
-- Query #: NULL Checks
-- ======================================================
-- Union ALL Report of Null Values in Each Table

-- Structure: inventory_null_checks (column_name, num_null_values, total_rows, perc_null)
-- Few ways to find Nulls, use SET STATISTICS and Execution Plan to check performance
-- Need to figure out how to pivot the column names into rows

SELECT TOP 100
	  *
FROM ##inventory;

SET STATISTICS TIME ON;

WITH null_report AS (
	SELECT
		  COUNT(*) - COUNT(bibnum) AS bibnum_nulls -- should be 0
		, COUNT(*) - COUNT(title) AS title_nulls
		, COUNT(*) - COUNT(author) AS author_nulls
		, COUNT(*) - COUNT(isbn) AS isbn_nulls
		, COUNT(*) - COUNT(pub_year) AS year_nulls
		, COUNT(*) - COUNT(publisher) AS publisher_nulls
		, COUNT(*) - COUNT(latest_report_date) AS date_nulls -- should be 0
		, COUNT(*) AS num_rows
	FROM ##inventory
)
SELECT column_name, num_nulls, num_rows, CAST(ROUND((100.0 * num_nulls / num_rows), 2) AS DECIMAL(5, 2)) AS perc_null
FROM (
		SELECT
			  bibnum_nulls
			, title_nulls
			, author_nulls
			, isbn_nulls
			, year_nulls
			, publisher_nulls
			, date_nulls
			, num_rows
		FROM null_report
	) P
UNPIVOT
	(num_nulls FOR column_name IN (bibnum_nulls, title_nulls, author_nulls, isbn_nulls, year_nulls, publisher_nulls, date_nulls)
) AS U;
--SET STATISTICS TIME OFF;


-- They should ideally all be 0
WITH checkout_nulls AS (
	SELECT
		  COUNT(*) - COUNT(checkout_id) AS id_nulls
		, COUNT(*) - COUNT(bibnum) AS bibnum_nulls
		, COUNT(*) - COUNT(type_Key) AS type_nulls
		, COUNT(*) - COUNT(col_key) AS col_nulls
		, COUNT(*) - COUNT(checkout_datetime) AS datetime_nulls
		, COUNT(*) AS num_rows
	FROM ##checkouts
)
SELECT column_name, num_nulls, num_rows, CAST(ROUND((100.0 * num_nulls / num_rows), 2) AS DECIMAL(5, 2)) AS perc_null
FROM (
		SELECT
			  id_nulls
			, bibnum_nulls
			, type_nulls
			, col_nulls
			, datetime_nulls
			, num_rows
		FROM checkout_nulls
	) P
UNPIVOT
	(num_nulls FOR column_name IN (id_nulls, bibnum_nulls, type_nulls, col_nulls, datetime_nulls)
) AS U;

SELECT TOP 10 *
FROM ##checkouts;
