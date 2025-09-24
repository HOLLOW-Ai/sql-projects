/*
===========================================================
  Miscellaneous Scripts
===========================================================
  If you're reading this, these are just random snippets of SQL queries I used while working in the Bronze layer.

  I didn't think it fit in the other folders so it was to keep the clean scripts separate from the mess of my working queries.
*/

-- working.sql

SELECT TOP 10 *
FROM bronze.dictionary
WHERE code like '%HOTSPOT%';

SELECT TOP 10 *
FROM bronze.checkouts
WHERE item_title LIKE '%HOTSPOT%';


SELECT *
FROM bronze.dictionary
WHERE code_type = 'ItemTypeDetail';

WITH item_col_tbl AS (
	SELECT *
	FROM bronze.dictionary
	WHERE code_type = 'ItemCollection'
)
SELECT *
FROM item_col_tbl
WHERE LOWER(code) != LOWER(TRIM(code))
;

-- Probably drop the 'Location' code_type because I don't plan to keep the item location in the Library Collection table
WITH item_col_tbl AS (
	SELECT *
	FROM bronze.dictionary
	WHERE code_type = 'Location'
)
SELECT *
FROM item_col_tbl
WHERE code = 'cen'
;

-- Keep description as is
WITH item_col_tbl AS (
	SELECT *
	FROM bronze.dictionary
	WHERE code_type != 'Location'
)
SELECT
	description
	, COUNT(*)
FROM item_col_tbl
GROUP BY description
HAVING COUNT(*) > 1
;



/*  =====================
	Catalog Table
    =====================
	- Should I make a publisher table?
	- Some publishers end with commas at the end and some have "" around them - remove if possible; periods are fine
	- No difference with UPPER() or LOWER(), mainly the spelling difference
	- Possible Change:
		- Keep multiple of the same copy of a book, but they belong to a different collection and/or location
		- Add in a new surrogate key like ROW_NUMBER() to the Inventory table; Call it inventory_id
		- Get the new Key into the Checkouts table by joining on BibNumber and Collection
	- Some of the titles and authors have inconsistencies, but just join on bibnum; get rid of dupes using ROW_NUMBER() and CTE
	- Do TRIM(), LOWER() on the titles and author if necessary
	- Split author name by delimiter
	- Drop Location, but keep the Collection
	- Order by ISBN and get rid of duplicates by ROW_NUMBER() OVER (PARTITION BY bibnum, item_type, item_col ORDER BY isbn DESC)
	
*/


-- Normal: 126,559 rows
-- Inconsistencies when inputting Publisher name, weird quotation marks around some of them
SELECT
	  LOWER(TRIM(publisher))
	, COUNT(*)
FROM loading
GROUP BY LOWER(TRIM(publisher))
ORDER BY LOWER(TRIM(publisher))
;


SELECT TOP 100 *
FROM loading
WHERE bibnum IN (
	SELECT
		bibnum
	FROM loading
	GROUP BY bibnum
	HAVING COUNT(*) > 1
)
ORDER BY bibnum
;

-- Multiple rows where you have multiple bibnum with multiple isbn

WITH bibnum_isbn AS (
SELECT DISTINCT
	bibnum
	, isbn
FROM loading
), cte2 AS (
	SELECT bibnum, COUNT(*) AS cnt
	FROM bibnum_isbn
	GROUP BY bibnum
	HAVING COUNT(*) > 1
)
SELECT *
FROM cte2;
--SELECT DISTINCT TOP 100 bibnum, isbn
--FROM loading
--WHERE bibnum IN (SELECT bibnum FROM cte2)
--ORDER BY bibnum;

-- Why does Suzume 1 and Suzume 3 have the same bibnum??
SELECT *, ROW_NUMBER() OVER (PARTITION BY bibnum, item_type, item_col ORDER BY isbn DESC) AS rn
FROM loading
WHERE bibnum IN (1702, 8489, 4031834, 3470, 8157, 11614, 13917, 19786)
;

-- Looks like someone incorrectly put Suzume 3 with the same bibnum as Suzume 1 in April 2025

SELECT *
FROM loading
WHERE author = 'Shinkai, Makoto'
ORDER BY bibnum
;

SELECT DISTINCT bibnum, author, isbn
FROM loading
WHERE bibnum = 4031834
;

