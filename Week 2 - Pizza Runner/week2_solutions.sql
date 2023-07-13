-- Clean the data for customer_orders table
DROP TABLE IF EXISTS customer_orders_cleaned;
CREATE TABLE customer_orders_cleaned AS
SELECT 
  order_id, 
  customer_id, 
  pizza_id, 
  CASE
	  WHEN exclusions IS null OR exclusions LIKE 'null' THEN ' '
      WHEN exclusions = 'NaN' THEN ' '
	  ELSE exclusions
	  END AS exclusions,
  CASE
	  WHEN extras IS NULL or extras LIKE 'null' THEN ' '
      WHEN extras = 'NaN' THEN ' '
	  ELSE extras
	  END AS extras,
	order_time
FROM pizza_runner.customer_orders;

-- Clean the data for the runner orders table
DROP TABLE IF EXISTS runner_orders_cleaned;
CREATE TABLE runner_orders_cleaned AS
SELECT 
  order_id, 
  runner_id,  
  CASE
	  WHEN pickup_time IS null OR pickup_time LIKE 'null' THEN ' '
	  ELSE pickup_time
	  END AS pickup_time,
  CASE
	  WHEN distance IS null OR distance LIKE 'null' THEN ' '
	  ELSE REGEXP_REPLACE(distance, 'km| ', '', 'g')
    END AS distance,
  CASE
	  WHEN duration IS null OR duration LIKE 'null' THEN ' '
	  ELSE REGEXP_REPLACE(duration, 'minutes|minute|mins|min| ', '', 'g')
	  END AS duration,
  CASE
	  WHEN cancellation IS NULL or cancellation LIKE 'null' THEN ' '
	  ELSE cancellation
	  END AS cancellation
FROM pizza_runner.runner_orders;

--1. How many pizzas were ordered?
SELECT COUNT(*) AS count_orders
FROM customer_orders_cleaned;

--2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS unique_no_of_orders
FROM customer_orders_cleaned;

--3. How many successful orders were delivered by each runner?
SELECT runner_id,
	COUNT(order_id) AS delivered_orders
FROM runner_orders_cleaned
where cancellation LIKE ' '
GROUP BY runner_id;

--4. How many of each type of pizza was delivered?
SELECT p.pizza_name, COUNT(C.pizza_id) as no_of_pizzas_delivered
FROM customer_orders_cleaned AS C
INNER JOIN pizza_runner.pizza_names AS p ON C.pizza_id = p.pizza_id
GROUP BY p.pizza_name;
