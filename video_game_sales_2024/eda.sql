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
-- Check to see if i can do a pivot

SELECT console, genre, COUNT(*), DENSE_RANK() OVER (PARTITION BY console ORDER BY COUNT(*) DESC)
FROM vg_2024
GROUP BY console, genre;

-- What titles are popular in one region but flop in another?
-- Wonder if I could pivot this to and then filter by percentage of total_sales

-- come back later, need to group by title, developer, publisher and then find total sales
-- and then calculate the percentage of total sales by region
WITH pct_sales AS (
SELECT
	  title
	, developer
	, publisher
	, total_sales
	--, na_sales / total_sales
	, ROUND(CASE
		WHEN total_sales IS NOT NULL AND na_sales > 0 THEN na_sales / total_sales
		WHEN total_sales IS NOT NULL AND (na_sales IS NULL OR na_sales = 0) THEN 0
	  END, 2) AS pct_na_sales
	--, jp_sales / total_sales
	, ROUND(CASE
		WHEN total_sales IS NOT NULL AND TRY_CAST(jp_sales AS FLOAT) > 0 THEN TRY_CAST(jp_sales AS FLOAT) / total_sales
		WHEN total_sales IS NOT NULL AND (TRY_CAST(jp_sales AS FLOAT) IS NULL OR TRY_CAST(jp_sales AS FLOAT) = 0) THEN 0
	  END, 2) AS pct_jp_sales
	--, pal_sales / total_sales
	, ROUND(CASE
		WHEN total_sales IS NOT NULL AND TRY_CAST(pal_sales AS FLOAT) > 0 THEN TRY_CAST(pal_sales AS FLOAT) / total_sales
		WHEN total_sales IS NOT NULL AND (TRY_CAST(pal_sales AS FLOAT) IS NULL OR TRY_CAST(pal_sales AS FLOAT) = 0) THEN 0
	  END, 2) AS pct_pal_sales
	--, other_sales / total_sales
	, ROUND(CASE
		WHEN total_sales IS NOT NULL AND TRY_CAST(other_sales AS FLOAT) > 0 THEN TRY_CAST(other_sales AS FLOAT) / total_sales
		WHEN total_sales IS NOT NULL AND (TRY_CAST(other_sales AS FLOAT) IS NULL OR TRY_CAST(other_sales AS FLOAT) = 0) THEN 0
	  END, 2) AS pct_other_sales
FROM vg_2024
)
SELECT
	  title
	, SUM(total_sales) AS total_sales
	, SUM(pct_na_sales) AS pct_na_sales
	, SUM(pct_jp_sales) AS pct_jp_sales
	, SUM(pct_pal_sales) AS pct_pal_sales
	, SUM(pct_other_sales) AS pct_other_sales
FROM pct_sales
WHERE total_sales IS NOT NULL
GROUP BY title, developer, publisher;

/*
===================================================
Beginner
===================================================
*/
-- Find titles that have a critic score above 9.0
SELECT 
	  title
	, console
	, genre
	, publisher
	, developer
	, critic_score
	, total_sales
	, TRY_CAST(release_date AS DATE) AS release_date
FROM vg_2024
WHERE critic_score > 9.0
ORDER BY critic_score DESC;

-- Find number of titles released per year -- this will include rereleases on different platforms
SELECT
	  YEAR(release_date) AS release_year
	, COUNT(title) AS titles_released
FROM vg_2024
GROUP BY YEAR(release_date)
ORDER BY release_year;

-- Find the most popular genre per year

-- Number of titles released per console
SELECT
	  console
	, COUNT(*) AS titles_released
FROM vg_2024
GROUP BY console
ORDER BY console;

-- Average critic score for each genre
SELECT
	  genre
	, ROUND(AVG(critic_score), 2) AS avg_critic_score
FROM vg_2024
GROUP BY genre;

-- Which publisher has published the most games?
SELECT
	  publisher
	, COUNT(*) AS titles_published
FROM vg_2024
WHERE publisher != 'Unknown'
GROUP BY publisher
ORDER BY titles_published DESC;

-- Which top 5 publishers have the highest average total sales across their games?
SELECT TOP (5)
	  publisher
	, AVG(total_sales) AS avg_total_sales
FROM vg_2024
WHERE publisher != 'Unknown'
GROUP BY publisher
ORDER BY avg_total_sales DESC;

-- Total sales per region for games released after 2010
SELECT
	title
FROM vg_2024
WHERE release_date > '2010-12-31';

SELECT 
	  title 
	, SUM(na_sales) AS north_america
	, SUM(TRY_CAST(jp_sales AS FLOAT)) AS japan_sales
	, SUM(TRY_CAST(pal_sales AS FLOAT)) AS europe_africa_sales
	, SUM(TRY_CAST(other_sales AS FLOAT)) AS other_region_sales
FROM vg_2024
WHERE release_date > '2010-12-31'
  AND NOT (
		na_sales IS NULL
	AND jp_sales IS NULL
	AND pal_sales IS NULL
	AND other_sales IS NULL)
GROUP BY title, developer, publisher
;

-- Average critic score between 2000 and 2020
SELECT ROUND(AVG(critic_score), 2) AS avg_critic_score
FROM vg_2024
WHERE release_date >= '2000-01-01' AND release_date <= '2020-12-31';

SELECT 
	  YEAR(release_date) AS release_year
	, ROUND(AVG(critic_score), 2) AS avg_critic_score
FROM vg_2024
WHERE release_date >= '2000-01-01' AND release_date <= '2020-12-31'
GROUP BY YEAR(release_date)
ORDER BY release_year;

-- Identify games whose last update is more than 3 years after their release date

SELECT *
FROM vg_2024
WHERE last_update IS NOT NULL
  AND last_update > DATEADD(year, 3, release_date)
