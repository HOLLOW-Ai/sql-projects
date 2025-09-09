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

SELECT TOP 1000
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
FROM bronze.raw_inv;
