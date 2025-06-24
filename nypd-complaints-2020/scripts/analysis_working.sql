-- What officers have since moved to a different command
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
SELECT
	AVG(1.0 * DATEDIFF(month, date_received, date_closed))
FROM complaints
;

-- What are the contributions of the FADO type that make up the complaints/allegations
SELECT DISTINCT fado_type
FROM complaints
;

SELECT
	  fado_type
	, COUNT(*) -- Not counting the complaint_id because complaints can have multiple allegations that belong to different FADO categories
	, CAST(ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM complaints), 2) AS DECIMAL(5,2))
FROM complaints
GROUP BY fado_type
;

-- Complaints by Officer Race and Complainant RAce (racial disparities?)


-- Trend of complaints received
-- Low number in 2020 because the dataset only goes up to January 2020
WITH agg_data AS (
SELECT
	  year_received
	, COUNT(DISTINCT complaint_id) AS num_complaints
FROM complaints
GROUP BY year_received
)
SELECT
	  year_received
	, num_complaints
	, CAST(100.0 * (num_complaints - LAG(num_complaints, 1) OVER (ORDER BY year_received ASC)) / LAG(num_complaints, 1) OVER (ORDER BY year_received ASC) AS DECIMAL(5, 1)) -- Casting will round
FROM agg_data
;

-- Finding each officers last complaint and finding the month difference
SELECT DISTINCT -- Adding distinct to remove the duplicate complaint_id that occurs due to multiple allegations
	  officer_id
	, complaint_id
	, date_received
	, LAG(date_received, 1) OVER (PARTITION BY officer_id ORDER BY date_received ASC) AS last_complaint_received_date
	, DATEDIFF(month, LAG(date_received, 1) OVER (PARTITION BY officer_id ORDER BY date_received ASC), date_received)
FROM complaints
ORDER BY officer_id
;

WITH lag_complaints AS (
SELECT DISTINCT -- Adding distinct to remove the duplicate complaint_id that occurs due to multiple allegations
	  officer_id
	, complaint_id
	, date_received
FROM complaints
)
SELECT
	  officer_id
	, complaint_id
	, date_received
	, LAG(date_received, 1) OVER (PARTITION BY officer_id ORDER BY date_received, complaint_id ASC) AS last_complaint_received_date
	, DATEDIFF(month, LAG(date_received, 1) OVER (PARTITION BY officer_id ORDER BY date_received, complaint_id ASC), date_received) AS months_last_complaint
FROM lag_complaints
ORDER BY officer_id, date_received, complaint_id
;

-- Just to see if complaint_id and the date of the complaint is related
SELECT DISTINCT complaint_id, date_received
FROM complaints
ORDER BY complaint_id

-- Finding officers who received more than 1 complaint in a month
SELECT
	  officer_id
	, date_received
	, COUNT(DISTINCT complaint_id)
FROM complaints
GROUP BY officer_id, date_received
HAVING COUNT(DISTINCT complaint_id) > 1
ORDER BY date_received, officer_id
;

-- Officer aggregated complaint information
SELECT
	  officer_id
	, MIN(date_received) AS earliest_complaint_received
	, MAX(date_received) AS latest_complaint_received
	, COUNT(DISTINCT complaint_id) AS num_complaints
	, COUNT(complaint_id) AS num_charges
FROM complaints
GROUP BY officer_id
ORDER BY officer_id
;
