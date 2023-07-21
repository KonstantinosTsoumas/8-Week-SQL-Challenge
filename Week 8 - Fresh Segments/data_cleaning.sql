-- 1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
ALTER TABLE fresh_segments.interest_metrics
ALTER COLUMN month_year TYPE DATE USING TO_DATE(month_year, 'MM-YYYY');

-- 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
SELECT month_year, COUNT(*) AS record_count
FROM fresh_segments.interest_metrics
GROUP BY month_year
ORDER BY month_year NULLS FIRST;

-- 3. What do you think we should do with these null values in the fresh_segments.interest_metrics?
-- Let's first check what percentage of the dataset contain null values.
SELECT
  (COUNT(*) FILTER (WHERE month_year IS NULL) * 100.0 / COUNT(*)) AS null_percentage
FROM fresh_segments.interest_metrics;

-- Find what column contain null values
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'interest_metrics' AND table_schema = 'fresh_segments'
  AND column_name NOT IN (
    SELECT column_name
    FROM fresh_segments.interest_metrics
    WHERE column_name IS NULL
  );


-- Because we have null values in every the following columns : _month, _year, month_year, interest_id, composition, index_value, ranking, percentile_ranking
-- we shall delete them as they compliment each other and they are useless when not used together.
-- It would be better however if we would not touch the original table directly but create a copy one with the removed null values.
DELETE FROM fresh_segments.interest_metrics
WHERE interest_id IS NULL OR month_year IS NULL;

-- Check the percentage of null values again.
SELECT
  (COUNT(*) FILTER (WHERE month_year IS NULL) * 100.0 / COUNT(*)) AS null_percentage
FROM fresh_segments.interest_metrics;

-- 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
SELECT 
  COUNT(DISTINCT map.id) AS map_id_count,
  COUNT(DISTINCT metrics.interest_id) AS metrics_id_count,
  SUM(CASE WHEN map.id IS NULL THEN 1 ELSE 0 END) AS map_missing,
  SUM(CASE WHEN metrics.interest_id IS NULL THEN 1 ELSE 0 END) AS metric_missing
FROM fresh_segments.interest_map map
FULL OUTER JOIN fresh_segments.interest_metrics metrics
  ON map.id::text = metrics.interest_id::text;

-- 5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table
SELECT 
  map.id, 
  interest_name, 
  COUNT(*)
FROM fresh_segments.interest_map AS map
JOIN fresh_segments.interest_metrics AS metrics
  ON map.id = CAST(metrics.interest_id AS INTEGER)
GROUP BY map.id, interest_name
ORDER BY COUNT(*) DESC, map.id;

-- 6. What sort of table join should we perform for our analysis and why? 
-- Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns 
-- from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.
SELECT *
FROM fresh_segments.interest_map map
INNER JOIN fresh_segments.interest_metrics metrics
  ON map.id::varchar = metrics.interest_id
WHERE metrics.interest_id = '21246'
  AND metrics._month IS NOT NULL;

-- 7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?
-- Let's check how many records (if so) are out here and then if there are, what values do they take.
SELECT COUNT(*)
FROM fresh_segments.interest_metrics metrics
JOIN fresh_segments.interest_map map
  ON metrics.interest_id= map.id::varchar
WHERE metrics.month_year < CAST(map.created_at AS DATE);

-- What are their values?
SELECT *
FROM fresh_segments.interest_metrics metrics
JOIN fresh_segments.interest_map map
  ON metrics.interest_id= map.id::varchar
WHERE metrics.month_year < CAST(map.created_at AS DATE);

-- The answer to our question is yes, they are valid. This is because the 'month_year' column contain only values that are set at the first day of the month. 
