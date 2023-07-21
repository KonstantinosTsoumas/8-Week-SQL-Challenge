-- 1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
ALTER TABLE fresh_segments.interest_metrics
ALTER COLUMN month_year TYPE DATE USING TO_DATE(month_year, 'MM-YYYY');
