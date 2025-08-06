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
select 
	CONCAT(emp.first_name,' ',emp.last_name) as seller, --выбор имени фамилии
	ROUND(SUM(s.quantity * p.price)/count(*), 0) as average_income --средняя выручка за продажу
from sales as s
join employees as emp 
	on s.sales_person_id=emp.employee_id  
join products as p 
	on s.product_id=p.product_id  
group by emp.first_name , emp.last_name
order by average_income 
limit 10


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
income desc
