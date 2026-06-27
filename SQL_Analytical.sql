
USE enterprise_analytics;

															#Understand the structure of each table
Show tables;
Describe customers;
Desc orders;
Desc Sales;
Desc products;
Desc categories;
Desc employees;
Desc emails;
desc projects;

SELECT * FROM sales;

SELECT * FROM customers
LIMIT 10;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(customer_id) AS non_null_ids,
    COUNT(customer_name) AS non_null_names
FROM customers;

SELECT COUNT(*) FROM orders;

SELECT MIN(order_date), MAX(order_date)
FROM orders;

SELECT DISTINCT status
FROM project_tasks;

SELECT COUNT(*) FROM emails;

SELECT customer_id, COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT MAX(amount),MIN(amount) FROM sales;

																		#Check Foreign Keys
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM 
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE 
    REFERENCED_TABLE_NAME IS NOT NULL
    AND TABLE_SCHEMA = 'enterprise_analytics'
order by Table_name;


																#1) Total Sales revenue by month
select date_format(sale_date, '%b-%y') as Month, round(sum(amount),0) as Revenue
from sales
group by Year(sale_date),month(sale_date),date_format(sale_date, '%b-%y')
order by Year(sale_date),month(sale_date);

Select * from Sales;
Select * from products;
Select * from categories;



																	#2)What is the month-over-month sales growth?
with Monthwise_revenue as (
	select 
		YEAR(sale_date) AS sales_year,
		MONTH(sale_date) AS sales_month,
		date_format(sale_date, '%b-%y') as Month, round(sum(amount),0) as Revenue
	from sales
	group by Year(sale_date),month(sale_date),date_format(sale_date, '%b-%y')
	order by Year(sale_date),month(sale_date)
),
LastMonthsales as (
select Month,Revenue,
		lag(revenue,1) over(order by sales_year,sales_month) as LastMonth_Revenue
 from Monthwise_revenue)
 
 Select Month,Revenue,Lastmonth_Revenue,
			concat(ROUND(
        ((Revenue - LastMonth_Revenue)
         / LastMonth_Revenue) * 100,
        2),"%") AS  "LM_GW%"
            from Lastmonthsales;
            
																#3) Which product categories generate the highest revenue?
WITH categorywisesales AS (
    SELECT 
        s.amount,
        p.product_name,
        c.category_name 
    FROM sales s
    INNER JOIN products p ON s.product_id = p.product_id
    INNER JOIN categories c ON p.category_id = c.category_id
)
SELECT 
    category_name,
    SUM(amount) AS Revenue, 
    concat(round((SUM(amount) / SUM(SUM(amount)) OVER ()) * 100,2),"%") AS "Rev_contribution%"
FROM categorywisesales
GROUP BY category_name
ORDER BY revenue DESC;

																		#4)Which products generate the highest sales revenue?
                                                                        
WITH categorywisesales AS (
    SELECT 
        s.amount,
        p.product_name,
        c.category_name 
    FROM sales s
    INNER JOIN products p ON s.product_id = p.product_id
    INNER JOIN categories c ON p.category_id = c.category_id
)
SELECT 
    category_name,
    Product_name,
    SUM(amount) AS Revenue, 
    concat(round((SUM(amount) / SUM(SUM(amount)) OVER ()) * 100,2),"%") AS "Rev_contribution%"
FROM categorywisesales
GROUP BY category_name,Product_name
ORDER BY revenue DESC;

																	#5)Who are our top 10 customers by revenue?
Select * from customers;
select * from Orders;
Select * from Sales;

Select c.customer_id,c.customer_name,sum(o.amount) as order_amount
from customers c
inner join orders o
on c.customer_id = o.customer_id
group by c.customer_id
order by order_amount desc
limit 10;

				
													#6)Which customers contribute 80% of total Revenue?
with Customer_revenue as(
	Select c.customer_id as customer_id ,c.customer_name as customer_name,
			sum(o.amount) as order_amount
	from customers c
	inner join orders o
	on c.customer_id = o.customer_id
	group by c.customer_id
	order by order_amount desc),
    
    Running_total as(select customer_id,customer_name,order_amount,
		sum(order_amount) over(order by Order_amount Desc
								ROWS BETWEEN UNBOUNDED PRECEDING
    AND CURRENT ROW) as Running_total
        from Customer_revenue),

Pareto AS (
    select customer_id,customer_name,Running_total,
						concat(Round((running_total/sum(order_amount) over())*100,2),"%") as Cumulative_Pct
                        from Running_total)
                        
