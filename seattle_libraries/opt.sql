USE library;

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

-- From the Execution Plan, the above query is doing 2 separate Table Scans, although the following step of SORT is taking up most of the cost
-- From Copilot, it suggested to create a Nonclusted Index on BibNum, Item_Type, and Report_date DESC
-- INCLUDE: Use for columns that aren't in the WHERE/JOIN/GROUP BY/ORDER BY clauses, but only in the SELECT column list
	-- Adds the data at the lowest/leaf leave than in the index tree, making the index smaller

-- Issue rn is that 'item_type' cant be used as a key because i set it as NVARCHAR(MAX) during table creation
SELECT MAX(LEN(item_type))
from bronze.raw_inv;

CREATE NONCLUSTERED INDEX idx_inv_cover 
	ON bronze.raw_inv (bibnum, item_type, report_date DESC)
	INCLUDE (title, author, isbn, pub_year, publisher);
GO
DROP INDEX idx_bibnum ON bronze.raw_inv;

CREATE NONCLUSTERED INDEX idx_bibnum
	ON bronze.raw_inv (bibnum);

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'raw_inv';

BEGIN TRANSACTION;

	ALTER TABLE bronze.raw_inv
	ALTER COLUMN item_type NVARCHAR(10);

ROLLBACK TRANSACTION;
COMMIT TRANSACTION;

SELECT TOP 5 *
FROM bronze.raw_inv;


-- Doing all of the above only to find out there's not enough storage for the new index...
-- Remember to add back the old index lol


-- Ideally, the table scan only happens once
-- Runtime is now 1:25, returns the expected 875k rows
WITH scan_table AS (
	SELECT
		  bibnum
		, title
		, author
		, isbn
		, pub_year
		, publisher
		, item_type
		, report_date
		, MAX(title) OVER (PARTITION BY bibnum, item_type) AS max_title
		, MAX(author) OVER (PARTITION BY bibnum, item_type) AS max_author
		, MAX(isbn) OVER (PARTITION BY bibnum, item_type) AS max_isbn
		, MAX(pub_year) OVER (PARTITION BY bibnum, item_type) AS max_year
		, MAX(publisher) OVER (PARTITION BY bibnum, item_type) AS max_publisher
		, ROW_NUMBER() OVER (PARTITION BY bibnum, item_type ORDER BY report_date DESC) AS rn
	FROM bronze.raw_inv
)
SELECT
	  bibnum
	, COALESCE(title, max_title) AS title
	, COALESCE(author, max_author) AS author
	, COALESCE(isbn, max_isbn) AS isbn
	, COALESCE(pub_year, max_year) AS pub_year
	, COALESCE(publisher, max_publisher) AS publisher
	, item_type
	, report_date
FROM scan_table
WHERE rn = 1
;
