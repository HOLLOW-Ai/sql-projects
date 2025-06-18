CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN

	PRINT '======================';
	PRINT 'Loading Silver Layer';
	PRINT '======================';

	PRINT 'Dropping FKs in Tables';
	PRINT '======================';

	PRINT '>> Dropping Foreign Key Constraints from Table: silver.question_answer';
	ALTER TABLE silver.question_answer DROP CONSTRAINT question_id_FK;
	ALTER TABLE silver.question_answer DROP CONSTRAINT answer_id_qa_FK;

	PRINT '>> Dropping Foreign Key Constraints from Table: silver.user_answers';
	ALTER TABLE silver.user_answers DROP CONSTRAINT response_id_FK;
	ALTER TABLE silver.user_answers DROP CONSTRAINT q_id_FK;
	ALTER TABLE silver.user_answers DROP CONSTRAINT answer_id_ua_FK;

	PRINT '>> Dropping Foreign Key Constraints from Table: silver.amazon_purchases';
	ALTER TABLE silver.amazon_purchases DROP CONSTRAINT response_id_purchase_FK;


	PRINT '>> Truncating Table: silver.users';
	TRUNCATE TABLE silver.users;

	PRINT '>> Loading Data into Table: silver.users';
	INSERT INTO silver.users (response_id)
	SELECT DISTINCT response_id
	FROM bronze.survey_response;

	PRINT '>> Truncating Table: silver.questions';
	TRUNCATE TABLE silver.questions;

	PRINT '>> Loading Data into Table: silver.questions';
	INSERT INTO silver.questions (question_id, category, question_type, question_text)
	VALUES
		(1, 'demographic', 'single', 'What is your age group?'),
		(2, 'demographic', 'binary', 'Are you of Spanish, Hispanic, or Latino origin?'),
		(3, 'demographic', 'multi-select', 'Choose one or more races that you consider yourself to be'),
		(4, 'demographic', 'single', 'What is the highest level of education you have completed?'),
		(5, 'demographic', 'single', 'What was your total household income before taxes during the past 12 months?'),
		(6, 'demographic', 'single', 'How do you describe yourself?'),
		(7, 'demographic', 'single', 'Which best describes your sexual orientation?'),
		(8, 'demograhpic', 'dropdown', 'In 2021, which U.S. State did you live in?'),
		(9, 'household_use', 'single', 'How many people do you share your Amazon account with? i.e. how many people log in and make orders using your account?'),
		(10, 'household_use', 'single', 'How many people are in your "household"?'),
		(11, 'household_use', 'single', 'How often do you (+ anyone you share your account with) order deliveries from Amazon?'),
		(12, 'personal', 'single', 'Do you or someone in your household or someone you share your Amazon account with smoke cigarettes regularly?'),
		(13, 'personal', 'single', 'Do you or someone in your household or someone you share your Amazon account with smoke marijuana regularly?'),
		(14, 'personal', 'single', 'Do you or someone in your household or someone you share your Amazon account with drink alcohol regularly?'),
		(15, 'personal', 'single', 'Do you or someone in your household or someone you share your Amazon account with have diabetes?'),
		(16, 'personal', 'single', 'Do you or someone in your household or someone you share your Amazon account with use a wheelchair?'),
		(17, 'personal', 'multi-select', 'In 2021 did you, or someone you share your Amazon account with, experience any of the following life changes?')
	;

	PRINT '>> Truncating Table: silver.answers';
	TRUNCATE TABLE silver.answers;

	PRINT '>> Loading Data into Table: silver.answers';
	INSERT INTO silver.answers (answer_id, answer_text)
	VALUES
		(1, '18 - 24 years'),
		(2, '25 - 34 years'),
		(3, '35 - 44 years'),
		(4, '45 - 54 years'),
		(5, '55 - 64 years'),
		(6, '65 and older'),
		(7, 'Yes'),
		(8, 'No'),
		(9, 'White or Caucasian'),
		(10, 'Black or African American'),
		(11, 'American Indian/Native American or Alaska Native'),
		(12, 'Asian'),
		(13, 'Native Hawaiian or Other Pacific Islander'),
		(14, 'Other'),
		(15, 'Some high school or less'),
		(16, 'High school diploma or GED'),
		(17, 'Bachelor''s degree'),
		(18, 'Graduate or professional degree (MA, MS, MBA, PhD, JD, MD, DDS, etc)'),
		(19, 'Prefer not to say'),
		(20, 'Less than $25,000'),
		(21, '$25,000 - $49,999'),
		(22, '$50,000 - $74,999'),
		(23, '$75,000 - $99,999'),
		(24, '$100,000 - $149,999'),
		(25, '$150,000 or more'),
		(26, 'Male'),
		(27, 'Female'),
		(28, 'heterosexual (straight)'),
		(29, 'LGBTQ+'),
		(30, '1 (just me!)'),
		(31, '2'),
		(32, '3'),
		(33, '4+'),
		(34, 'Less than 5 times per month'),
		(35, '5 - 10 times per month'),
		(36, 'More than 10 times per month'),
		(37, 'I stopped in the recent past'),
		(38, 'Lost a job'),
		(39, 'Divorce'),
		(40, 'Moved place of residence'),
		(41, 'Became pregnant'),
		(42, 'Had a child'),
		(43, 'None of the above'),
		(44, 'Alabama'),
		(45, 'Alaska'),
		(46, 'Arizona'),
		(47, 'Arkansas'),
		(48, 'California'),
		(49, 'Colorado'),
		(50, 'Connecticut'),
		(51, 'Delaware'),
		(52, 'Florida'),
		(53, 'Georgia'),
		(54, 'Hawaii'),
		(55, 'Idaho'),
		(56, 'Illinois'),
		(57, 'Indiana'),
		(58, 'Iowa'),
		(59, 'Kansas'),
		(60, 'Kentucky'),
		(61, 'Louisiana'),
		(62, 'Maine'),
		(63, 'Maryland'),
		(64, 'Massachusetts'),
		(65, 'Michigan'),
		(66, 'Minnesota'),
		(67, 'Mississippi'),
		(68, 'Missouri'),
		(69, 'Montana'),
		(70, 'Nebraska'),
		(71, 'Nevada'),
		(72, 'New Hampshire'),
		(73, 'New Jersey'),
		(74, 'New Mexico'),
		(75, 'New York'),
		(76, 'North Carolina'),
		(77, 'North Dakota'),
		(78, 'Ohio'),
		(79, 'Oklahoma'),
		(80, 'Oregon'),
		(81, 'Pennsylvania'),
		(82, 'Rhode Island'),
		(83, 'South Carolina'),
		(84, 'South Dakota'),
		(85, 'Tennessee'),
		(86, 'Texas'),
		(87, 'Utah'),
		(88, 'Vermont'),
		(89, 'Virginia'),
		(90, 'Washington'),
		(91, 'West Virginia'),
		(92, 'Wisconsin'),
		(93, 'Wyoming'),
		(94, 'District of Columbia'),
		(95, 'I did not reside in the United States'),
		(999, 'BLANK')
	;

	PRINT '>> Truncating Table: silver.question_answer';
	TRUNCATE TABLE silver.question_answer;

	PRINT '>> Loading Data into Table: silver.question_answer';
	INSERT INTO silver.question_answer (question_id, answer_id)
	VALUES
		(1, 1),
		(1, 2),
		(1, 3),
		(1, 4),
		(1, 5),
		(1, 6),
		(2, 7),
		(2, 8),
		(3, 9),
		(3, 10),
		(3, 11),
		(3, 12),
		(3, 13),
		(3, 14),
		(4, 15),
		(4, 16),
		(4, 17),
		(4, 18),
		(4, 19),
		(5, 20),
		(5, 21),
		(5, 22),
		(5, 23),
		(5, 24),
		(5, 25),
		(5, 19),
		(6, 26),
		(6, 27),
		(6, 14),
		(6, 19),
		(7, 28),
		(7, 29),
		(7, 19),
		(8, 44),
		(8, 45),
		(8, 46),
		(8, 47),
		(8, 48),
		(8, 49),
		(8, 50),
		(8, 51),
		(8, 52),
		(8, 53),
		(8, 54),
		(8, 55),
		(8, 56),
		(8, 57),
		(8, 58),
		(8, 59),
		(8, 60),
		(8, 61),
		(8, 62),
		(8, 63),
		(8, 64),
		(8, 65),
		(8, 66),
		(8, 67),
		(8, 68),
		(8, 69),
		(8, 70),
		(8, 71),
		(8, 72),
		(8, 73),
		(8, 74),
		(8, 75),
		(8, 76),
		(8, 77),
		(8, 78),
		(8, 79),
		(8, 80),
		(8, 81),
		(8, 82),
		(8, 83),
		(8, 84),
		(8, 85),
		(8, 86),
		(8, 87),
		(8, 88),
		(8, 89),
		(8, 90),
		(8, 91),
		(8, 92),
		(8, 93),
		(8, 94),
		(8, 95),
		(9, 30),
		(9, 31),
		(9, 32),
		(9, 33),
		(10, 30),
		(10, 31),
		(10, 32),
		(10, 33),
		(11, 34),
		(11, 35),
		(11, 36),
		(12, 7),
		(12, 8),
		(12, 37),
		(12, 19),
		(13, 7),
		(13, 8),
		(13, 37),
		(13, 19),
		(14, 7),
		(14, 8),
		(14, 37),
		(14, 19),
		(15, 7),
		(15, 8),
		(15, 19),
		(16, 7),
		(16, 8),
		(16, 19),
		(17, 38),
		(17, 39),
		(17, 40),
		(17, 41),
		(17, 42),
		(17, 43),
		(17, 999)
	;

	PRINT '>> Truncating Table: silver.user_answers';
	TRUNCATE TABLE silver.user_answers;

	PRINT '>> Loading Data into Table: silver.user_answers';	
	WITH answers_cte AS (
		SELECT
			  S.response_id
			, 1 AS q_id
			, A.answer_id
		FROM bronze.survey_response S
		LEFT JOIN silver.answers A
			ON S.q_demos_age_group = A.answer_text

		UNION ALL

		-- Q2: Hispanic
		SELECT
			  S.response_id
			, 2 AS q_id
			, A.answer_id
		FROM bronze.survey_response S
		LEFT JOIN silver.answers A
			ON S.q_demos_hispanic = A.answer_text

		UNION ALL

		-- Q3: Race
		SELECT
			  S.response_id
			, 3 AS q_id
			, A.answer_id
		FROM bronze.survey_response S
		OUTER APPLY string_split(S.q_demos_race, ',') R
		LEFT JOIN silver.answers A
			ON R.value = A.answer_text

		UNION ALL

		-- Q4: Education
		SELECT
			  S.response_id
			, 4 AS q_id
			, A.answer_id
		FROM bronze.survey_response S
		LEFT JOIN silver.answers A
			ON S.q_demos_education = A.answer_text

		UNION ALL

		-- Q5: Income
		SELECT
			  S.response_id
			, 5 AS q_id
			, A.answer_id
		FROM bronze.survey_response S
		LEFT JOIN silver.answers A
			ON S.q_demos_income = A.answer_text

		UNION ALL

		-- Q6: Gender
		SELECT
			  S.response_id
			, 6 AS q_id
			, A.answer_id
		FROM bronze.survey_response S
		LEFT JOIN silver.answers A
			ON S.q_demos_gender = A.answer_text

		UNION ALL

		-- Q7: Sexual Orientation
		SELECT
			  S.response_id
			, 7 AS q_id
			, A.answer_id
		FROM bronze.survey_response S
		LEFT JOIN silver.answers A
			ON S.q_demos_sexual_orientation = LOWER(A.answer_text)

		UNION ALL

		-- Q8: State
		SELECT
			  S.response_id
			, 8 AS q_id
			, A.answer_id
		FROM bronze.survey_response S
		LEFT JOIN silver.answers A
			ON S.q_demos_state = A.answer_text

		UNION ALL

		-- Q9: # sharing account
		SELECT
			  S.response_id
			, 9 AS q_id
			, A.answer_id
		FROM bronze.survey_response S
		LEFT JOIN silver.answers A
			ON S.q_amazon_use_howmany = A.answer_text

		UNION ALL

		-- Q10: Household size
		SELECT
			  S.response_id
			 , 10 AS q_id
			, A.answer_id
		FROM bronze.survey_response S
		LEFT JOIN silver.answers A
			ON S.q_amazon_use_hh_size = A.answer_text

		UNION ALL

		-- Q11: How often
		SELECT
			  S.response_id
			, 11 AS q_id
			, A.answer_id
		FROM bronze.survey_response S
		LEFT JOIN silver.answers A
			ON S.q_amazon_use_how_oft = A.answer_text

		UNION ALL

		-- Q12: Substance - Cigs
		SELECT
			  S.response_id
			, 12 AS q_id
			, A.answer_id
		FROM bronze.survey_response S
		LEFT JOIN silver.answers A
			ON S.q_substance_cig_use = A.answer_text

		UNION ALL

		-- Q13: Substance - Marijuana
		SELECT
			  S.response_id
			, 13 AS q_id
			, A.answer_id
		FROM bronze.survey_response S
		LEFT JOIN silver.answers A
			ON S.q_substance_marij_use = A.answer_text

		UNION ALL

		-- Q14: Substance - Alcohol
		SELECT
			  S.response_id
			, 14 AS q_id
			, A.answer_id
		FROM bronze.survey_response S
		LEFT JOIN silver.answers A
			ON S.q_substance_alcohol_use = A.answer_text

		UNION ALL

		-- Q15: Diabetes
		SELECT
			  S.response_id
			, 15 AS q_id
			, A.answer_id
		FROM bronze.survey_response S
		LEFT JOIN silver.answers A
			ON S.q_personal_diabetes = A.answer_text

		UNION ALL

		-- Q16: Wheelchair
		SELECT
			  S.response_id
			, 16 AS q_id
			, A.answer_id
		FROM bronze.survey_response S
		LEFT JOIN silver.answers A
			ON S.q_personal_wheelchair = A.answer_text

		UNION ALL

		-- Q17: Life Changes
		-- Going to have for now that NULL = 999 for answer_id
		SELECT
			  S.response_id
			, 17 AS q_id
			, A.answer_id
		FROM bronze.survey_response S
		OUTER APPLY string_split(CASE WHEN q_life_changes IS NULL THEN 'BLANK' ELSE S.q_life_changes END, ',') L
		LEFT JOIN silver.answers A
			ON L.value = A.answer_text
	)
	INSERT INTO silver.user_answers (response_id, q_id, answer_id)
	SELECT response_id, q_id, answer_id
	FROM answers_cte
	;


	PRINT '>> Truncating Table: silver.amazon_purchases';
	TRUNCATE TABLE silver.amazon_purchases;

	PRINT '>> Loading Data into Table: silver.amazon_purchases';
	INSERT INTO silver.amazon_purchases (order_date, purchase_price_per_unit, quantity, shipping_address_state, title, product_code, category, response_id)
		SELECT
			  TRY_CAST(order_date AS DATE) AS order_date
			, TRY_CAST(purchase_price_per_unit AS DECIMAL(10, 2)) AS purchase_price_per_unit
			, TRY_CAST(TRY_CAST(quantity AS NUMERIC) AS INT) AS quantity
			, TRY_CAST(shipping_address_state AS NVARCHAR(2)) AS shipping_address_state -- Change to NVARCHAR(2)
			, title
			, asin_isbn_product_code
			, category
			, response_id
		FROM bronze.amazon_purchases
		-- There is one row in the amazon_purchases table that I believe there was a user upload error
		-- It looked like it contained multiple purchase orders in one line from the same respondent
		-- Considering how it was missing some information and there were orders that data pre-2018, I opted to not include that row
		WHERE title NOT LIKE '%20[0-9][0-9]-[0-9][0-9]-[0-9][0-9] 00:00:00%'
	;



	PRINT 'Adding FKs to Tables';
	PRINT '======================';

	PRINT '>> Adding Foreign Key Constraints to Table: silver.question_answer';
	ALTER TABLE silver.question_answer
	ADD CONSTRAINT question_id_FK
	FOREIGN KEY (question_id) REFERENCES silver.questions (question_id)
	;

	ALTER TABLE silver.question_answer
	ADD CONSTRAINT answer_id_qa_FK 
	FOREIGN KEY (answer_id) REFERENCES silver.answers (answer_id)
	;

	PRINT '>> Adding Foreign Key Constraints to Table: silver.user_answers';
	ALTER TABLE silver.user_answers
	ADD CONSTRAINT response_id_FK 
	FOREIGN KEY (response_id) REFERENCES silver.users (response_id)
	;

	ALTER TABLE silver.user_answers
	ADD CONSTRAINT q_id_FK 
	FOREIGN KEY (q_id) REFERENCES silver.questions (question_id)
	;

	ALTER TABLE silver.user_answers
	ADD CONSTRAINT answer_id_ua_FK 
	FOREIGN KEY (answer_id) REFERENCES silver.answers (answer_id)
	;


	PRINT '>> Adding Foreign Key Constraints to Table: silver.amazon_purchases';
	ALTER TABLE silver.amazon_purchases
	ADD CONSTRAINT response_id_purchase_FK 
	FOREIGN KEY (response_id) REFERENCES silver.users (response_id)
	;

END

EXEC silver.load_silver;
