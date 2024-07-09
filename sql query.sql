-- Q1 > Total number of orders placed.
-- Ans> 21350 orders
SELECT 
    COUNT(order_id)
FROM
    orders;

-- Q2 > Total Revenue generated from store 
-- ANS> Rs.817860
select round(sum(a.quantity*b.price),2) as tot_revenue from order_details as a 
join pizzas as b 
on	a.pizza_id = b.pizza_id;

-- Q3> Highest priced pizza 
-- Ans> 'The Greek Pizza', '35.95'
SELECT a.name, b.price FROM pizza_types AS a
        JOIN pizzas AS b 
        ON a.pizza_type_id = b.pizza_type_id
		ORDER BY b.price DESC
		LIMIT 1;

-- Q4> Most common pizza size ordered
-- ans> L	18526
select a.size, count(b.quantity) from pizzas as a
join order_details as b 
on a.pizza_id = b.pizza_id
group by 1
order by count(b.quantity) desc;

-- Q5> LIST 5 MOST ORDERED PIZZA TYPES WITH QTY
select a.name, count(b.quantity) as qty from pizza_types as a 
join pizzas as c  
on a.pizza_type_id = c.pizza_type_id
join order_details as b 
on c.pizza_id = b.pizza_id
group by 1
order by 2 desc
limit 5;

-- Q6> FIND TOTAL QTY OF EACH PIZZA CATEGORY ORDERED 
Select sum(a.quantity), b.category from order_details as a
join pizzas as c 
on a.pizza_id = c.pizza_id
join pizza_types as b 
on c.pizza_type_id = b.pizza_type_id
group by 2;

-- Q7> DISTRIBUTION OF ORDERS BY HOUR OF THE DAY 
SELECT count(order_id) as tot_orders , HOUR(time) FROM orders
group by HOUR(time);

-- Q8> CATEGORY-WISE DISTRIBUTION OF PIZZAS 
SELECT a.category, count(b.order_id) as tot_count FROM pizza_types as a
JOIN pizzas as c
on a.pizza_type_id = c.pizza_type_id
JOIN order_details as d
on c.pizza_id = d.pizza_id
join orders as b 
on d.order_id = b.order_id
GROUP BY 1;

-- Q9> CALCULATE AVG NUMBERS OF PIZZA ORDERED PER DAY
WITH AA AS 
(
SELECT A.date, sum(B.quantity) AS QTY FROM orders AS A
JOIN order_details AS B 
ON A.order_id = B.order_id
group by 1
)
select avg(QTY) from AA;

-- Q10> FIND MOST ORDERED PIZZA NAME BASED ON REVENUE
select a.name, round(sum(c.quantity*b.price),2) as revenue from pizza_types as a 
join pizzas as b
ON a.pizza_type_id = b.pizza_type_id
join order_details as c
on b.pizza_id = c.pizza_id
group by 1
order by 2 desc;

-- Q11> PERCENTAGE CONTRIBUTION OF EACH PIZZA CATEGORY  TO TOTAL REVENUE 
with aa as 
(
	select a.category as cat, round(sum(b.price*c.quantity),2) as Trevenue from  pizza_types as a 
	Join pizzas as b 
	on a.pizza_type_id = b.pizza_type_id
	join order_details as c
	on b.pizza_id = c.pizza_id
	group by 1
)
select cat, (Trevenue/(select sum(Trevenue) from AA))*100.0 as Total_rev from aa;

-- Q12> ANALYZE CUMMULATIVE REVENUE GENERATED 
with aa as 
(
	SELECT a.date as date, round(sum(b.price*d.quantity),2) AS revenue from orders as a 
	join order_details as d
	on a.order_id = d.order_id
	join pizzas as b 
	on b.pizza_id = d.pizza_id
	group by 1
)
select date, revenue, sum(revenue) over (partition by date order by date) as cum_revenue from aa;

-- Q13> Top 3 most ordered pizza name based on revenue, for each pizza category 
with BB as 
(
with AA as
(
	select a.category, a.name, round(sum(b.price*c.quantity),2) as revenue from pizza_types as a 
	join pizzas as b 
	on a.pizza_type_id = b.pizza_type_id
	join order_details as c
	on c.pizza_id = b.pizza_id
	group by 1,2
)
select category, name, revenue, row_number()over(partition by category order by revenue desc) as rankk from AA
)
select category, name, revenue from BB
where rankk<=3;
 