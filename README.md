Dataset is taken from [Alex the Analyst](https://github.com/AlexTheAnalyst/MySQL-YouTube-Series/blob/main/layoffs.csv).
Following steps were taken to clean and explore data
  - Copy dataset
  - Check duplicates
  - Remove duplicates
  - Check nulls
  - Remove/ Replace Null
  - Explore datasets to analyse data
Data Cleaning Code
``` sql
USE layoff;

SELECT * FROM layoffs;

-- Data cleaning
	-- make a duplicate so, the original file stays intact
    -- Remove duplicates
    -- standerdize data
    -- handle null or blank values
    -- Remove unnecassery columns
    
-- create duplicate table
CREATE TABLE layoffs_staging LIKE layoffs;

-- Copy data from layoffs table
INSERT layoffs_staging
SELECT * FROM layoffs;

SELECT * FROM layoffs_staging;


-- Check Duplicates
WITH duplicate_cte
AS 
(
	SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY company, location, industry,  total_laid_off, percentage_laid_off, `date`, stage,
    country, funds_raised_millions) AS row_num
    FROM layoffs_staging
)
SELECT * FROM duplicate_cte
WHERE row_num > 1;


-- Remove duplicates
DELETE
FROM
    layoffs_staging2
WHERE
    row_num > 1;

-- Check the results
SELECT 
    *
FROM
    layoffs_staging2;

```
Standerdize data
``` sql
-- Standerdizing Data

SELECT company, TRIM(company)
FROM 
layoffs_staging2;


-- Update table with standard values
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Industry field cleaning
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    industry LIKE 'Crypto%';
-- Updating table
UPDATE layoffs_staging2 
SET 
    industry = 'Crypto'
WHERE
    industry LIKE 'Crypto%';
    
    
-- Country cleaning
SELECT DISTINCT
    country
FROM
    layoffs_staging2
WHERE
    country LIKE 'United States%';
    
-- Update 
UPDATE layoffs_staging2 
SET 
    country = TRIM(TRAILING '.' FROM country)
WHERE
    country LIKE 'United States%';
    
-- Convert Text Date into DATETIME Format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- View Updated data
SELECT 
    `date`
FROM
    layoffs_staging2;
-- Now change column type
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
    
-- Modify null values by 1st checking null or blank values in industry column
SELECT 
    *
FROM
    layoffs_staging2 t1
        JOIN
    layoffs_staging2 t2 ON t1.company = t2.company
WHERE
    (t1.industry IS NULL OR t1.industry = '')
        AND t2.industry IS NOT NULL;
        
-- Now populate our null or blank values from our table 
-- 1st set blank with null values
UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';

-- now populate our missing data
UPDATE layoffs_staging2 t1
JOIN
    layoffs_staging2 t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE
    t1.industry IS NULL
        AND t2.industry IS NOT NULL;
        

-- Remaining Nulls and blanks
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL;
        
        
-- Delete data that is null in total_laid_off & percentage_laid_off
DELETE
FROM
    layoffs_staging2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL;
        
-- Now check the clean data
SELECT 
    *
FROM
    layoffs_staging2;
    

 -- Drop column row_num
 ALTER TABLE layoffs_staging2
 DROP COLUMN row_num;
```

Explore Data

``` sql
-- Exploratory Data Analysis
-- Here we are jsut going to explore the data and find trends or patterns or anything interesting like outliers

SELECT 
    *
FROM
    layoffs_staging2;
    
-- Total laid of by Each company
SELECT 
    company, SUM(total_laid_off) AS total_laid_off,
    COUNT(total_laid_off) AS total_times_laid_off,
    MIN(YEAR(`date`)) AS first_layoff,
    MAX(YEAR(`date`)) AS last_layoff
FROM
    layoffs_staging2
GROUP BY company
ORDER BY 3 DESC;


-- this it total in the past 3 years or in the dataset
SELECT YEAR(date), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 ASC;


-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year. It's a little more difficult.
-- I want to look at 

WITH Company_Year AS 
(
  SELECT company, YEAR(`date`) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(`date`)
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



-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;

-- now use it in a CTE so we can query off of it
WITH DATE_CTE AS 
(
SELECT company, SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY dates, company
ORDER BY dates ASC
)
SELECT dates, company, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;
```
