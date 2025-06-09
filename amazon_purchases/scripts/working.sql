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
	q_life_changes -- Multiple select, contains NULL -- should replace with 'BLANK' instead?
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

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'amazon_purchases';

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'survey_response';


/*
========================================================================
Skeleton structure of other tables to create
========================================================================
*/

DROP TABLE IF EXISTS silver.survey_questions;
CREATE TABLE silver.survey_questions (
	question_id INT NOT NULL	IDENTITY	PRIMARY KEY,
	category NVARCHAR(50),
	question NVARCHAR(255)
);

TRUNCATE TABLE silver.survey_questions;

INSERT INTO silver.survey_questions (category, question)
VALUES
	('demographic', 'What is your age group?'),
	('demographic', 'Are you of Spanish, Hispanic, or Latino origin?'),
	('demographic', 'Choose one or more races that you consider yourself to be'),
	('demographic', 'What is the highest level of education you have completed?'),
	('demographic', 'What was your total household income before taxes during the past 12 months?'),
	('demographic', 'How do you describe yourself?'),
	('demographic', 'Which best describes your sexual orientation?'),
	('demograhpic', 'In 2021, which U.S. State did you live in?'),
	('household_use', 'How many people do you share your Amazon account with? i.e. how many people log in and make orders using your account?'),
	('household_use', 'How many people are in your "household"?'),
	('household_use', 'How often do you (+ anyone you share your account with) order deliveries from Amazon?'),
	('personal', 'Do you or someone in your household or someone you share your Amazon account with smoke cigarettes regularly?'),
	('personal', 'Do you or someone in your household or someone you share your Amazon account with smoke marijuana regularly?'),
	('personal', 'Do you or someone in your household or someone you share your Amazon account with drink alcohol regularly?'),
	('personal', 'Do you or someone in your household or someone you share your Amazon account with have diabetes?'),
	('personal', 'Do you or someone in your household or someone you share your Amazon account with use a wheelchair?'),
	('personal', 'In 2021 did you, or someone you share your Amazon account with, experience any of the following life changes?')
;

SELECT *
FROM silver.survey_questions;
