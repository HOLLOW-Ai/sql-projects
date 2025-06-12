/*
===================================
Demographic Analysis
===================================
*/

SELECT *
FROM silver.questions;

-- How many respondents identified with more than one race?
SELECT *
FROM silver.user_answers
WHERE q_id = 3;

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


-- Most popular category per age group

-- Education and race, and age

-- income and order amount

-- income and race

-- income and gender

-- income and popular category

-- sexual orientation + age + race

-- the amount of time users purchase from amazon per month and segmented by some demographic

-- how often do people shop on amazon per month based on age, race, gender, sexual orientation, etc


-- ========================================
-- Time Trend Analysis
-- ========================================
