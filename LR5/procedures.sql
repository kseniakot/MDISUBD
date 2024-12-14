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
	cart_total_price DECIMAL(10, 2);
BEGIN

    IF NOT EXISTS (SELECT 1 FROM cart WHERE client_id = p_client_id) THEN
        RAISE EXCEPTION 'No cart found for client with ID %', client_id;
    END IF;

	SELECT total_price INTO cart_total_price
    FROM cart
    WHERE client_id = client_id;
	
    --creating new order
    INSERT INTO client_order (client_id, pharmacy_id, promocode_id, total_price)
    VALUES (p_client_id, p_pharmacy_id, p_promocode_id, cart_total_price)
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


CREATE OR REPLACE FUNCTION get_order_details(p_order_id INT)
RETURNS TABLE (
    id INT,
    product_name VARCHAR(100),
    quantity INT,
    order_id INT,
	street VARCHAR(100),
	building INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        oi.id,
        product.name,
        oi.quantity,
        oi.order_id,
		address.street,
		address.building
    FROM orderItem oi
	JOIN product ON product.id = oi.product_id
	JOIN client_order ci ON ci.id = p_order_id
	JOIN pharmacy ON pharmacy.id = ci.pharmacy_id
	JOIN address ON address.id = pharmacy.address_id
    WHERE oi.order_id = p_order_id;
	
END;
$$ LANGUAGE plpgsql;

select * from client_order;
SELECT * FROM get_order_details(14);
SELECT * from product;

CREATE OR REPLACE PROCEDURE add_client(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_date_of_birth DATE,
    p_phone VARCHAR,
    p_email VARCHAR,
    p_password VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    client_id INT;
BEGIN

    INSERT INTO client (first_name, last_name, date_of_birth, phone, email, password)
    VALUES (p_first_name, p_last_name, p_date_of_birth, p_phone, p_email, p_password)
    RETURNING id INTO client_id;

    RAISE NOTICE 'Client added with ID: %', client_id;
END;
$$;

select * from client;

CREATE OR REPLACE PROCEDURE add_to_cart(
    p_product_id INT,
    p_quantity INT,
    p_cart_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Проверяем, существует ли уже этот продукт в корзине
    IF EXISTS (SELECT 1 FROM cartitem WHERE product_id = p_product_id AND cart_id = p_cart_id) THEN
        -- Если продукт уже в корзине, увеличиваем количество
        UPDATE cartitem
        SET quantity = quantity + p_quantity
        WHERE product_id = p_product_id AND cart_id = p_cart_id;
    ELSE
        -- Если продукта нет, добавляем новую запись
        INSERT INTO cartitem (product_id, quantity, cart_id)
        VALUES (p_product_id, p_quantity, p_cart_id);
    END IF;
END;
$$;

--call add_to_cart(2, 3, 24);
select * from cart;
