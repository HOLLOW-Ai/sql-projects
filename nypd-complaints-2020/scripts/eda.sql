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
*/

SELECT DISTINCT
	fado_type
FROM complaints
;

SELECT DISTINCT
	  fado_type
	, allegation
FROM complaints
ORDER BY fado_type, allegation
;

SELECT DISTINCT
	contact_reason
FROM complaints
ORDER BY contact_reason
;

SELECT DISTINCT
	board_disposition
FROM complaints;

SELECT
	command_at_incident AS command
FROM complaints
UNION
SELECT
	command_july_2020
FROM complaints
ORDER BY command
;

SELECT DISTINCT
	outcome_description
FROM complaints
ORDER BY outcome_description
;

SELECT DISTINCT
	board_disposition
FROM complaints
ORDER BY board_disposition
;

SELECT
	rank_incident AS officer_rank
FROM complaints
UNION
SELECT
	rank_july_2020
FROM complaints
ORDER BY officer_rank
;

-- Difference in the diversity of gender of the Officer vs. Complainant
SELECT
	  'Officer' AS person
	, officer_gender AS gender
FROM complaints
UNION
SELECT
	  'Complainant'
	, complainant_gender
FROM complaints
ORDER BY person, gender
;

SELECT
	  'Officer' AS person
	, officer_ethnicity AS ethnicity
FROM complaints
UNION
SELECT
	  'Complainant'
	, complainant_ethnicity
FROM complaints
ORDER BY person, ethnicity
;

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
	, DATEDIFF(month, MIN(date_received), MAX(date_received))
	, DATEDIFF(month, MIN(date_closed), MAX(date_closed))
FROM complaints
;

/*
Measures Exploration
*/

-- Average Age of Officers
SELECT
	1.0 * AVG(officer_age_incident)
FROM complaints
;

-- Average Age of Complainant
SELECT
	1.0 * AVG(complainant_age_incident)
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

/*
Magnitude Analyis
*/

-- Number of Officers with Complaints by Precinct
SELECT
	  precinct
	, COUNT(DISTINCT officer_id) AS num_officers
FROM complaints
GROUP BY precinct
ORDER BY precinct
;

-- Count of Complaints Filed by Complainant Ethnicity
	-- From what I gather from the dataset, multiple people can file one complaint; Best to just count by unique complaint_id
SELECT
	  complainant_ethnicity
	, COUNT(DISTINCT complaint_id) AS num_complaints
FROM complaints
GROUP BY complainant_ethnicity
;

-- Count of Complaints by Officer Ethnicity
SELECT
	  officer_ethnicity
	, COUNT(DISTINCT complaint_id) AS num_complaints
FROM complaints
GROUP BY officer_ethnicity
;

SELECT complaint_id, complainant_age_incident, complainant_ethnicity, complainant_gender
FROM complaints
ORDER BY complaint_id
;

-- Total Complaints by FADO type
SELECT
	  fado_type
	, COUNT(DISTINCT complaint_id) AS num_complaints
FROM complaints
GROUP BY fado_type
;

-- Gender Distribution of Officers; move this up
SELECT
	officer_gender
	, COUNT(DISTINCT officer_id)
FROM complaints
GROUP BY officer_gender
;


-- Total Complaints by Gender
SELECT
	  officer_gender
	, COUNT(DISTINCT complaint_id)
FROM complaints
GROUP BY officer_gender
;

-- Outcomes of Complaints
	-- Multiple allegations can be in one complaint, and each allegation will have its own board_disposition
	-- Substantiated can appear multiple times due to a follow-up contained in parentheses
SELECT
	board_disposition
	, COUNT(*)
FROM complaints
GROUP BY board_disposition
;

-- Without multiple Substantiated outcomes
SELECT
	CASE WHEN board_disposition LIKE 'Substantiated%' THEN 'Substantiated' ELSE board_disposition END
	, COUNT(*)
FROM complaints
GROUP BY CASE WHEN board_disposition LIKE 'Substantiated%' THEN 'Substantiated' ELSE board_disposition END
;


/*
Ranking Analyis
*/

-- Top 5 Precincts with the most complaints filed
WITH precinct_rnk AS (
SELECT
	precinct
	, COUNT(DISTINCT complaint_id) AS num_complaints
	, DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT complaint_id) DESC) AS rnking
FROM complaints
GROUP BY precinct
)
SELECT
	  precinct
	, num_complaints
FROM precinct_rnk
WHERE rnking <= 5
ORDER BY rnking
;

-- Top 5 Officers with the most complaints filed
SELECT
	officer_id
	, COUNT(DISTINCT complaint_id) AS num_complaints
	, DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT complaint_id) DESC) AS rnking
FROM complaints
GROUP BY officer_id
;
