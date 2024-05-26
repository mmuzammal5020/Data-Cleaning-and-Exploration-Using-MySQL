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