-- ISBN null, item_col and item_loc differ
-- Could indicate multiple copies of this book existing in the inventory
SELECT *, ROW_NUMBER() OVER (PARTITION BY bibnum, item_type, item_col ORDER BY isbn DESC)
FROM loading
WHERE bibnum = 1702
;

SELECT DISTINCT *
FROM loading
WHERE bibnum = 3470
ORDER BY isbn DESC
;

-- Spelling diff of title, isbn has 1+, pub_year weird format, publisher spelling diff
SELECT DISTINCT *
FROM loading
WHERE bibnum = 8157
;

-- Spelling diff of Author
SELECT DISTINCT *
FROM loading
WHERE bibnum = 19786
;

SELECT *, ROW_NUMBER() OVER (PARTITION BY bibnum, isbn, item_type, item_col ORDER BY isbn DESC) AS rn
FROM loading
WHERE bibnum IN (1702, 8489, 4031834, 3470, 8157, 11614, 13917, 19786)
;


/*  =====================
	  Checkouts Table
    =====================
*/
-- Multiple id's show up
SELECT TOP 5 id
FROM bronze.checkouts
GROUP BY id
HAVING COUNT(*) > 1
;

SELECT *
FROM bronze.checkouts
WHERE id IN ('202303290802000010107757345', '202303290810000010104848691', '202303290937000010102444055', '202303290939000010093342136', '202303290939000010107019035')
ORDER BY id
;

-- 16,938,644 vs 16,614,613
SELECT COUNT(*), COUNT(DISTINCT id)
FROM bronze.checkouts;

-- 16,146,613 records return, remove when moving to new table
WITH distinct_recs AS (
	SELECT DISTINCT *
	FROM bronze.checkouts
)
SELECT COUNT(*)
FROM distinct_recs
;

SELECT *
FROM bronze.checkouts
WHERE LOWER(item_title) != LOWER(TRIM(item_title))
;

SELECT *
FROM bronze.checkouts
WHERE LEN(item_title) != LEN(TRIM(item_title))
;

-- Load checkouts into the Silver schema
WITH distinct_recs AS (
	SELECT DISTINCT *
	FROM bronze.checkouts
)
SELECT
	  id
	, checkout_year
	, bibnum
	, item_type
	, collection
	, item_title
	, checkout_datetime
INTO silver.checkouts
FROM distinct_recs;


INSERT INTO silver.checkout_records (id, checkout_year, bibnum, item_type, collection, item_title, checkout_datetime)
SELECT id, checkout_year, bibnum, item_type, collection, item_title, checkout_datetime
FROM silver.checkouts;


SELECT COUNT(*)
FROM silver.checkout_records;

SELECT *
FROM silver.checkout_records
WHERE item_title = 'HOTSPOT'
;

-- Deleting the hotspot records from checkouts
DELETE FROM silver.checkout_records
WHERE item_title = 'HOTSPOT'
;


WITH cte_dictionary AS (
	SELECT 
		  code
		, description
		, code_type
		, format_group
		, format_subgroup
		, cat_group
		, cat_subgroup
		, age_group
	FROM bronze.dictionary
	WHERE code NOT LIKE '%HOTSPOT%'
)
INSERT INTO silver.dictionary (
	  code
	, description
	, code_type
	, format_group
	, format_subgroup
	, cat_group
	, cat_subgroup
	, age_group
)
SELECT
	  code
	, description
	, code_type
	, format_group
	, format_subgroup
	, cat_group
	, cat_subgroup
	, age_group
FROM cte_dictionary
;

SELECT *
FROM silver.dictionary
WHERE code like '%HOTSPOT%';


-- workv2.sql

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
SELECT T1.bibnum, T1.title, T1.item_type, T2.bibnum, T2.title, T2.item_type
FROM cte2 T1
INNER JOIN cte2 T2
	ON T1.title = T2.title
	AND T1.item_type = T2.item_type
WHERE T1.bibnum != T2.bibnum
--SELECT DISTINCT T1.bibnum, T1.title, T2.bibnum, T2.title
--FROM cte2 T1
--INNER JOIN cte2 T2
--	ON T1.bibnum = T2.bibnum
--WHERE T1.title != T2.title AND T1.title < T2.title
--ORDER BY T1.bibnum
--;



-- inv_redo.sql

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
