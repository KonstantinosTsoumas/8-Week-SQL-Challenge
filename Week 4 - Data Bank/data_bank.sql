--1.How many unique nodes are there on the Data Bank system?
SELECT count(DISTINCT node_id) AS unique_nodes
FROM customer_nodes;

--2.What is the number of nodes per region?
SELECT 
	regions.region_id,
    region_name,
	COUNT(nodes.node_id) AS nodes_count
FROM data_bank.customer_nodes AS nodes
JOIN data_bank.regions AS regions ON nodes.region_id = regions.region_id
GROUP BY regions.region_id, region_name;

--3. How many customers are allocated to each region?
SELECT 
	regions.region_id,
    region_name,
	COUNT(DISTINCT customer_id) AS customers_count
FROM data_bank.customer_nodes AS nodes
JOIN data_bank.regions AS regions ON nodes.region_id = regions.region_id
GROUP BY regions.region_id, region_name;

--4.How many days on average are customers reallocated to a different node?
WITH number_of_days_cte AS (
  SELECT
  	customer_id,
  	node_id,
    end_date - start_date AS amount_of_days_in_node
  FROM data_bank.customer_nodes
  WHERE end_date!='9999-12-31'
  ),
  	total_number_of_days AS (
    SELECT
      	customer_id,
      	node_id,
      	SUM(amount_of_days_in_node) AS total_days_in_node
    FROM number_of_days_cte
    GROUP BY customer_id, node_id
	)


SELECT ROUND(AVG(total_days_in_node),1) AS avg_reallocated_days
FROM total_number_of_days


--5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
WITH durations AS (
  SELECT 
    region_id,
    customer_id, 
    node_id,
    end_date - start_date AS duration
  FROM 
    data_bank.customer_nodes
)

SELECT 
  regions.region_name,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY duration) AS median_duration,
  PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY duration) AS percentile_80th,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY duration) AS percentile_95th
FROM 
  durations
JOIN 
  data_bank.regions AS regions
ON 
  regions.region_id = durations.region_id
GROUP BY 
  regions.region_name;
