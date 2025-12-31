
--data exploration



--Q1 How many total distinct customer_id are there and by category also
 -- total distinct user id
 select count(distinct customer_id) from sales_analysis;

 --distinct customer_id by category
select 
	category, 
	count(distinct customer_id) as total_customer_id 
from sales_analysis
group by category;




--Q2 total+sales on a particular day and whole
select sum(total_sale) from sales_analysis; -- total sale

select
	sum(total_sale) 
from sales_analysis
where sale_date='2022-11-05'; --on a particular day





--Q3 All trancsaction_id where category is beauty and price is less then 50 in particular month

select 
	transaction_id, price_per_unit, sale_date 
from sales_analysis
where
	price_per_unit < 50 
	and
	sale_date between '2022-03-01' and '2022-03-31'
	


	
--Q4  total sales by customer_id in decending order where total_sale is more than  10000

select 
	sum(total_sale) as sum_total_sale,
	customer_id
from sales_analysis
group by customer_id
having sum(total_sale)>10000 --used having because we already used group by function
order by sum_total_sale desc;



--Q5 find avg sale for each month and  the best calling month

WITH MonthlySales AS (
    SELECT 
        TO_CHAR(sale_date, 'YYYY') AS sale_year,
        TO_CHAR(sale_date, 'Month') AS sale_month,
        -- We extract the month number to ensure the results are sorted chronologically
        EXTRACT(MONTH FROM sale_date) AS month_num,
        AVG(total_sale) AS avg_monthly_sale
    FROM sales_analysis
    GROUP BY 1, 2, 3
)
SELECT 
    sale_year,
    sale_month,
    ROUND(avg_monthly_sale::numeric, 2) AS average_sale,
    -- Label the month with the highest average sale
    CASE 
        WHEN avg_monthly_sale = (SELECT MAX(avg_monthly_sale) FROM MonthlySales) 
        THEN 'Best Calling Month' 
        ELSE NULL 
    END AS status
FROM MonthlySales
ORDER BY sale_year, month_num;




--Q6 Sort the customer who purchase the electronics price more then 300 in ascending order

SELECT * FROM sales_analysis
WHERE category = 'Electronics' 
  AND price_per_unit > 300
ORDER BY price_per_unit ASC;


--Q7 For each category (e.g., Clothing), find the top-performing gender segment and calculate what percentage of that category's total sales they contribute.


WITH CategorySales AS (
    SELECT 
        category,
        gender,
        SUM(total_sale) AS gender_total_sales,
        SUM(SUM(total_sale)) OVER(PARTITION BY category) AS category_total_sales
    FROM sales_analysis
    GROUP BY category, gender
),
RankedSegments AS (
    SELECT 
        category,
        gender,
        gender_total_sales,
        category_total_sales,
        RANK() OVER(PARTITION BY category ORDER BY gender_total_sales DESC) as rank_position
    FROM CategorySales
)
SELECT 
    category,
    gender AS top_performing_gender,
    -- Using ::numeric to cast the float before rounding
    ROUND(gender_total_sales::numeric, 2) AS total_sales,
    ROUND(((gender_total_sales / category_total_sales) * 100)::numeric, 2) AS contribution_percentage
FROM RankedSegments
WHERE rank_position = 1;


--Q8 Which hour of the day generates the highest average total_sale, and how does that peak hour's average compare to the overall average sale?


WITH HourlyAvgSales AS (
    --  Calculate average sales for every hour of the day
    SELECT 
        EXTRACT(HOUR FROM sale_time) as sale_hour,
        AVG(total_sale) as avg_sale_hour
    FROM sales_analysis
    GROUP BY 1
),
PeakHour AS (
    --  Identify the hour with the highest average
    SELECT 
        sale_hour, 
        avg_sale_hour
    FROM HourlyAvgSales
    ORDER BY avg_sale_hour DESC
    LIMIT 1
),
OverallAvg AS (
    -- Calculate the overall average for the whole dataset
    SELECT AVG(total_sale) as avg_sale_overall
    FROM sales_analysis
)
--  Compare the peak hour average to the global average
SELECT 
    p.sale_hour,
    ROUND(p.avg_sale_hour::numeric, 2) as peak_hour_avg_sale,
    ROUND(o.avg_sale_overall::numeric, 2) as overall_avg_sale,
    ROUND((p.avg_sale_hour - o.avg_sale_overall)::numeric, 2) as difference,
    ROUND(((p.avg_sale_hour / o.avg_sale_overall - 1) * 100)::numeric, 2) as percentage_above_avg
