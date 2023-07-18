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

--4. What is the total sales for each region for each month?
SELECT 
  month_number, 
  region, 
  SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY month_number, region
ORDER BY month_number, region;

--5. What is the total count of transactions for each platform
SELECT platform,
      SUM(transactions) total_transactions
FROM clean_weekly_sales
GROUP BY platform;

--6. What is the percentage of sales for Retail vs Shopify for each month?
SELECT
  calendar_year,
  month_number,
  ROUND(100 * MAX(CASE WHEN platform = 'Retail' THEN sales ELSE 0 END) / SUM(sales), 2) AS retail_percentage,
  ROUND(100 * MAX(CASE WHEN platform = 'Shopify' THEN sales ELSE 0 END) / SUM(sales), 2) AS shopify_percentage
FROM clean_weekly_sales
GROUP BY calendar_year, month_number
ORDER BY calendar_year, month_number;

--7. What is the percentage of sales by demographic for each year in the dataset?
SELECT
    calendar_year,
    ROUND(100 * MAX(CASE WHEN demographic = 'Families' THEN yearly_sales ELSE NULL END) / SUM(yearly_sales), 2) AS families_percentage,
    ROUND(100 * MAX(CASE WHEN demographic = 'Couples' THEN yearly_sales ELSE NULL END) / SUM(yearly_sales), 2) AS couples_percentage,
    ROUND(100 * MAX(CASE WHEN demographic = 'Unknown' THEN yearly_sales ELSE NULL END) / SUM(yearly_sales), 2) AS unknown_percentage
FROM (
    SELECT calendar_year, demographic, SUM(sales) AS yearly_sales
    FROM clean_weekly_sales
    GROUP BY calendar_year, demographic
) AS demographic_sales
GROUP BY calendar_year;
