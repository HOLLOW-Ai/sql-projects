/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
	- To gain a better understanding of the dataset and find possible
	  relationships and/or trends
	- To understand the demographics of the survey respondents
===============================================================================
*/

-- Most popular category per race
-- Top 5 categories per race
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
-- Top 5 Categories by Age Group
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
