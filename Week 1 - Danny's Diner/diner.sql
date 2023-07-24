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
WITH order_after_member AS (
  SELECT 
    sales.customer_id,
    menu.product_name,
    sales.order_date,
    members.join_date,
    DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date) AS rank
  FROM dannys_diner.sales
  JOIN dannys_diner.members
    ON sales.customer_id = members.customer_id
  JOIN dannys_diner.menu 
    ON sales.product_id = menu.product_id
  WHERE sales.order_date >= members.join_date
)

SELECT 
  customer_id,
  product_name,
  order_date,
  join_date
FROM order_after_member
WHERE rank = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH order_after_member AS (
  SELECT 
    sales.customer_id,
    menu.product_name,
    sales.order_date,
    members.join_date,
    DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date) AS rank
  FROM dannys_diner.sales
  JOIN dannys_diner.members
    ON sales.customer_id = members.customer_id
  JOIN dannys_diner.menu 
    ON sales.product_id = menu.product_id
  WHERE sales.order_date < members.join_date
)

SELECT 
  customer_id,
  product_name,
  order_date,
  join_date
FROM order_after_member
WHERE rank = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT 
  sales.customer_id,
  COUNT(sales.product_id) AS total_items,
  SUM(menu.price) AS total_spend
FROM dannys_diner.sales
JOIN dannys_diner.members
  ON sales.customer_id = members.customer_id
JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
WHERE sales.order_date < members.join_date
GROUP BY sales.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH points_cte AS
(
   SELECT *, 
      CASE  
         WHEN product_name = 'sushi' THEN price * 20
         ELSE price * 10
      END AS points
   FROM dannys_diner.menu
)

SELECT sales.customer_id, 
      SUM(points_cte.points) AS total_points
FROM points_cte
JOIN dannys_diner.sales
   ON points_cte.product_id = sales.product_id
GROUP BY sales.customer_id
ORDER BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH dates_cte AS (
  SELECT 
    customer_id, 
    join_date,
    join_date + INTERVAL '6 day' AS valid_date, 
    ('2021-01-31'::date) AS last_date
  FROM dannys_diner.members
)

SELECT 
  dates.customer_id,
  SUM(CASE 
      	WHEN sales.order_date BETWEEN dates.join_date AND dates.valid_date THEN menu.price*20
      	WHEN menu.product_name = 'sushi' THEN menu.price*20
      ELSE menu.price*10 END) AS total_points
FROM dannys_diner.sales
JOIN dates_cte as dates 
  ON sales.customer_id = dates.customer_id
JOIN dannys_diner.menu 
  ON sales.product_id = menu.product_id
WHERE sales.order_date <= dates.last_date
GROUP BY dates.customer_id;

