/*
	===================================================
	Create Database and Schema
	===================================================
*/

CREATE DATABASE library;

USE library;
GO

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO


/*
	===================================================
	Create Bronze Layer Tables
	===================================================
*/

-- This table contains the bibliographic record snapshots of the books the Seattle libraries have at the time of the monthly count
CREATE TABLE bronze.catalog (
	  bibnum NVARCHAR(MAX)
	, title NVARCHAR(MAX)
	, author NVARCHAR(MAX)
	, isbn NVARCHAR(MAX)
	, pub_year NVARCHAR(MAX)
	, publisher NVARCHAR(MAX)
	, item_type NVARCHAR(MAX)
	, item_col NVARCHAR(MAX)
	--, item_loc NVARCHAR(MAX)
);

-- This table contains the Lookup table of Horizon and borrower codes of the Seattle libraries
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

-- This table contains a log of all physical checkouts from Seattle Public Library. Dataset ranges from Jan 1, 2020 to Sept 8, 2025
CREATE TABLE bronze.checkouts (
	  id NVARCHAR(MAX)
	, checkout_year INT
	, bibnum INT
	, item_type NVARCHAR(MAX)
	, collection NVARCHAR(MAX)
	, item_title NVARCHAR(MAX)
	, checkout_datetime DATETIME
);

/*
	===================================================
	Bulk Insert Load Statement
	===================================================
*/

BULK INSERT bronze.'[Table Name]'
FROM '[Input Path]'
WITH (
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0A',
		FIRSTROW = 2,
		FORMAT = 'CSV' -- Needed to remove the quotes
);
