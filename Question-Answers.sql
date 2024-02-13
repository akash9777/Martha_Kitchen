
--This case study includes some set of questions which are listed below-
--1. What is the total amount each customer spent at the restaurant?
--2. How many days has each customer visited the restaurant?
--3. What was the first item from the menu purchased by each customer?
--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
--5. Which item was the most popular for each customer?
--6. Which item was purchased first by the customer after they became a member?
--7. Which item was purchased just before the customer became a member?
--8. What is the total items and amount spent for each member before they became a member?
--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

--####Important Point-Do not be confused with keyword "Martha_Kitchen" used in the code. This is the name of database.

--1. What is the total amount each customer spent at the restaurant?

select 
customer_id ,
sum(price) as Total_Spent
from martha_kitchen.sales S
join martha_kitchen.menu M
on M.product_id=S.product_id
group by customer_id
;



--2. How many days has each customer visited the restaurant?

select 
customer_id,
 count(distinct order_date) as Days_visited
from martha_kitchen.sales
group by customer_id
;



--3. What was the first item from the menu purchased by each customer?

with temp as (
select 
customer_id,
product_name,
rank() over( 
partition by customer_id
order by order_date
) as Rank_
from martha_kitchen.sales S
join martha_kitchen.menu M
on M.product_id=S.product_id
)
select customer_id,
product_name
 from temp
 where rank_=1
 ;
 
 
 
--4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select 
product_name ,
count(*) as total_ordered
from martha_kitchen.sales S
join martha_kitchen.menu M
on S.product_id=M.product_id
group by product_name
order by total_ordered desc
limit 1
;



--5. Which item was the most popular for each customer?

with temp as (
select 
customer_id,
product_name,
count(*) as Number_of_times_ordered,
rank() over (
partition by customer_id
order by count(*) desc
) as Rank_
from martha_kitchen.sales S
join martha_kitchen.Menu M
on S.product_id=M.product_id
group by customer_id, product_name
)
select customer_id, 
product_name ,
total_ordered
from temp
where rank_=1
;



--6. Which item was purchased first by the customer after they became a member?

with temp as (
select 
S.customer_id,
product_name,
order_date,
rank() over (
partition by customer_id
order by order_date
) as rank_

from martha_kitchen.sales S
join martha_kitchen.menu M
on S.product_id=M.product_id
join martha_kitchen.members MM
on MM.customer_id=S.customer_id
where order_date>=join_date
group by customer_id, product_name, order_date
)
select Customer_id, Product_name
from temp where rank_=1
;



--7. Which item was purchased just before the customer became a member?

with record as (
select 
MM.customer_id,
product_name,
order_date,
join_date,
rank() over(
partition by customer_id
order by order_date desc
) as Rank_

from martha_kitchen.sales S
join martha_kitchen.menu M
on S.product_id=M.product_id
join martha_kitchen.members MM
on MM.customer_id=S.customer_id

where order_date< join_date
)
select customer_id,
product_name,
order_date,
join_date
 from record
 where rank_=1
;


--8. What is the total items and amount spent for each member before they became a member?

select 
MM.customer_id,
count(M.product_id) as Total_products_bought,
sum(price) as Total_expenditure

from martha_kitchen.sales S
join martha_kitchen.menu M
on M.product_id=S.product_id
join martha_kitchen.members MM
on MM.customer_id=S.customer_id
where order_date < join_date
group by customer_id
;


--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
select 
Customer_id,
sum(
case 
    when product_name="sushi"  then (price*20)
    else (price*10)
end    
) as Points
from martha_kitchen.sales S
join martha_kitchen.menu M
on S.product_id=M.product_id
group by customer_id
;



