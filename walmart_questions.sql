select * from walmart

-- Business Problems
--Q.1 Find different payment method and number of transactions, number of qty sold
select payment_method,
	count(*) as no_of_payments,
	sum(quantity) as total_quantity
from walmart 
group by payment_method;

--Question #2
-- Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING
select * from (
select branch, 
	category, 
	dense_rank() over(partition by branch order by avg(rating) desc) as rank
from walmart 
group by 1,2 
)
where rank=1

-- Q.3 Identify the busiest day for each branch based on the number of transactions
select * from (
select branch, 
	   TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
	rank() over(partition by branch order by count(*) desc) as rank 
	from walmart
	group by 1,2
) 
where rank=1; 


-- Q. 4 
-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.
select * from walmart;
select sum(quantity) as total_quantity, payment_method from walmart group by payment_method; 

-- Q.5
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.
select city, 
	category,
	round(avg(rating)::numeric,2) as average_rating, 
	min(rating) as minimum_rating, 
	max(rating) as maximum_rating 
from walmart 
group by 1,2;

-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.
select * from walmart;
select category, 
	round(sum(total)::numeric,2) as total_revenue, 
	round(sum(total*profit_margin)::numeric,2) as total_profit 
from walmart 
group by 1 
order by 3 desc;


-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.
select branch,
	payment_method 
from (
		select branch, 
		payment_method,
		rank() over(partition by branch order by count(payment_method) desc) as something 
		from walmart 
		group by 1,2
)
where something = 1;



-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

select 
	branch,
ase 
		when extract (hour from(time::time)) < 12 then 'Morning'
		when extract(hour from(time::time)) between 12 and 17 then 'Afternoon'
		else 'Evening'
	end day_time,
	count(*)
from walmart
group by 1, 2
order by 1, 3 desc

-- #9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100
select * from walmart;

with revenue_2022 
as
( select branch, 
		sum(total) as revenue 
		from walmart 
		where extract(year from to_date(date, 'YY/MM/DD')) = 2022 
		group by 1
),
revenue_2023 as(
		select branch, 
		sum(total) as revenue 
		from walmart 
		where extract(year from to_date(date, 'YY/MM/DD')) = 2023
		group by 1
)
select ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as current_year_revenue,
	round((cs.revenue- ls.revenue)::numeric/ls.revenue::numeric*100,2) as rev_dec_ratio
from revenue_2022 as ls
join revenue_2023 as cs
on ls.branch = cs.branch
where ls.revenue>cs.revenue 
order by 4 desc
limit 5

