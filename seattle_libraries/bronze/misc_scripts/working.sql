/*
===========================================================
  Miscellaneous Scripts
===========================================================
  If you're reading this, these are just random snippets of SQL queries I used while working in the Bronze layer.

  I didn't think it fit in the other folders so it was to keep the clean scripts separate from the mess of my working queries.
*/


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
