BULK INSERT bronze.run_log
FROM '[Input Path]'
WITH (
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0A', -- Should check in Notepad++
		FIRSTROW = 2,
		FORMAT = 'CSV' -- Needed to remove the quotes
);

BULK INSERT bronze.keepsake_log
FROM '[Input Path]'
WITH (
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0A', -- Should check in Notepad++
		FIRSTROW = 2,
		FORMAT = 'CSV' -- Needed to remove the quotes
);

BULK INSERT bronze.weapon_log
FROM '[Input Path]'
WITH (
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0A', -- Should check in Notepad++
		FIRSTROW = 2,
		FORMAT = 'CSV' -- Needed to remove the quotes
);

BULK INSERT bronze.vow_log
FROM '[Input Path]'
WITH (
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0A', -- Should check in Notepad++
		FIRSTROW = 2,
		FORMAT = 'CSV' -- Needed to remove the quotes
);

BULK INSERT bronze.arcana_log
FROM '[Input Path]'
WITH (
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0A', -- Should check in Notepad++
		FIRSTROW = 2,
		FORMAT = 'CSV' -- Needed to remove the quotes
);

BULK INSERT bronze.boon_log
FROM '[Input Path]'
WITH (
		FIELDTERMINATOR = ',',
		ROWTERMINATOR = '0x0A', -- Should check in Notepad++
		FIRSTROW = 2,
		FORMAT = 'CSV' -- Needed to remove the quotes
);
