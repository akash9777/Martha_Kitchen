select 
customer_id ,
sum(price)
from sales S
join menu M
on M.product_id=S.product_id
group by customer_id
;