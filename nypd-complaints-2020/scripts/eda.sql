/*
=============================================================================
Exploratory Data Analysis
=============================================================================
*/

/*
Database Exploration
*/
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'complaints'
;

/*
Dimension Exploration

Dimensions:
	- officer_id
	- command_july_2020
	- shield_no
	- complaint_id
	- date_received
	- date_closed
	- command_at_incident
	- rank_abbrev_incident
	- rank_abbrev_july_2020
	- rank_incident
	- rank_july_2020
	- officer_ethnicity
	- officer_gender
	- complainant_ethnicity
	- complainant_gender
	- fado_type
	- allegation
	- precinct
	- contact_reason
	- outcome_description
	- board_disposition
*/

/*
Date Exploration
*/
-- Earliest and Latest Complaint Dates
	-- According to the dataset information, the records should range from September 1985 to January 2020
	-- Note that the '-01' for the day in the date was added by me as a placeholder to turn the field into a date type
SELECT
	  MIN(date_received) AS earliest_complaint_received
	, MAX(date_received) AS latest_complaint_received
	, MIN(date_closed) AS earliest_complaint_closed
	, MAX(date_closed) AS latest_complaint_closed
FROM complaints
;

-- Number of Unique Complaints
SELECT
	COUNT(DISTINCT complaint_id) AS num_complaints
FROM complaints
;

-- Number of Officers listed in this dataset
SELECT
	COUNT(DISTINCT officer_id) AS num_officers
FROM complaints
;
