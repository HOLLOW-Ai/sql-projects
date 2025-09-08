USE library;

SELECT *
FROM INFORMATION_SCHEMA.TABLES;

-- To Do:
	-- Check if bronze.dictionary is ready to drop

-- 2,935,842 rows
-- This does a table scan
SELECT COUNT(*)
FROM loading;

SELECT DISTINCT *
FROM loading;

-- 375,772 BibNumbers have more than 1 unique entry; 241 cost -> cost of 7; 5secs vs 2
SELECT bibnum
FROM loading
GROUP BY bibnum
HAVING COUNT(*) > 1;

-- 481,814 BibNumbers have only 1 entry; 241 cost -> 12 cost after nonclustered index; 5secs vs 2
SELECT bibnum
FROM loading
GROUP BY bibnum
HAVING COUNT(*) = 1;

/*
	Index Notes
	=================================

	- Index: Data structure that provides quick access to data, optimizing the speed of queries

	Index Types (Structure, Storage, Functions):
	- Structure
		- Clustered: TAble of Contents
		- Non-Clustered: Book Index

	- Storage
		- Rowstore
		- Columnstore

	- Functions
		- Unique
		- Filtered

	No Clustered Index? Heap Structure, Fast writes, slow reads
*/

CREATE NONCLUSTERED INDEX idx_bibnum ON dbo.loading (bibnum);
DROP INDEX idx_bibnum ON dbo.loading;

-- With a regular index, the size of dbo.loading is 2520 MB for the table and 51 MB for the index (Total: 2571 MB)
-- COLUMNSTORE does make the query run a little longer, but still faster than a Heap
CREATE NONCLUSTERED COLUMNSTORE INDEX idx_bibnum ON dbo.loading (bibnum);

-- Data space increases to 2535 MB but Index size drops to 16 MB (2551 MB)
-- Baraa's video has the Properties tab listing that the Compression Type is Columnstore but mine is listed as None

SELECT bibnum, title, author, isbn, item_type
FROM loading
WHERE bibnum = 4031834
;

-- Return the rows where this combination of columns does not exist with any other bibnum

SELECT DISTINCT bibnum, title, author, isbn
FROM loading L1
WHERE NOT EXISTS (
	SELECT 1
	FROM loading L2
	WHERE L1.bibnum != L2.bibnum
		AND L1.title = L2.title
		AND L1.author = L2.author
		AND L1.isbn = L2.isbn
	)
AND bibnum = 4031834;

SELECT DISTINCT bibnum, title, author, isbn, pub_year, publisher, item_type, ROW_NUMBER() OVER (
																							PARTITION BY bibnum, title, author, isbn, pub_year, publisher, item_type
																							ORDER BY bibnum, title, author, isbn) AS rn
FROM loading
WHERE bibnum IN (
	SELECT bibnum
	FROM loading
	GROUP BY bibnum
	HAVING COUNT(*) > 1
	)
ORDER BY bibnum, rn
;

SELECT TOP 10 bibnum
FROM loading
ORDER BY bibnum;


-- Presumably, the bibnum is an indiciation of the relative order of when an item is catalogued in the seattle libraries
SELECT bibnum, title
FROM loading L1
WHERE EXISTS (
			SELECT 1
			FROM loading L2
			WHERE L1.bibnum < L2.bibnum
			AND L1.isbn = L2.isbn
			)
AND bibnum < 1000
;

WITH RankedBooks AS (
    SELECT 
        bibnum, 
        isbn, 
        title, 
        ROW_NUMBER() OVER (PARTITION BY isbn ORDER BY bibnum ASC) AS row_num
    FROM loading
)
SELECT bibnum, title
FROM RankedBooks
WHERE row_num > 1;

-- First step is to removing all the wrongly input records
-- Then figure out how to coalesce information

-- Maybe I drop Item_Collection and Item_location from "Loading"

SELECT DISTINCT
	  bibnum
	, title
	, author
	, isbn
	, pub_year
	, publisher
	, item_type
