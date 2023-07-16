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

