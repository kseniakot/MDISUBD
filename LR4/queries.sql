SELECT p.name, price, pt.name as type,
m.name as manufacturer, m.country as country
FROM product p JOIN product_type pt
ON pt.id = p.product_type_id
JOIN manufacturer m ON m.id = p.manufacturer_id
WHERE pt.name = 'Pill'
  AND p.price BETWEEN 5 AND 10
  AND m.country = 'USA';
  /*
SELECT client.first_name, client.last_name, client_order.order_date, promocode.code
FROM client
JOIN client_order ON client.id = client_order.client_id
JOIN pharmacy ON client_order.pharmacy_id = pharmacy.id
JOIN promocode ON client_order.promocode_id = promocode.id
WHERE pharmacy.id = 5
  AND client_order.promocode_id IS NOT NULL;

SELECT name, price
FROM product
WHERE price > (SELECT AVG(price) FROM product);

SELECT pharmacy.id, address.street, address.building, pi.quantity
FROM pharmacy
JOIN address ON pharmacy.address_id = address.id
JOIN product_instance pi ON pharmacy.id = pi.pharmacy_id
WHERE pharmacy.id IN (
    SELECT pharmacy_id
    FROM product_instance
    WHERE product_id = (SELECT id FROM product WHERE name = 'Aspirin')
) AND  pi.product_id = (SELECT id FROM product WHERE name = 'Aspirin');

/*Найти заказы, в которых использован промокод с максимальной скидкой, и которые сделаны после определенной даты*/
SELECT client_order.id, client_order.order_date, client.first_name, client.last_name, promocode.code, promocode.discount
FROM client_order
JOIN client ON client_order.client_id = client.id
JOIN promocode ON client_order.promocode_id = promocode.id
WHERE promocode.discount = (SELECT MAX(discount) FROM promocode)
  AND client_order.order_date > '2023-01-01';

/*Найти топ-5 самых продаваемых продуктов по всем аптекам с указанием общего количества и общей выручки*/
SELECT p.name AS product_name, 
       SUM(oi.quantity) AS total_quantity_sold,
       SUM(oi.quantity * p.price) AS total_revenue
FROM product p
JOIN orderItem oi ON p.id = oi.product_id
GROUP BY p.name
ORDER BY total_quantity_sold DESC
LIMIT 5;

/*Посчитать количество клиентов, заказывающих с промокодом и без промокода*/
SELECT 
    CASE 
        WHEN client_order.promocode_id IS NOT NULL THEN 'With Promo'
        ELSE 'Without Promo'
    END AS promo_usage,
    COUNT(DISTINCT client_order.client_id) AS num_clients
FROM client_order
GROUP BY promo_usage;

/*Найти продукты, у которых есть аналоги, и сравнить их цены*/
SELECT p1.name AS product_name, p1.price AS product_price, 
       p2.name AS analog_name, p2.price AS analog_price
FROM product p1
JOIN product p2 ON p1.analog_code = p2.analog_code AND p1.id <> p2.id
ORDER BY p1.name;

SELECT first_name, last_name, email, order_date, total_price
FROM client 
LEFT OUTER JOIN client_order ON client.id = client_order.id;

/*все возможные сочетания работников и их ролей в системе*/
SELECT employee.first_name, role.name AS role_name
FROM employee
CROSS JOIN role;

/*показать всех сотрудников и инфо о ролях, даже если у роли нет сотрудника*/
SELECT role.name,role.description, employee.first_name, employee.email
FROM role RIGHT OUTER JOIN employee
ON employee.role_id = role.id;

SELECT role.name AS role_name, employee.first_name
FROM role
FULL OUTER JOIN employee ON role.id = employee.role_id;

WITH client_order_summary AS (
    SELECT client_id, COUNT(id) AS total_orders, SUM(total_price) AS total_amount
    FROM client_order
    GROUP BY client_id
	HAVING SUM(total_price) BETWEEN 50 AND 100
)
SELECT client.first_name, client.last_name, client_order_summary.total_orders, client_order_summary.total_amount
FROM client
JOIN client_order_summary ON client.id = client_order_summary.client_id;

SELECT first_name, last_name, 'Client' AS person_type
FROM client
UNION
SELECT first_name, last_name, 'Employee' AS person_type
FROM employee;

