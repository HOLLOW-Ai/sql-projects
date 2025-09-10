USE library;

SELECT *
FROM INFORMATION_SCHEMA.TABLES;

DROP TABLE dbo.loading;


CREATE TABLE bronze.raw_inv (
	  bibnum INT
	, title NVARCHAR(MAX)
	, author NVARCHAR(MAX)
	, isbn NVARCHAR(MAX)
	, pub_year NVARCHAR(MAX)
	, publisher NVARCHAR(MAX)
	, item_type NVARCHAR(MAX)
	, item_col NVARCHAR(MAX)
	, report_date DATE
);

-- Added:
-- 2020
-- 2021
-- 2022
-- 2023
-- 2024
-- 2025

BULK INSERT bronze.raw_inv
FROM '\Library_Collection_Inventory_20250908_2025.csv'
WITH (
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0A',
		FIRSTROW = 2,
		FORMAT = 'CSV' -- Needed to remove the quotes
);

-- 17,493,963 rows for 2020-2025
-- Now have 11,267,263 rows after running the delete query
SELECT COUNT(*)
FROM bronze.raw_inv;

-- Strangely, we get 11,267,263 distinct rows using all the columns
WITH distinct_rec AS (
	SELECT DISTINCT *
	FROM bronze.raw_inv
)
SELECT COUNT(*)
FROM distinct_rec;

-- Look at the distinct rows
WITH cte AS (
SELECT
	  bibnum
	, title
	, author
	, isbn
	, pub_year
	, publisher
	, item_type
	, item_col
	, report_date
	, ROW_NUMBER() OVER (PARTITION BY
							bibnum, title, author, isbn, pub_year, publisher, item_type, item_col, report_date
						 ORDER BY
							bibnum, title, author, isbn, pub_year, publisher, item_type, item_col, report_date
						 ) AS rn
FROM bronze.raw_inv
)
SELECT TOP 100 *
FROM cte
WHERE rn > 1
;


-- No room to move the distinct rows to a new table, so we're just going to use a CTE to delete rows with a row_num value > 1

-- 6,226,700 rows deleted
--WITH del_cte AS (
--	SELECT
--		  bibnum
--		, title
--		, author
--		, isbn
--		, pub_year
--		, publisher
--		, item_type
--		, item_col
--		, report_date
--		, ROW_NUMBER() OVER (PARTITION BY
--								bibnum, title, author, isbn, pub_year, publisher, item_type, item_col, report_date
--							 ORDER BY
--								bibnum, title, author, isbn, pub_year, publisher, item_type, item_col, report_date
--							 ) AS rn
--	FROM bronze.raw_inv
--)
--DELETE FROM del_cte
--WHERE rn > 1
--;

DROP INDEX idx_bibnum_ncl ON bronze.raw_inv;
CREATE NONCLUSTERED COLUMNSTORE INDEX idx_bibnum_ncl ON bronze.raw_inv (bibnum);

SELECT *
FROM bronze.raw_inv
WHERE bibnum = 4031834;

-- 858,970 distinct Bibnums this time; this is still close to the # of distinct bibnums from using all the data from 2020-2025
SELECT COUNT(DISTINCT bibnum)
FROM bronze.raw_inv;

--SELECT 375772 + 481814

-- Let's see the rows that have other rows with NULL info using a self join
WITH cte2 AS (
	SELECT
		  bibnum
		, title
		, author
		, isbn
		, pub_year
		, publisher
		, item_type
		, item_col
		, report_date
		, ROW_NUMBER() OVER (PARTITION BY bibnum ORDER BY report_date DESC) AS rn
	FROM bronze.raw_inv
)
SELECT TOP 100
	  T1.bibnum
	, T1.title
	, T1.author
	, T1.isbn
	, T1.pub_year
	, T1.publisher
	, T1.item_type
	, T1.item_col
	, T1.report_date
	, T2.title
	, T2.author
	, T2.isbn
	, T2.pub_year
	, T2.publisher
	, T2.item_type
	, T2.item_col
	, T2.report_date
