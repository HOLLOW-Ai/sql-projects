BULK INSERT bronze.survey_response
FROM 'C:\Users\Mary Huynh\Downloads\dataverse_files\survey.csv'
WITH (
		FIRSTROW = 2,
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0A',
		FORMAT = 'CSV' -- needed or else it will break up the data in the income column
);

SELECT TOP (500) *
FROM bronze.survey_response;

TRUNCATE TABLE bronze.survey_response;

BULK INSERT bronze.amazon_purchases
FROM 'C:\Users\Mary Huynh\Downloads\dataverse_files\amazon-purchases.csv'
WITH (
		FIRSTROW = 2,
		FORMAT = 'CSV',
		ROWTERMINATOR = '0x0A',
		FIELDTERMINATOR = ','
);

SELECT TOP (500) *
FROM bronze.amazon_purchases;

SELECT TOP (500) *
FROM bronze.amazon_purchases
WHERE shipping_address_state != 'NJ'

TRUNCATE TABLE bronze.amazon_purchases;
