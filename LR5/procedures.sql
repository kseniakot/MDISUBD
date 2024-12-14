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


CREATE OR REPLACE PROCEDURE remove_from_cart(
    p_product_id INT,
    p_cart_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
   
    IF EXISTS (
        SELECT 1 
        FROM cartitem 
        WHERE product_id = p_product_id AND cart_id = p_cart_id
    ) THEN
       
        DELETE FROM cartitem 
        WHERE product_id = p_product_id AND cart_id = p_cart_id;
    ELSE
       
        RAISE EXCEPTION 'Product with ID % not found in cart %', p_product_id, p_cart_id;
    END IF;
END;
$$;

--call remove_from_cart(2, 24);
call add_to_cart(5, 3, 24);
select * from cart;
select * from logs join action on logs.action_id = action.id;


CREATE OR REPLACE PROCEDURE decrease_product_quantity(
    p_product_id INT,
    p_cart_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM cartitem 
        WHERE product_id = p_product_id AND cart_id = p_cart_id
    ) THEN
        UPDATE cartitem
        SET quantity = quantity - 1
        WHERE product_id = p_product_id AND cart_id = p_cart_id;

        DELETE FROM cartitem 
        WHERE product_id = p_product_id AND cart_id = p_cart_id AND quantity <= 0;
    ELSE
        RAISE EXCEPTION 'Product with ID % not found in cart %', p_product_id, p_cart_id;
    END IF;
END;
$$;
--call decrease_product_quantity(2, 24);
select 
cart.client_id as cart_id,
total_price,
promocode.code as promocode,
promocode.discount as discount,
p.id as product_id,
p.name as product,
p.price as price,
cartItem.quantity as quantity
from cart 
left JOIN cartitem on cartItem.cart_id = cart.client_id
join product p on p.id = cartItem.product_id
left join promocode on promocode.id = cart.promocode_id
where cart.client_id = 24;
select * from promocode;

CREATE OR REPLACE PROCEDURE apply_promocode(
    p_cart_id INT,
    p_promocode_code VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    discount_value DECIMAL(5, 2);
    p_promocode_id INT;
BEGIN
    
    SELECT id, discount
    INTO p_promocode_id, discount_value
    FROM promocode
    WHERE code = p_promocode_code;

    IF p_promocode_id IS NULL THEN
        RAISE EXCEPTION 'Promocode % not found', p_promocode_code;
    END IF;

    IF NOT EXISTS (
        SELECT 1 
        FROM cart
        WHERE client_id = p_cart_id
    ) THEN
        RAISE EXCEPTION 'Cart with ID % not found', p_cart_id;
    END IF;

    UPDATE cart
    SET 
        promocode_id = p_promocode_id,
        total_price = total_price * (1 - discount_value / 100)
    WHERE client_id = p_cart_id;

    RAISE NOTICE 'Promocode % with discount % applied to cart ID %', 
        p_promocode_code, discount_value, p_cart_id;
END;
$$;

SELECT 	* from cart;
call apply_promocode(24, 'WINTR2024');
