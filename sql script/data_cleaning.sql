USE freelancers;

SELECT * FROM global_freelancers;


-- Check for duplicates and null in primary key
WITH CTE AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY freelancer_ID ORDER BY freelancer_ID) AS occurence
FROM global_freelancers)
SELECT * FROM CTE
WHERE freelancer_ID IS NULL OR occurence > 1;

-- Check for white space in name column
SELECT name 
FROM global_freelancers
WHERE name != TRIM(name);

-- Standardizing Gender column

SELECT DISTINCT
gender 
FROM global_freelancers;

UPDATE global_freelancers
SET 
gender =
	CASE
		WHEN gender IN ('f', 'FEMALE') THEN 'Female'
		WHEN gender IN ('m', 'male') THEN 'Male'
		ELSE gender
	END
WHERE gender IN ('f', 'FEMALE', 'm', 'male');

-- Change age datatype 
ALTER TABLE global_freelancers
ALTER COLUMN age INT;


-- Fill NULL age with average age
UPDATE global_freelancers
SET 
age = (
	SELECT AVG(age) 
	FROM global_freelancers)
WHERE age IS NULL;


-- Check for white space in country, language, primary_skill column
SELECT country, language, primary_skill
FROM global_freelancers
WHERE country != TRIM(country) OR language != TRIM(language) OR primary_skill != TRIM(primary_skill);

-- Change years_of_experience datatype
ALTER TABLE global_freelancers
ALTER COLUMN years_of_experience INT;


-- Fill NULL years_of_experience base on median years_of_experience of each primary_skill
WITH grp_med AS (
	SELECT DISTINCT
	primary_skill,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY years_of_experience)
	OVER (PARTITION BY primary_skill) AS median
	FROM global_freelancers
	WHERE years_of_experience IS NOT NULL
)
UPDATE gf
SET gf.years_of_experience = gm.median
FROM global_freelancers gf
JOIN grp_med gm
ON gf.primary_skill = gm.primary_skill
WHERE gf.years_of_experience IS NULL;

-- Removed USD and $ from hourly_rate_USD
UPDATE global_freelancers
SET
hourly_rate_USD = 
	TRIM(
		REPLACE(REPLACE(hourly_rate_USD, 'USD', ''), '$', '')
	);


-- Changed hourly_rate_USD data type
ALTER TABLE global_freelancers
ALTER COLUMN hourly_rate_USD DECIMAL(10, 2)

GO

-- Filled missing value with the average hourly_rate_USD
UPDATE global_freelancers
SET
hourly_rate_USD = (
		SELECT AVG(hourly_rate_USD)
		FROM global_freelancers
		)
WHERE hourly_rate_USD IS NULL;

-- Filled missing rating with 0
UPDATE global_freelancers
SET
rating = 0
WHERE rating IS NULL;


-- Set rating to 2 decimal places
UPDATE global_freelancers
SET
rating = ROUND(rating, 2);

-- Remove the % in client_satisfaction
UPDATE global_freelancers
SET
client_satisfaction = REPLACE(client_satisfaction, '%', '');


-- Fill NULL client_satisfaction with 0
UPDATE global_freelancers
SET
client_satisfaction = 0
WHERE client_satisfaction IS NULL;


-- Change client_satisfaction data type
ALTER TABLE global_freelancers
ALTER COLUMN client_satisfaction INT;


-- Create experience_level column
ALTER TABLE global_freelancers
ADD experience_level VARCHAR(20);

UPDATE global_freelancers
SET
experience_level = CASE
	WHEN years_of_experience <=2 THEN 'Entry level'
	WHEN years_of_experience <=5 THEN 'Mid level'
	WHEN years_of_experience <=8 THEN 'Senior level'
	ELSE 'Executive level'
END;

SELECT * FROM global_freelancers;