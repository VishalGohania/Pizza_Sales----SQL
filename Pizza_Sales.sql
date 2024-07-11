create database pizzahut;


create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id));


create table orders_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null, 
primary key(order_details_id));

-- QUESTIONS

-- Retrieve the total number of orders placed.

select count(*) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales.

select round(sum((od.quantity * p.price)),2) as Total_revenue
from orders_details as od
join pizzas as p on p.pizza_id = od.pizza_id;

-- Identify the highest-priced pizza.

select pt.name, p.price
from pizza_types as pt 
join pizzas as p on pt.pizza_type_id = p.pizza_type_id
order by p.price desc
limit 1;

-- Identify the most common pizza size ordered.

select p.size, count(od.order_details_id) as count_of_pizza_size
from pizzas as p
join orders_details as od on od.pizza_id = p.pizza_id
group by p.size
order by count_of_pizza_size desc;

-- List the top 5 most ordered pizza types along with their quantities.

select pt.name, sum(od.quantity) as quantities
from pizza_types as pt
join pizzas as p on p.pizza_type_id = pt.pizza_type_id
join orders_details as od on od.pizza_id = p.pizza_id
group by pt.name
order by quantities desc
limit 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pt.category, sum(od.quantity) as quantity
from pizza_types as pt
join pizzas as p on p.pizza_type_id = pt.pizza_type_id
join orders_details as od on od.pizza_id = p.pizza_id
group by pt.category
order by quantity desc;

-- Determine the distribution of orders by hour of the day.

select hour(order_time) as hour, count(order_id) as order_count
from orders
group by hour;

-- Join relevant tables to find the category-wise distribution of pizzas.

select category, count(name) as category_count
from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantity),0) as avg_pizzas_ordered_per_day from 
	(select o.order_date, sum(od.quantity) as quantity
	from orders as o
	join orders_details as od on od.order_id = o.order_id
	group by o.order_date) as order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue.

select pt.name, sum(od.quantity * p.price) as revenue
from pizza_types as pt
join pizzas as p on p.pizza_type_id = pt.pizza_type_id
join orders_details as od on od.pizza_id = p.pizza_id
group by pt.name
order by revenue desc
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

select pt.category, 
round(sum(od.quantity * p.price)/ (select 
	round(sum(od.quantity * p.price),2) as total_sales
    from orders_details as od
    join pizzas as p on p.pizza_id = od.pizza_id) *100,2)
    as revenue
from pizza_types as pt
join pizzas as p on p.pizza_type_id = pt.pizza_type_id
join orders_details as od on od.pizza_id = p.pizza_id
group by pt.category
order by revenue desc;

-- Analyze the cumulative revenue generated over time.

select order_date, 
sum(revenue) over(order by order_date) as cum_revenue
from (
	select o.order_date, 
	sum(od.quantity * p.price) as revenue
	from orders_details as od 
	join pizzas as p on p.pizza_id = od.pizza_id
	join orders as o on o.order_id = od.order_id
	group by o.order_date) as sales;
    
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue 
from
	(select category, name, revenue,
	rank() over(partition by category order by revenue desc) as rnk
	from
		(select pt.category, pt.name, 
		sum(od.quantity * p.price) as revenue
		from pizza_types as pt
		join pizzas as p on p.pizza_type_id = pt.pizza_type_id
		join orders_details as od on od.pizza_id = p.pizza_id
		group by pt.category, pt.name) as a) as b
where rnk <=3;

