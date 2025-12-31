## Retail-Sales-Analysis-SQL
**Project Overview**

This project involves a comprehensive analysis of retail sales data. I performed data cleaning, handled missing values, and conducted advanced exploratory data analysis (EDA) using  	PostgreSQL to answer some specific business questions regarding customer behavior and sales trends.

**Database Schema**
	
* The data is stored in a table named sales_analysis with the following structure:

* Transaction Info: transaction_id, sale_date, sale_time
	
* Customer Info: customer_id, gender, age
	
* Product Info: category, quantity, price_per_unit, cogs

* Financials: total_sale


  

**Analysis Roadmap**


  **1. Data Cleaning & Preparation**
	   
* Null Value Management: Identified missing records in key columns.
	    
* Imputation: Replaced NULL values in age, quantity, and price using mean/average values to maintain dataset integrity.
	    
* Type Casting: Utilized PostgreSQL casting (:: numeric) for precise financial calculations.
  

  **2. Business Questions Answered**
	| ID | Analysis Focus | Key SQL Techniques Used |
	| :--- | :--- | :--- |
	| Q1-Q4 | Basic Aggregations | `DISTINCT`, `GROUP BY`, `HAVING` |
	| Q5 | Monthly Performance | `TO_CHAR`, `EXTRACT`, Subqueries |
	| Q7 | Gender Contribution | **Window Functions** (`SUM OVER PARTITION`) |
	| Q8 | Peak Hour Analysis | `EXTRACT(HOUR)`, CTEs |
	| Q9 | Running Totals | `SUM() OVER(ORDER BY)` |
	| Q10 | Customer Retention | Date arithmetic & `MIN/MAX` |
	| Q12 | Revenue Growth % | `LAG()` Window Function |

****Key Technical Highlights****

* Time-Series Analysis: Used LAG() to compare month-over-month revenue growth.
	
* Advanced Filtering: Identified outliers by calculating transactions that were 4.5x higher than the category average.
	
* Customer Insights: Calculated the average "gap" in days between first and last purchases to understand loyalty.

  
