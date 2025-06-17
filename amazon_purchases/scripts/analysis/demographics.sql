USE amazon;

/*
===================================
Demographic Analysis
===================================
*/


-- Education and race, and age

-- income and order amount; AVG money spent per income group
-- Income q_id = 5
SELECT
	  age_group
	, AVG(purchase_price_per_unit * quantity) AS avg_spent_per_order
FROM silver.amazon_purchases P
INNER JOIN (
	SELECT response_id, answer_text AS age_group
	FROM silver.user_answers UA
	INNER JOIN silver.answers A
		ON UA.answer_id = A.answer_id
		AND q_id = 5
	) age_groups
	ON P.response_id = age_groups.response_id
GROUP BY age_group
;

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
