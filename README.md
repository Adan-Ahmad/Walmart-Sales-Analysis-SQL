# Walmart Sales Analysis Project (SQL)
Data cleaning and exploratory data analysis project of Walmart sales.
The dataset can be found [here](https://www.kaggle.com/datasets/mikhail1681/walmart-sales/data)

## Project Overview
This project involves a comprehensive analysis of Walmart's weekly sales data to identify key revenue drivers. The study focuses on data cleaning, the impact of factors like Unemployment, Inflation, Temperature etc make on sales.

## Key Technical Skills
- **Data Cleaning & Preparation:** Standardized date formats, converted temperatures from Fahrenheit to Celsius, and handled missing values using `DELETE` and `UPDATE`.
- **Statistical Analysis:** Calculated the **Coefficient of Variation (Volatility)** to determine the reliability of sales trends across different environmental conditions.
- **Advanced Querying:** Utilized `CASE` statements for temperature binning, `JOINs` for summary table updates, and Window Functions (`LAG`) to calculate holiday premiums.

## Key Insights
- **The Holiday Premium:** Analysis shows a **7.84% increase** in average weekly sales during holiday periods compared to normal weeks.
- **Temperature Volatility:** While sales are highest in "Cold" ranges (0-10°C), this is primarily due to holiday overlap. Sales in **Hot weather (>30°C)** are the most unpredictable, showing a high volatility index of **0.612**.
- **Seasonal Trends:** Warmer seasons (Spring/Summer) generally show more consistent revenue streams, whereas Winter months are heavily skewed by specific holiday spikes.

##  Project Structure
- `walmart_analysis.sql`: Full SQL script containing data cleaning, transformation, and exploratory queries.
- `README.md`: Project documentation and summary of findings.
