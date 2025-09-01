CREATE OR ALTER PROCEDURE synthea_schema.load_data
AS
BEGIN

	PRINT '======================';
	PRINT 'Loading Synthea Tables';
	PRINT '======================';

	PRINT '>> Truncating Table: synthea_schema.allergies';
	TRUNCATE TABLE synthea_schema.allergies;

	PRINT '>> Loading Data into Table: synthea_schema.allergies';
	BULK INSERT synthea_schema.allergies
	FROM '...\allergies.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '0x0A', -- Looking on Notepad++ the row terminator is "LF" so "0x0A" is the code for that
			FORMAT = 'CSV' -- needed or else it will break up the data in the income column
		);


	PRINT '>> Truncating Table: synthea_schema.careplans';
	TRUNCATE TABLE synthea_schema.careplans;

	PRINT '>> Loading Data into Table: synthea_schema.careplans';
	BULK INSERT synthea_schema.careplans
	FROM '...\careplans.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
			FORMAT = 'CSV',
			ROWTERMINATOR = '0x0A',
			FIELDTERMINATOR = ','
		);


  PRINT '>> Truncating Table: synthea_schema.conditions';
	TRUNCATE TABLE synthea_schema.conditions;

	PRINT '>> Loading Data into Table: synthea_schema.conditions';
	BULK INSERT synthea_schema.conditions
	FROM '...\conditions.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
      FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			ROWTERMINATOR = '0x0A'
		);


  PRINT '>> Truncating Table: synthea_schema.devices';
	TRUNCATE TABLE synthea_schema.devices;

	PRINT '>> Loading Data into Table: synthea_schema.devices';
	BULK INSERT synthea_schema.devices
	FROM '...\devices.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
      FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			ROWTERMINATOR = '0x0A'
		);


  PRINT '>> Truncating Table: synthea_schema.encounters';
	TRUNCATE TABLE synthea_schema.encounters;

	PRINT '>> Loading Data into Table: synthea_schema.encounters';
	BULK INSERT synthea_schema.encounters
	FROM '...\encounters.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
      FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			ROWTERMINATOR = '0x0A'
		);


  PRINT '>> Truncating Table: synthea_schema.imaging_studies';
	TRUNCATE TABLE synthea_schema.imaging_studies;

	PRINT '>> Loading Data into Table: synthea_schema.imaging_studies';
	BULK INSERT synthea_schema.imaging_studies
	FROM '...\imaging_studies.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
      FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			ROWTERMINATOR = '0x0A'
		);


  PRINT '>> Truncating Table: synthea_schema.immunizations';
	TRUNCATE TABLE synthea_schema.immunizations;

	PRINT '>> Loading Data into Table: synthea_schema.immunizations';
	BULK INSERT synthea_schema.immunizations
	FROM '...\immunizations.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
      FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			ROWTERMINATOR = '0x0A'
		);


  PRINT '>> Truncating Table: synthea_schema.medications';
	TRUNCATE TABLE synthea_schema.medications;

	PRINT '>> Loading Data into Table: synthea_schema.medications';
	BULK INSERT synthea_schema.medications
	FROM '...\medications.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
      FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			ROWTERMINATOR = '0x0A'
		);


  PRINT '>> Truncating Table: synthea_schema.observations';
	TRUNCATE TABLE synthea_schema.observations;

	PRINT '>> Loading Data into Table: synthea_schema.observations';
	BULK INSERT synthea_schema.observations
	FROM '...\observations.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
      FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			ROWTERMINATOR = '0x0A'
		);


  PRINT '>> Truncating Table: synthea_schema.organizations';
	TRUNCATE TABLE synthea_schema.organizations;

	PRINT '>> Loading Data into Table: synthea_schema.organizations';
	BULK INSERT synthea_schema.organizations
	FROM '...\organizations.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
      FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			ROWTERMINATOR = '0x0A'
		);


  PRINT '>> Truncating Table: synthea_schema.patients';
	TRUNCATE TABLE synthea_schema.patients;

	PRINT '>> Loading Data into Table: synthea_schema.patients';
	BULK INSERT synthea_schema.patients
	FROM '...\patients.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
      FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			ROWTERMINATOR = '0x0A'
		);


  PRINT '>> Truncating Table: synthea_schema.payers';
	TRUNCATE TABLE synthea_schema.payers;

	PRINT '>> Loading Data into Table: synthea_schema.payers';
	BULK INSERT synthea_schema.payers
	FROM '...\payers.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
      FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			ROWTERMINATOR = '0x0A'
		);


  PRINT '>> Truncating Table: synthea_schema.payer_transitions';
	TRUNCATE TABLE synthea_schema.payer_transitions;

	PRINT '>> Loading Data into Table: synthea_schema.payer_transitions';
	BULK INSERT synthea_schema.payer_transitions
	FROM '...\payer_transitions.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
      FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			ROWTERMINATOR = '0x0A'
		);


  PRINT '>> Truncating Table: synthea_schema.procedures';
	TRUNCATE TABLE synthea_schema.procedures;

	PRINT '>> Loading Data into Table: synthea_schema.procedures';
	BULK INSERT synthea_schema.procedures
	FROM '...\procedures.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
      FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			ROWTERMINATOR = '0x0A'
		);


  PRINT '>> Truncating Table: synthea_schema.providers';
	TRUNCATE TABLE synthea_schema.providers;

	PRINT '>> Loading Data into Table: synthea_schema.providers';
	BULK INSERT synthea_schema.providers
	FROM '...\providers.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
      FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			ROWTERMINATOR = '0x0A'
		);


  PRINT '>> Truncating Table: synthea_schema.supplies';
	TRUNCATE TABLE synthea_schema.supplies;

	PRINT '>> Loading Data into Table: synthea_schema.supplies';
	BULK INSERT synthea_schema.supplies
	FROM '...\supplies.csv' -- Edit path
	WITH (
			FIRSTROW = 2,
      FIELDTERMINATOR = ',',
			FORMAT = 'CSV',
			ROWTERMINATOR = '0x0A'
		);

END
