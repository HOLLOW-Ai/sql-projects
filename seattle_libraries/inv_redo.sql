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
