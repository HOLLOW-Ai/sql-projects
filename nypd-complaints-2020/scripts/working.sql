/*
=============================================================================
DDL
=============================================================================
*/
USE nypd;

-- Raw table
CREATE TABLE complaints_raw (
	officer_id NVARCHAR(100) NOT NULL, -- Changing the "mos" prefix to "officer"
	first_name NVARCHAR(100),
	last_name NVARCHAR(100),
	command_july_2020 NVARCHAR(100),
	shield_no NVARCHAR(100), -- shield_no is added at a later time
	complaint_id NVARCHAR(100) NOT NULL,
	month_received NVARCHAR(100),
	year_received NVARCHAR(100),
	month_closed NVARCHAR(100),
	year_closed NVARCHAR(100),
	command_at_incident NVARCHAR(100),
	rank_abbrev_incident NVARCHAR(100),
	rank_abbrev_july_2020 NVARCHAR(100),
	rank_july_2020 NVARCHAR(100),
	rank_incident NVARCHAR(100), -- Move this to before the rank_july_2020 column to follow the pattern of the abbreviation columns
	officer_ethnicity NVARCHAR(100),
	officer_gender NVARCHAR(100),
	officer_age_incident NVARCHAR(100),
	complainant_ethnicity NVARCHAR(100),
	complainant_gender NVARCHAR(100),
	complainant_age_incident NVARCHAR(100),
	fado_type NVARCHAR(100),
	allegation NVARCHAR(100),
	precinct NVARCHAR(100),
	contact_reason NVARCHAR(100),
	outcome_description NVARCHAR(100),
	board_disposition NVARCHAR(100)
	)
;

-- Transformed table
CREATE TABLE complaints (
	officer_id INT NOT NULL, -- Changing the "mos" prefix to "officer"
	first_name NVARCHAR(50),
	last_name NVARCHAR(50),
	command_july_2020 NVARCHAR(100),
	shield_no INT, -- shield_no is added at a later time
	complaint_id INT NOT NULL,
	month_received INT,
	year_received INT,
	month_closed INT,
	year_closed INT,
	command_at_incident NVARCHAR(20),
	rank_abbrev_incident NVARCHAR(10),
	rank_abbrev_july_2020 NVARCHAR(10),
	rank_july_2020 NVARCHAR(50),
	rank_incident NVARCHAR(50), -- Move this to before the rank_july_2020 column to follow the pattern of the abbreviation columns
	officer_ethnicity NVARCHAR(15),
	officer_gender NVARCHAR(10),
	officer_age_incident INT,
	complainant_ethnicity NVARCHAR(15),
	complainant_gender NVARCHAR(10),
	complainant_age_incident INT,
	fado_type NVARCHAR(50),
	allegation NVARCHAR(100),
	precinct INT,
	contact_reason NVARCHAR(100),
	outcome_description NVARCHAR(100),
	board_disposition NVARCHAR(100)
	)
;

/*
=============================================================================
Transforming
=============================================================================
*/
BULK INSERT complaints_raw
FROM '...\allegations_202007271729.csv'
WITH (
		FORMAT = 'CSV', -- Needed; Otherwise, all values will be surrounded by double quotes
		FIRSTROW = 2,
		ROWTERMINATOR = '0x0A',
		FIELDTERMINATOR = ','
	)
;

TRUNCATE TABLE complaints_raw;

SELECT TOP (10) *
FROM complaints_raw;

-- Checking for all rows to be imported
-- Source cite says that there is 33,358 rows
SELECT COUNT(*)
FROM complaints_raw;

SELECT
	  TRY_CAST(officer_id AS INT) AS officer_id
	, TRIM(first_name) AS first_name -- Adding the TRIM() preemptively to make sure there is no extra whitespace
	, TRIM(last_name) AS last_name
	, TRIM(command_july_2020) AS command_july_2020
	, TRY_CAST(shield_no AS INT) AS shield_no -- Unsure if 0 means something or if it is the default over NULL
	, TRY_CAST(month_received AS INT) AS month_received
	, TRY_CAST(year_received AS INT) AS year_received
	, TRY_CAST(month_closed AS INT) AS month_closed
	, TRY_CAST(year_closed AS INT) AS year_closed
	, TRIM(command_at_incident) AS command_at_incident
	, TRIM(rank_abbrev_incident) AS rank_abbrev_incident
	, TRIM(rank_abbrev_july_2020) AS rank_abbrev_july_2020
	, TRIM(rank_incident) AS rank_incident
	, TRIM(rank_july_2020) AS rank_july_2020 
	, TRIM(officer_ethnicity) AS officer_ethnicity
	, CASE TRIM(officer_gender)
		WHEN 'M' THEN 'Male'
		WHEN 'F' THEN 'Female'
	  END AS officer_gender
	, TRIM(officer_age_incident) AS officer_age_incident
	, TRIM(complainant_ethnicity) AS complainant_ethnicity
	, TRIM(complainant_gender) AS complainant_gender -- Standardize how gender is entered
	, TRIM(complainant_age_incident) AS complainant_age_incident
	, TRIM(fado_type) AS fado_type
	, TRIM(allegation) AS allegation
	, TRY_CAST(precinct AS INT) AS precinct
	, TRIM(contact_reason) AS contact_reason
	, TRIM(outcome_description) AS contact_reason
	, TRIM(board_disposition) AS contact_reason
FROM complaints_raw
;
