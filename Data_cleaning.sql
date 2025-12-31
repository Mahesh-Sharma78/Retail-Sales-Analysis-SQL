
create table sales_analysis
			(
			transaction_id int,
			sale_date date,
			sale_time time,
			customer_id int,
			gender varchar(20),
			age int,
			category varchar(20),
			quantity int,
			price_per_unit float,
			cogs float,
			total_sale float

			);
select * from sales_analysis
limit 10;

-- checking how long data is and imported data is compleeted or not

select count(*) from sales_analysis;



--checking is there any null values in the data
select * from sales_analysis
where 
	transaction_id is null
	or	sale_date is null
	or	sale_time is null
	or	customer_id is null
	or	gender is null
	or	age is null
	or	category is null
	or	quantity is null
	or	price_per_unit is null
	or  cogs is null
	or  total_sale is null;


--Replacing null values by there avg values
select round(avg(age),0) as avg_age from sales_analysis;
select round(avg(quantity),0) as avg_qunt from sales_analysis;
select avg(price_per_unit) as avg_price from sales_analysis;
select avg(cogs) as avg_cogs from sales_analysis;
select avg(total_sale) from sales_analysis;


--updating null values
UPDATE sales_analysis
SET 
    age = COALESCE(age, (SELECT ROUND(AVG(age), 0) FROM sales_analysis)),
    quantity = COALESCE(quantity, (SELECT ROUND(AVG(quantity), 0) FROM sales_analysis)),
    price_per_unit = COALESCE(price_per_unit, (SELECT AVG(price_per_unit) FROM sales_analysis)),
    cogs = COALESCE(cogs, (SELECT AVG(cogs) FROM sales_analysis)),
    total_sale = COALESCE(total_sale, (SELECT AVG(total_sale) FROM sales_analysis))
WHERE 
    age IS NULL 
    OR quantity IS NULL 
    OR price_per_unit IS NULL 
    OR cogs IS NULL 
    OR total_sale IS NULL;


