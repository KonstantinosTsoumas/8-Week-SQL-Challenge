--1. What day of the week is used for each week_date value?
SELECT DISTINCT(TO_CHAR(week_date, 'day')) AS week_day 
FROM clean_weekly_sales;

--2. What range of week numbers are missing from the dataset?
WITH week_number_cte AS (
  SELECT GENERATE_SERIES(1, 52) AS week_number
),
existing_weeks AS (
  SELECT week_number
  FROM clean_weekly_sales
)
SELECT week_number
FROM week_number_cte
EXCEPT
SELECT week_number
FROM existing_weeks;

--3. How many total transactions were there for each year in the dataset?
SELECT calendar_year,
      SUM(transactions)
FROM clean_weekly_sales
GROUP BY calendar_year;