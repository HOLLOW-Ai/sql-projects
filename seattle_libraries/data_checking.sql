USE library;

SELECT *
FROM INFORMATION_SCHEMA.TABLES;


/*  =====================
	Data Dictionary Table
    =====================
	- Remove 'Location' rows from table
	- Create 2 tables for ItemCollection and ItemType
	- ItemTypeDetail: HOTSPOT? HOTSPOT rows found in bronze.checkouts, just remove from checkouts when loading to silver
	- This table is relatively clean
*/

SELECT TOP 10 *
FROM loading
WHERE item_type like '%HOTSPOT%';

SELECT TOP 10 *
FROM bronze.checkouts
WHERE item_title LIKE '%HOTSPOT%';

SELECT *
FROM bronze.dictionary;

SELECT DISTINCT code_type
FROM bronze.dictionary;

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
	WHERE code_type != 'Location'
)
SELECT *
FROM item_col_tbl
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

--SELECT
--	  code
--	, description
--	, format_group
--	, format_subgroup
--	, cat_group
--	, cat_subgroup
--	, age_group
--FROM item_col_tbl;


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
	
*/

SELECT TOP 100
	  bibnum
	, title
	, author
	, isbn
	, pub_year
	, publisher
	, item_type
	, item_col
FROM loading
;

-- Normal: 126,559 rows
-- Inconsistencies when inputting Publisher name, weird quotation marks around some of them
SELECT
	  LOWER(TRIM(publisher))
	, COUNT(*)
FROM loading
GROUP BY LOWER(TRIM(publisher))
ORDER BY LOWER(TRIM(publisher))
;

-- Update so publisher name doesn't end with a comma, period is fine
SELECT DISTINCT publisher
FROM loading
WHERE publisher LIKE '%,'
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
