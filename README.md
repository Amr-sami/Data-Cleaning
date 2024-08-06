# Data Cleaning and Transformation Process for layoffs_staging2 Table
This section describes the SQL script used to clean and transform data in the layoffs_staging2 table. The script performs several tasks including table creation, data insertion, duplicate removal, data standardization, and final cleanup.


The script begins by dropping the layoffs_staging table if it exists and then recreates it using the same structure as the layoffs table to ensure it is empty and ready for data insertion.
## Insert Data into layoffs_staging:

All data from the layoffs table is copied into the layoffs_staging table.
## Create the layoffs_staging2 Table:

The script drops the layoffs_staging2 table if it exists and creates a new one with specified columns, including an additional row_num column used for managing duplicates.
## Insert Cleaned Data into layoffs_staging2:

Data is inserted into layoffs_staging2 after removing duplicates. Duplicates are identified by partitioning the data on several key columns and retaining only the first occurrence within each group.
##Verify the Cleaned Data:

A query is executed to verify that the duplicate removal process was successful by checking the contents of layoffs_staging2.
## Standardize Company Names:

The script trims whitespace from the company names to ensure consistency.
## Standardize Industry Names:

Industry names starting with 'Crypto' are updated to 'Crypto Currency' to maintain uniformity.
The script verifies that the update was applied correctly.
## Standardize Country Names:

Country names starting with 'United States' are updated to 'United States' for consistency.
The script verifies the updated country names.
## Convert Date Format:

Dates in the date column are converted from text to MySQL's DATE format for better data handling.
The column is altered to be of type DATE.
## Handle Null or Empty Industry Values:

Industry values that are empty strings are set to NULL to standardize the data.
## Populate Null Industry Values:
For rows with a null industry, the script updates them with the industry from another row with the same company name where the industry is not null. This ensures that all rows have an industry value if possible.
## Remove Irrelevant Data:
Rows where both total_laid_off and percentage_laid_off are null are deleted as they provide no useful information.
## Final Cleanup:
The row_num column, used for duplicate management, is dropped from the layoffs_staging2 table as it is no longer needed.
This script ensures that the data in the layoffs_staging2 table is cleaned, standardized, and ready for further analysis or reporting.
