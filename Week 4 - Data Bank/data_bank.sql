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