FROM cte2 T1
INNER JOIN cte2 T2
	ON T1.bibnum = T2.bibnum
	AND T1.rn < T2.rn
	AND (
			T2.title IS NULL OR T2.author IS NULL OR T2.isbn IS NULL OR T2.pub_year IS NULL OR T2.item_type IS NULL OR T2.item_col IS NULL
		)
WHERE T1.rn = 1
;

-- Create a CTE where i group by BibNum and find the MAX() value for each column, and then use another CTE to combine it to the Main query to COALESCE() if any information is missing
SELECT TOP 1000
	  bibnum
	, MAX(title)
	, MAX(author)
	, MAX(isbn)
	, MAX(pub_year)
	, MAX(publisher)
FROM bronze.raw_inv
GROUP BY bibnum;

SELECT TOP 1000
	  bibnum
	, MAX(report_date) AS latest_date
FROM bronze.raw_inv
GROUP BY bibnum;


-- Do I include 'item_type' as something to partition by?
-- Check the item_types that have NULL values typically for isbn, or other missing info
WITH latest_report AS (
SELECT
	  bibnum
	, title
	, author
	, isbn
	, pub_year
	, publisher
	, item_type
	, item_col
	, report_date
	, ROW_NUMBER() OVER (PARTITION BY bibnum ORDER BY report_date DESC) AS rownum
FROM bronze.raw_inv
)
SELECT *
FROM latest_report
WHERE rownum = 1;

SELECT *
FROM bronze.raw_inv
WHERE rownum = 1;

SELECT DISTINCT item_type
FROM bronze.raw_inv;


WITH items AS (
SELECT DISTINCT item_type
FROM bronze.raw_inv
)
SELECT I.item_type, D.code, D.description
FROM items I
LEFT JOIN silver.dictionary D
	ON I.item_type = D.code
;

-- 76 diff item_types
WITH null_isbn AS (
	SELECT item_type, COUNT(*) AS num_null
	FROM bronze.raw_inv
	WHERE isbn IS NULL
	GROUP BY item_type
), cte2 AS (
	SELECT item_type, COUNT(*) AS total_recs
	FROM bronze.raw_inv
	GROUP BY item_type
)
SELECT T1.item_type, D.description, T2.num_null, ROUND(100.0 * T2.num_null / total_recs, 2) AS prop
FROM cte2 T1
LEFT JOIN null_isbn T2
	ON T1.item_type = T2.item_type
INNER JOIN silver.dictionary D
	ON T1.item_type = D.code
ORDER BY prop
;


SELECT *
FROM bronze.raw_inv
WHERE item_type IN ('acrec', 'ucfold');

-- Find the bibnums that have different item_types

WITH test AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY bibnum, item_type ORDER BY report_date) AS rn
FROM bronze.raw_inv
)
SELECT *
FROM test
WHERE rn = 1
	AND isbn IS NULL;


-- Takes 2:16 for 1000 rows, highest operation cost is a SORT
-- 7+ min and still executing for all rows
--WITH filled_info AS (
--	SELECT 
--		  bibnum
--		, MAX(title) AS title
--		, MAX(author) AS author
--		, MAX(isbn) AS isbn
--		, MAX(pub_year) AS pub_year
--		, MAX(publisher) AS publisher
--		, item_type
--	FROM bronze.raw_inv
--	GROUP BY bibnum, item_type
--), latest_report AS (
--	SELECT
--		  bibnum
--		, title
--		, author
--		, isbn
--		, pub_year
--		, publisher
--		, item_type
--		, item_col
--		, report_date
--		, ROW_NUMBER() OVER (PARTITION BY bibnum ORDER BY report_date DESC) AS rownum
--	FROM bronze.raw_inv
--)
--SELECT
--	  R.bibnum
--	, COALESCE(R.title, I.title) AS title
--	, COALESCE(R.author, I.author) AS author
--	, COALESCE(R.isbn, I.isbn) AS isbn
--	, COALESCE(R.pub_year, I.pub_year) AS pub_year
--	, COALESCE(R.publisher, I.publisher) AS publisher
--	, R.item_type
--	, R.report_date
--FROM latest_report AS R
--LEFT JOIN filled_info I
--	ON R.bibnum = I.bibnum
--	AND R.item_type = I.item_type
--WHERE R.rownum = 1;