/*TRUNCATE TABLE employee RESTART IDENTITY CASCADE;*/

/*INSERT INTO employee (role_id, first_name, last_name, phone, email, password_hash, passport) VALUES
(1, 'Admin', 'Admin', '123-555-7890', 'admin@example.com', 'hashedpass1', 123456),
(2, 'Jane', 'Gilbert', '234-555-7890', 'jane@example.com', 'hashedpass2', 234567),
(3, 'Emily', 'Blossom', '345-555-7890', 'emily@example.com', 'hashedpass3', 345678),
(4, 'Tom', 'Couper', '456-555-7890', 'tom@example.com', 'hashedpass4', 456789),
(5, 'Alex', 'Smith', '567-555-7890', 'alex@example.com', 'hashedpass5', 567890);

INSERT INTO logs (employee_id, action_id, action_date) VALUES
(1, 1, '2024-10-10 10:00:00'),  -- Админ (id=1) выполнил действие 'Update'
(1, 2, '2024-10-10 10:15:00'),  -- Админ (id=1) выполнил действие 'Insert'
(1, 3, '2024-10-10 10:30:00'),  -- Админ (id=1) выполнил действие 'Delete'
(1, 4, '2024-10-10 11:00:00'),  -- Админ (id=1) выполнил действие 'Login'
(1, 5, '2024-10-10 11:30:00');  -- Админ (id=1) выполнил действие 'Logout'
*/

ALTER TABLE manufacturer RENAME TO manufacturer_source;
ALTER TABLE client RENAME TO client_source;
ALTER TABLE client_order rename TO order_source;
*/
/*CREATE TABLE client_order (
    id SERIAL,
    status VARCHAR(50) NOT NULL,
    client_id INT REFERENCES client(id) ON DELETE CASCADE,
    order_date TIMESTAMP NOT NULL,
    promocode_id INT REFERENCES Promocode(id),
    total_price DECIMAL(10, 2),
    pharmacy_id INT REFERENCES Pharmacy(id),
	PRIMARY KEY (id, order_date)
) PARTITION BY RANGE (order_date);
*/
/*
CREATE TABLE client (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    phone VARCHAR(20),
    email VARCHAR(255),
    password VARCHAR(255)
) PARTITION BY HASH(id);
*/
/*
CREATE TABLE manufacturer (
    id SERIAL,
    name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    country VARCHAR(100),
	PRIMARY KEY(id, country)
);
*/
/*create partitions*/
/*CREATE TABLE orders_y2024 PARTITION OF client_order
FOR VALUES FROM ('2024-01-01') TO ('2024-12-31');
*/
/*
INSERT INTO client_order (status, client_id, order_date, promocode_id, total_price, pharmacy_id)
SELECT status, client_id, order_date, promocode_id, total_price, pharmacy_id 
FROM order_source;
*/
/*CREATE TABLE client_p0 PARTITION OF client
    FOR VALUES WITH (MODULUS 4, REMAINDER 0);

CREATE TABLE client_p1 PARTITION OF client
    FOR VALUES WITH (MODULUS 4, REMAINDER 1);

CREATE TABLE client_p2 PARTITION OF client
    FOR VALUES WITH (MODULUS 4, REMAINDER 2);

CREATE TABLE client_p3 PARTITION OF client
    FOR VALUES WITH (MODULUS 4, REMAINDER 3);

INSERT INTO client (first_name, last_name, date_of_birth, phone, email, password)
SELECT first_name, last_name, date_of_birth, phone, email, password
FROM client_source;*/

/*ALTER TABLE client DETACH PARTITION client_p0;
DROP TABLE client_p0;

ALTER TABLE client DETACH PARTITION client_p1;
DROP TABLE client_p1;

ALTER TABLE client DETACH PARTITION client_p2;
DROP TABLE client_p2;

ALTER TABLE client DETACH PARTITION client_p3;
DROP TABLE client_p3;*/

