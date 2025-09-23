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

### 3. Checking Cardinality

### 4. Checking Size of Columns