FROM loading
WHERE bibnum IN (
					SELECT bibnum
					FROM loading
					GROUP BY bibnum
					HAVING COUNT(*) > 1
				)
ORDER BY bibnum;

-- Adult/YA description, Ref Adult/YA
SELECT *
FROM silver.dictionary
WHERE code IN ('arbk', 'acbk');


SELECT COUNT(bibnum)
FROM loading;

-- 12 seconds
WITH cte AS (
SELECT DISTINCT
	  bibnum
	, title
	, author
	, isbn
	, pub_year
	, publisher
	, item_type
FROM loading
)
SELECT COUNT(bibnum)
FROM cte;

-- 12 seconds too
WITH cte2 AS (
	SELECT
		  bibnum
		, title
		, author
		, isbn
		, pub_year
		, publisher
		, item_type
	FROM loading
	GROUP BY bibnum, title, author, isbn, pub_year, publisher, item_type
)
SELECT COUNT(bibnum)
FROM cte2;


WITH reduced_tbl AS (
	SELECT DISTINCT
		  bibnum
		, title
		, author
		, isbn
		, pub_year
		, publisher
		, item_type
	FROM loading
)
SELECT
	  bibnum
	, title
	, author
	, isbn
	, pub_year
	, publisher
	, item_type
INTO silver.catalog
FROM reduced_tbl
;

SELECT *
FROM silver.catalog;

SELECT *
FROM silver.catalog
GROUP BY title
HAVING COUNT(*) > 1
ORDER BY bibnum;

SELECT *
FROM silver.catalog
WHERE bibnum = 4031834;

-- Bibnums have rows where the only filled data is the bibnum and item_type, and next record for the same Bibnum has all the info filled out
-- Maybe create a another table in a CTE or whatever with filtering to make sure no data is missing and then join to use COALESCE()
-- LAG and LEAD? Combined with CASE WHEN and COALESCE
SELECT *, ROW_NUMBER() OVER (PARTITION BY bibnum ORDER BY bibnum) AS rn
FROM silver.catalog
WHERE bibnum IN (
	SELECT bibnum
	FROM silver.catalog
	WHERE isbn IS NULL
	GROUP BY bibnum
)
ORDER BY isbn DESC, bibnum, rn;

SELECT *
FROM silver.catalog
WHERE title IS NULL;

SELECT *
FROM silver.catalog
WHERE bibnum = 1271782;

-- 889,278 rows vs 857,586 distinct IDs: 31,692 difference
SELECT COUNT(*)
FROM silver.catalog;

SELECT COUNT(DISTINCT bibnum)
FROM silver.catalog;


-- This returns 30,438 BibNums have multiple records
-- 827,148 items have its BibNum show up only once

WITH cte2 AS (
SELECT DISTINCT
	  bibnum
	, title
	, author
	, isbn
	, pub_year
	, publisher
	, item_type
	, ROW_NUMBER() OVER (PARTITION BY bibnum ORDER BY isbn DESC) AS rn
FROM silver.catalog
WHERE bibnum IN (
					SELECT bibnum
					FROM silver.catalog
					GROUP BY bibnum
					HAVING COUNT(*) > 1
				)
)
SELECT DISTINCT T1.bibnum, T1.title, T2.bibnum, T2.title
FROM cte2 T1
INNER JOIN cte2 T2
	ON T1.bibnum = T2.bibnum
WHERE T1.title != T2.title AND T1.title < T2.title
ORDER BY T1.bibnum;



/*
	Union to combine the items with 1 rows with the items with multiple records after I figure out how to de-duplicate, combine them

	SELECT
		  bibnum
		, title
		, author
		, isbn
		, pub_year
		, publisher
		, item_type
	FROM silver.catalog
	WHERE bibnum IN (
						SELECT bibnum
						FROM silver.catalog
						GROUP BY bibnum
						HAVING COUNT(*) = 1
					)

	UNION
*/
