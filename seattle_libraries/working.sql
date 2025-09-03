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
