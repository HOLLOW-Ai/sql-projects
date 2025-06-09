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
	FROM 'C:\Users\Mary Huynh\Downloads\dataverse_files\survey.csv'
	WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0A',
			FORMAT = 'CSV' -- needed or else it will break up the data in the income column
		);

	PRINT '>> Truncating Table: bronze.amazon_purchases';
	TRUNCATE TABLE bronze.amazon_purchases;

	PRINT '>> Loading Data into Table: bronze.amazon_purchases';
	BULK INSERT bronze.amazon_purchases
	FROM 'C:\Users\Mary Huynh\Downloads\dataverse_files\amazon-purchases.csv'
	WITH (
			FIRSTROW = 2,
			FORMAT = 'CSV',
			ROWTERMINATOR = '0x0A',
			FIELDTERMINATOR = ','
		);

END

EXEC bronze.load_bronze;

