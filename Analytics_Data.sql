-- Query to fetch all rows from the layoffs_staging2 table
select * 
from layoffs_staging2;

-- Query to retrieve companies, dates, and total layoffs grouped by date, total layoffs, and company, sorted by date.
select company, `date`, total_laid_off
from layoffs_staging2
group by `date`, total_laid_off, company
order by `date`;

-- Query to find the maximum and minimum percentage of layoffs recorded.
-- This helps understand the range of percentage layoffs across companies.
SELECT MAX(percentage_laid_off), MIN(percentage_laid_off)
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL;

-- Query to identify companies where 100% layoffs occurred.
-- These companies potentially shut down completely during the recorded period.
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

-- Query to list companies with 100% layoffs, ordered by funds raised in descending order.
select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions DESC;

-- Query to find companies with the highest total layoffs, ordered by the total number of layoffs in descending order.
SELECT company, total_laid_off
FROM layoffs_staging2
ORDER BY total_laid_off DESC;

-- Query to list companies with the most cumulative layoffs, grouped by company and ordered by total layoffs in descending order.
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by sum(total_laid_off) DESC;

-- Query to sum up total layoffs by location, ordered by total layoffs in descending order.
select location, sum(total_laid_off)
from layoffs_staging2
group by location
order by sum(total_laid_off) DESC;

-- Query to sum up total layoffs by year, ordered by year in descending order.
select Year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by year(`date`) DESC;

-- Query to sum up total layoffs by month, ordered by total layoffs in descending order.
select month(`date`), sum(total_laid_off)
from layoffs_staging2
group by month(`date`)
order by sum(total_laid_off) DESC;

-- Query to sum up total layoffs by country, ordered by total layoffs in descending order.
SELECT country, sum(total_laid_off)
from layoffs_staging2
group by country
ORDER BY sum(total_laid_off) DESC;

-- Query to sum up total layoffs by industry, ordered by total layoffs in ascending order.
SELECT industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by sum(total_laid_off);

-- Query to sum up total layoffs by funding stage, ordered by total layoffs in descending order.
select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by sum(total_laid_off) DESC;

-- Query to rank companies based on their highest layoffs in each year, showing the top 3 companies per year.
WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;

-- Query to sum up total layoffs by year-month (YYYY-MM), ordered by date in ascending order.
select substring(date,1,7) as dates, sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by dates
order by dates ASC;

-- Query using a CTE to calculate rolling total layoffs over time, ordered by date in ascending order.
WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;

-- Query to identify companies with the highest percentage of layoffs, ordered by percentage in descending order.
SELECT company, percentage_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL
ORDER BY percentage_laid_off DESC;

-- Query to analyze distribution of layoffs by industry and year, ordered by industry and year.
SELECT industry, YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE industry IS NOT NULL AND `date` IS NOT NULL
GROUP BY industry, YEAR(`date`)
ORDER BY industry, YEAR(`date`);

-- Query to analyze geographical distribution of layoffs over time, ordered by year and total layoffs in descending order.
SELECT location, YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE location IS NOT NULL AND `date` IS NOT NULL
GROUP BY location, YEAR(`date`)
ORDER BY year, SUM(total_laid_off) DESC;

-- Query to analyze layoffs by funding stage, ordered by total layoffs in descending order.
SELECT stage, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE stage IS NOT NULL
GROUP BY stage
ORDER BY total_laid_off DESC;

-- Query to analyze trend of layoffs over rolling quarters, showing cumulative total layoffs.
WITH QuarterlyTrend AS (
    SELECT DATE_FORMAT(`date`, '%Y-Q%q') AS quarter, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY quarter
    ORDER BY quarter
)
SELECT quarter, total_laid_off, 
       SUM(total_laid_off) OVER (ORDER BY quarter) AS cumulative_total_laid_off
FROM QuarterlyTrend;


-- Query to analyze layoffs by day of the week, ordered by day of the week.
SELECT DAYNAME(`date`) AS day_of_week, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

-- Query to find companies that have experienced layoffs across multiple years, showing the number of years affected.
SELECT company, COUNT(DISTINCT YEAR(`date`)) AS years_affected, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company
HAVING years_affected > 1
ORDER BY years_affected DESC;

-- Query to analyze layoffs by funding raised in millions, grouped into ranges.
SELECT
    CASE
        WHEN funds_raised_millions < 10 THEN 'Less than 10'
        WHEN funds_raised_millions >= 10 AND funds_raised_millions < 50 THEN '10 - 50'
        WHEN funds_raised_millions >= 50 AND funds_raised_millions < 100 THEN '50 - 100'
        ELSE 'More than 100'
    END AS funds_raised_range,
    COUNT(*) AS num_companies,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE funds_raised_millions IS NOT NULL
GROUP BY funds_raised_range
ORDER BY MIN(funds_raised_millions);