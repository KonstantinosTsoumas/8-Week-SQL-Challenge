-- Using a single SQL query - create a new output table which has the following details:

-- How many times was each product viewed?
-- How many times was each product added to cart?
-- How many times was each product added to a cart but not purchased (abandoned)?
-- How many times was each product purchased?

-- The Single Query answer to the above.
WITH combined_events AS (
  SELECT
    events.visit_id,
    page_hierarchy.product_id AS product_id,
    page_hierarchy.page_name AS product_name,
    page_hierarchy.product_category,
    SUM(CASE WHEN events.event_type = 1 THEN 1 ELSE 0 END) AS page_view,
    SUM(CASE WHEN events.event_type = 2 THEN 1 ELSE 0 END) AS cart_add,
    MAX(CASE WHEN events.event_type = 3 THEN 1 ELSE 0 END) AS purchase
  FROM clique_bait.events AS events
  JOIN clique_bait.page_hierarchy AS page_hierarchy
    ON events.page_id = page_hierarchy.page_id
  WHERE product_id IS NOT NULL
  GROUP BY events.visit_id, page_hierarchy.product_id, page_hierarchy.page_name, page_hierarchy.product_category
),
product_info AS (
  SELECT 
    product_id,
    product_name, 
    product_category, 
    SUM(page_view) AS views,
    SUM(cart_add) AS cart_adds, 
    SUM(CASE WHEN cart_add = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
    SUM(CASE WHEN cart_add = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
  FROM combined_events
  GROUP BY product_id, product_name, product_category
)

SELECT *
FROM product_info
ORDER BY product_id;


-- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.
WITH combined_events AS (
  SELECT
    events.visit_id,
    page_hierarchy.product_id AS product_id,
    page_hierarchy.page_name AS product_name,
    page_hierarchy.product_category,
    SUM(CASE WHEN events.event_type = 1 THEN 1 ELSE 0 END) AS page_view,
    SUM(CASE WHEN events.event_type = 2 THEN 1 ELSE 0 END) AS cart_add,
    MAX(CASE WHEN events.event_type = 3 THEN 1 ELSE 0 END) AS purchase
  FROM clique_bait.events AS events
  JOIN clique_bait.page_hierarchy AS page_hierarchy
    ON events.page_id = page_hierarchy.page_id
  WHERE product_id IS NOT NULL
  GROUP BY events.visit_id, page_hierarchy.product_id, page_hierarchy.page_name, page_hierarchy.product_category
),
product_info AS (
  SELECT 
    product_id,
    product_name, 
    product_category, 
    SUM(page_view) AS views,
    SUM(cart_add) AS cart_adds, 
    SUM(CASE WHEN cart_add = 1 AND purchase = 0 THEN 1 ELSE 0 END) AS abandoned,
    SUM(CASE WHEN cart_add = 1 AND purchase = 1 THEN 1 ELSE 0 END) AS purchases
  FROM combined_events
  GROUP BY product_id, product_name, product_category
),
category_info AS (
  SELECT
    product_category,
    SUM(views) AS total_views,
    SUM(cart_adds) AS total_cart_adds,
    SUM(abandoned) AS total_abandoned,
    SUM(purchases) AS total_purchases
  FROM product_info
  GROUP BY product_category
)

SELECT *
FROM category_info
ORDER BY product_category;

--Use your 2 new output tables - answer the following questions:


-- 1.Which product had the most views, cart adds and purchases?
-- I will only paste the query here to avoid replication. The following query should be 
-- embedded into the previous solutions using CTEs.
SELECT TOP 1 *
FROM product_info
ORDER BY views DESC
LIMIT 1;

