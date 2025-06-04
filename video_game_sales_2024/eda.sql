SELECT TOP (100) *
FROM vg_2024;

SELECT DISTINCT publisher
FROM vg_2024
ORDER BY publisher;

-- Which titles sold the most worldwide?
SELECT TOP (100) title, total_sales, na_sales, jp_sales, pal_sales, other_sales, na_sales + jp_sales + pal_sales + other_sales, release_date, console, developer, publisher
FROM vg_2024;

SELECT TOP (10) title, SUM(total_sales) AS total_sales_mil
FROM vg_2024
GROUP BY title, developer, publisher
ORDER BY total_sales_mil DESC

-- Instead of being NULL, some games have the total_sales to be 0 instead
SELECT *
FROM vg_2024
WHERE total_sales IS NULL;

-- Which year had the highest sales? Has the industry grown over time?

SELECT YEAR(release_date) AS year, SUM(total_sales) AS total_year_sales
FROM vg_2024
GROUP BY YEAR(release_date)
ORDER BY total_year_sales DESC;

WITH vg_yearly_sales AS (
	SELECT YEAR(release_date) AS year, SUM(total_sales) AS total_year_sales
	FROM vg_2024
	GROUP BY YEAR(release_date)
)
SELECT 
	  year
	, total_year_sales
	, LAG(total_year_sales, 1) OVER (ORDER BY year ASC) AS previous_year_sales
	, ROUND((total_year_sales - LAG(total_year_sales, 1) OVER (ORDER BY year ASC)) / LAG(total_year_sales, 1) OVER (ORDER BY year ASC) * 100.0, 2) AS pct_change
FROM vg_yearly_sales
ORDER BY year;

SELECT *
FROM vg_2024
WHERE release_date BETWEEN '2021-01-01' AND '2021-12-31';

-- Do any consoles seem to specialize in a particular genre?

-- What titles are popular in one region but flop in another?
