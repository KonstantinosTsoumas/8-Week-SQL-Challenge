-- The [index_value] is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.
-- Average composition can be calculated by dividing the 'composition' column by the [index_value] column rounded to 2 decimal places.

-- 1. What is the top 10 interests by the average composition for each month?
WITH composion_average_ranking_cte AS (
  SELECT 
    metrics.interest_id,
    map.interest_name,
    metrics.month_year,
	ROUND(CAST(metrics.composition AS NUMERIC) / CAST(metrics.index_value AS NUMERIC), 2) AS avg_composition,
    DENSE_RANK() OVER(PARTITION BY metrics.month_year ORDER BY metrics.composition / metrics.index_value DESC) AS rank_per_month
  FROM fresh_segments.interest_metrics metrics
  JOIN fresh_segments.interest_map map 
    ON CAST(metrics.interest_id AS INTEGER) = map.id
  WHERE metrics.month_year IS NOT NULL
) 
SELECT *
FROM composion_average_ranking_cte
WHERE rank_per_month <= 10; 

-- 2. For all of these top 10 interests - which interest appears the most often?
-- This could also be solved with an additional CTE but I find this way quite straightforward.
WITH composion_average_ranking_cte AS (
  SELECT 
    metrics.interest_id,
    map.interest_name,
    metrics.month_year,
    ROUND(CAST(metrics.composition AS NUMERIC) / CAST(metrics.index_value AS NUMERIC), 2) AS avg_composition,
    DENSE_RANK() OVER(PARTITION BY metrics.month_year ORDER BY metrics.composition / metrics.index_value DESC) AS rank_per_month
  FROM fresh_segments.interest_metrics metrics
  JOIN fresh_segments.interest_map map 
    ON CAST(metrics.interest_id AS INTEGER) = map.id
  WHERE metrics.month_year IS NOT NULL
) 
SELECT interest_name, COUNT(*) AS appearance_count
FROM composion_average_ranking_cte
WHERE rank_per_month <= 10
GROUP BY interest_name
ORDER BY appearance_count DESC
LIMIT 5;
