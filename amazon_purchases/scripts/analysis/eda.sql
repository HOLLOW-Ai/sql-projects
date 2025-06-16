/*
===============================================================================
Exploratory Data Analysis
===============================================================================
Purpose:
	- To explore the cardinality of columns
	- To gain a better understanding of the dataset and find possible
	  relationships and/or trends
===============================================================================
*/

-- Survey questions given to respondents during data collection can be found in the table silver.questions
SELECT
	  question_id
	, category
	, question_type
	, question_text
FROM silver.questions;

-- Each question_id is associated with an answer_id in the table silver.question_answer
SELECT
	  question_id
	, answer_id
FROM silver.question_answer;

-- To connect the questions and its associated answer choices, it needs to be joined to silver.question_answer
SELECT
	  Q.question_text AS question
	, A.answer_text AS answer
FROM silver.question_answer QA
INNER JOIN silver.questions Q
	ON QA.question_id = Q.question_id
INNER JOIN silver.answers A
	ON QA.answer_id = A.answer_id
ORDER BY Q.question_id
;

-- To see how respondents answered to the survey questions, you can view the table silver.user_answers
SELECT TOP (100)
	  response_id
	, q_id
	, answer_id
FROM silver.user_answers;

-- To see the full text of question and answers for each respondent, tables silver.questions and silver.answers can be joined
SELECT TOP (100)
	  U.response_id
	, Q.question_text AS question
	, A.answer_text AS answer
FROM silver.user_answers U
INNER JOIN silver.questions Q
	ON U.q_id = Q.question_id
INNER JOIN silver.answers A
	ON U.answer_id = A.answer_id
ORDER BY U.response_id, Q.question_id
;

-- What is the age distribution of the respondents?
WITH ages AS (
	SELECT
		  answer_id
		, COUNT(DISTINCT response_id) AS num_ppl
	FROM silver.user_answers
	WHERE q_id = 1
	GROUP BY answer_id
)
SELECT
	  ANS.answer_text AS age_groups
	, AGE.num_ppl
FROM ages AGE
INNER JOIN silver.answers ANS
	ON AGE.answer_id = ANS.answer_id
ORDER BY age_groups
;

-- What is the race distribution of the respondents?
-- Note: Some respondents identified with multiple races, so they would be counted multiple times
WITH race_count AS (
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
FROM race_count R
INNER JOIN silver.answers A
	ON R.answer_id = A.answer_id
ORDER BY race
;

-- How many races did the respondents identify with?
WITH race_per_respondent AS (
	SELECT
	-- Counting the number of races selected by each respondent
		  response_id
		, COUNT(DISTINCT answer_id) AS num_selected
	FROM silver.user_answers
	WHERE q_id = 3
	GROUP BY response_id
)
SELECT
	num_selected
	, COUNT(DISTINCT response_id) AS num_ppl
FROM race_per_respondent
GROUP BY num_selected
ORDER BY num_selected
;
