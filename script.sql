-- QUERY 1 :
drop table emp;
create table emp
( emp_ID int
, emp_NAME varchar(50)
, SALARY int);

insert into emp values(101, 'Mohan', 40000);
insert into emp values(102, 'James', 50000);
insert into emp values(103, 'Robin', 60000);
insert into emp values(104, 'Carol', 70000);
insert into emp values(105, 'Alice', 80000);
insert into emp values(106, 'Jimmy', 90000);

with cte1 (average_salary) as (
	SELECT round(avg(salary), 0) 
	from emp
)
select e.emp_name, e.salary, c.average_salary
from emp e join cte1 c on e.salary > c.average_salary;

select * from emp;

with avg_sal(avg_salary) as
		(select avg(salary)::int from emp)
select *
from emp e
join avg_sal av on e.salary > av.avg_salary

-- QUERY 2 :
DROP table sales;
create table sales
(
	store_id  		int,
	store_name  	varchar(50),
	product			varchar(50),
	quantity		int,
	cost			int
);
insert into sales values
(1, 'Apple Originals 1','iPhone 12 Pro', 1, 1000),
(1, 'Apple Originals 1','MacBook pro 13', 3, 2000),
(1, 'Apple Originals 1','AirPods Pro', 2, 280),
(2, 'Apple Originals 2','iPhone 12 Pro', 2, 1000),
(3, 'Apple Originals 3','iPhone 12 Pro', 1, 1000),
(3, 'Apple Originals 3','MacBook pro 13', 1, 2000),
(3, 'Apple Originals 3','MacBook Air', 4, 1100),
(3, 'Apple Originals 3','iPhone 12', 2, 1000),
(3, 'Apple Originals 3','AirPods Pro', 3, 280),
(4, 'Apple Originals 4','iPhone 12 Pro', 2, 1000),
(4, 'Apple Originals 4','MacBook pro 13', 1, 2500);

select * from sales;

select *, ROW_NUMBER() over (order by cost) as ranking from sales;

select *, round(avg(cost) over (PARTITION by store_id), 0) as average_per_store from sales;

select POSITION('Pro' in product) from sales;

select sum(
	case
		when LEFT(product, 6) = 'iPhone' then cost
		else 0
	end
) as ip_cost from sales;

select round(avg(
	case
		when cost >= 2000 then cost 
	end
), 0) as overprice_value
from sales;

SELECT store_name, case 
	when cost > 1000 then 'OVER PRICE'
	else 'HOP LY'
end as status from sales;

SELECT cast(cost as int) from sales;

select cost::int from sales;

select COALESCE(cost, 0) as cost_custom from sales;

with total_all_stores as (
	SELECT store_id, round(sum(cost), 0) as sum_per_store
	from sales group by store_id
),
average_all_stores as (
	select round(avg(sum_per_store), 0) as avg_per_store
	from total_all_stores
)
select l1.store_id, l1.sum_per_store, l2.avg_per_store
from total_all_stores l1 inner join average_all_stores l2 on l1.sum_per_store > l2.avg_per_store;

select cost / NULLIF(quantity, 0) as ratio
from sales;

-- Find total sales per each store
select s.store_id, sum(s.cost) as total_sales_per_store
from sales s
group by s.store_id;


-- Find average sales with respect to all stores
select cast(avg(total_sales_per_store) as int) avg_sale_for_all_store
from (select s.store_id, sum(s.cost) as total_sales_per_store
	from sales s
	group by s.store_id) x;

-- Find stores who's sales where better than the average sales accross all stores
select *
from   (select s.store_id, sum(s.cost) as total_sales_per_store
				from sales s
				group by s.store_id
	   ) total_sales
join   (select cast(avg(total_sales_per_store) as int) avg_sale_for_all_store
				from (select s.store_id, sum(s.cost) as total_sales_per_store
		  	  		from sales s
			  			group by s.store_id) x
	   ) avg_sales
on total_sales.total_sales_per_store > avg_sales.avg_sale_for_all_store;

-- Using WITH clause
WITH total_sales as
		(select s.store_id, sum(s.cost) as total_sales_per_store
		from sales s
		group by s.store_id),
	avg_sales as
		(select cast(avg(total_sales_per_store) as int) avg_sale_for_all_store
		from total_sales)
select *
from   total_sales
join   avg_sales
on total_sales.total_sales_per_store > avg_sales.avg_sale_for_all_store;

select *, ROW_NUMBER() over(order by cost desc) as ranking
from sales; 

-- per store ranking
select *, ROW_NUMBER() over(PARTITION by store_id order by cost) as ranking_in_store from sales; -- PARTITION by must in before ORDER BY
select *, sum(cost) over(PARTITION by store_id) as sum_per_store
from sales;

with ranked as (
	select *, ROW_NUMBER() over(PARTITION by store_id order by cost desc) as rank
	from sales
)
select * from ranked where rank = 1;

select *, ROW_NUMBER() over (order by cost desc) as ranking_global
from sales;

select *, avg(cost) over(PARTITION by store_id)::int as avg_per_store from sales;

select *, ROW_NUMBER() over(PARTITION by store_id ORDER by cost desc) as ranking_per_store from sales;

-- rank()
select *, rank() over(order by cost desc) as rank_include_tie
from sales;

-- rank() with per store
select *, rank() over(PARTITION by store_id ORDER by cost) as rank_tie_per_store from sales;

-- dense_rank()
SELECT *, DENSE_RANK() over(ORDER by cost) as dense_rank_global
from sales;

-- lag(column)
SELECT *, lag(cost) over (order by cost) as prev_row_cost
from sales;

-- find diff
SELECT *, cost - lag(cost, 1) over(order by cost) as diff_2rows -- lag(col, num_of_row_back, default_value if not want null)
from sales;

-- lead(column)
select *, lead(cost) over(order by cost) as next_cost_row from sales;

-- trunc
select trunc(12.9876);
select trunc(12.9876, 2);
select trunc(12.9876, 0);
