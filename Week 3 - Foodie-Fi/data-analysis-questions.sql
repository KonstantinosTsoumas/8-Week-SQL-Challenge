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

