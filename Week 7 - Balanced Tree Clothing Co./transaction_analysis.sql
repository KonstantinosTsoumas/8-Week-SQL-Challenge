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

-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
WITH revenue_cte AS (
  SELECT 
    txn_id, 
    SUM(price * qty) AS total_revenue
  FROM balanced_tree.sales
  GROUP BY txn_id
)

SELECT
	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY revenue) AS median_percentile_25th,
  	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY revenue) AS median_percentile_50th,
	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue) AS median_percentile_75th
FROM revenue_cte;

-- 4.What is the average discount value per transaction?
SELECT ROUND(AVG(revenue_discount)) AS average_discount
FROM (
    SELECT 
        txn_id,
        SUM(qty*price*discount/100) AS revenue_discount
        FROM balanced_tree.sales
        GROUP BY txn_id
     )	AS revenue_discount_cte
        