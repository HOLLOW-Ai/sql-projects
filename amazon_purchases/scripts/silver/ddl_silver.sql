DROP TABLE IF EXISTS silver.users;
CREATE TABLE silver.users (
	response_id NVARCHAR(100) NOT NULL PRIMARY KEY
);

DROP TABLE IF EXISTS silver.questions;
CREATE TABLE silver.questions (
	question_id INT NOT NULL PRIMARY KEY,
	category NVARCHAR(50),
	question_type NVARCHAR(50),
	question_text NVARCHAR(255)
);

DROP TABLE IF EXISTS silver.answers;
CREATE TABLE silver.answers (
	answer_id INT NOT NULL PRIMARY KEY,
	answer_text NVARCHAR(255)
);

DROP TABLE IF EXISTS silver.question_answer;
CREATE TABLE silver.question_answer (
	question_id INT FOREIGN KEY REFERENCES silver.questions(question_id), --foreign key
	answer_id INT FOREIGN KEY REFERENCES silver.answers(answer_id) --FK
);

DROP TABLE IF EXISTS silver.user_answers;
CREATE TABLE silver.user_answers (
	response_id NVARCHAR(100) NOT NULL FOREIGN KEY REFERENCES silver.users(response_id), --FK KEY
	q_id INT NOT NULL FOREIGN KEY REFERENCES silver.questions(question_id), --FK
	answer_id INT NOT NULL FOREIGN KEY REFERENCES silver.answers(answer_id)
);

DROP TABLE IF EXISTS silver.amazon_purchases;
CREATE TABLE silver.amazon_purchases (
	order_date DATE NOT NULL,
	purchase_price_per_unit DECIMAL(10, 2) NOT NULL,
	quantity INT NULL,
	shipping_address_state NVARCHAR(2) NULL,
	title NVARCHAR(2000) NULL,
	product_code NVARCHAR(30) NULL,
	category NVARCHAR(100) NULL,
	response_id NVARCHAR(100) NOT NULL FOREIGN KEY REFERENCES silver.users(response_id)-- FK add the constraint during or after table creation?
);
