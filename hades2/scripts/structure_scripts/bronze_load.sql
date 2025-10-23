CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN

	PRINT '====================';
	PRINT 'Loading Bronze Layer';
	PRINT '====================';

	PRINT '>> Truncating Table: bronze.run_log';
	TRUNCATE TABLE bronze.run_log;

	PRINT '>> Loading Data into Table: bronze.run_log';
	BULK INSERT bronze.run_log
	FROM '...\Hades 2 CSV - Run Log.csv' -- Edit
	WITH (
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2
	);
	---------------------------------------------------------------------
	PRINT '>> Truncating Table: bronze.keepsake_log';
	TRUNCATE TABLE bronze.keepsake_log;

	PRINT '>> Loading Data into Table: bronze.keepsake_log';
	BULK INSERT bronze.keepsake_log
	FROM '...\Hades 2 CSV - Keepsake Log.csv' -- Edit
	WITH (
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2
	);
	---------------------------------------------------------------------
	PRINT '>> Truncating Table: bronze.weapon_log';
	TRUNCATE TABLE bronze.weapon_log;

	PRINT '>> Loading Data into Table: bronze.weapon_log';
	BULK INSERT bronze.weapon_log
	FROM '...\Hades 2 CSV - Weapon Log.csv' -- Edit
	WITH (
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2
	);
	---------------------------------------------------------------------
	PRINT '>> Truncating Table: bronze.vow_log';
	TRUNCATE TABLE bronze.vow_log;

	PRINT '>> Loading Data into Table: bronze.vow_log';
	BULK INSERT bronze.vow_log
	FROM '...\Hades 2 CSV - Vow Log.csv' -- Edit
	WITH (
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2
	);
	---------------------------------------------------------------------
	PRINT '>> Truncating Table: bronze.arcana_log';
	TRUNCATE TABLE bronze.arcana_log;

	PRINT '>> Loading Data into Table: bronze.arcana_log';
	BULK INSERT bronze.arcana_log
	FROM '...\Hades 2 CSV - Arcana Log.csv' -- Edit
	WITH (
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2
	);
	---------------------------------------------------------------------
	PRINT '>> Truncating Table: bronze.boon_log';
	TRUNCATE TABLE bronze.boon_log;

	PRINT '>> Loading Data into Table: bronze.boon_log';
	BULK INSERT bronze.boon_log
	FROM '...\Hades 2 CSV - Boon Log.csv' -- Edit
	WITH (
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2
	);

END
