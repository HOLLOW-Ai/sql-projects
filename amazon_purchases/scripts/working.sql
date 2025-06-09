SELECT TOP (10) *
FROM bronze.survey_response;

/*
========================================================================
Checking the distinct values in each column for bronze.survey_response
========================================================================
*/
SELECT DISTINCT
	q_demos_age_group -- different age ranges from 18 to 65+
FROM bronze.survey_response;

SELECT DISTINCT
	q_demos_hispanic -- yes/no
FROM bronze.survey_response;

SELECT DISTINCT
	q_demos_race -- multiple select
FROM bronze.survey_response;

SELECT DISTINCT
	q_demos_education -- highest lvl of educ
FROM bronze.survey_response;

SELECT DISTINCT
	q_demos_income -- range of income from 25k to 150k+
FROM bronze.survey_response;

SELECT DISTINCT
	q_demos_sexual_orientation -- hetero, lgbt+, or prefer not to say
FROM bronze.survey_response;

SELECT DISTINCT
	q_demos_state -- all 50 states + i did not reside in US
FROM bronze.survey_response
ORDER BY q_demos_state;

SELECT DISTINCT
	q_amazon_use_howmany
FROM bronze.survey_response;

SELECT DISTINCT
	q_amazon_use_hh_size
FROM bronze.survey_response;

SELECT DISTINCT
	q_amazon_use_how_oft
FROM bronze.survey_response;

/*
Substancr questions have the same 4 options
*/
SELECT DISTINCT
	q_substance_cig_use
FROM bronze.survey_response;

SELECT DISTINCT
	q_substance_marij_use
FROM bronze.survey_response;

SELECT DISTINCT
	q_substance_alcohol_use
FROM bronze.survey_response;

/*
Personal questions have same 3 options
*/
SELECT DISTINCT
	q_personal_diabetes
FROM bronze.survey_response;

SELECT DISTINCT
	q_personal_wheelchair
FROM bronze.survey_response;

SELECT DISTINCT
	q_life_changes -- Multiple select, contains NULL
FROM bronze.survey_response;

SELECT DISTINCT
	q_sell_your_data
FROM bronze.survey_response;

SELECT DISTINCT
	q_sell_consumer_data
FROM bronze.survey_response;

SELECT DISTINCT
	q_small_biz_use
FROM bronze.survey_response;

SELECT DISTINCT
	q_census_use
FROM bronze.survey_response;

SELECT DISTINCT
	q_research_society
FROM bronze.survey_response;

/*
========================================================================
Checking the PK response_id is unique
========================================================================
*/
SELECT response_id
FROM bronze.survey_response
GROUP BY response_id
HAVING COUNT(*) > 1
