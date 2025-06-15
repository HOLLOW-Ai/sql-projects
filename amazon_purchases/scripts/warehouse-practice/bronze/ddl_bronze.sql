CREATE DATABASE amazon;
USE amazon;

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO

DROP TABLE IF EXISTS bronze.survey_response;
CREATE TABLE bronze.survey_response (
	response_id NVARCHAR(255) NOT NULL,
	q_demos_age_group NVARCHAR(255) NULL,
	q_demos_hispanic NVARCHAR(255) NULL,
	q_demos_race NVARCHAR(255) NULL,
	q_demos_education NVARCHAR(255) NULL,
	q_demos_income NVARCHAR(255) NULL,
	q_demos_gender NVARCHAR(255) NULL,
	q_demos_sexual_orientation NVARCHAR(255) NULL,
	q_demos_state NVARCHAR(255) NULL,
	q_amazon_use_howmany NVARCHAR(255) NULL,
	q_amazon_use_hh_size NVARCHAR(255) NULL,
	q_amazon_use_how_oft NVARCHAR(255) NULL,
	q_substance_cig_use NVARCHAR(255) NULL,
	q_substance_marij_use NVARCHAR(255) NULL,
	q_substance_alcohol_use NVARCHAR(255) NULL,
	q_personal_diabetes NVARCHAR(255) NULL,
	q_personal_wheelchair NVARCHAR(255) NULL,
	q_life_changes NVARCHAR(255) NULL,
	q_sell_your_data NVARCHAR(255) NULL,
	q_sell_consumer_data NVARCHAR(255) NULL,
	q_small_biz_use NVARCHAR(255) NULL,
	q_census_use NVARCHAR(255) NULL,
	q_research_society NVARCHAR(255) NULL
);

DROP TABLE IF EXISTS bronze.amazon_purchases;
CREATE TABLE bronze.amazon_purchases (
	order_date NVARCHAR(255) NULL,
	purchase_price_per_unit NVARCHAR(255) NULL,
	quantity NVARCHAR(255) NULL,
	shipping_address_state NVARCHAR(255) NULL,
	title NVARCHAR(255) NULL,
	asin_isbn_product_code NVARCHAR(255) NULL,
	category NVARCHAR(255) NULL,
	response_id NVARCHAR(255) NOT NULL
);
