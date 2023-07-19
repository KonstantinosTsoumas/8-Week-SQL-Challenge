--1. How many unique transactions were there? 
SELECT COUNT(DISTINCT txn_id) AS unique_transactions
FROM balanced_tree.sales;
