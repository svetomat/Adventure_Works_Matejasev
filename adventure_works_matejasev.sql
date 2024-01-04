use adventure_works

-- first overview of the table

select SalesOrderNumber
from orders_aw;

select distinct Sales_Person
from sales_aw
where Sales_Region <> 'United States';
    
-- altering tables	

select distinct
	sales_aw.OrderDate
from
	sales_aw;
    
select
	year ('OrderDate') as DateYear
from
	sales_aw;

alter table orders_aw
add column Total_Cost double;

update orders_aw
set Total_Cost = Unit_Cost + Unit_Freight_Cost
where Unit_Cost <> 0;

select Total_Cost
from orders_aw;

alter table orders_aw
add column Total_Price int;

update orders_aw
set Total_Price = UnitPrice - (UnitPrice*UnitPriceDiscount)
where UnitPrice <> 0;

select Total_Price
from orders_aw;

alter table orders_aw
add column Profit double;

alter table orders_aw
add column Revenue double;

update orders_aw
set Revenue = Total_Price * OrderQty
where Total_Price <> 0;

select Revenue
from orders_aw;

update orders_aw
set Profit = Revenue - Total_Cost
where Revenue <> 0;

select 
	round(sum(Profit),2) as profit
from orders_aw;

select
Customer_Code,
Product_Code,
Revenue,
Total_Cost,
Profit
from orders_aw
order by 5 desc;

-- pivoting with count & case based on joins 

select distinctrow
	customers_aw.Customer_Name as company,
    customers_aw.Customer_Region as regions,
    orders_aw.Revenue,
    orders_aw.Total_Cost
from customers_aw
	left join orders_aw  on customers_aw.Customer_Code = orders_aw.Customer_Code
order by 3 desc;

select
	products_aw.Product_Category as category,
    count(distinct case when orders_aw.UnitPrice > 100 then orders_aw.Customer_Code else null end) as customers,
    count(distinct case when orders_aw.UnitPrice > 100 then orders_aw.OrderQty else null end) as quantity
from products_aw
	left join orders_aw on products_aw.Product_Code = orders_aw.Product_Code
group by 1;

select
	sales_aw.OrderDate,
    sum(case when orders_aw.OrderQty > 0 then orders_aw.OrderQty else null end) / 
    count(distinct case when orders_aw.OrderQty > 0 then orders_aw.Customer_Code else null end) as orders_per_customer,
    sum(case when orders_aw.OrderQty > 0 then orders_aw.Profit else null end) / 
    count(distinct case when orders_aw.OrderQty > 0 then orders_aw.Customer_Code else null end) as profit_per_customer
from sales_aw
	left join orders_aw on sales_aw.SalesOrderNumber = orders_aw.SalesOrderNumber
where orders_aw.OrderQty >
	(select avg(orders_aw.OrderQty) as avg_column
    from orders_aw)
group by 1
order by 2 desc;

-- ***top ten***

select
	customers_aw.Customer_Name,
    count(orders_aw.OrderQty) as num_of_orders,
    round(sum(orders_aw.Total_Cost),2) as cost,
    round(sum(orders_aw.Profit),2) as profit
from customers_aw
	left join orders_aw on customers_aw.Customer_Code = orders_aw.Customer_Code
group by 1
order by 4 desc
limit 10;
