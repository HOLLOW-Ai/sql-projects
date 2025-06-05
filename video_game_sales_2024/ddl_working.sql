BULK INSERT games FROM 'C:\Users\Mary Huynh\Downloads\vgchartz-2024.csv'
WITH (
		  FIRSTROW = 2 -- Data starts in the second row
		, FIELDTERMINATOR = ','
		, ROWTERMINATOR = '\r\n'
	  );

BULK INSERT games
FROM 'C:\Users\Mary Huynh\Downloads\vgchartz-2024.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 1, -- Use 2 if your file includes a header row
    KEEPNULLS,
    CODEPAGE = '65001' -- For UTF-8 encoding, if needed
);

DROP DATABASE portfolio;
CREATE DATABASE portfolio;
USE portfolio;


DROP TABLE IF EXISTS dbo.games;

CREATE TABLE games (
	img NVARCHAR(50),
	title NVARCHAR(50) NOT NULL,
	console NVARCHAR(25),
	genre NVARCHAR(25),
	publisher NVARCHAR(50),
	developer NVARCHAR(50),
	critic_score DECIMAL(4, 2),
	total_sales DECIMAL(5, 2),
	na_sales DECIMAL(5, 2),
	jp_sales DECIMAL(5, 2),
	pal_sales DECIMAL(5, 2),
	other_sales DECIMAL(5, 2),
	release_date DATE,
	last_update DATE
);

CREATE TABLE games (
	img NVARCHAR(MAX) NULL,
	title NVARCHAR(MAX) NULL,
	console NVARCHAR(50) NULL,
	genre NVARCHAR(50) NULL,
	publisher NVARCHAR(50) NULL,
	developer NVARCHAR(MAX) NULL,
	critic_score NVARCHAR(50) NULL,
	total_sales NVARCHAR(50) NULL,
	na_sales NVARCHAR(50) NULL,
	jp_sales NVARCHAR(50) NULL,
	pal_sales NVARCHAR(50) NULL,
	other_sales NVARCHAR(50) NULL,
	release_date NVARCHAR(50) NULL,
	last_update NVARCHAR(100) NULL
);

SELECT TOP (100) *
FROM vg_2024;

BULK INSERT del_later
FROM 'C:\Users\Mary Huynh\Downloads\vgchartz-2024.csv'
WITH (
		  FIRSTROW = 2
		, FIELDTERMINATOR = ','
		, ROWTERMINATOR = '0x0A' -- Using '\n' did not work, so used the hex code for LF after checking in Notepadd++
		, TABLOCK
	 );
