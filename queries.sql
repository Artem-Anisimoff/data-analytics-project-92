SELECT COUNT(customer_id) AS customers_count
FROM customers;

/* top_10_total_income.csv */
SELECT CONCAT(emp.first_name, ' ', emp.last_name) AS seller,
       COUNT(s.sales_person_id) AS operations,
       TRUNC(SUM(s.quantity * p.price), 0) AS income
FROM sales AS s
INNER JOIN employees AS emp ON s.sales_person_id = emp.employee_id
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY emp.first_name,
         emp.last_name
ORDER BY income DESC
LIMIT 10;

/* lowest_average_income.csv */
SELECT CONCAT(e.first_name, ' ', e.last_name) AS seller,
       trunc(AVG(s.quantity * p.price), 0) AS average_income
FROM sales AS s
INNER JOIN employees AS e ON s.sales_person_id = e.employee_id
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY e.first_name,
         e.last_name
HAVING AVG(s.quantity * p.price) <
  (SELECT AVG(s2.quantity * p2.price)
   FROM sales AS s2
   INNER JOIN products AS p2 ON s2.product_id = p2.product_id)
ORDER BY average_income /* day_of_the_week_income.csv */
SELECT CONCAT(emp.first_name, ' ', emp.last_name) AS seller,
       TO_CHAR(s.sale_date, 'day') AS day_of_week,
       TRUNC(SUM(s.quantity * p.price), 0) AS income
FROM sales AS s
INNER JOIN employees AS emp ON s.sales_person_id = emp.employee_id
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY emp.first_name,
         emp.last_name,
         TO_CHAR(s.sale_date, 'day'),
         EXTRACT(ISODOW
                 FROM s.sale_date)
ORDER BY EXTRACT(ISODOW
                 FROM s.sale_date),
         seller;

/* age_groups.csv */
SELECT CASE
           WHEN age BETWEEN 16 AND 25 THEN '16-25'
           WHEN age BETWEEN 26 AND 40 THEN '26-40'
           WHEN age BETWEEN 41 AND 100 THEN '40+'
       END AS age_category,
       COUNT(*) AS age_count
FROM customers
GROUP BY age_category
ORDER BY age_category;

/* customers_by_month.csv */
SELECT TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
       COUNT(DISTINCT s.customer_id) AS total_customers,
       TRUNC(SUM(s.quantity * p.price), 0) AS income
FROM sales AS s
INNER JOIN products AS p ON s.product_id = p.product_id
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY TO_CHAR(s.sale_date, 'YYYY-MM');

/* special_offer.csv */
WITH sale_number AS
  (SELECT s.customer_id,
          s.sale_date,
          s.sales_person_id,
          ROW_NUMBER() OVER (PARTITION BY s.customer_id
                             ORDER BY s.sale_date) AS sale_number
   FROM sales AS s
   INNER JOIN products AS p ON s.product_id = p.product_id
   WHERE p.price = 0)
SELECT sn.sale_date,
       CONCAT(c.first_name, ' ', c.last_name) AS customer,
       CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM sale_number AS sn
INNER JOIN customers AS c ON sn.customer_id = c.customer_id
INNER JOIN employees AS e ON sn.sales_person_id = e.employee_id
WHERE sn.sale_number = 1
ORDER BY sn.customer_id;