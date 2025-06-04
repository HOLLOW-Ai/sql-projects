USE portfolio;

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO

DROP TABLE IF EXISTS bronze.healthcare;

CREATE TABLE bronze.healthcare (
	name NVARCHAR(50),
	age NVARCHAR(50),
	gender NVARCHAR(50),
	blood_type NVARCHAR(50),
	medical_condition NVARCHAR(50),
	admission_date NVARCHAR(50),
	doctor NVARCHAR(50),
	hospital NVARCHAR(50),
	insurance_provider NVARCHAR(50),
	billing_amount NVARCHAR(50),
	room_number NVARCHAR(50),
	admission_type NVARCHAR(50),
	discharge_date NVARCHAR(50),
	medication NVARCHAR(50),
	test_results NVARCHAR(50)
);

DROP TABLE IF EXISTS silver.healthcare;

CREATE TABLE silver.healthcare (
	name NVARCHAR(50),
	age INT,
	gender NVARCHAR(10),
	blood_type NVARCHAR(5),
	medical_condition NVARCHAR(50),
	admission_date DATE,
	doctor NVARCHAR(50),
	hospital NVARCHAR(50),
	insurance_provider NVARCHAR(50),
	billing_amount DECIMAL(10, 2),
	room_number INT,
	admission_type NVARCHAR(25),
	discharge_date DATE,
	medication NVARCHAR(50),
	test_results NVARCHAR(25)
);

SELECT *
FROM INFORMATION_SCHEMA.TABLES;

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES;
