-- DATA CLEANING

-- 1. Remove Duplicates
-- 2. Standardize The Data
-- 3. Deal With The NULL Values And Blanks
-- 4. Remove Any Unnecessary Coloumns or rows

# Do not apply the changes onto the raw data. It's not best practice.

CREATE TABLE layoffs_staging
LIKE layoffs_raw;

SELECT *
FROM layoffs_staging;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs_raw;

-- 1. Remove Duplicates

WITH duplicate_CTE AS 
(
SELECT *,
ROW_NUMBER() OVER( PARTITION BY company,
location, industry,
total_laid_off,
percentage_laid_off,
`date`,
stage,
country,
funds_raised_millions ) AS dup_finder
FROM layoffs_staging
)
SELECT *
FROM duplicate_CTE
	WHERE dup_finder > 1 ;

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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER( PARTITION BY company,
location, industry,
total_laid_off,
percentage_laid_off,
`date`,
stage,
country,
funds_raised_millions ) AS dup_finder
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
	WHERE row_num > 1;

-- 2. Standardize The Data

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging2
	ORDER BY 1;
    
SELECT industry
FROM layoffs_staging2
	WHERE industry LIKE '%Crypto%';
    
UPDATE layoffs_staging2
SET industry = 'Crypto'
	WHERE industry LIKE '%Crpto%';
    
SELECT *
FROM layoffs_staging2;

SELECT DISTINCT location
FROM layoffs_staging2
	ORDER BY 1;
    

SELECT *
FROM layoffs_staging2 
	WHERE location = 'MalmÃ¶';
    
UPDATE layoffs_staging2
SET location = 'Malmo'
	WHERE location = 'MalmÃ¶';
    
SELECT DISTINCT country
FROM layoffs_staging2
	ORDER BY 1;
    
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
    ORDER BY 1;
    
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
	WHERE country LIKE 'United States%';
    
SELECT `date`
FROM layoffs_staging2;
    
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date` , '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; 

-- 3. Deal With The NULL Values And Blanks

SELECT *
FROM layoffs_staging2
	WHERE industry IS NULL OR industry = '';
    
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND (t2.industry IS NOT NULL AND t2.industry != '');
    
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
	WHERE (t1.industry IS NULL OR t1.industry = '')
	AND (t2.industry IS NOT NULL AND t2.industry != '');

-- 4. Remove Any Unnecessary Coloumns or rows

SELECT *
FROM layoffs_staging2
	WHERE (percentage_laid_off IS NULL) 
    AND (total_laid_off IS NULL);

DELETE 
FROM layoffs_staging2
	WHERE (percentage_laid_off IS NULL) 
    AND (total_laid_off IS NULL);

SELECT *
FROM layoffs_staging2
	WHERE (percentage_laid_off = '') 
    AND (total_laid_off = '');

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

# DONE.