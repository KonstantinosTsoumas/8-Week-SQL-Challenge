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

-- 3. What is the average of the average composition for the top 10 interests for each month?
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
SELECT month_year, AVG(avg_composition) AS average_composition
FROM composion_average_ranking_cte
WHERE rank_per_month <= 10
GROUP BY month_year;

-- 4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.
WITH avg_compositions AS (
  SELECT 
    month_year,
    CAST(interest_id AS INTEGER) AS interest_id,
    CAST(composition / index_value AS NUMERIC) AS average_composition,
    CAST(MAX(composition / index_value) OVER(PARTITION BY month_year) AS NUMERIC) AS average_composition_max
  FROM fresh_segments.interest_metrics
  WHERE month_year BETWEEN '2018-09-01' AND '2019-08-01'
),
moving_avg_compositions AS (
  SELECT 
    comp.month_year,
    i_map.interest_name,
    comp.average_composition_max AS average_composition_max,
    ROUND(AVG(comp.average_composition_max) OVER(ORDER BY comp.month_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS three_months_moving_avg,
    LAG(i_map.interest_name) OVER (ORDER BY comp.month_year) || ': ' || CAST(LAG(comp.average_composition_max) OVER (ORDER BY comp.month_year) AS VARCHAR) AS one_month_ago,
    LAG(i_map.interest_name, 2) OVER (ORDER BY comp.month_year) || ': ' || CAST(LAG(comp.average_composition_max, 2) OVER (ORDER BY comp.month_year) AS VARCHAR) AS two_months_ago
  FROM avg_compositions AS comp 
  JOIN fresh_segments.interest_map i_map 
    ON comp.interest_id = i_map.id
)

SELECT *
FROM moving_avg_compositions;

-- 5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments?
-- If we pay attention to the top interest names, it's evident that there are services related to travelling.
-- This lead us to believe that we're dealing with highly seasonal matters and that Fresh Segments is relying on this.