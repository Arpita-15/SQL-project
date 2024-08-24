-- Retrieve the total number of orders placed
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
    
-- calculate the total revenue generated from pizza sales

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- Identify the highest- priced pizza
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- identify the most common pizza size ordered

select pizzas.size, count(order_details.order_details_id) as order_count
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id 
group by pizzas.size
order by order_count desc;

-- list the top 5 most ordered pizza types along with their quantities
select pizza_types.name,
sum(order_details.quantity) as quantity
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by quantity desc
limit 5;
    

-- join the necessary tables to find the total quantity of each pizza category ordered
select pizza_types.category,
sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details 
on order_details.pizza_id =pizzas.pizza_id
group by pizza_types.category 
order by quantity desc;

-- determine the distribution of orders by hour of the day
select hour(order_time) as hour ,
count(order_id) as order_count 
from orders
group by hour(order_time)
order by count(order_id) desc;

-- join relevant tables to find the category-wise distribution of pizzas
select category, count(name) 
from pizza_types 
group by category;

-- group the orders by date and calculate the avg number of pizzas ordered per day
select orders.order_date, 
sum(order_details.quantity) as order_quantity
from orders join order_details
on orders.order_id=order_details.order_id
group by orders.order_date;

select round(avg(order_quantity),0) as avg_orders from
(select orders.order_date, 
sum(order_details.quantity) as order_quantity
from orders join order_details
on orders.order_id=order_details.order_id
group by orders.order_date) as order_quantity;

-- determine the top 3 most ordered pizza types based on revenue
select pizza_types.name, 
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details 
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.name
order by revenue desc
limit 3;

-- calculate the percentage contribution of each pizza type to total revenue
select pizza_types.category, 
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details 
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category
order by revenue desc
limit 3;

# TO FIND PERCENTAGE -> divide the query by total revenue genertared * 100
select pizza_types.category, 
round(sum(order_details.quantity * pizzas.price) /(SELECT ROUND(SUM(order_details.quantity * pizzas.price),2) 
AS total_sales FROM order_details JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id)* 100 ,2)as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details 
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category
order by revenue desc
limit 3;

-- analyze the cumulative revenue generated over time
/*CUMULATIVE
DAY 1 200 TOTAL 200
DAY 2 300 TOTAL 500
DAY 3 100 TOTAL 600*/

select orders.order_date, 
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id
join orders
on orders.order_id=order_details.order_id
group by orders.order_date;

# WE HAVE TO MAKE IT CUMULATIVE

select order_date,
sum(revenue) over(order by order_date) as cumu_revenue
from 
(select orders.order_date, 
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id
join orders
on orders.order_id=order_details.order_id
group by orders.order_date) as sales;
    
-- determine the top 3 most ordered pizza types based on revenue for each pizza category
select pizza_types.category,
pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category, pizza_types.name;
    
# TO GIVE RANKING

select name,revenue from
(select category,name, revenue,
rank() over(partition by category order by revenue desc) as rn
from 
(select pizza_types.category,
pizza_types.name,
sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category, pizza_types.name)
as det) as deta
where rn <=3;
    
    
    
    