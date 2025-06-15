DROP TABLE IF EXISTS silver.users;
CREATE TABLE silver.users (
	response_id NVARCHAR(100) NOT NULL 
	CONSTRAINT reponse_id_PK PRIMARY KEY (response_id) -- specifying constraint so i can name the PKs and FKs
);

DROP TABLE IF EXISTS silver.questions;
CREATE TABLE silver.questions (
	question_id INT NOT NULL,
	category NVARCHAR(50),
	question_type NVARCHAR(50),
	question_text NVARCHAR(255),
	CONSTRAINT question_id_PK PRIMARY KEY (question_id)
);

DROP TABLE IF EXISTS silver.answers;
CREATE TABLE silver.answers (
	answer_id INT NOT NULL,
	answer_text NVARCHAR(255),
	CONSTRAINT answer_id_PK PRIMARY KEY (answer_id)
);

DROP TABLE IF EXISTS silver.question_answer;
CREATE TABLE silver.question_answer (
	question_id INT, --foreign key
	answer_id INT, --FK
	CONSTRAINT question_id_FK FOREIGN KEY (question_id) REFERENCES silver.questions (question_id),
	CONSTRAINT answer_id_qa_FK FOREIGN KEY (answer_id) REFERENCES silver.answers (answer_id)
);

DROP TABLE IF EXISTS silver.user_answers;
CREATE TABLE silver.user_answers (
	response_id NVARCHAR(100) NOT NULL, --FK KEY
	q_id INT NOT NULL, --FK
	answer_id INT NOT NULL,
	CONSTRAINT response_id_FK FOREIGN KEY (response_id) REFERENCES silver.users (response_id),
	CONSTRAINT q_id_FK FOREIGN KEY (q_id) REFERENCES silver.questions (question_id),
	CONSTRAINT answer_id_ua_FK FOREIGN KEY (answer_id) REFERENCES silver.answers (answer_id)
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
	response_id NVARCHAR(100) NOT NULL,
	CONSTRAINT response_id_purchase_FK FOREIGN KEY (response_id) REFERENCES silver.users (response_id)
);
