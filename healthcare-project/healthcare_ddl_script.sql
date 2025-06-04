DROP TABLE IF EXISTS healthcare;

CREATE TABLE healthcare (
	name NVARCHAR(50),
	age INT,
	gender NVARCHAR(10),
	blood_type NVARCHAR(5),
	medical_condition NVARCHAR(50),
	admission_date DATE,
	doctor NVARCHAR(50),
	hospital NVARCHAR(50),
	insurance_provider NVARCHAR(50),
	billing_amount FLOAT,
	room_number INT,
	admission_type NVARCHAR(25),
	discharge_date DATE,
	medication NVARCHAR(50),
	test_results NVARCHAR(25)
);

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES;
