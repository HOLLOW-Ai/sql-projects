CREATE TABLE silver.checkout_records (
		  id NVARCHAR(50)    -- BIGINT doesn't work because value overflows
		, checkout_year INT
		, bibnum INT
		, item_type NVARCHAR(10)
		, collection NVARCHAR(10)
		, item_title NVARCHAR(400)
		, checkout_datetime DATETIME
);

CREATE TABLE silver.dictionary (
	  code NVARCHAR(20)
	, description NVARCHAR(100)
	, code_type NVARCHAR(25)
	, format_group NVARCHAR(20)
	, format_subgroup NVARCHAR(20)
	, cat_group NVARCHAR(25)
	, cat_subgroup NVARCHAR(20)
	, age_group NVARCHAR(20)
);

CREATE TABLE silver.inventory (
	  bibnum INT
	, title NVARCHAR(2000)
	, author NVARCHAR(500)
	, isbn NVARCHAR(2000)
	, pub_year NVARCHAR(250)
	, publisher NVARCHAR(500)
	, item_type NVARCHAR(20)
	, latest_report_date DATE
);
