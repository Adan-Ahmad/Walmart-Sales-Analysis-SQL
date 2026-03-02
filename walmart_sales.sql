-- Walmart sales dataset project
-- DATA CLEANING AND PREPARATION

SELECT * FROM walmart_sales;
SELECT COUNT(*) num_rows FROM walmart_sales;

-- Removing blank or null values from the store IDs
DELETE FROM walmart_sales
WHERE Store IS NULL OR Store = '';

DESCRIBE walmart_sales;
-- Converting the date text into a Date format:
UPDATE walmart_sales
SET `Date` = STR_TO_DATE(`Date`, '%d/%m/%Y');

SELECT `Date` FROM walmart_sales;

-- Converting temperature values to Celsius:
UPDATE walmart_sales
SET Temperature = ROUND((Temperature - 32) * 5 / 9, 1);

-- Changing relevant column names
ALTER TABLE walmart_sales 
RENAME COLUMN Weekly_Sales TO weekly_net_sales;


-- DATA EXPLORATION:

-- Ranking each Walmart based on their total sales
SELECT store, ROUND(SUM(weekly_net_sales), 2) AS total_sales
FROM walmart_sales
GROUP BY store
ORDER BY total_sales DESC;

-- Inserting total sales values into our original table
ALTER TABLE walmart_sales
ADD COLUMN total_sales DECIMAL (20, 2);

SELECT * FROM walmart_sales;

UPDATE walmart_sales AS w
JOIN (
    SELECT store, ROUND(SUM(weekly_net_sales), 2) AS calculated_total
    FROM walmart_sales
    GROUP BY store
) AS summary ON w.store = summary.store
SET w.total_sales = summary.calculated_total;

-- A look at whether CPI volatility affects store revenue directly:
-- Lets first select some stores where CPI changes the most within the data

SELECT * FROM (
	SELECT store, MAX(CPI) - MIN(CPI) CPI_difference, 
    ROUND(SUM(weekly_net_sales), 2) total_sales
	FROM walmart_sales
	GROUP BY store
	ORDER BY CPI_difference DESC
	LIMIT 10
) top_cpi
UNION ALL
SELECT * FROM (
	SELECT store, MAX(CPI) - MIN(CPI) CPI_difference, 
    ROUND(SUM(weekly_net_sales), 2) total_sales
	FROM walmart_sales
	GROUP BY store
	ORDER BY CPI_difference ASC
	LIMIT 10
) bottom_cpi;
-- Table suggests CPI volatilty is not a strong indicator of sales revenue generated

-- A look at whether unemployment affects store revenue directly:

SELECT Store, 
ROUND(AVG(Unemployment), 3) unemployment_rate,
ROUND(SUM(weekly_net_sales), 2) total_sales
FROM walmart_sales
GROUP BY store
ORDER BY total_sales DESC;
-- It appears there is a small correlation between store rev and unemployment
-- Regression analysis will be necessary to confirm this


-- Ranking sales based on the season

ALTER TABLE walmart_sales
ADD COLUMN season VARCHAR(20);

UPDATE walmart_sales
SET season = CASE
		WHEN MONTH(`Date`) IN (12, 01, 02) THEN 'winter'
        WHEN MONTH(`Date`) IN (03, 04, 05) THEN 'spring'
        WHEN MONTH(`Date`) IN (06, 07, 08) THEN 'summer'
        WHEN MONTH(`Date`) IN (09, 10, 11) THEN 'autumn'
END;

SELECT season, ROUND(SUM(total_sales)) seasonal_revenue,
AVG(weekly_net_sales) avg_weekly_sales
FROM walmart_sales
GROUP BY season
ORDER BY seasonal_revenue DESC;
-- In total, warmer seasons generate higher revenue for the store, as well as higher averages overall

-- Taking this a step further, is there a sweet spot where certain temperatures bring about greater sales?
SELECT MIN(temperature) lowest_temp, MAX(temperature) highest_temp
FROM walmart_sales;

SELECT
CASE 
	WHEN Temperature > -20 and Temperature <= -10 THEN 'Extreme Cold'
    WHEN Temperature > -10 and Temperature <= 0 THEN 'Very Cold'
    WHEN Temperature > 0 and Temperature <= 10 THEN 'Cold'
    WHEN Temperature > 10 and Temperature <= 20 THEN 'Mild'
    WHEN Temperature > 20 and Temperature <= 30 THEN 'Warm'
    WHEN Temperature > 30 and Temperature <= 40 THEN 'Hot'
END temp_range,
COUNT(*) sample_size,
ROUND(AVG(weekly_net_sales), 2) avg_sales,
ROUND(STDDEV(weekly_net_sales) / AVG(weekly_net_sales), 3) volatility
FROM walmart_sales
GROUP BY temp_range
ORDER BY avg_sales DESC;
/* relative volatility across most temp ranges. 'Hot' weather sees increased, more unpredictable volatility.
Further factors influencing spending habits in hot weather may come into play.
Nonetheless, 'Cold' times of year tend to generate the highest average revenue. */

-- Seeing if holidays generate increased sales
SELECT 
    CASE WHEN Holiday_Flag = 1 THEN 'Holiday Week' ELSE 'Normal Week' END AS week_type,
    COUNT(*) AS total_weeks,
    ROUND(AVG(weekly_net_sales), 2) AS avg_weekly_sales,
    ROUND((AVG(weekly_net_sales) / LAG(AVG(weekly_net_sales)) OVER (ORDER BY Holiday_Flag) - 1) * 100, 2) AS pct_increase
FROM walmart_sales
GROUP BY Holiday_Flag;
/* Average sales increase 7.84% during holiday weeks.
This could partly account for highest sales falling under 'cold' and 'very cold' temperatures, since
holidays appear disproportionately in colder seasons */