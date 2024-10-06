
-- Data cleaning



SELECT *
FROM world_layoffs.layoffs;

CREATE TABLE layoffs_cleaning
LIKE world_layoffs.layoffs;

SELECT *
FROM world_layoffs.layoffs_cleaning;

INSERT world_layoffs.layoffs_cleaning
SELECT *
FROM world_layoffs.layoffs;



-- Remove duplicates

CREATE TABLE `layoffs_cleaning2` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM world_layoffs.layoffs_cleaning2;

INSERT INTO layoffs_cleaning2
SELECT * , ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,
								`date`, stage, country, funds_raised_millions) AS row_num
FROM lworld_layoffs.layoffs_cleaning;

SELECT *
FROM world_layoffs.layoffs_cleaning2
WHERE row_num > 1;

DELETE
FROM world_layoffs.layoffs_cleaning2
WHERE row_num > 1;


-- Standardizing data

UPDATE world_layoffs.layoffs_cleaning2
SET company=TRIM(company), location = TRIM(location), industry=TRIM(industry), total_laid_off=TRIM(total_laid_off),
    percentage_laid_off=TRIM(percentage_laid_off), `date`=TRIM(`date`), stage=TRIM(stage), country=TRIM(country),
    funds_raised_millions=TRIM(funds_raised_millions);
    
SELECT *
FROM world_layoffs.layoffs_cleaning2;

SELECT DISTINCT industry
FROM world_layoffs.layoffs_cleaning2
ORDER BY 1;

UPDATE world_layoffs.layoffs_cleaning2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry 
FROM world_layoffs.layoffs_cleaning2
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country
FROM world_layoffs.layoffs_cleaning2
WHERE country LIKE 'United States%';

UPDATE world_layoffs.layoffs_cleaning2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


SELECT `date`
FROM world_layoffs.layoffs_cleaning2;

UPDATE world_layoffs.layoffs_cleaning2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE world_layoffs.layoffs_cleaning2
MODIFY COLUMN `date` DATE;

SELECT DISTINCT stage
FROM world_layoffs.layoffs_cleaning2
ORDER BY 1;


-- Work with null and blank values

SELECT *
FROM world_layoffs.layoffs_cleaning2
WHERE industry IS NULL OR industry ='';

UPDATE world_layoffs.layoffs_cleaning2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM world_layoffs.layoffs_cleaning2 c1
JOIN world_layoffs.layoffs_cleaning2 c2
ON c1.company = c2.company
WHERE c1.industry IS NULL AND c2.industry IS NOT NULL;

UPDATE world_layoffs.layoffs_cleaning2 c1
JOIN world_layoffs.layoffs_cleaning2 c2
	ON c1.company = c2.company
SET c1.industry = c2.industry
WHERE c1.industry IS NULL AND c2.industry IS NOT NULL;


-- Remove not needed columns and rows

SELECT *, ROW_NUMBER() OVER()
FROM world_layoffs.layoffs_cleaning2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE
FROM world_layoffs.layoffs_cleaning2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

ALTER TABLE world_layoffs.layoffs_cleaning2
DROP COLUMN row_num;

SELECT *
FROM world_layoffs.layoffs_cleaning2;
