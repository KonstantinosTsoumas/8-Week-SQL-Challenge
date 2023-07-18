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

--8. Which age_band and demographic values contribute the most to Retail sales?
SELECT 
  age_band, 
  demographic, 
  SUM(sales) AS retail_sales,
  ROUND(SUM(sales) * 100.0 / SUM(SUM(sales)) OVER (), 1) AS sales_percentage
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY retail_sales DESC;

--9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT 
  calendar_year, 
  platform, 
  ROUND(AVG(avg_transaction),0) AS avg_transaction_row, 
  SUM(sales) / sum(transactions) AS avg_transaction_group
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;

-- So the difference in this is that the first (avg_transaction_row) computes only the average transaction size by diving 
-- the sales per row with the number of transactions in that specific column alone. Whereas, the other one, (avg_transaction_group) calculates
-- the average transaction size by dividing the total sales for the WHOLE dataset by the total number of transactions in the dataset.
-- This is quite different, indeed.