Select * from Pareto
where Cumulative_Pct <=80;
		
        
																	#7)what is the average order value per customer?
select c.customer_id,c.customer_name,avg(o.amount) as Avg_amount
from customers c
inner join orders o
on c.customer_id = o.customer_id
group by c.customer_id
order by Avg_amount desc;



select p.product_name,sum(s.amount) as Revenue,
		concat(round((sum(s.amount)/sum(sum(s.amount)) over()) *100,2),"%") as Revenue_pct
from products p
inner join sales s
on p.product_id = s.product_id
group by p.product_name
order by revenue desc;


																	#8)Monthly Net Revenue
WITH GrossRevenue AS (
    SELECT
        YEAR(sale_date) AS sales_year,
        MONTH(sale_date) AS sales_month,
        DATE_FORMAT(sale_date, '%b-%y') AS Month,
        SUM(amount) AS Sales_Revenue
    FROM sales
    GROUP BY
        YEAR(sale_date),
        MONTH(sale_date),
        DATE_FORMAT(sale_date, '%b-%y')
),

ReturnAmount AS (
    SELECT
        YEAR(return_date) AS return_year,
        MONTH(return_date) AS return_month,
        DATE_FORMAT(return_date, '%b-%y') AS Month,
        SUM(amount) AS Returns_Amount
    FROM returns
    GROUP BY
        YEAR(return_date),
        MONTH(return_date),
        DATE_FORMAT(return_date, '%b-%y')
)

SELECT
    g.Month,
    g.Sales_Revenue,
    COALESCE(r.Returns_Amount,0) AS Returns_Amount,
    g.Sales_Revenue - COALESCE(r.Returns_Amount,0) AS Net_Revenue
FROM GrossRevenue g
LEFT JOIN ReturnAmount r
    ON g.sales_year = r.return_year
   AND g.sales_month = r.return_month
ORDER BY
    g.sales_year,
    g.sales_month;
    
													#9)Which customers have the highest return value as a percentage of their total order value?
				
with customer_orderValue as(
		select	c.customer_id,c.customer_name,sum(o.amount) as Ordervalue
        from customers c
        inner join orders o
        on c.customer_id = o.customer_id
        group by c.customer_id,c.customer_name),
        
customer_returns as(
select c.customer_id,c.customer_name,sum(r.amount) as returnvalue
        from customers c
        inner join orders o
        on c.customer_id=o.customer_id
        left join returns r
        on o.order_id = r.order_id
        group by c.customer_id,c.customer_name)

select co.customer_id,co.customer_name,co.ordervalue,cr.returnvalue,
				concat(Round(((COALESCE(cr.returnvalue,0)/co.ordervalue)*100),2),"%")as "Return %"
from customer_orderValue co
inner join customer_returns cr
on co.customer_id = cr.customer_id
order by ordervalue desc;

Select * from customers;
select * from Orders;
Select * from Sales;
Select * from products;
select * from categories;
select * from returns;
Desc orders;
Desc Sales;

																#10)Which products generate the highest sales volume?
                                                                
select p.product_id,p.product_name,coalesce(sum(s.quantity),0) as Sale_volume
from products p 
left join sales s
on p.product_id = s.product_id
group by p.product_id,p.product_name
order by sale_volume Desc;

																	#11)Which category products generate the highest sales volume?
                                                                
select c.category_id,c.category_name,coalesce(sum(s.quantity),0) as Sale_volume,
sum(s.amount) as Revenue from categories c
inner join products p
on c.category_id = p.category_id
left join sales s
on p.product_id = s.product_id
group by c.category_id,c.category_name
order by sale_volume Desc;

CREATE VIEW v_monthly_revenue_summary AS
SELECT 
    YEAR(sale_date) AS sales_year,
    MONTH(sale_date) AS sales_month,
    DATE_FORMAT(sale_date, '%b-%y') AS Month,
    ROUND(SUM(amount), 0) AS Total_Revenue
FROM sales
GROUP BY YEAR(sale_date), MONTH(sale_date), DATE_FORMAT(sale_date, '%b-%y');

SELECT * FROM v_monthly_revenue_summary ORDER BY sales_year, sales_month;


CREATE VIEW v_customer_revenue_summary AS
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS Total_Orders,
    ROUND(SUM(o.amount), 0) AS Total_Revenue,
    ROUND(AVG(o.amount), 2) AS Avg_Order_Value
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;
 
-- Usage:
SELECT * FROM v_customer_revenue_summary ORDER BY Total_Revenue DESC LIMIT 10;