--1. How many users are there?
SELECT 
  COUNT(DISTINCT user_id) AS user_count
FROM clique_bait.users;
