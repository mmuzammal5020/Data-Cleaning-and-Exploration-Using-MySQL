-- created a new table to remove duplicates

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
;

SELECT * FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY company, location, industry,  total_laid_off, percentage_laid_off, `date`, stage,
    country, funds_raised_millions) AS row_num
    FROM layoffs_staging;
    
    
    
