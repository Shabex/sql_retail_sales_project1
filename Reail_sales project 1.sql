-- SQL Retail Sales Analysis - P1

-- Create Table 
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE  retail_sales 
	(
		transactions_id	INT PRIMARY KEY, 
		sale_date DATE,
		sale_time	TIME,
		customer_id	INT,
		gender	VARCHAR(50),
		age	INT,
		category VARCHAR(50),	
		quantiy	INT,
		price_per_unit	FLOAT,
		cogs	FLOAT,
		total_sale FLOAT
	);

SELECT *
	FROM retail_sales
	LIMIT 10;


-- DATA CLEANING

SELECT COUNT(*)
	FROM retail_sales;


SELECT *
	FROM retail_sales
	WHERE transactions_id IS NULL;



SELECT *
	FROM retail_sales
	WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	gender IS NULL
	OR 
	sale_time IS NULL
	OR 
	category IS NULL
	OR
	Quantiy IS NULL
	OR
	cogs IS NULL
	OR
	price_per_unit is null
	or
	total_sale is null;
	

DELETE FROM retail_sales
	WHERE 
		transactions_id IS NULL
		OR
		sale_date IS NULL
		OR
		gender IS NULL
		OR 
		sale_time IS NULL
		OR 
		category IS NULL
		OR
		Quantiy IS NULL
		OR
		cogs IS NULL
		OR
		price_per_unit is null
		or
		total_sale is null;


SELECT *
	FROM retail_sales;

-- DATA EXPLORATION

-- How many sales we have

select count(*) as total_sales
	from retail_sales;

select count (distinct(customer_id)) AS customers
	from retail_sales;

select count (distinct(category)) AS No_categories
	from retail_sales;

select distinct(category) AS categories
	from retail_sales;

-- DATA ANALYSIS/BUSINESS KEY PROBLEMS AND ANSWERS
-- 1. Write a SQL query to retrieve all columns for sales made on '2022-11-05

SELECT *
	FROM retail_sales
	WHERE sale_date = '2022-11-05';

-- 2. Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4  in the month of Nov-2022.
SELECT *
	FROM retail_sales 	
	WHERE category = 'Clothing'
		AND 
		TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
		AND
		quantiy >= 4
	order by quantiy desc;

-- 3. Write a SQL query to calculate the total sales (total_sale) for each category.
select category, 
		sum(total_sale),
		count(*) As total_orders
	from retail_sales
	group by category;

-- 4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
select category,
		round(avg(age),2) as Avg_age,
		count(customer_id) AS No_customers
	from retail_sales
	where category = 'Beauty'
	group by category;

-- 5. Write a SQL query to find all transactions where the total_sale is greater than 1000.
select *
	from retail_sales
	where total_sale > 1000;

-- 6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
select
		gender,
		category,
		count(transactions_id)
	from retail_sales
	group by gender, category
	order by 3 desc;

-- 7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year - Use CTE
With yearly_total as
	(
		select 
				extract(Year from sale_date) as year,
				extract(Month from sale_date) as month,
				avg(total_sale) as Avg_sales,
				Rank() over(
					partition by extract(Year from sale_date) 
					order by avg(total_sale) desc) as rank
			from retail_sales
			Group by year, month
	) 
select *
from yearly_total
where rank = 1;

-- 8. Write a SQL query to find the top 5 customers based on the highest total sales
select 
		customer_id,
		sum(total_sale) total_sales
	from retail_sales
	group by customer_id
	order by total_sales Desc
	Limit 5;

-- 9. Write a SQL query to find the number of unique customers who purchased items from each category.
select  
		category,
		count(distinct(customer_id)) as No_Cstm
	from retail_sales
	group by category
	order by No_Cstm Desc;

-- 10. Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)

With hourly_orders as
	(
		Select 
				sale_time,
				CASE
					When extract(Hour from sale_time) < 12 then 'Morning'
					When extract(Hour from sale_time) between 12 and 17 then 'Afternoon'
					When extract(Hour from sale_time) > 17 then 'Evening'
				END as shifts
			from retail_sales
	)
	select 
			shifts,
			count(*) total_orders
		from hourly_orders
		group by shifts
		order by 2 desc;

-- End of Project
	
		





