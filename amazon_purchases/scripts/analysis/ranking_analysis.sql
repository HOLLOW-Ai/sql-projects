/*
===============================================================================
Ranking Analysis
===============================================================================
Practicing using DENSE_RANK() to see if there was a difference in 
purchasing behavior between different demographics.
===============================================================================
*/

-- Top 5 Categories by Total Orders
WITH ranked_cats AS (
	SELECT
		  category
		, COUNT(response_id) AS num_orders
		, DENSE_RANK() OVER (ORDER BY COUNT(response_id) DESC) AS rnk
	FROM silver.amazon_purchases
	GROUP BY category
)
SELECT
	  category
	, num_orders
	, rnk
FROM ranked_cats
WHERE rnk <= 5
ORDER BY rnk
;

-- Top 5 Best Performing Categories by Total Sales
WITH ranked_sales AS (
	SELECT
		  category
		, SUM(purchase_price_per_unit * quantity) AS total_sales
		, DENSE_RANK() OVER (ORDER BY SUM(purchase_price_per_unit * quantity) DESC) AS rnk
	FROM silver.amazon_purchases
	GROUP BY category
)
SELECT
	  category
	, total_sales
	, rnk
FROM ranked_sales
WHERE rnk <= 5
ORDER BY rnk
;

-- Top 5 Worst Performing Categories by Total Sales
WITH ranked_sales AS (
	SELECT
		  category
		, SUM(purchase_price_per_unit * quantity) AS total_sales
		, DENSE_RANK() OVER (ORDER BY SUM(purchase_price_per_unit * quantity) ASC) AS rnk
	FROM silver.amazon_purchases
	GROUP BY category
)
SELECT
	  category
	, total_sales
	, rnk
FROM ranked_sales
WHERE rnk <= 5
ORDER BY rnk
;

-- Top 5 Categories for each Race
-- Note: This query ends up counting some of the respondents multiple times because they identified with multiple races
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

-- Top 5 Categories for each Age Group
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
WHERE rnks <= 5 -- Change if you want to see less categories
ORDER BY age_group, rnks
;

-- Ranking Age Groups by Total Orders
WITH orders_per_user AS (
	-- Number of orders made by each respondent
	SELECT
		  response_id
		, COUNT(*) AS num_orders
	FROM silver.amazon_purchases
	GROUP BY response_id
), age_answers AS (
	-- Respondents' answer to question 16 about wheelchair use
	SELECT
		response_id
		, answer_id
	FROM silver.user_answers
	WHERE q_id = 1
), age_orders AS (
	-- Combining the 2 previous CTEs
	SELECT
		  O.response_id
		, O.num_orders
		, A.answer_id
	FROM orders_per_user O
	INNER JOIN age_answers A
		ON O.response_id = A.response_id
), orders_per_group AS (
	-- Average orders made by answer to wheelchair question
	SELECT
		  answer_id
		, COUNT(*) AS total_orders
	FROM age_orders
	GROUP BY answer_id
)
SELECT
	  answers.answer_text
	, total_orders
FROM orders_per_group
INNER JOIN silver.answers
	ON orders_per_group.answer_id = answers.answer_id
ORDER BY total_orders DESC
;
-- Perhaps we see a skew because younger people may be more likely to respond to an online survey
