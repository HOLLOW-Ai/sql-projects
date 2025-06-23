USE nypd;

SELECT *
FROM complaints;

-- Earliest and Latest date of complaints
-- To combine the Year and Month columns into a date, we're going to use DATEFROMPARTS() and use '01' as the day since the function needs 3 arguments
WITH date_of_complaints AS (
SELECT
	DATEFROMPARTS(year_received, month_received, '01') AS complaint_date
FROM complaints
)
SELECT
	  MIN(complaint_date)
	, MAX(complaint_date)
FROM date_of_complaints
;
-- The earliest date of a complaint is from September 1985
-- Latest date is January 2020

-- How many unique complaints are there?
SELECT
	COUNT(DISTINCT complaint_id)
FROM complaints
;
-- 12056 unique complaints

-- From the dataset information page, we know that these are complaints for closed cases of officers who are still in the force as of July 2020
-- This doesn't include complaints that were found to be unfounded after investigations

-- FADO Types
SELECT DISTINCT fado_type
FROM complaints
;

-- List columns later
SELECT *
FROM complaints
WHERE command_at_incident != command_july_2020
;

-- What Precint has the highest number of unique complaints, and compare that to the officers there?
SELECT
	  precinct
	, COUNT(DISTINCT complaint_id) AS num_complaints
	, COUNT(DISTINCT officer_id) AS num_officers
	, 1.0 * COUNT(DISTINCT complaint_id) / COUNT(DISTINCT officer_id) AS complaints_per_officer
FROM complaints
GROUP BY precinct
ORDER BY num_complaints DESC
;
-- There is listed a Precinct 0, which I can't confirm the existence of from the NYPD. There is also a case where the precinct is NULL. Possibly, the precinct 0 means something
-- but I don't know what it's supposed to mean if the dataset differentiates that from a Precinct being NULL

-- In one complaint, who are the top 5 officers that had the most charges accused against them?
-- Find the complaint ath has the most allegations in one
SELECT DISTINCT precinct
FROM complaints;

SELECT *
FROM complaints WHERE precinct IS NULL

-- Find how many allegations in each complaint
SELECT
	complaint_id
	, COUNT(DISTINCT allegation) AS unique_allegation
FROM complaints
GROUP BY complaint_id
;
-- Find the max number and the associated complaint_id
WITH cte1 AS (
SELECT
	complaint_id
	, COUNT(DISTINCT allegation) AS unique_allegation
FROM complaints
GROUP BY complaint_id
), cte2 AS (
SELECT
	complaint_id, unique_allegation
FROM cte1
WHERE unique_allegation = (SELECT MAX(unique_allegation) FROM cte1)
)
SELECT *
FROM complaints
WHERE complaint_id IN (SELECT complaint_id FROM cte2)


-- What is the average resolution time from when a complaint is received and when it is closed?
-- Use months since the day is added to us to make the column a date type
WITH date_cols AS (
SELECT
	  DATEFROMPARTS(year_received, month_received, '01') AS complaint_date
	, DATEFROMPARTS(year_closed, month_closed, '01') AS closed_date
FROM complaints
)
SELECT
	AVG(1.0* DATEDIFF(month, complaint_date, closed_date))
FROM date_cols;

-- What are the contributions of the FADO type that make up the complaints
SELECT DISTINCT fado_type
FROM complaints
;
