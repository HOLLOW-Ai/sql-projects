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
;
```
I have made a `null_report` script meant for the gold layer, but I repurposed it here because I had accidentally removed this code block while practicing. I am skipping the the UNPIVOT step here because the focus is on one table right now.

There are NULLs in the columns beginning at `format_group` to `age_group`. Note that for all rows with the value `Location` in the `code_type` column, only code, description, and code_type have a value while the rest are NULL. Later, I decide to remove the rows labeled with `Location` because I did not download the `Location` columns from the source database (mainly due to storage reasons as SQL Express has a 10gb limit per database).

I was unsure how to handle the NULLs here, because for the column `format_group` there exists a value of "Other" that is used for some of the rows, but some are left NULL regardless, excluding the "Location" rows. The source doesn't provide the meaning of these values and why some are left blank. I decide later on that if the proportion of NULL values in a column isn't "large" (More than 30%, I suppose) then I opted to use a CASE WHEN statement to change NULLs to "N/A". If there were a large amount of NULL values, I opted to keep the NULLs mainly to draw attention to it to whoever views the dataset later. I don't think this is an optimal strategy, but this is all practice and will be dependent on whatever business rules are in place.

### 3. Checking Cardinality
I won't be doing a cardinality check for all columns here, but I wanted to highlight the `code_type` column:
```sql
SELECT DISTINCT code_type
FROM bronze.dictionary
;
```
|code_type|
|---------|
|ItemCollection|
|ItemType|
|ItemTypeDetail|
|Location|

I have already decided to not include "Location" in the silver table. I was confused on what "ItemTypeDetail" meant so filtering to that type leads to only one code named "HOTSPOT". I checked out the `checkouts` table and found some records where the `item_type` is listed as "HOTSPOT". Considering how few those rows are, I opted to remove the "HOTSPOT" rows in both tables because in the gold layer, I want to make views that separate the rows that are listed as "ItemType" and "ItemCollection".

### 4. Checking Size of Columns
Admittedly, the dictionary table was created using specified sizes rather than MAX, so this section isn't that necessary. However, considering the size of the checkouts.csv file, every bit of memory and storage counts. We'll see if we can reduce the sizes of the columns.
```sq;
SELECT
      LEN(code)
    , LEN(description)
    , LEN(code_type)
    , LEN(format_group)
    , LEN(format_subgroup)
    , LEN(cat_group)
    , LEN(cat_subgroup)
    , LEN(age_group)
FROM bronze.dictionary
;
```

### 5. Checking for Whitespace
This would just be checked using LEN() and TRIM() in combination. LOWER() if you want to be certain. I'll only write it once for the Data Dictionary table because the other two tables are too big to be doing string checks and I have different plans on handling those tables.
```sql
WITH lowercase_cte AS (
    SELECT
        LOWER(code) AS lw_code
      , LOWER(description) AS lw_desc
      , LOWER(code_type) AS lw_type
      , LOWER(format_group) AS lw_fg
      , LOWER(format_subgroup) AS lw_fsg
      , LOWER(cat_group) AS lw_cg
      , LOWER(cat_subgroup) AS lw_csg
      , LOWER(age_group) AS lw_ag
    FROM bronze.dictionary
)
SELECT *    -- * for laziness and I know there is at most 640 rows in this dataset, so it's not a big performance issue
FROM lowercase_cte
WHERE LEN(lw_code) = LEN(TRIM(lw_code))
    OR LEN(lw_desc) = LEN(TRIM(lw_desc))
    OR LEN(lw_type) = LEN(TRIM(lw_type))
    OR LEN(lw_fg) = LEN(TRIM(lw_fg))
    OR LEN(lw_fsg) = LEN(TRIM(lw_fsg))
    OR LEN(lw_cg) = LEN(TRIM(lw_cg))
    OR LEN(lw_csg) = LEN(TRIM(lw_csg))
    OR LEN(lw_ag) = LEN(TRIM(lw_ag))
