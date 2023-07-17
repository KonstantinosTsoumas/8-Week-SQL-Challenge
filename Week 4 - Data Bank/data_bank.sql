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