-- 1. How many unique transactions were there? 
SELECT COUNT(DISTINCT txn_id) AS unique_transactions
FROM balanced_tree.sales;

-- 2. What is the average unique products purchased in each transaction?
SELECT 
	ROUND(AVG(product_count),2)
    FROM (
SELECT
	txn_id,
    COUNT(DISTINCT prod_id) AS product_count
FROM balanced_tree.sales
GROUP BY txn_id
      )product_query ; 
