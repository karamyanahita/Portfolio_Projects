-- EXPLORATORY DATA ANALYSIS

SELECT * 
FROM layoffs_staging2;

SELECT company, total_laid_off, percentage_laid_off
FROM layoffs_staging2
	WHERE total_laid_off = 
    (SELECT MAX(total_laid_off)
    FROM layoffs_staging2);
    
    
SELECT company, total_laid_off, percentage_laid_off
FROM layoffs_staging2
	WHERE percentage_laid_off = 1;
    
SELECT company, total_laid_off, percentage_laid_off, funds_raised_millions
FROM layoffs_staging2
	WHERE percentage_laid_off = 1
    ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
	ORDER BY 2 DESC;
    
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
	ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
	ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off), SUM(funds_raised_millions)
FROM layoffs_staging2
GROUP BY country
	ORDER BY 3 DESC;
    
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
	ORDER BY 1 ;
    
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging2
	WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
    ORDER BY 1 ASC;

WITH rolling_total_tab AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
	WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
    ORDER BY 1 ASC
    )
SELECT `month`, total_laid_off,
SUM(total_laid_off) OVER(ORDER BY `month`) AS rolling_total
	FROM rolling_total_tab;
    
SELECT company, YEAR(`date`) AS  `year`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, `year`
	ORDER BY total_laid_off DESC;
    
WITH company_year AS
(
SELECT company, YEAR(`date`) AS  `year`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, `year`
), company_rank_by_year AS
(
SELECT *, 
DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_laid_off DESC) AS rank_by_year
FROM company_year
	WHERE `year` IS NOT NULL
    ORDER BY rank_by_year ASC
)
SELECT *
FROM company_rank_by_year
	WHERE rank_by_year <= 5;