--TRUNCATE TABLE client RESTART IDENTITY CASCADE;
/*CREATE TABLE client_p0 PARTITION OF client
    FOR VALUES WITH (MODULUS 4, REMAINDER 0);

CREATE TABLE client_p1 PARTITION OF client
    FOR VALUES WITH (MODULUS 4, REMAINDER 1);

CREATE TABLE client_p2 PARTITION OF client
    FOR VALUES WITH (MODULUS 4, REMAINDER 2);

CREATE TABLE client_p3 PARTITION OF client
    FOR VALUES WITH (MODULUS 4, REMAINDER 3);*/
	
/*INSERT INTO client (first_name, last_name, date_of_birth, phone, email, password)
SELECT first_name, last_name, date_of_birth, phone, email, password
FROM client_source;*/

SELECT * FROM client;

/*INSERT INTO client_order (status, client_id, order_date, promocode_id, total_price, pharmacy_id)
SELECT status, client_id, order_date, promocode_id, total_price, pharmacy_id 
FROM order_source;*/

SELECT * FROM orders_y2024;
/*
CREATE TABLE manufacturer_usa PARTITION OF manufacturer
    FOR VALUES IN ('USA');

CREATE TABLE manufacturer_uk PARTITION OF manufacturer
    FOR VALUES IN ('UK');

CREATE TABLE manufacturer_canada PARTITION OF manufacturer
    FOR VALUES IN ('Canada');

CREATE TABLE manufacturer_germany PARTITION OF manufacturer
    FOR VALUES IN ('Germany');

CREATE TABLE manufacturer_france PARTITION OF manufacturer
    FOR VALUES IN ('France');
*/
/*
ALTER TABLE manufacturer
DROP COLUMN last_name;

INSERT INTO manufacturer (name, phone, email, country)
SELECT name, phone, email, country FROM manufacturer_source;
*/

--window functions
select * from client_order;
select * from address;

with pharmacy_info as (
select pharmacy.id, street, building
from pharmacy join address on
	pharmacy.address_id = address.id
)

/*select order_date, total_price, street, building,
SUM(total_price) over (partition by order_date) as total
from client_order join pharmacy_info
ON client_order.pharmacy_id = pharmacy_info.id
where status <> 'Cancelled'; */

/*select order_date, total_price, street, building,
SUM(total_price) over (partition by order_date order by street) as total
from client_order join pharmacy_info
ON client_order.pharmacy_id = pharmacy_info.id
where status <> 'Cancelled' ;*/

/*select order_date, total_price, street, building,
SUM(total_price) over (partition by order_date order by street ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) as total
from client_order join pharmacy_info
ON client_order.pharmacy_id = pharmacy_info.id
where status <> 'Cancelled'*/
/*
SELECT order_date, total_price, street, building,
SUM(total_price) over (partition by order_date) as total_sum,
COUNT(total_price) OVER (PARTITION BY  order_date) as total_count,
AVG(total_price) OVER (PARTITION BY  order_date) as average,
MIN(total_price) OVER (PARTITION BY  order_date) as min_value,
MAX(total_price) OVER (PARTITION BY  order_date) as max_value
FROM client_order JOIN pharmacy_info
ON client_order.pharmacy_id = pharmacy_info.id
where status <> 'Cancelled'; 

SELECT order_date, total_price, street, building,
ROW_NUMBER() OVER (PARTITION BY order_date ORDER BY street DESC) AS number_of_row,
RANK() OVER (PARTITION BY order_date ORDER BY street DESC) AS rank_of_row,
DENSE_RANK() OVER (PARTITION BY order_date ORDER BY street DESC) AS dense_rank_of_row,
NTILE(3) OVER (PARTITION BY order_date ORDER BY street DESC) AS ntile_group
FROM client_order JOIN pharmacy_info
ON client_order.pharmacy_id = pharmacy_info.id
where status <> 'Cancelled';
*/
 SELECT order_date, total_price, street, building,
LAG(total_price) OVER (PARTITION BY order_date ORDER BY street) AS "LAG", -- data from next row
LEAD(total_price) OVER (PARTITION BY order_date ORDER BY street) AS "LEAD", -- data from previous
FIRST_VALUE(total_price) OVER (PARTITION BY order_date ORDER BY street) AS "FIRST VALUE",
LAST_VALUE(total_price) OVER (PARTITION BY order_date ORDER BY street
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS "LAST VALUE"
FROM client_order JOIN pharmacy_info
ON client_order.pharmacy_id = pharmacy_info.id
where status <> 'Cancelled';

--show all the indexes
SELECT * 
FROM pg_indexes
WHERE schemaname = 'public';

SELECT id, first_name, last_name
FROM client
WHERE EXISTS (
    SELECT 1 -- the result of the query does not matter
    FROM client_order
    WHERE client_order.client_id = client.id
);

SELECT order_date, total_price
FROM client_order
WHERE total_price > 50
  AND EXISTS (
    SELECT 1
    FROM client
    WHERE client.id = client_order.client_id
      AND client.date_of_birth > '1985-01-01'
);


EXPLAIN SELECT * FROM client WHERE client.date_of_birth > '1985-01-01';
EXPLAIN SELECT * FROM product_type WHERE name LIKE 'C%';

EXPLAIN SELECT p.name, price, pt.name as type,
m.name as manufacturer, m.country as country
FROM product p JOIN product_type pt
ON pt.id = p.product_type_id
JOIN manufacturer m ON m.id = p.manufacturer_id
WHERE pt.name = 'Pill'
  AND p.price BETWEEN 5 AND 10
  AND m.country = 'USA';
  
select Distinct(status) from client_order
where status ilike '%I%' 
order by status desc;

SELECT client.first_name, client.last_name, product.name
FROM orderItem
JOIN client_order ON client_order.id = orderItem.order_id
JOIN client ON client.id = client_order.client_id
JOIN product ON product.id = orderItem.product_id;

WITH product_counts AS (
    SELECT
        c.first_name,
        c.last_name,
        p.name AS product_name,
        COUNT(oi.product_id) OVER (PARTITION BY c.id, p.id) AS purchase_count
    FROM 
        client c
    JOIN client_order co ON c.id = co.client_id
    JOIN orderItem oi ON co.id = oi.order_id
    JOIN product p ON oi.product_id = p.id
), ranked_products AS (
    SELECT
        first_name,
        last_name,
        product_name,
        purchase_count,
        ROW_NUMBER() OVER (PARTITION BY first_name, last_name ORDER BY purchase_count DESC) AS rank
    FROM 
        product_counts
)
SELECT 
    first_name,
    last_name,
    product_name,
    purchase_count
FROM 
    ranked_products
WHERE 
    rank = 1;

select * from orderItem;

/*Insert into orderItem (product_id, quantity, order_id)
values (5, 2, 2);*/
select * from client_order
join client on client.id = client_order.client_id;
 --5 --2 --2
 WITH product_counts AS (
    SELECT
        c.first_name,
        c.last_name,
        p.name AS product_name,
        COUNT(oi.product_id) OVER (PARTITION BY c.id, p.id) AS purchase_count
    FROM 
        client c
    JOIN client_order co ON c.id = co.client_id
    JOIN orderItem oi ON co.id = oi.order_id
    JOIN product p ON oi.product_id = p.id
), ranked_products AS (
    SELECT
        first_name,
        last_name,
        product_name,
        purchase_count,
        ROW_NUMBER() OVER (PARTITION BY first_name, last_name ORDER BY purchase_count DESC) AS rank
    FROM 
        product_counts
)
SELECT 
    first_name,
    last_name,
    product_name,
    purchase_count
FROM 
    ranked_products
WHERE 
    rank = 1;
	
select * from orderItem;
select * from client_order
join client on client.id = client_order.client_id;

Insert into orderItem (product_id, quantity, order_id)
values (5, 2, 2);

 WITH product_counts AS (
    SELECT
        c.first_name,
        c.last_name,
        p.name AS product_name,
        COUNT(oi.product_id) OVER (PARTITION BY c.id, p.id) AS purchase_count
    FROM 
        client c
    JOIN client_order co ON c.id = co.client_id
    JOIN orderItem oi ON co.id = oi.order_id
    JOIN product p ON oi.product_id = p.id
), ranked_products AS (
    SELECT
        first_name,
        last_name,
        product_name,
        purchase_count,
        ROW_NUMBER() OVER (PARTITION BY first_name, last_name ORDER BY purchase_count DESC) AS rank
    FROM 
        product_counts
)
SELECT 
    first_name,
    last_name,
    product_name,
    purchase_count
FROM 
    ranked_products
WHERE 
    rank = 1;