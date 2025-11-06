-- Data Cleaning 

SELECT *
FROM layoffs;

-- 1. REMOVE DUPLICATES: 
-- 2. STANDARDIZE THE DATA: This means if there are issues with the data with spellings and so forth, you want to standardize it so its the same as it should be 
-- 3. NULL VALUES OR BLANK VALUES: 
-- 4. REMOVE ANY COLOMNS 


CREATE TABLE layoffs_staging -- We are creating this table and copying all the data from the layoffs table to it 
LIKE layoffs; 

SELECT *
from layoffs_staging;

insert layoffs_staging
select * 
from layoffs; -- now we have copied everything from the raw data (layoffs) to the duplicate data (layoffs_staging). now we do this because if we make a mistake we can always have the original data to go back to 

-- Now we are focusing on removing the duplicates from the layoffs_staging table

select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) as row_num
from layoffs_staging; -- if you run this and look at the table again, you'll see row_num column 

-- we are creating a CTE to partition over everything and print out the duplicates 

with duplicate_cte as 
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, date, 
stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1 ;  -- after running this we can see that any row_num that 2 and above is a duplicate

select *
from layoffs_staging
where company = 'yahoo'; -- we can confirm that they are duplicates by running this to check

-- we are trying to delete the duplicates and because this a cte we cant just delete it. here's why, below we are trying to delete the duplicates whic are the ones that are greater than one:
with duplicate_cte as 
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, date, 
stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
delete 
from duplicate_cte
where row_num > 1 -- it brings an errorthat's because you cannot update a CTE (deleting is updating)
;

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

select *
from layoffs_staging2;

insert into layoffs_staging2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, date, 
stage, country, funds_raised_millions) as row_num
from layoffs_staging;

delete
from layoffs_staging2
WHERE row_num > 1 ;

-- select *
-- from layoffs_staging2
-- where row_num > 1 ;

select *
from layoffs_staging2;


-- STANDADRDIZING DATA: it's finding issues in your data and fixing it 

-- we can already notice at the front that the first company (E Inc) has a space at the front 

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

-- now we are going to take a look at the industry. there are some noticable issues there 
-- we can see an empty column and we can also see a null column 
-- crpto, crypto currency and cryptocurrency which are all the same industry but are appearing 3 times 
select distinct industry
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where industry like 'Crypto%';-- now we want to set all the crypto currency industry to one thing CRYPTO

update layoffs_staging2
set industry = 'Crypto'
where industry like 'crypto%';

-- we have checked location and everything seems to be alright but in country, The united states seems to pop up multiple times so we'll fix that 

select distinct country
from layoffs_staging2
where country like 'United S%';

-- to target the the United state witht the ., we use something called Trailing
-- then we remove the united states with the '.' 

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

select `date`, 
str_to_date(`date`, '%m/%d/%Y') as DATE
from layoffs_staging2;

update layoffs_staging2
set date = str_to_date(`date`, '%m/%d/%Y');

select `date`
from layoffs_staging2;

-- now if we go to the right side and check this table for the date we will see that it is says that the date column is still in text format, we will change that below 

alter table layoffs_staging2
modify column `date` date;

select *
from layoffs_staging2;


-- NULL VALUES OR BLANK VALUES

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

update layoffs_staging2
set industry = null
where industry = '';

-- now remember that there were some null or empty values in the industry column  
select *
from layoffs_staging2 
where industry is null
or industry = '';


-- so what we are trying to do here is to fill in those blank spaces

select * 
from layoffs_staging2
where company like 'Bally%';

-- we are going to try to create a join here 
select t1.industry, t2.industry
from layoffs_staging2 as t1 -- what we are going to do is run a check, in this table we have one that is blank and we have the other that isn't blank, if so, we are going to update it with the non blank one 
join layoffs_staging2 as t2
	on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;


-- REMOVE COLOMNS 

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- we are going to go ahead and delete the roles because its not needed in the table 

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- now we have to remove the row_num column from the table since we have no more use of it anymore 

alter table layoffs_staging2
drop column row_num