SELECT 
    o.id AS order_id,
    o.order_date,
    o.total_price,
    p.name AS product_name,
    oi.quantity AS product_quantity,
    street, 
	building,
    CONCAT(c.first_name, ' ', c.last_name) AS client_name,
    m.name AS manufacturer_name,
    pt.name AS product_type
FROM 
    client_order o
JOIN 
    orderItem oi ON o.id = oi.order_id
JOIN 
    product p ON oi.product_id = p.id
JOIN 
    pharmacy ph ON o.pharmacy_id = ph.id
JOIN 
    client c ON o.client_id = c.id
JOIN 
    manufacturer m ON p.manufacturer_id = m.id
JOIN 
    product_type pt ON p.product_type_id = pt.id
JOIN 
	address a ON ph.address_id = a.id
ORDER BY 
    o.order_date DESC;

/*
select * from product;
SELECT 
    p.id AS product_id,
    p.name AS product_name,
    pt.name AS product_type,
    m.name AS manufacturer_name,
    CONCAT(a.street, ', ', a.building) AS pharmacy_address,
    pi.quantity AS available_quantity,
    p.price AS price
FROM 
    product p
JOIN 
    product_type pt ON p.product_type_id = pt.id
JOIN 
    manufacturer m ON p.manufacturer_id = m.id
LEFT JOIN 
    product_instance pi ON p.id = pi.product_id
LEFT JOIN 
    pharmacy ph ON pi.pharmacy_id = ph.id
LEFT JOIN 
    address a ON ph.address_id = a.id
ORDER BY 
    p.name ASC, pt.name ASC, m.name ASC;*/
/*
SELECT *
                           FROM
                               product p
                           JOIN
                               product_type pt ON p.product_type_id = pt.id
                           JOIN
                               manufacturer m ON p.manufacturer_id = m.id
                           JOIN 
                               description d ON p.description_id = d.id
                           ORDER BY
                               p.name ASC, pt.name ASC, m.name ASC
*/

/*
SELECT 
    p.name AS product_name,
    pi.quantity AS product_quantity,
    ph.id AS pharmacy_id,
    a.street AS pharmacy_street,
    a.building AS pharmacy_building
FROM 
    product_instance pi
JOIN 
    product p ON pi.product_id = p.id
JOIN 
    pharmacy ph ON pi.pharmacy_id = ph.id
JOIN 
    address a ON ph.address_id = a.id
ORDER BY 
    p.name, a.street, a.building;*/

SELECT 
        p.id AS product_id,
        p.name AS product_name,
        pt.name AS product_type,
        m.name AS manufacturer_name,
		m.country AS country,
        CONCAT(a.street, ', ', a.building) AS pharmacy_address,
        pi.quantity AS available_quantity,
        p.price AS price
    FROM 
        product p
    JOIN 
        product_type pt ON p.product_type_id = pt.id
    JOIN 
        manufacturer m ON p.manufacturer_id = m.id
    LEFT JOIN 
        product_instance pi ON p.id = pi.product_id
    LEFT JOIN 
        pharmacy ph ON pi.pharmacy_id = ph.id
    LEFT JOIN 
        address a ON ph.address_id = a.id
    ORDER BY 
        p.name ASC, pt.name ASC, m.name ASC;

select * from logs
join action on action.id = logs.action_id;
