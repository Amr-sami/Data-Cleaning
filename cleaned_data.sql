-- Create the layoffs_staging table like layoffs, ensuring it's empty
DROP TABLE IF EXISTS layoffs_staging;
CREATE TABLE layoffs_staging LIKE layoffs;

-- Insert data from layoffs to layoffs_staging
INSERT INTO layoffs_staging
SELECT * 
FROM layoffs;

-- Check for duplicates and create layoffs_staging2
DROP TABLE IF EXISTS layoffs_staging2;
CREATE TABLE layoffs_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT,
    row_num INT
);

-- Insert cleaned data into layoffs_staging2
INSERT INTO layoffs_staging2
SELECT 
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    row_num
FROM (
    SELECT 
        company,
        location,
        industry,
        total_laid_off,
        percentage_laid_off,
        `date`,
        stage,
        country,
        funds_raised_millions,
        ROW_NUMBER() OVER (
            PARTITION BY 
                company, 
                location, 
                industry, 
                total_laid_off, 
                percentage_laid_off, 
                `date`, 
                stage, 
                country, 
                funds_raised_millions
            ORDER BY 
                company -- Specify an ORDER BY clause to ensure deterministic row numbering
        ) AS row_num
    FROM layoffs_staging
) AS RankedLayoffs
WHERE row_num = 1; -- Keep only the first occurrence of each duplicate group

-- Verify the cleaned data
SELECT * 
FROM layoffs_staging2
WHERE row_num = 1;

-- Trim leading and trailing spaces from company names
SELECT company , TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Display distinct industry values
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- Standardize 'Crypto' industries to 'Crypto Currency'
UPDATE layoffs_staging2
SET industry =
    CASE 
        WHEN industry LIKE 'Crypto%' THEN 'Crypto Currency'
        ELSE industry
    END;

-- Verify standardization for 'Crypto' industries
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- Display distinct country values
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- Standardize 'United States' country names
UPDATE layoffs_staging2
SET country =
    CASE 
        WHEN country LIKE 'United States%' THEN 'United States'
        ELSE country
    END;

-- Display all columns from layoffs_staging2
SELECT * 
FROM layoffs_staging2;

-- Convert 'date' column from string to date format
SELECT `date` , STR_TO_DATE(`date`,'%m/%d/%y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Alter 'date' column to DATE type
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Identify and handle rows with null or empty industry values
SELECT * 
FROM layoffs_staging2 
WHERE industry IS NULL OR industry = '';

UPDATE layoffs_staging2 
SET industry = NULL 
WHERE industry = '';

-- Verify null or empty industry handling
SELECT * 
FROM layoffs_staging2 
WHERE industry IS NULL OR industry = '';

-- Update industry for specific company patterns ('airbnb%' as example)
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'airbnb%';

-- Update industry for companies with null industry based on non-null values
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Identify and handle rows with null total_laid_off or percentage_laid_off values
SELECT * 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Delete rows with null total_laid_off and percentage_laid_off values
DELETE FROM layoffs_staging2 
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Verify deletion of rows with null total_laid_off and percentage_laid_off values
SELECT * 
FROM layoffs_staging2 
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Remove the row_num column from layoffs_staging2
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Display all columns from layoffs_staging2
SELECT *
FROM layoffs_staging2;
