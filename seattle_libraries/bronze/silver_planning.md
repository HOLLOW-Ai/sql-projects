# Preparing for Silver Layer

This document tracks the changes I plan to make to ensure the data loaded in the bronze tables are cleaned and standardized when loading it in the silver layer tables. This will involve checking NULLs, duplicates, whitespaces, etc. The sections will be divided by table.

## Data Dictionary Table

Considering this table is meant to lookup the description for the differnt codes used in the other tables, I would expect every row to be unique.

### 1. Checking Duplicates
```sql
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
GROUP BY code, description, code_type, format_group, format_subgroup, cat_group, cat_subgroup, age_group    -- I do opt to use GROUP BY instead of DISTINCT for performance reasons and to help build as a habit
HAVING COUNT(*) > 1
;
```
There are no duplicates as far as I can tell. It's possible there misspellings, whitespace, or cases. As far as I know, MSSQL is case insensitive by default, so different capitalizations don't matter. Moving on to the next step, but will refer back to this code block if there is white space.

### 2. Checking for Null Values
```sql
SELECT
      COUNT(*) - COUNT(code) AS code
    , COUNT(*) - COUNT(description) AS description
    , COUNT(*) - COUNT(code_type) AS code_type
    , COUNT(*) - COUNT(format_group) AS format_group
    , COUNT(*) - COUNT(format_subgroup) AS format_subgroup
    , COUNT(*) - COUNT(cat_group) AS cat_group
    , COUNT(*) - COUNT(cat_subgroup) AS cat_subgroup
    , COUNT(*) - COUNT(age_group) AS age_group
    , COUNT(*) AS num_rows
FROM bronze.dictionary
```
I have made a `null_report` script meant for the gold layer, but I repurposed it here because I had accidentally removed this code block while practicing. I am skipping the the UNPIVOT step here because the focus is on one table right now.

There are NULLs in the columns beginning at `format_group` to `age_group`. Note that for all rows with the value `Location` in the `code_type` column, only code, description, and code_type have a value while the rest are NULL. Later, I decide to remove the rows labeled with `Location` because I did not download the `Location` columns from the source database (mainly due to storage reasons as SQL Express has a 10gb limit per database).

I was unsure how to handle the NULLs here, because for the column `format_group` there exists a value of "Other" that is used for some of the rows, but some are left NULL regardless, excluding the "Location" rows. The source doesn't provide the meaning of these values and why some are left blank. I decide later on that if the proportion of NULL values in a column isn't "large" (More than 30%, I suppose) then I opted to use a CASE WHEN statement to change NULLs to "N/A". If there were a large amount of NULL values, I opted to keep the NULLs mainly to draw attention to it to whoever views the dataset later. I don't think this is an optimal strategy, but this is all practice and will be dependent on whatever business rules are in place.

### 3. Checking Cardinality

### 4. Checking Size of Columns
