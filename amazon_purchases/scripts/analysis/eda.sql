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

-- Survey questions given to respondents during data collection
SELECT
	  question_id
	, category
	, question_type
	, question_text
FROM silver.questions;

-- Each question_id is associated with an answer_id
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



