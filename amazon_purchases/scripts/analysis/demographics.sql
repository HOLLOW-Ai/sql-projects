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

--
