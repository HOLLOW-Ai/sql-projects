-- Add Indexes later

CREATE OR ALTER PROCEDURE gold.temp_inv_heap AS
BEGIN
	WITH impute_titles AS (
		SELECT
			  bibnum
			, item_title
		FROM silver.checkout_records R
		WHERE EXISTS
			(SELECT 1 FROM silver.inventory I WHERE R.bibnum = I.bibnum AND I.title IS NULL AND R.item_title IS NOT NULL)
	), filtered_inv AS (
		SELECT
			  bibnum
			, MAX(title) AS title
			, MAX(author) AS author
			, MAX(isbn) AS isbn
			, MAX(pub_year) AS pub_year
			, MAX(publisher) AS publisher
			, MAX(report_date) AS latest_report_date
		FROM silver.inventory
		GROUP BY bibnum
	)
	SELECT
		  I.bibnum
		, COALESCE(I.title, T.item_title) AS title
		, author
		, isbn
		, pub_year
		, publisher
		, latest_report_date
	INTO ##inventory
	FROM filtered_inv AS I
	LEFT JOIN impute_titles AS T
		ON I.bibnum = T.bibnum
	;
END
GO




CREATE OR ALTER PROCEDURE gold.temp_checkout_heap AS
BEGIN
	WITH filtered_tbl AS (
		SELECT
			  id AS checkout_id
			, bibnum
			, item_type
			, collection AS item_collection
			, checkout_datetime
		FROM silver.checkout_records R
		WHERE EXISTS
			(SELECT 1 FROM silver.inventory I WHERE I.bibnum = R.bibnum)
	)
	SELECT
		  checkout_id
		, C.bibnum
		, type_key
		, col_key
		, checkout_datetime
	INTO ##checkouts -- Use 2 #'s if I'm opening a new query window, otherwise 1 # if it's the same query window (session)
	FROM filtered_tbl AS C
	LEFT JOIN gold.dim_inventory AS I
		ON C.bibnum = I.bibnum
	LEFT JOIN gold.dim_item_type AS T
		ON C.item_type = T.code
	LEFT JOIN gold.dim_item_collection CO
		ON C.item_collection = CO.code
	;
END
GO
