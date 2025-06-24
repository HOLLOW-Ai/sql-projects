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
DROP TABLE IF EXISTS complaints;

CREATE TABLE complaints (
	officer_id INT NOT NULL, -- Changing the "mos" prefix to "officer"
	first_name NVARCHAR(50),
	last_name NVARCHAR(50),
	command_july_2020 NVARCHAR(100),
	shield_no INT, -- shield_no is added at a later time
	complaint_id INT NOT NULL,
	month_received INT,
	year_received INT,
	date_received DATE,
	month_closed INT,
	year_closed INT,
	date_closed DATE,
	command_at_incident NVARCHAR(20),
	rank_abbrev_incident NVARCHAR(10),
	rank_abbrev_july_2020 NVARCHAR(10),
	rank_incident NVARCHAR(50), -- Move this to before the rank_july_2020 column to follow the pattern of the abbreviation columns
	rank_july_2020 NVARCHAR(50),
	officer_ethnicity NVARCHAR(15),
	officer_gender NVARCHAR(30), -- Length of gender is matched to 30 because complainant gender can be longer than expected
	officer_age_incident INT,
	complainant_ethnicity NVARCHAR(15),
	complainant_gender NVARCHAR(30), -- This needs to be longer considering there is more than 2 genders
	complainant_age_incident INT,
	fado_type NVARCHAR(50),
	allegation NVARCHAR(100),
	precinct INT,
	contact_reason NVARCHAR(100),
	outcome_description NVARCHAR(100),
	board_disposition NVARCHAR(100),
	board_disposition_short NVARCHAR(30)
	)
;

INSERT INTO complaints
SELECT
	  TRY_CAST(officer_id AS INT) AS officer_id
	, TRIM(first_name) AS first_name -- Adding the TRIM() preemptively to make sure there is no extra whitespace
	, TRIM(last_name) AS last_name
	, TRIM(command_july_2020) AS command_july_2020
	, TRY_CAST(shield_no AS INT) AS shield_no -- Unsure if 0 means something or if it is the default over NULL
	, TRY_CAST(complaint_id AS INT) AS complaint_id
	, TRY_CAST(month_received AS INT) AS month_received
	, TRY_CAST(year_received AS INT) AS year_received
	, DATEFROMPARTS(year_received, month_received, '01') AS date_received -- Remember to add the new date columns to the updated field list in info.md
	, TRY_CAST(month_closed AS INT) AS month_closed
	, TRY_CAST(year_closed AS INT) AS year_closed
	, DATEFROMPARTS(year_closed, month_closed, '01') AS date_closed
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
	, TRIM(complainant_gender) AS complainant_gender
	, TRIM(complainant_age_incident) AS complainant_age_incident
	, TRIM(fado_type) AS fado_type
	, TRIM(allegation) AS allegation
	, TRY_CAST(precinct AS INT) AS precinct
	, TRIM(contact_reason) AS contact_reason
	, TRIM(outcome_description) AS outcome_description
	, TRIM(board_disposition) AS board_disposition
	, CASE WHEN TRIM(board_disposition) LIKE 'Substantiated%' THEN 'Substantiated' ELSE TRIM(board_disposition) END AS board_disposition_short
FROM complaints_raw
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

/*
=============================================================================
Distinct Values
=============================================================================
	Checking for the distinct values NVARCHAR columns to define 
	appropriate length.
*/

SELECT DISTINCT command_at_incident
FROM complaints_raw
;

SELECT DISTINCT command_july_2020
FROM complaints_raw
;

SELECT DISTINCT rank_abbrev_incident
FROM complaints_raw
;

SELECT DISTINCT rank_abbrev_july_2020
FROM complaints_raw
;

SELECT DISTINCT rank_incident
FROM complaints_raw
;

SELECT DISTINCT rank_july_2020
FROM complaints_raw
;

SELECT DISTINCT officer_ethnicity
FROM complaints_raw
;

SELECT DISTINCT officer_gender
FROM complaints_raw
;


SELECT DISTINCT complainant_ethnicity
FROM complaints_raw
;

SELECT DISTINCT complainant_gender, LEN(complainant_gender)
FROM complaints_raw
;

SELECT DISTINCT fado_type
FROM complaints_raw
;

SELECT DISTINCT allegation
FROM complaints_raw
;

SELECT DISTINCT contact_reason
FROM complaints_raw
;

SELECT DISTINCT outcome_description
FROM complaints_raw
;

SELECT DISTINCT board_disposition
FROM complaints_raw
;
