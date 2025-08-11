SELECT 
	COUNT(customer_id) as customers_count
FROM customers;

--запрос считает количество покупателей

/*---------------------------------------------------------*/

--1 запрос

select 
	CONCAT(emp.first_name,' ',emp.last_name) as seller, --выбор имени фамилии
	count(s.sales_person_id) as operations, --кол-во операций
	sum(s.quantity * p.price ) as income --выручка
from sales as s
join employees as emp 
	on s.sales_person_id=emp.employee_id  
join products as p 
	on s.product_id=p.product_id  
group by emp.first_name , emp.last_name 
order by income
limit 10

--2 запрос
with seller_tab  as (
	select 
		CONCAT(e.first_name,' ',e.last_name) as seller, --выбор имени фамилии
		ROUND(AVG(s.quantity * p.price), 0) as average_income --средняя выручка за продажу
	from sales as s
	join employees as e
		on s.sales_person_id=e.employee_id  
	join products as p 
		on s.product_id=p.product_id  
	group by e.first_name , e.last_name
),
seller_avg as (
	select 
		ROUND(AVG(s.quantity * p.price), 0) as all_average
	from sales as s
	join products as p 
		on s.product_id=p.product_id
)

select 
st.seller, 
st.average_income
from seller_tab st
where st.average_income < (select all_average from seller_avg)
order by st.average_income 




--3 запрос

select 
	CONCAT(emp.first_name,' ',emp.last_name) as seller, --выбор имени фамилии
	TO_CHAR(s.sale_date, 'Day') AS day_of_week, --выбор по дням недели
	ROUND(SUM(s.quantity * p.price), 0) as income --выбор суммы продаж в день недели
from sales as s
join employees as emp 
	on s.sales_person_id=emp.employee_id  
join products as p 
	on s.product_id=p.product_id  
group by 
	emp.first_name ,
	emp.last_name,
	to_char(s.sale_date, 'Day'),
	EXTRACT(ISODOW FROM s.sale_date)
order by EXTRACT(ISODOW FROM s.sale_date), --соритровка по порядку дней недели
seller desc


/*----------------------6шаг---------------------------*/

with young as (
	select age
	from customers
	where age between 16 and 25
),                              --разделение на группы
average as (
	select age
	from customers
	where age between 26 and 40
),
old as (
	select age
	from customers
	where age between 41 and 100
)
select                          --вывод групп
	'16-25' as age_category,
	count(age) as age_count
from young 						

union all

select 
	'26-40' as age_category,
	count(age) as age_count
from average 

union all

select 
	'41+' as age_category,
	count(age) as age_count
from old



/*---------------------------------------------------------------*/

select 
	TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month, --выбор даты в формате год-месяц
	count(s.customer_id ) as total_customers, --кол-во покупателей
	round(sum(s.quantity * p.price ), 0) as income 
from sales as s
join products as p 
	on s.product_id = p.product_id 
group by TO_CHAR(sale_date, 'YYYY-MM') --группировка по дате
order by TO_CHAR(sale_date, 'YYYY-MM')

/*----------------------------------------------------------------*/


with sale_number as (
select 
	s.customer_id,
	s.sale_date,
	s.sales_person_id,
	ROW_NUMBER() OVER (partition by s.customer_id order by sale_date) AS sale_number
from sales as s
join products as p 
	on s.product_id = p.product_id 
where p.price = 0
) --нумерация всех 0 покупок

select 
	CONCAT(c.first_name,' ',c.last_name) as customer,
	sn.sale_date,
	CONCAT(e.first_name,' ',e.last_name) as seller
from sale_number sn
join customers c on sn.customer_id = c.customer_id
join employees e on sn.sales_person_id = e.employee_id
where sn.sale_number = 1 --выбор 1 нулевой покупки
order by sn.customer_id