FROM PeakHour p, OverallAvg o;




--Q9 Track the "Running Total" of sales for each category as the month progressed


WITH MonthlySales AS (
    SELECT 
        category,
        TO_CHAR(sale_date, 'YYYY-MM') AS sale_month,
        SUM(total_sale) AS monthly_sum
    FROM sales_analysis
    GROUP BY category, sale_month
)
SELECT 
    category,
    sale_month,
    ROUND(monthly_sum::numeric, 2) AS monthly_sales,
    ROUND(SUM(monthly_sum) OVER (
        PARTITION BY category 
        ORDER BY sale_month
    )::numeric, 2) AS running_total_by_month
FROM MonthlySales
ORDER BY category, sale_month;



--q10 Which customers have made more than one purchase in different months, and what is the average time gap between their first and last purchase?
WITH CustomerStats AS (
    SELECT 
        customer_id,
        MIN(sale_date) as first_purchase,
        MAX(sale_date) as last_purchase,
        COUNT(DISTINCT TO_CHAR(sale_date, 'YYYY-MM')) as distinct_months,
        COUNT(transaction_id) as total_purchases
    FROM sales_analysis
    GROUP BY customer_id
)
SELECT 
    customer_id,
    total_purchases,
    first_purchase,
    last_purchase,
    -- Subtracting dates in Postgres returns the number of days
    (last_purchase - first_purchase) as total_days_gap,
    -- Calculating average gap (total days divided by number of gaps between purchases)
    CASE 
        WHEN total_purchases > 1 
        THEN ROUND(((last_purchase - first_purchase)::numeric / (total_purchases - 1)), 2)
        ELSE 0 
    END AS avg_days_between_purchases
FROM CustomerStats
WHERE distinct_months > 1
ORDER BY avg_days_between_purchases DESC;



--Q11 Find all transactions where the total_sale is higher than four and half times the average total_sale for that specific category.


WITH CategoryAverages AS (
    SELECT 
        *,
        -- Calculate the average total_sale for each category
        AVG(total_sale) OVER(PARTITION BY category) as avg_category_sale
    FROM sales_analysis
)
SELECT 
    transaction_id,
    sale_date,
    category,
    total_sale,
    ROUND(avg_category_sale::numeric, 2) as category_avg,
    ROUND((avg_category_sale * 3)::numeric, 2) as threshold_value
FROM CategoryAverages
WHERE total_sale > (avg_category_sale * 4.5)
ORDER BY category, total_sale DESC;



--Q12 Calculate the percentage growth in total revenue for the entire store from one month to the next.

WITH MonthlySales AS (
    -- Group all sales by month
    SELECT 
        TO_CHAR(sale_date, 'YYYY-MM') AS sale_month,
        SUM(total_sale) AS current_month_revenue
    FROM sales_analysis
    GROUP BY 1
    ORDER BY 1
),
PrevMonthData AS (
    --  Use LAG to bring the previous month's revenue into the current row
    SELECT 
        sale_month,
        current_month_revenue,
        LAG(current_month_revenue) OVER (ORDER BY sale_month) AS previous_month_revenue
    FROM MonthlySales
)
--  Calculate the percentage growth
SELECT 
    sale_month,
    ROUND(current_month_revenue::numeric, 2) AS total_revenue,
    ROUND(previous_month_revenue::numeric, 2) AS last_month_revenue,
    ROUND(
        (
            ((current_month_revenue - previous_month_revenue) / previous_month_revenue) * 100
        )::numeric, 
        2
    ) AS percentage_growth
FROM PrevMonthData;
