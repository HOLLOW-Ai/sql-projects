CREATE TABLE silver.checkout_records (
		  id NVARCHAR(50)    -- BIGINT doesn't work because value overflows
		, checkout_year INT
		, bibnum INT
		, item_type NVARCHAR(10)
		, collection NVARCHAR(10)
		, item_title NVARCHAR(400)
		, checkout_datetime DATETIME
);
