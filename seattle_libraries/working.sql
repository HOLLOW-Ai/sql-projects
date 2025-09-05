CREATE DATABASE library;
USE library;

DROP TABLE staging;

CREATE TABLE staging (
	  bibnum NVARCHAR(MAX)
	, title NVARCHAR(MAX)
	, author NVARCHAR(MAX)
	, isbn NVARCHAR(MAX)
	, pub_year NVARCHAR(MAX)
	, publisher NVARCHAR(MAX)
	, item_type NVARCHAR(MAX)
	, item_col NVARCHAR(MAX)
	, item_loc NVARCHAR(MAX)
);

CREATE TABLE loading (
	  bibnum INT
	, title NVARCHAR(MAX)
	, author NVARCHAR(MAX)
	, isbn NVARCHAR(MAX)
	, pub_year NVARCHAR(MAX)
	, publisher NVARCHAR(MAX)
	, item_type NVARCHAR(MAX)
	, item_col NVARCHAR(MAX)
	, item_loc NVARCHAR(MAX)
);

BULK INSERT staging
FROM '\Library_Collection_Inventory_20250903(1).csv'
WITH (
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0A',
		FIRSTROW = 2,
		FORMAT = 'CSV' -- Needed to remove the quotes
);

SELECT TOP 100 *
FROM staging;

WITH cte AS (
SELECT bibnum
FROM staging
GROUP BY bibnum, title, author, isbn, pub_year, publisher, item_type, item_col, item_loc
HAVING COUNT(*) > 1
)
SELECT COUNT(*)
FROM cte;

WITH cte2 AS (
	SELECT DISTINCT *
	FROM staging
)
SELECT COUNT(*)
FROM cte2;



INSERT INTO loading
SELECT DISTINCT *
FROM staging;

SELECT TOP 100 *, 2025 AS data_year
FROM loading;

-- Added data
-- 2025


-- Staging Data
	-- 2024: 14,446,679 rows raw; 1,735,955 distinct
	-- 2023: 10,180,283 rows raw; 1,807,218 distinct
	-- 2022: 17,639,430 rows raw; 1,861,674 distinct
	-- 2021: 17,725,364 rows raw; 1,665,362 distinct
	-- 2020: 17,487,259 rows raw; 1,661,134 distinct

WITH distinct_cnt AS (
	SELECT DISTINCT *
	FROM staging
)
SELECT COUNT(*)
FROM distinct_cnt
;


-- Loading
INSERT INTO loading (
	  bibnum
	, title
	, author
	, isbn
	, pub_year
	, publisher
	, item_type
	, item_col
	, item_loc
)
SELECT DISTINCT
	  bibnum
	, title
	, author
	, isbn
	, pub_year
	, publisher
	, item_type
	, item_col
	, item_loc
FROM staging
;

SELECT COUNT(*)
FROM loading;

-- Data
-- Without 2020 data, 2,739,958 distinct rows
WITH distinct_load AS (
	SELECT DISTINCT *
	FROM loading
)
SELECT COUNT(*)
FROM distinct_load
;

-- Delete Duplicate Rows from 'loading'
WITH cte_del AS (
SELECT
	  *
	, ROW_NUMBER() OVER (PARTITION BY bibnum, title, author, isbn, pub_year, publisher, item_type, item_col, item_loc ORDER BY bibnum) AS rn
FROM loading
)
DELETE cte_del
WHERE rn > 1
;


SELECT TOP 100 *
FROM loading
;

-- 375,722 rows returned total
SELECT TOP 10
	bibnum
	, COUNT(*) AS num
FROM loading
GROUP BY bibnum
HAVING COUNT(*) > 1
;

-- Differences arise from item_col and item_loc
SELECT *
FROM loading
WHERE bibnum IN (3511456, 3156174, 1736578, 3171494, 3519116, 2808552, 3731922, 3384300)
ORDER BY bibnum, item_type, item_col, item_loc
;

/*
	Info on columns
	=====================================

	ItemCollection (item_col): Collection code for this item. Value descriptions can be found in Integrated LIbrary System (ILS) Data Dictionary

	ItemLocation (item_loc): Location that owned the item at the time of snapshot. 3-letter code. This can be changed depending on where the item is returned.
*/

/*
	ILS Data Dictionary
	=======================
	To Do:
		- There's a row for each ItemCollection, ItemType, Location codes
		- Need to separate it into tables and Unpivot
*/

USE library;

CREATE SCHEMA bronze;

SELECT COUNT(*)
FROM staging;

