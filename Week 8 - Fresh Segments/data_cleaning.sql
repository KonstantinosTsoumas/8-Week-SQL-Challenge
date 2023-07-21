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