;
```
No issues with whitespace. Thankfully, the datasets uploaded from Seattle were relatively clean.

### Changes to be Made
- Remove `HOTSPOT` from both dictionary and checkout tables
- Remove `Location` from dictionary when moving to silver table
- Replace `NULL` values in group and subgroup columns
- Reduce size of columns in silver table creation

## Inventory Catalog Table

This table is meant to be a bibliographic snapshot record of books in circulation at Seattle Libraries. Meaning, that the same item (indicated by the BibNum) can show up multiple times because it has snapshots at different points in time.

Honestly, the most frustrating table to work with. My assumption is that these items are inputted manually, because for the same item the inputs can be way different or just left `NULL`. There is no consistent way of inputting the data. I should say that the dataset included a `Location` column of where the item currently was at the time of the snapshot, but I had removed it due to storage concerns. This makes me think that it is different librarians who input these records. Absolutely maddening while I figured out how I wanted to transform this data.

An example of a frustration:
```sql
SELECT
      bibnum
    , author
    , isbn
    , report_date
FROM bronze.catalog
WHERE bibnum = 4031834
GROUP BY bibnum, author, isbn, report_date
;
```
We see here what appears to be the case of an item being ascribed the wrong BibNum. Other examples of data inconsistency issues include difference in spelling of the title for the same author, weird formatting with the publish year, different author spellings, etc.
```sql
-- Spelling diff of title, isbn has 1+, pub_year weird format, publisher spelling diff
SELECT DISTINCT *
FROM loading
WHERE bibnum = 8157
;

-- Spelling diff of Author
SELECT DISTINCT *
FROM loading
WHERE bibnum = 19786
;
```
At this point, I decided that we are going to turn the inventory catalog into a dimension table where there is a unique BibNum; each physical item should only have one row. Latest report date for an item takes priority. If any of the columns are `NULL` for the latest report date, then we're going to use MAX() to find a non-Null value to impute.

The loading process was done using CTEs. The rows that were filtered out were any duplicate BibNums. I used ROW_NUMBER() and ordered by report_date to number the latest reported info as 1. If any of the columns happen to be `NULL` for the latest report record, then it will use the values found using the MAX() window function to impute values with COALESCE().

### 1. Checking Duplicates
Without the item collection and item type columns, you'll end up with some duplicate rows. Furthermore, removing the report date column will increase the number of duplicates if you are focusing on records that have the the `BibNum`. If you do include title, you'll end up with records with the same `BibNum` but slightly different titles because either the spelling or punctuation is off. Same with author, publisher, publish year, etc.

### 2. Checking for Null Values
There are a lot of `NULL` values in the `author`, `title`, `pub_year`, `publisher`, and `isbn` columns. There are not any `NULL` values in the `BibNum` column. Instead of getting rid of the rows, we'll keep one row for each unique `BibNum` and impute any `NULL` values with a non-NULL value for the same `BibNum` using `COALESCE()`.

### 3. Checking Cardinality
Each column is going to have a high cardinality. You would think the `pub_year` column would have a lower cardinality, even if it is a wide range of year, but as per the FAQ of the source dataset, the `pub_year` column has many different formats for the year that could be due to copyright, approximate publish year, a range of years, etc. This is also why you can't cast the `pub_year` column as an integer.

### 4. Checking Size of Columns

### 5. Checking for Whitespace

### Changes to be Made
- Use `ROW_NUMBER()` and order by `report_date` descending
- `COALESCE()` on the rows numbered 1 and use the values from the MAX(column) window function columns to impute values
- Reduce size of columns

## Checkout Records Table

Biggest table by around ~16 million rows. The records date from January 1, 2020 to September 9, 2025. According to the source page, each record is a checkout record. Renewals are not included. The data is anonymized. The only "identifying" information there is is a checkout ID row. There were more columns in the original dataset; however, just downloading the checkout records from 2020-2025 with 3 less columns already was taking up ~5 GB of the 10 GB database limit on SQL Server Management Studio (I have Express edition).

### 1. Checking Duplicates

### 2. Checking for Null Values

### 3. Checking Cardinality

### 4. Checking Size of Columns

### 5. Checking for Whitespace
