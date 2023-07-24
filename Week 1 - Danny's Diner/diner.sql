-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
  sales.customer_id,
  SUM(menu.price) AS total_spent
FROM dannys_diner.sales
JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT 
  customer_id,
  COUNT(DISTINCT order_date) AS visit_count
FROM dannys_diner.sales 
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH rank_cte AS (
  SELECT 
    customer_id,
    product_id,
    order_date,
    DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rank
  FROM dannys_diner.sales
)

SELECT 
  rank_cte.customer_id,
  rank_cte.order_date,
  menu.product_name
FROM rank_cte
JOIN dannys_diner.menu 
  ON rank_cte.product_id = menu.product_id
WHERE rank_cte.rank = 1
GROUP BY rank_cte.customer_id, rank_cte.order_date, menu.product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT sales.product_id, menu.product_name, COUNT(sales.product_id) AS purchase_count
FROM dannys_diner.sales
JOIN dannys_diner.menu
 ON sales.product_id=menu.product_id
GROUP BY sales.product_id, menu.product_name
ORDER BY purchase_count DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
WITH purchased_item AS (
SELECT
    customer_id,
    product_id,
    COUNT(*) AS purchase_frequency,
    DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(product_id) DESC) AS rank
  FROM dannys_diner.sales
  GROUP BY customer_id, product_id
  )
  
SELECT 
  purchased_item.customer_id,
  menu.product_name,
  purchased_item.purchase_frequency
FROM purchased_item
JOIN dannys_diner.menu
  ON purchased_item.product_id = menu.product_id
WHERE purchased_item.rank = 1
ORDER BY purchased_item.customer_id;
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?