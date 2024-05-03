create table df_orders(
         [order_id] int primary key,
		 [order_date] date,
		 [ship_mode] varchar(20),
		 [segment] varchar(20),
		 [country] varchar(20),
		 [city] varchar(20),
		 [state] varchar(20),
		 [postal_code] varchar(20),
		 [region] varchar(20),
		 [category] varchar(20),
		 [sub_category] varchar(20),
		 [product_id] varchar(20),
		 [quantity] int,
		 [discount] decimal(7,2),
		 [sale_price] decimal(7,2),
		 [profit] decimal(7,2))

select * from df_orders;

--find top 10 highest reveue generating products 
select top 10 product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc

--find top 5 highest selling products in each region
with ct1 as(
    select region, product_id, sum(sale_price) as sales
    from df_orders
    group by region, product_id
    
)
select * from (
select * , rank() over(partition by region order by sales desc) as rnk
from ct1) A
where rnk<=5;

--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with ct1 as(
   select year(order_date) as years, month(order_date) as months, sum(sale_price) as sales from df_orders
   group by year(order_date),  month(order_date)
)
select  ct1.months, 
        sum(case when years=2022 then sales else 0 end) sales_2022, 
		sum(case when years=2023 then sales else 0 end) sales_2023
		from ct1
		group by months;

--for each category which month had highest sales 
with ct1 as(
select category, format(order_date,'yyyyMM') as months , sum(sale_price) as sales from df_orders
group by category, format(order_date,'yyyyMM')
)
select * from(
select *, row_number() over(partition by category order by sales desc) as rn from ct1
) A 
where rn=1;


--which sub category had highest growth by profit in 2023 compare to 2022
with ct1 as(
select sub_category, year(order_date) as years , sum(sale_price) as tot from df_orders
group by sub_category, year(order_date)
)
select top 1 sub_category, sum(case when years=2022 then tot else 0 end) pr_2022,
       sum(case when years=2023 then tot else 0 end) pr_2023, 
	   sum(case when years=2023 then tot else 0 end) - sum(case when years=2022 then tot else 0 end) as profit
	   from ct1
	   group by sub_category
	   order by 4 desc;
