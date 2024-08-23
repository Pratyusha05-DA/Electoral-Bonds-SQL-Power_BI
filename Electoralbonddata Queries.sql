create database project;
use project;
select * from data;
set sql_safe_updates=0;
select str_to_date(date,'%m/%d/%y');

alter TABLE data
change `invoice id` ID VARCHAR(30);
alter TABLE data
change `unit price` unit_price double;
alter TABLE data
change `customer type` customer_type VARCHAR(30),
change `product line` product_line VARCHAR(30),
change `tax 5%` VAT DOUBLE,
change `GROSS MARGIN PERCENTAGE` graoss_percent double,
change `gross income` gross_income double;

alter TABLE data
change graoss_percent gross_percent double;

alter table data
ADD time_of_day TEXT;
update data
set time_of_day=case
	when HOUR(time) < 12 then 'Morning'
    when HOUR(time) < 18 then 'Afternoon'
    else 'Evening'
    end;

alter table data
add date_name text;
update data
set date_name=dayname(str_to_date(date,'%m/%d/%Y'));

alter table data
change date_name day_name text;

alter table data
ADD month_name TEXT;
update data
set month_name=monthname(str_to_date(date,'%m/%d/%Y'));

/* 1. How many unique cities does the data have? */
SELECT count(distinct city) as unique_city FROM DATA;

/* 2. In which city is each branch? */
SELECT branch , city
FROM data
GROUP BY branch , city;


--/* PRODUCT */

/* 1. How many unique product lines does the data have? */
SELECT count(distinct product_line) AS unique_product_line from data;

/* 2. What is the most common payment method? */
select max(payment) AS common_payment_method
from data;

/* 3. What is the most selling product line? */
SELECT product_line,sum(quantity) as total_sold FROM data
group by product_line
order by sum(quantity) desc
limit 1;

/* 4. What is the total revenue by month? */
select month_name,sum(total) as total_revenue
from data
group by month_name;

/* 5. What month had the largest COGS? */
select month_name,max(sum_of_cogs) as largest_COGS from 
(select month_name, sum(cogs) as sum_of_cogs from data
group by month_name ) as total_cogs
group by month_name;

/* 6. What product line had the largest revenue? */
select product_line,max(total) as largest_revenue
from data group by product_line
order by max(total) DESC ;

/* 7. What is the city with the largest revenue? */
select city,max(total_) as largest_revenue
from (select city, sum(total) as total_ from data group by city) as sub_query
group by city order by largest_revenue desc;

/* 8. What product line had the largest VAT? */
select product_line,max(total_VAT) as largest_vat from (select product_line,sum(VAT) as total_VAT from data 
group by product_line) as vat_ group by product_line
order by largest_vat desc;

/* 9. Fetch each product line and add a column to those product line 
showing "Good","Bad" .Good if its greater than average sales */
select product_line, count(quantity) as total_sales,
case  
	when count(quantity) > avg(quantity) then "Good"
    else "bad" 
    end "type"
    from data
group by product_line
order by total_sales desc;

/* 10. Which branch sold more products than average product sold? */
select branch,sum(quantity), avg(total) from data
group by branch
having sum(quantity) > (select avg(total) from data)
order by sum(quantity) desc;

/* 11. What is the most common product line by gender? */
WITH ranked_productlines AS (
    SELECT gender, product_line,
	COUNT(*) AS total_sales,
	ROW_NUMBER() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS rn
    FROM data
    GROUP BY gender, product_line)
SELECT gender, product_line, total_sales
FROM ranked_productlines
WHERE rn = 1;

/* 12. What is the average rating of each product line? */
select product_line, round(avg(rating),1) as avg_rating from data
group by product_line;


--/* SALES */

/* 1. Number of sales made in each time of the day per weekday */
SELECT day_name,time_of_day,sum(quantity) as total_sales from data
group by day_name,time_of_day
having day_name in ('monday','tuesday','wednesday','thursday','friday');

