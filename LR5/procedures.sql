--///
CREATE OR REPLACE PROCEDURE delete_expired_promocodes()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM promocode
    WHERE expiration_date < CURRENT_DATE;
    RAISE NOTICE 'Expired promocodes have been deleted.';
END;
$$;

/*ALTER TABLE promocode
ALTER COLUMN expiration_date SET DEFAULT (CURRENT_DATE + INTERVAL '7 days');*/
select * from promocode;
/*update promocode set expiration_date "2020-12-12"
where id = 5;*/
--call delete_expired_promocodes();


CREATE OR REPLACE PROCEDURE add_product(
    p_name VARCHAR,
    p_description TEXT,
    p_price DECIMAL(10, 2),
    p_product_type_id INT,
    p_manufacturer_id INT,
    p_unit_of_measure_id INT,
    p_quantity INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Product (name, description, price, product_type_id, manufacturer_id, unit_of_measure_id, quantity)
    VALUES (p_name, p_description, p_price, p_product_type_id, p_manufacturer_id, p_unit_of_measure_id, p_quantity);
END;
$$;

CREATE OR REPLACE PROCEDURE update_product(
    p_id INT,
    p_name VARCHAR,
    p_description TEXT,
    p_price DECIMAL(10, 2),
    p_product_type_id INT,
    p_manufacturer_id INT,
    p_unit_of_measure_id INT,
    p_quantity INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Product
    SET 
        name = p_name,
        description = p_description,
        price = p_price,
        product_type_id = p_product_type_id,
        manufacturer_id = p_manufacturer_id,
        unit_of_measure_id = p_unit_of_measure_id,
        quantity = p_quantity
    WHERE id = p_id;
END;
$$;

CREATE OR REPLACE PROCEDURE delete_product(p_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Product WHERE id = p_id;
END;
$$;

select * from client_order;

CREATE OR REPLACE PROCEDURE create_order_from_cart(
    p_client_id INT,
    p_pharmacy_id INT,
    p_promocode_id INT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    new_order_id INT;
BEGIN

    IF NOT EXISTS (SELECT 1 FROM cart WHERE client_id = p_client_id) THEN
        RAISE EXCEPTION 'No cart found for client with ID %', client_id;
    END IF;

    --creating new order
    INSERT INTO client_order (client_id, pharmacy_id, promocode_id)
    VALUES (p_client_id, p_pharmacy_id, p_promocode_id)
    RETURNING id INTO new_order_id;

    
    INSERT INTO orderItem (product_id, quantity, order_id)
    SELECT product_id, quantity, new_order_id
    FROM cartItem
    WHERE cart_id = p_client_id;

    
    DELETE FROM cartItem
    WHERE cart_id = p_client_id;


    RAISE NOTICE 'Order created with ID %', new_order_id;
END;
$$;

--DROP PROCEDURE create_order_from_cart(integer,integer,integer);
--call create_order_from_cart(1, 1, null);
select * from client_order;