DROP TABLE staging;

CREATE TABLE bronze.dictionary (
	  code NVARCHAR(50)
	, description NVARCHAR(255)
	, code_type NVARCHAR(50)
	, format_group NVARCHAR(50)
	, format_subgroup NVARCHAR(50)
	, cat_group NVARCHAR(50)
	, cat_subgroup NVARCHAR(50)
	, age_group NVARCHAR(25)
);

BULK INSERT bronze.dictionary
FROM '\Integrated_Library_System_(ILS)_Data_Dictionary_20250902.csv'
WITH (
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0A',
		FIRSTROW = 2,
		FORMAT = 'CSV' -- Needed to remove the quotes
);

SELECT *
FROM bronze.dictionary;


DROP TABLE bronze.checkouts;

CREATE TABLE bronze.checkouts (
	  id NVARCHAR(MAX)
	, checkout_year INT
	, bibnum INT
	, item_type NVARCHAR(MAX)
	, collection NVARCHAR(MAX)
	, item_title NVARCHAR(MAX)
	, checkout_datetime DATETIME
);

BULK INSERT bronze.checkouts
FROM 'Checkouts_By_Title_(Physical_Items)_20250904.csv'
WITH (
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0A',
		FIRSTROW = 2,
		FORMAT = 'CSV' -- Needed to remove the quotes
);

SELECT TOP 50 *
FROM bronze.checkouts;

SELECT *
FROM INFORMATION_SCHEMA.TABLES;

/*
	=================================
	Data Check for bronze.dictionary
	=================================

	CREATE TABLE silver.dictionary (
	  code NVARCHAR(20)
	, description NVARCHAR(100)
	, code_type NVARCHAR(25)
	, format_group NVARCHAR(20)
	, format_subgroup NVARCHAR(20)
	, cat_group NVARCHAR(25)
	, cat_subgroup NVARCHAR(20)
	, age_group NVARCHAR(20)
	);

*/

SELECT
	  MAX(LEN(code))
	, MAX(LEN(description))
	, MAX(LEN(code_type))
	, MAX(LEN(format_group))
	, MAX(LEN(format_subgroup))
	, MAX(LEN(cat_group))
	, MAX(LEN(cat_subgroup))
	, MAX(LEN(age_group))
FROM bronze.dictionary;

SELECT DISTINCT age_group
FROM bronze.dictionary;


/*
	=================================
	Data Check for bronze.checkouts
	=================================

	CREATE TABLE silver.checkouts (
		  id NVARCHAR(50)
		, checkout_year INT
		, bibnum INT
		, item_type NVARCHAR(10)
		, collection NVARCHAR(10)
		, item_title NVARCHAR(400)
		, checkout_datetime DATETIME
	);

*/

SELECT
	  MAX(LEN(id))
	, MAX(LEN(checkout_year))
	, MAX(LEN(bibnum))
	, MAX(LEN(item_type))
	, MAX(LEN(collection))
	, MAX(LEN(item_title))
	, MAX(LEN(checkout_datetime))
FROM bronze.checkouts;

SELECT TOP 10 *
FROM loading;



/*
	=================================
	Data Check for loading (catalog of books that have been recorded in inventory)
	=================================

	CREATE TABLE loading (
		  bibnum INT
		, title NVARCHAR(3000)
		, author NVARCHAR(500)
		, isbn NVARCHAR(200)
		, pub_year NVARCHAR(500)
		, publisher NVARCHAR(500)
		, item_type NVARCHAR(10)
		, item_col NVARCHAR(10)
		, item_loc NVARCHAR(10)
	);

*/

SELECT
	  MAX(LEN(bibnum))
	, MAX(LEN(title))
	, MAX(LEN(author))
	, MAX(LEN(isbn))
	, MAX(LEN(pub_year))
	, MAX(LEN(publisher))
	, MAX(LEN(item_type))
	, MAX(LEN(item_col))
	, MAX(LEN(item_loc))
FROM loading;

/*
	===================================
	To Do
	===================================

	Data Cleaning
	- Make sure no white spaces (TRIM)
	- Make sure the necessary columns have an ID; no NULLs

	After Cleaning
	- Load into Silver layer, with necessary adjustments to table creation (rename columns, change sizes of values, remove checkout_year?)
	- Create Gold layer
	- Plan out how to unpivot the Data Dictionary table
	- Clear out Bronze layer because of storage reasons
	- Create columns necessary for analysis
	- If needed, export Silver layer tables to CSV if storage runs out
*/
