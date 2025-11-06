SQL Data Cleaning Project - Layoffs Dataset

Overview of Project
* The following project serves to clean and standardize a dataset containing information about company layoffs.
* The main goal was the preparation of data for analysis through the elimination of duplicates, correction of inconsistencies, handling of missing values, and cleaning of data formatting.

Tools & Skills Used
* SQL (MySQL)
* Common Table Expressions (CTEs)
* Window Functions (ROW_NUMBER)
* Data Standardization
* Null and Empty Value Handling
* Data Type Conversion
* Schema Modification


Steps Performed
1 Created a Staging Table:
  Duplicated the raw data for safe cleaning: layoffs_staging

2 Removed Duplicates:
  Used ROW_NUMBER() to locate and remove duplicate rows.

3 Standardized Text Data
  Trimmed whitespace with TRIM().
  Harmonized the incoherent spellings in industry and country.

4 Converted Data Types
  Changed date column from text to proper SQL DATE format.

5 Handled Null and Blank Values
  Replaced empty strings with NULL.
  Used JOIN logic to fill in missing industry values when possible.

6 Irrelevant Records & Columns Removed
  Deleted rows that do not have any layoff information.
  Dropped helper columns like row_num.


Final Result 
A clean and standardized dataset ready for analysis or visualization, called layoffs_staging2:
