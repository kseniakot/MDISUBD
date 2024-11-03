
-- GET CART INFO FOR CLIENT WITH ID=1
SELECT 
    (SELECT name FROM product WHERE id = ci.product_id) AS product_name,
    ci.quantity,
    (SELECT price FROM product WHERE id = ci.product_id) AS price,
    (ci.quantity * (SELECT price FROM product WHERE id = ci.product_id)) AS total_price
FROM cartItem ci
WHERE ci.cart_id = (SELECT client_id FROM cart WHERE client_id = 1);

--SET REAL TOTAL PRICE TO THE CART

UPDATE cart
SET total_price = (
    SELECT SUM(
        ci.quantity * (SELECT p.price FROM product p WHERE p.id = ci.product_id)
    )
    FROM cartItem ci
    WHERE ci.cart_id = cart.client_id
);

SELECT * FROM cart;

SELECT code, discount FROM promocode;

-- ADD DISCOUNT DYNAMICALLY
SELECT 
    name,
    price,
    CASE 
        WHEN price > 15 THEN price * 0.8 
        WHEN price > 10 THEN price * 0.9  
        ELSE price                        
    END AS dynamic_discount_price
FROM product;

SELECT name, price
FROM product
WHERE price > 10;

SELECT name, price
FROM product
WHERE (price > 5 AND product_type_id = (SELECT id FROM product_type WHERE name = 'Pill'))
   OR price < 5;

SELECT name, price
FROM product
WHERE price BETWEEN 5 AND 20;

SELECT name, price
FROM product
WHERE product_type_id IN (
    SELECT id FROM product_type WHERE name IN ('Pill', 'Syrup')
);

SELECT (SELECT name FROM product where id = pi.product_id) AS product_name,
(SELECT price FROM product where id = pi.product_id) AS product_price,
quantity AS stock_quantity
FROM product_instance pi
WHERE (SELECT price FROM product WHERE id = pi.product_id) < 50
ORDER BY product_name, stock_quantity DESC;

SELECT name AS product_name,
price
FROM product
WHERE name LIKE 'I%';

SELECT DISTINCT manufacturer_id FROM product;


SELECT 
    (SELECT manufacturer.name FROM manufacturer WHERE manufacturer.id = p.manufacturer_id) AS manufacturer, 
    COUNT(DISTINCT p.name) AS unique_products, 
    SUM(pi.quantity) AS quantity
FROM product p, product_instance pi
WHERE p.id = pi.product_id
GROUP BY p.manufacturer_id
ORDER BY (SELECT manufacturer.name FROM manufacturer WHERE manufacturer.id = p.manufacturer_id);

SELECT MIN(price) AS min_price
FROM product;

SELECT (SELECT name FROM manufacturer WHERE id = p.manufacturer_id ),
MIN(price) AS min_price
FROM product p
GROUP BY manufacturer_id;

SELECT (SELECT name FROM product WHERE id = pi.product_id) as name, 
MAX(quantity) AS max_quantity
FROM product_instance pi
GROUP BY product_id;

SELECT (SELECT name FROM manufacturer WHERE id = p.manufacturer_id ),
ROUND(AVG(price), 2) AS average_price
FROM product p
GROUP BY manufacturer_id;

SELECT (SELECT name FROM manufacturer WHERE id = p.manufacturer_id ),
ROUND(AVG(price), 2) AS average_price
FROM product p
GROUP BY manufacturer_id
HAVING ROUND(AVG(price), 2) > 10;


SELECT (SELECT name FROM manufacturer WHERE id = manufacturer_id ), MIN(price),
(SELECT name FROM product_type pt WHERE pt.id = p.product_type_id)
FROM product p
WHERE product_type_id IN (
    SELECT id FROM product_type WHERE name LIKE '_____'
)
GROUP BY (SELECT name FROM manufacturer WHERE id = manufacturer_id),
(SELECT name FROM product_type pt WHERE pt.id = p.product_type_id)
HAVING AVG(price) > 10;


SELECT pi.pharmacy_id as pharmacy,
(SELECT price FROM product WHERE id = product_id) as price
FROM product_instance pi
WHERE (SELECT price FROM product WHERE id = product_id) > ALL (
    SELECT price FROM product WHERE manufacturer_id = 1
)
LIMIT 2;


SELECT count(*) FROM product
where product_type_id in (select id from product_type where name LIKE '%i%');
