--1. How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS total_customers_unique
FROM foodie_fi.plans as p
INNER JOIN foodie_fi.subscriptions AS s ON s.plan_id = p.plan_id;

--2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT 
  TO_CHAR(s.start_date, 'Month') AS month,
  s.plan_id
FROM foodie_fi.plans as p
INNER JOIN foodie_fi.subscriptions AS s ON s.plan_id = p.plan_id
WHERE s.plan_id = 0
GROUP BY month, s.plan_id;

--3.What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT
	s.plan_id,
	plan_name,
    COUNT(*)
FROM foodie_fi.subscriptions as s
INNER JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
WHERE DATE(start_date) > DATE '2020-12-31'
GROUP BY s.plan_id, plan_name
ORDER BY plan_id ASC;

--4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT
	COUNT(DISTINCT s.customer_id) AS Customer_count,
	ROUND (100 * COUNT(s.customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions), 1) AS Churn_percentage
FROM foodie_fi.subscriptions as s
INNER JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
WHERE p.plan_id = 4;

--5.How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH customers_plans_cte AS (
  SELECT 
  	s.customer_id,
  	p.plan_name,
  	LEAD(p.plan_name) OVER (
      PARTITION BY s.customer_id
	  ORDER BY s.start_date) as next_plan
 FROM foodie_fi.subscriptions AS s
  INNER JOIN foodie_fi.plans AS p ON s.plan_id = p.plan_id
)

SELECT 
	COUNT(customer_id) as churned_customers_count,
	ROUND((100.0 * COUNT(customer_id)) / (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions), 0) AS percentage_of_churn
FROM customers_plans_cte
WHERE plan_name = 'trial' AND next_plan = 'churn';

--6. What is the number and percentage of customer plans after their initial free trial?
WITH customer_plans AS (
  SELECT 
    customer_id, 
    plan_id, 
    LEAD(plan_id) OVER(
      PARTITION BY customer_id 
      ORDER BY plan_id) as customer_plans_ids
  FROM foodie_fi.subscriptions
)

SELECT 
  customer_plans_ids AS plan_id, 
  COUNT(customer_id) AS converted_customers,
  ROUND(100 * 
    COUNT(customer_id)::NUMERIC 
    / (SELECT COUNT(DISTINCT customer_id) 
      FROM foodie_fi.subscriptions)
  ,1) AS conversion_percentage
FROM customer_plans
WHERE customer_plans_ids IS NOT NULL 
  AND plan_id = 0
GROUP BY customer_plans_ids
ORDER BY customer_plans_ids;

--7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH upcoming_dates AS (
  SELECT
    customer_id,
    plan_id,
  	start_date,
    LEAD(start_date) OVER (
      PARTITION BY customer_id
      ORDER BY start_date
    ) AS upcoming_date
  FROM foodie_fi.subscriptions
  WHERE start_date <= '2020-12-31'
)

SELECT
	plan_id, 
	COUNT(DISTINCT customer_id) AS customer_count,
  ROUND(100.0 * 
    COUNT(DISTINCT customer_id)
    / (SELECT COUNT(DISTINCT customer_id) 
      FROM foodie_fi.subscriptions)
  ,1) AS customer_percentage
FROM upcoming_dates
WHERE upcoming_date IS NULL
GROUP BY plan_id;

--8. How many customers have upgraded to an annual plan in 2020?
SELECT COUNT(DISTINCT customer_id) as upgraded_customers_count
FROM foodie_fi.subscriptions
WHERE plan_id = 3 
	AND start_date <= '2020-12-31'


--9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH trial_plan_customers_cte AS (
  SELECT 
    customer_id,
    start_date AS trial_date
    FROM foodie_fi.subscriptions
    WHERE plan_id = 0
), annual_plan_customers_cte AS (
    SELECT 
    customer_id, 
    start_date AS annual_date
  FROM foodie_fi.subscriptions
  WHERE plan_id = 3
)
SELECT
  ROUND (
    AVG(annual_plan_customers_cte.annual_date - trial_plan_customers_cte.trial_date)
  ,0) AS avg_upgrade_days
FROM trial_plan_customers_cte
JOIN annual_plan_customers_cte ON trial_plan_customers_cte.customer_id = annual_plan_customers_cte.customer_id;