-- 39 secs for 1000 rows
-- 2:04 time for 1mil rows
WITH filled_info AS (
	SELECT 
		  bibnum
		, MAX(title) AS title
		, MAX(author) AS author
		, MAX(isbn) AS isbn
		, MAX(pub_year) AS pub_year
		, MAX(publisher) AS publisher
		, item_type
	FROM bronze.raw_inv
	GROUP BY bibnum, item_type
), latest_report AS (
	SELECT
		  bibnum
		, item_type
		, MAX(report_date) AS latest_date
		--, ROW_NUMBER() OVER (PARTITION BY bibnum, item_type ORDER BY report_date DESC) AS rownum
	FROM bronze.raw_inv
	GROUP BY bibnum, item_type
)
SELECT
	  R.bibnum
	, COALESCE(R.title, I.title) AS title
	, COALESCE(R.author, I.author) AS author
	, COALESCE(R.isbn, I.isbn) AS isbn
	, COALESCE(R.pub_year, I.pub_year) AS pub_year
	, COALESCE(R.publisher, I.publisher) AS publisher
	, R.item_type
	, R.report_date
FROM bronze.raw_inv R
INNER JOIN latest_report L
	ON R.bibnum = L.bibnum
	AND R.item_type = L.item_type
	AND R.report_date = L.latest_date
INNER JOIN filled_info I
	ON R.bibnum = I.bibnum
	AND R.item_type = I.item_type
;





-- Takes 1:38 min, same amount of rows still
-- Getting a million rows when I should be getting around 870,000 rows
-- Running the Info CTE returns the 876,246 rows that is expected

-- The issue might be that I need the unique combination of BibNum, Item_Type, and Report_Date instead

-- Now runtime is 1:46 but we have the expected output now
WITH info AS (
	SELECT 
		  bibnum
		, MAX(title) AS title
		, MAX(author) AS author
		, MAX(isbn) AS isbn
		, MAX(pub_year) AS pub_year
		, MAX(publisher) AS publisher
		, item_type
		, MAX(report_date) AS report_date
	FROM bronze.raw_inv
	GROUP BY bibnum, item_type
), num_rows AS (
	SELECT
		  bibnum
		, title
		, author
		, isbn
		, pub_year
		, publisher
		, item_type
		, report_date
		, ROW_NUMBER() OVER (PARTITION BY bibnum, item_type ORDER BY report_date DESC) AS rn
	FROM bronze.raw_inv
)
SELECT
	  R.bibnum
	, COALESCE(R.title, I.title) AS title
	, COALESCE(R.author, I.author) AS author
	, COALESCE(R.isbn, I.isbn) AS isbn
	, COALESCE(R.pub_year, I.pub_year) AS pub_year
	, COALESCE(R.publisher, I.publisher) AS publisher
	, R.item_type
	, R.report_date
FROM num_rows R
INNER JOIN info I
	ON R.bibnum = I.bibnum
	AND R.item_type = I.item_type
	AND R.report_date = I.report_date
	AND rn = 1
;

-- There are only distinct rows in the table, at 11,267,263 rows; just use GROUP BY instead of DISTINCT next time
WITH cte3 AS (
SELECT DISTINCT *
FROM bronze.raw_inv
)
SELECT COUNT(*)
FROM cte3;

-- There are 875,246 combinations of BibNum and Item_Type
-- 8,837,374 combinations, but we just want the latest date so it should be reduced later --> Still expect 875,246 rows
WITH cte4 AS (
SELECT bibnum, item_type, MAX(report_date) AS last_date
FROM bronze.raw_inv
GROUP BY bibnum, item_type
)
SELECT COUNT(*)
FROM cte4;
