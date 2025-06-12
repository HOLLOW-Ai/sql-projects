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
