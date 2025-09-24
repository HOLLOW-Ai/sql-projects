-- silver.inventory
WITH scan_table AS (
	SELECT
		  bibnum
		, title
		, author
		, isbn
		, pub_year
		, publisher
		, item_type
		, report_date
		, MAX(title) OVER (PARTITION BY bibnum, item_type) AS max_title
		, MAX(author) OVER (PARTITION BY bibnum, item_type) AS max_author
		, MAX(isbn) OVER (PARTITION BY bibnum, item_type) AS max_isbn
		, MAX(pub_year) OVER (PARTITION BY bibnum, item_type) AS max_year
		, MAX(publisher) OVER (PARTITION BY bibnum, item_type) AS max_publisher
		, ROW_NUMBER() OVER (PARTITION BY bibnum, item_type ORDER BY report_date DESC) AS rn
	FROM bronze.raw_inv
), final_table AS (
	SELECT
		  bibnum
		, COALESCE(title, max_title) AS title
		, COALESCE(author, max_author) AS author
		, COALESCE(isbn, max_isbn) AS isbn
		, COALESCE(pub_year, max_year) AS pub_year
		, COALESCE(publisher, max_publisher) AS publisher
		, item_type
		, report_date
	FROM scan_table
	WHERE rn = 1
)
INSERT INTO silver.inventory (
	  bibnum
	, title
	, author
	, isbn
	, pub_year
	, publisher
	, item_type
	, report_date
)
SELECT 
	  bibnum
	, title
	, author
	, isbn
	, pub_year
	, publisher
	, item_type
	, report_date
FROM final_table;

-- silver.dictionary
WITH cte_dictionary AS (
	SELECT 
		  code
		, description
		, code_type
		, format_group
		, format_subgroup
		, cat_group
		, cat_subgroup
		, age_group
	FROM bronze.dictionary
	WHERE code NOT LIKE '%HOTSPOT%'
)
INSERT INTO silver.dictionary (
	  code
	, description
	, code_type
	, format_group
	, format_subgroup
	, cat_group
	, cat_subgroup
	, age_group
)
SELECT
	  code
	, description
	, code_type
	, format_group
	, format_subgroup
	, cat_group
	, cat_subgroup
	, age_group
FROM cte_dictionary
;
