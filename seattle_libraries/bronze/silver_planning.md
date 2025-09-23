# Preparing for Silver Layer

This document tracks the changes I plan to make to ensure the data loaded in the bronze tables are cleaned and standardized when loading it in the silver layer tables. This will involve checking NULLs, duplicates, whitespaces, etc. The sections will be divided by table.

## Data Dictionary Table

Considering this table is meant to lookup the description for the differnt codes used in the other tables, I would expect every row to be unique.

### 1. Checking Duplicates
```
SELECT
FROM bronze.dictionary
GROUP BY 
```
### 2. Checking for Null Values

### 3. Checking Cardinality
