BULK INSERT bronze.run_log
FROM '[Input Path]'
WITH (
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		FIRSTROW = 2
);

BULK INSERT bronze.keepsake_log
FROM '[Input Path]'
WITH (
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		FIRSTROW = 2
);

BULK INSERT bronze.weapon_log
FROM '[Input Path]'
WITH (
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		FIRSTROW = 2
);

BULK INSERT bronze.vow_log
FROM '[Input Path]'
WITH (
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		FIRSTROW = 2
);

BULK INSERT bronze.arcana_log
FROM '[Input Path]'
WITH (
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		FIRSTROW = 2
);

BULK INSERT bronze.boon_log
FROM '[Input Path]'
WITH (
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '\n',
		FIRSTROW = 2
);
