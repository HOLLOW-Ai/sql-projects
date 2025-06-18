CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN

	PRINT '====================';
	PRINT 'Loading Bronze Layer';
	PRINT '====================';

	PRINT '>> Truncating Table: bronze.survey_response';
	TRUNCATE TABLE bronze.survey_response;

	PRINT '>> Loading Data into Table: bronze.survey_response';
	BULK INSERT bronze.survey_response
	FROM '...\survey.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0A', -- Looking on Notepad++ the row terminator is "LF" so "0x0A" is the code for that
			FORMAT = 'CSV' -- needed or else it will break up the data in the income column
		);

	PRINT '>> Truncating Table: bronze.amazon_purchases';
	TRUNCATE TABLE bronze.amazon_purchases;

	PRINT '>> Loading Data into Table: bronze.amazon_purchases';
	BULK INSERT bronze.amazon_purchases
	FROM '...\amazon-purchases.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
			FORMAT = 'CSV',
			ROWTERMINATOR = '0x0A',
			FIELDTERMINATOR = ','
		);

END
