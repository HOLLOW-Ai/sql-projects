/*
===============================================================================
Magnitude Analysis
===============================================================================
*/
-- Total customers by shipping state (q_id = 8) 
-- Also with the total orders shipped to each state
WITH user_states AS (
	SELECT
		  response_id
		, answer_id
	FROM silver.user_answers
	WHERE q_id = 8
), state_residents AS (
	SELECT
		  answers.answer_text AS states
		, COUNT(DISTINCT response_id) AS residents
	FROM user_states
	INNER JOIN silver.answers
		ON user_states.answer_id = answers.answer_id
	GROUP BY answer_text
), orders_shipped AS (
	SELECT
		  shipping_address_state
		, COUNT(*) AS num_orders
	FROM silver.amazon_purchases
	GROUP BY shipping_address_state
), survey_states_abr AS (
	-- I forgot that the survey used the full names of states but the amazon_purchases table uses the abbreviated state names
	-- Might be easier to put state names into its own tables with the abbreviations or transform the survey responses when loading in the csv file
	SELECT
		CASE states
			WHEN 'Alabama' THEN 'AL' 
			WHEN 'Alaska' THEN 'AK' 
			WHEN 'Arizona' THEN 'AZ' 
			WHEN 'Arkansas' THEN 'AR' 
			WHEN 'California' THEN 'CA' 
			WHEN 'Colorado' THEN 'CO' 
			WHEN 'Connecticut' THEN 'CT' 
			WHEN 'Delaware' THEN 'DE' 
			WHEN 'District of Columbia' THEN 'DC' 
			WHEN 'Florida' THEN 'FL' 
			WHEN 'Georgia' THEN 'GA' 
			WHEN 'Hawaii' THEN 'HI' 
			WHEN 'Idaho' THEN 'ID' 
			WHEN 'Illinois' THEN 'IL' 
			WHEN 'Indiana' THEN 'IN' 
			WHEN 'Iowa' THEN 'IA' 
			WHEN 'Kansas' THEN 'KS' 
			WHEN 'Kentucky' THEN 'KY' 
			WHEN 'Louisiana' THEN 'LA' 
			WHEN 'Maine' THEN 'ME' 
			WHEN 'Maryland' THEN 'MD' 
			WHEN 'Massachusetts' THEN 'MA' 
			WHEN 'Michigan' THEN 'MI' 
			WHEN 'Minnesota' THEN 'MN' 
			WHEN 'Mississippi' THEN 'MS' 
			WHEN 'Missouri' THEN 'MO' 
			WHEN 'Montana' THEN 'MT' 
			WHEN 'Nebraska' THEN 'NE' 
			WHEN 'Nevada' THEN 'NV' 
			WHEN 'New Hampshire' THEN 'NH' 
			WHEN 'New Jersey' THEN 'NJ' 
			WHEN 'New Mexico' THEN 'NM' 
			WHEN 'New York' THEN 'NY' 
			WHEN 'North Carolina' THEN 'NC' 
			WHEN 'North Dakota' THEN 'ND' 
			WHEN 'Ohio' THEN 'OH' 
			WHEN 'Oklahoma' THEN 'OK' 
			WHEN 'Oregon' THEN 'OR' 
			WHEN 'Pennsylvania' THEN 'PA' 
			WHEN 'Rhode Island' THEN 'RI' 
			WHEN 'South Carolina' THEN 'SC' 
			WHEN 'South Dakota' THEN 'SD' 
			WHEN 'Tennessee' THEN 'TN' 
			WHEN 'Texas' THEN 'TX' 
			WHEN 'Utah' THEN 'UT' 
			WHEN 'Vermont' THEN 'VT' 
			WHEN 'Virginia' THEN 'VA' 
			WHEN 'Washington' THEN 'WA' 
			WHEN 'West Virginia' THEN 'WV' 
			WHEN 'Wisconsin' THEN 'WI' 
			WHEN 'Wyoming' THEN 'WY' 
			ELSE NULL
		END AS state_abr
		, residents
	FROM state_residents
)
SELECT
	  S.state_abr
	, S.residents
	, O.num_orders
	, CAST(ROUND(1.0 * O.num_orders / S.residents, 1) AS DECIMAL(5, 1)) AS orders_per_resident
FROM survey_states_abr S
INNER JOIN orders_shipped O -- Will get rid of the orders where the shipping state was NULL
	ON S.state_abr = O.shipping_address_state
;


-- Category Analysis
	-- Average price of items in each category
	-- Total products in each category
	-- Total revenue generated by each category
SELECT
	  category
	, AVG(purchase_price_per_unit) AS avg_price
	, COUNT(DISTINCT product_code) AS total_products
	, SUM(purchase_price_per_unit * quantity) AS total_revenue
FROM silver.amazon_purchases
GROUP BY category
ORDER BY avg_price DESC
;


-- Customer Information: Total catergories bought from, total revenue generated
SELECT
	  response_id
	, COUNT(DISTINCT category) AS num_categories_bought
	, SUM(quantity * purchase_price_per_unit) AS revenue_generated
FROM silver.amazon_purchases
GROUP BY response_id
;


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


-- Do individuals using wheelchairs order more on average than individuals who do not use wheelchairs?
WITH orders_per_user AS (
	-- Number of orders made by each respondent
	SELECT
		  response_id
		, COUNT(*) AS num_orders
	FROM silver.amazon_purchases
	GROUP BY response_id
), wheelchair_user AS (
	-- Respondents' answer to question 16 about wheelchair use
	SELECT
		response_id
		, answer_id
	FROM silver.user_answers
	WHERE q_id = 16
), orders_and_wheelchair_use AS (
	-- Combining the 2 previous CTEs
	SELECT
		  O.response_id
		, O.num_orders
		, W.answer_id
	FROM orders_per_user O
	INNER JOIN wheelchair_user W
		ON O.response_id = W.response_id
), averaged_orders AS (
	-- Average orders made by answer to wheelchair question
	SELECT
		  answer_id
		, AVG(num_orders) AS avg_orders
	FROM orders_and_wheelchair_use
	GROUP BY answer_id
)
SELECT
	  answers.answer_text
	, avg_orders
FROM averaged_orders
INNER JOIN silver.answers
	ON averaged_orders.answer_id = answers.answer_id
;
-- Could delve deeper by adding other demographic factors, or looking at the change in number of orders over time
