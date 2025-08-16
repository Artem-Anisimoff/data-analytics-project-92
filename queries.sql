/* top_10_total_income.csv */
SELECT
    CONCAT(emp.first_name, ' ', emp.last_name) AS seller,
    COUNT(s.sales_person_id) AS operations,
    TRUNC(SUM(s.quantity * p.price), 0) AS income
FROM
    sales AS s
INNER JOIN
    employees AS emp
    ON s.sales_person_id = emp.employee_id
INNER JOIN
    products AS p
    ON s.product_id = p.product_id
GROUP BY
    emp.first_name,
    emp.last_name
ORDER BY
    income DESC
LIMIT 10;

/* day_of_the_week_income.csv */
SELECT
    CONCAT(emp.first_name, ' ', emp.last_name) AS seller,
    TO_CHAR(s.sale_date, 'day') AS day_of_week,
    TRUNC(SUM(s.quantity * p.price), 0) AS income
FROM
    sales AS s
INNER JOIN
    employees AS emp
    ON s.sales_person_id = emp.employee_id
INNER JOIN
    products AS p
    ON s.product_id = p.product_id
GROUP BY
    emp.first_name,
    emp.last_name,
    TO_CHAR(s.sale_date, 'day'),
    EXTRACT(ISODOW FROM s.sale_date)
ORDER BY
    EXTRACT(ISODOW FROM s.sale_date),
    seller;

/* customers_by_month.csv */
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    TRUNC(SUM(s.quantity * p.price), 0) AS income
FROM
    sales AS s
INNER JOIN
    products AS p
    ON s.product_id = p.product_id
GROUP BY
    TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY
    TO_CHAR(s.sale_date, 'YYYY-MM');


/* special_offer.csv */
WITH sale_number AS (
    SELECT
        s.customer_id,
        s.sale_date,
        s.sales_person_id,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.sale_date
        ) AS sale_number
    FROM
        sales AS s
    INNER JOIN
        products AS p
        ON s.product_id = p.product_id
    WHERE
        p.price = 0
)