/* 2. Which of the customer types brings the most revenue? */
select customer_type,max(total_) as most_paid_revenu from (select customer_type,sum(total) as total_ from data 
group by customer_type) as tab
group by customer_type;

/* 3. Which city has the largest tax percent/ VAT (Value Added Tax)? */
select city, max(_vat) as maximum_vat from (select city, sum(vat) as _vat from data
group by city) as va
group by city;

/* 4. Which customer type pays the most in VAT? */
select customer_type, max(m_vat) as maximum_vat from (select customer_type, sum(vat) as m_vat 
from data group by customer_type) as va
group by customer_type;


--/* CUSTOMER */ 

/* 1. How many unique customer types does the data have? */
SELECT distinct CUSTOMER_TYPE as unique_customers FROM DATA;

/* 2. How many unique payment methods does the data have? */
SELECT distinct payment as unique_payments FROM DATA;

/* 3. What is the most common customer type? */
SELECT customer_type,count(customer_type) as total_customers FROM DATA
group by customer_type
order by count(customer_type) desc;

/* 4. Which customer type buys the most? */
SELECT customer_type,sum(quantity) as purchases FROM DATA
group by customer_type
order by sum(quantity) desc;

/* 5. What is the gender of most of the customers? */
SELECT gender,count(gender) as total_customers FROM DATA
group by gender
order by count(gender) desc;

/* 6. What is the gender distribution per branch? */
SELECT distinct branch, gender, count(gender) as total_customers FROM DATA
group by branch,gender 
order by branch;

/* 7. Which time of the day do customers give most ratings? */
SELECT time_of_day,count(rating) as most_rated FROM DATA
group by time_of_day
order by count(rating) desc
limit 3;

/* 8. Which time of the day do customers give most ratings per branch? */
with a as(SELECT branch,time_of_day,count(rating) as most_rated FROM DATA
group by time_of_day,branch),
max_rate as (select branch,max(most_rated) as max_rated from a
group by branch)
select a.branch,a.time_of_day,a.most_rated
from a
join max_rate m
on a.branch = m.branch and a.most_rated= m.max_rated;

/* 9. Which day of the week has the best avg ratings? */
SELECT day_name,avg(rating) as avg_rating FROM DATA
group by day_name
order by avg_rating desc
limit 3;

/* 10. Which day of the week has the best average ratings per branch? */
with a as(SELECT branch,day_name,count(rating) as most_rated FROM DATA
group by day_name,branch),
max_rate as (select branch,max(most_rated) as max_rated from a
group by branch)
select a.branch,a.day_name,a.most_rated
from a
join max_rate m
on a.branch = m.branch and a.most_rated= m.max_rated;

/*************************************************************************
== My conclusion after looking into the result of the queries == 
1. According to sales, 
	-- Product like Electronic accessories are sold highest,
    -- A,B,C branches sold more than avg sales
    -- Yangon sold the highest product home and lifestyle
    -- January has highest sales on sports and travel
    -- sunday afternoon there are more sales in branch A 
    -- MEMBER customers and females purchase a lot
2. According to revenue,
	-- Fashion and accessories has highest revenue 1042.65
	-- Naypyitaw has highest revenue 1042.65
	-- JANUARY has highest revenue 116291.86
    -- MEMBER type of customer brings more revenue than NORMAL customers 
3. VAT - amount of tax on purchase,
    -- Highest VAT is on fashion and accessories
    -- Naypyitaw has highest VAT on its product_line
    -- MEMBER type of customers and females pay more VAT
4. Acoording to rating,
	-- During afternoon sports and travel is rated most w.r.t product_line 
    -- Monday has highest average 7.1 rating, w.r.t branch "B" has highest 7.3
    -- Fashion and accessiories are rated most w.r.t branch A
    -- On monday MEMBER type of customer has given highest rating 7.5
	-- Normal customer gave hight rating in branch c
5. In branch "A" and "B" males and more and in "C" female customers are more
    
*************************************************************************/




