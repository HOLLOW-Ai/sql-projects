/*
===================================
Demographic Analysis
===================================
*/

SELECT *
FROM silver.questions;

-- How many respondents identified with more than one race?
WITH race_per_respondent AS (
SELECT
	  response_id
	, COUNT(DISTINCT answer_id) AS races_picked
FROM silver.user_answers
WHERE q_id = 3
GROUP BY response_id
)
SELECT
	races_picked
	, COUNT(DISTINCT response_id) AS num_ppl
FROM race_per_respondent
GROUP BY races_picked
ORDER BY races_picked
;

-- Race spread?
WITH race AS (
	SELECT
		  answer_id
		, COUNT(DISTINCT response_id) AS num_ppl
	FROM silver.user_answers
	WHERE q_id = 3
	GROUP BY answer_id
)
SELECT
	  A.answer_text AS race
	, R.num_ppl
FROM race R
INNER JOIN silver.answers A
	ON R.answer_id = A.answer_id;

-- Age group count?
WITH ages AS (
	SELECT
		  answer_id
		, COUNT(DISTINCT response_id) AS num_ppl
	FROM silver.user_answers
	WHERE q_id = 1
	GROUP BY answer_id
)
SELECT
	  A.answer_text AS age_groups
	, AG.num_ppl
FROM ages AG
INNER JOIN silver.answers A
	ON AG.answer_id = A.answer_id;

-- Most popular category per race
-- Do both counting distinct buyers once and then another with ppl ordering multiple times
WITH orders_race AS (
	SELECT
		  P.response_id
		, P.category
		, A.answer_text AS race
	FROM silver.amazon_purchases P
	LEFT JOIN silver.user_answers UA
		ON P.response_id = UA.response_id
		AND UA.q_id = 3
	LEFT JOIN silver.answers A
		ON UA.answer_id = A.answer_id
), categories_rank AS (
	SELECT
		  race
		, category
		, COUNT(response_id) AS num_orders
		, DENSE_RANK() OVER (PARTITION BY race ORDER BY COUNT(response_id) DESC) AS rnks
	FROM orders_race
	GROUP BY race, category
)
SELECT
	  race
	, category
	, num_orders
	, rnks AS rank
FROM categories_rank
WHERE rnks <= 5
ORDER BY race, rnks
;


-- Most popular category per age group; age q_id = 1
WITH orders_age_groups AS (
	SELECT
		  P.response_id
		, P.category
		, A.answer_text AS age_group
	FROM silver.amazon_purchases P
	LEFT JOIN silver.user_answers UA
		ON P.response_id = UA.response_id
		AND UA.q_id = 1
	LEFT JOIN silver.answers A
		ON UA.answer_id = A.answer_id
), categories_rank AS (
	SELECT
		  age_group
		, category
		, COUNT(response_id) AS num_orders
		, DENSE_RANK() OVER (PARTITION BY age_group ORDER BY COUNT(response_id) DESC) AS rnks
	FROM orders_age_groups
	GROUP BY age_group, category
)
SELECT
	  age_group
	, category
	, num_orders
	, rnks AS rank
FROM categories_rank
WHERE rnks <= 5
ORDER BY age_group, rnks
;

-- Education and race, and age

-- income and order amount
-- Income q_id = 5



-- income and race

-- income and gender

-- income and popular category
-- think i can shorten this and do the aggregation in the first query tbh
WITH income_category AS (
	SELECT
		  P.response_id
		, A.answer_text AS income_group
		, P.category
	FROM silver.amazon_purchases P
	LEFT JOIN silver.user_answers UA
		ON P.response_id = UA.response_id
		AND UA.q_id = 5
	LEFT JOIN silver.answers A
		ON UA.answer_id = A.answer_id
), rnks AS (
	SELECT
		  income_group
		, category
		, COUNT(response_id) AS num_orders
		, DENSE_RANK() OVER (PARTITION BY income_group ORDER BY COUNT(response_id) DESC) AS rnk
	FROM income_category
	GROUP BY income_group, category
)
SELECT
	  income_group
	, category
	, num_orders
FROM rnks
WHERE rnk <= 3
ORDER BY income_group, num_orders DESC
;


-- sexual orientation + age + race

-- the amount of time users purchase from amazon per month and segmented by some demographic

-- how often do people shop on amazon per month based on age, race, gender, sexual orientation, etc

-- The most prevalent demographic (grouped by income (5), race (3), gender (6), sexual orientation (7), education (4), age (1))
SELECT
	    q_demos_gender AS gender
	  , q_demos_race AS race
	  , q_demos_age_group AS age_group
	  , q_demos_sexual_orientation AS sexual_orientation
	  , q_demos_education AS education
	  , q_demos_income AS income
	  , COUNT(DISTINCT response_id) AS num_ppl
FROM bronze.survey_response
GROUP BY q_demos_gender, q_demos_race, q_demos_age_group, q_demos_sexual_orientation, q_demos_education, q_demos_income
ORDER BY num_ppl DESC
;

-- ========================================
-- Time Trend Analysis
-- ========================================
