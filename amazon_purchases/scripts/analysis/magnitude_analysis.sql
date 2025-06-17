/*
===============================================================================
Magnitude Analysis
===============================================================================
*/
-- Total customers by shipping state (q_id = 8)

WITH user_states AS (
	SELECT
		  response_id
		, answer_id
	FROM silver.user_answers
	WHERE q_id = 8
)
SELECT
	  answers.answer_text
	, COUNT(DISTINCT response_id) AS residents
FROM user_states
INNER JOIN silver.answers
	ON user_states.answer_id = answers.answer_id
GROUP BY answer_text
;

-- Total Order Shipped to each State
SELECT
	  shipping_address_state
	, COUNT(*)
FROM silver.amazon_purchases
GROUP BY shipping_address_state
;

-- Total customers by gender

-- Total products by category

-- Average price in each category

-- Total revenue generated for each category


-- Customer Information: Total catergories bought from, total revenue generated
SELECT
	  response_id
	, COUNT(DISTINCT category) AS num_categories_bought
	, SUM(quantity * purchase_price_per_unit) AS revenue_generated
FROM silver.amazon_purchases
GROUP BY response_id
;

-- Distribution of customers across states

-- What is the average amount spent per order for each age group?
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
ORDER BY CASE age_group
				WHEN 'Less than $25,000' THEN 1
				WHEN '$25,000 - $49,999' THEN 2
				WHEN '$50,000 - $74,999' THEN 3
				WHEN '$75,000 - $99,999' THEN 4
				WHEN '$100,000 - $149,999' THEN 5
				WHEN '$150,000 or more' THEN 6
				WHEN 'Prefer not to say' THEN 7
		  END ASC 
;
