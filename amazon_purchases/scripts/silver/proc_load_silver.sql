/*
==============================================
Insert: silver.users
==============================================
*/

INSERT INTO silver.users (response_id)
SELECT DISTINCT response_id
FROM bronze.amazon_purchases;

/*
==============================================
Insert: silver.questions
==============================================
*/

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
	(17, 'personal', 'optional multi-select', 'In 2021 did you, or someone you share your Amazon account with, experience any of the following life changes?')
;

/*
==============================================
Insert: silver.answers
==============================================
*/
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
	(18, 'Graduate or professional degree (MA, MS, MBA, PhD, JD, MD, DDS, etc'),
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
	(30, 'prefer not to say'), --fix this later
	(31, '1 (just me!'),
	(32, '2'),
	(33, '3'),
	(34, '4+'),
	(35, 'Less than 5 times per month'),
	(36, '5 - 10 times per month'),
	(37, 'More than 10 times per month'),
	(38, 'I stopped in the recent past'),
	(39, 'Lost a job'),
	(40, 'Divorce'),
	(41, 'Moved place of residence'),
	(42, 'Became pregnant'),
	(43, 'Had a child'),
	(44, 'None of the above')
;

SELECT DISTINCT q_demos_age_group
FROM bronze.survey_response
