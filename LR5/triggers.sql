--///////////////////////////////////////

--Recalculate total price in cart whenever
--item is added or removed or updated

/*CREATE OR REPLACE FUNCTION update_cart_total()
RETURNS TRIGGER AS $$
DECLARE
    old_total_price DECIMAL(10, 2);
    new_total_price DECIMAL(10, 2);
BEGIN

	SELECT total_price INTO old_total_price
    FROM cart
    WHERE client_id = COALESCE(NEW.cart_id, OLD.cart_id);
	
    UPDATE cart
    SET total_price = (
        SELECT COALESCE(SUM(ci.quantity * p.price), 0)
        FROM cartItem ci
        JOIN product p ON ci.product_id = p.id
        WHERE ci.cart_id = COALESCE(NEW.cart_id, OLD.cart_id) 
    )
    WHERE cart.client_id = COALESCE(NEW.cart_id, OLD.cart_id);
	RAISE NOTICE 'Value of NEW.quantity: %', NEW.quantity;
	
	SELECT total_price INTO new_total_price
    FROM cart
    WHERE client_id = COALESCE(NEW.cart_id, OLD.cart_id);

    RAISE NOTICE 'Total price before update: %', old_total_price;
    RAISE NOTICE 'Total price after update: %', new_total_price;
	
    RETURN CASE
        WHEN TG_OP = 'DELETE' THEN OLD
        ELSE NEW
    END;
END;
$$ LANGUAGE plpgsql;
*/

/*
CREATE TRIGGER recalculate_cart_total_on_insert_or_update
AFTER INSERT OR UPDATE OF quantity
ON cartItem
FOR EACH ROW
EXECUTE FUNCTION update_cart_total();

CREATE TRIGGER recalculate_cart_total_on_delete
AFTER DELETE
ON cartItem
FOR EACH ROW
EXECUTE FUNCTION update_cart_total();
*/


-- TESTS
/*insert into cartItem (product_id, quantity, cart_id)
values (2, 10, 5);

select cart.client_id, cart.total_price, quantity, name, product_id, price  from cart
join cartItem ON cartItem.cart_id = cart.client_id
join product ON product.id = cartItem.product_id
order by cart_id;*/

--////////////////////////////////

--RECALCULATES QUANTITY OF PRODUCTS IN PHARMACY AFTER CLIENT CREATES OR REMOVES ORDER ITEM


CREATE OR REPLACE FUNCTION update_product_instance()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE product_instance
        SET quantity = GREATEST(quantity - NEW.quantity, 0)
        WHERE product_id = NEW.product_id AND pharmacy_id = (SELECT pharmacy_id FROM client_order WHERE id = NEW.order_id);
		RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE product_instance
        SET quantity = quantity + OLD.quantity
        WHERE product_id = OLD.product_id AND pharmacy_id = (SELECT pharmacy_id FROM client_order WHERE id = OLD.order_id);
		RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;


/*
CREATE TRIGGER update_product_instance_trigger
AFTER INSERT OR DELETE ON orderItem
FOR EACH ROW
EXECUTE FUNCTION update_product_instance();
*/

select pharmacy.id, street, building, quantity, product.name, product.id from pharmacy
join address on pharmacy.address_id = address.id
join product_instance on product_instance.pharmacy_id = pharmacy.id
join product on product_instance.product_id = product.id
order by street;

--select * from client_order;
--alter table client_order alter column order_date SET DEFAULT CURRENT_TIMESTAMP;

/*insert into orderItem (product_id, quantity, order_id)
values (5, 2, 24);*/

/*insert into client_order (client_id, pharmacy_id)
values (2, 5);*/
--delete from orderitem where id = 33;




--TEST

select pharmacy.id, street, building, quantity, product.name from pharmacy
join address on pharmacy.address_id = address.id
join product_instance on product_instance.pharmacy_id = pharmacy.id
join product on product_instance.product_id = product.id
order by street;

--select * from client_order;

/*insert into client_order (client_id, pharmacy_id)
values (2, 5);*/
/*insert into orderItem (product_id, quantity, order_id)
values (5, 2, 27);*/
--delete from client_order where id = 27;

--///////////////
--CREATE CART FOR ANY NEW CLIENT
/*
CREATE OR REPLACE FUNCTION create_cart_for_new_client()
RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO cart (client_id, total_price)
    VALUES (NEW.id, 0.00);
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;
*/
/*CREATE TRIGGER create_cart_trigger
AFTER INSERT ON client
FOR EACH ROW
EXECUTE FUNCTION create_cart_for_new_client();
*/

--select * from client;
--select * from cart;

/*INSERT INTO client (first_name, last_name, date_of_birth, phone, email, password)
VALUES ('DEVEN', 'MEHTA', '1990-06-21', '123-456-7890', 'd.mehta@tetragoniv.com', '12345678');
*/

--////////////////////////


--UPADTE CART TOTAL PRICE WHEN PROMOCODE IS ADDED
/*
CREATE OR REPLACE FUNCTION apply_promocode_to_cart()
RETURNS TRIGGER AS $$
DECLARE
    current_discount FLOAT := 0.0;
BEGIN
    
    IF NEW.promocode_id IS DISTINCT FROM OLD.promocode_id THEN
        
        
        UPDATE cartItem
        SET price = (
            SELECT p.price
            FROM product p
            WHERE p.id = cartItem.product_id
        )
        WHERE cart_id = NEW.client_id;

        IF NEW.promocode_id IS NOT NULL THEN
            
            SELECT CAST(discount AS FLOAT) / 100 INTO current_discount
            FROM promocode
            WHERE id = NEW.promocode_id;

            RAISE NOTICE 'Discount applied: %', current_discount;

            
            UPDATE cartItem
            SET price = price - (price * current_discount)
            WHERE cart_id = NEW.client_id;
        END IF;

        UPDATE cart
        SET total_price = (
            SELECT COALESCE(SUM(ci.quantity * ci.price), 0)
            FROM cartItem ci
            WHERE ci.cart_id = NEW.client_id
        )
        WHERE client_id = NEW.client_id;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

*/
/*
CREATE TRIGGER recalculate_cart_total_on_promocode
AFTER INSERT OR UPDATE OF promocode_id
ON cart
FOR EACH ROW
EXECUTE FUNCTION apply_promocode_to_cart();
*/
/*UPDATE cart
set promocode_id = 2
where client_id = 1;
*/
--select * from cart;
--select * from promocode;

CREATE OR REPLACE FUNCTION log_add_to_cart()
RETURNS TRIGGER AS $$
DECLARE
new_action_id INT;
BEGIN
	INSERT INTO action(name, description, table_name)
	VALUES ('INSERT', 'client added product to the cart', 'cartIitem')
	returning id into new_action_id;
	INSERT INTO logs (action_id, client_id, row_id, new_value)
    VALUES (new_action_id, NEW.cart_id, NEW.id, NEW.quantity);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
/*
CREATE TRIGGER add_to_cart_trigger
AFTER INSERT ON cartItem
FOR EACH ROW
EXECUTE FUNCTION log_add_to_cart();
*/
CREATE OR REPLACE FUNCTION log_update_quantity()
RETURNS TRIGGER AS $$
DECLARE
new_action_id INT;

BEGIN
	
	INSERT INTO action(name, description, table_name)
	VALUES ('UPDATE', 'client updated product quantity', 'cartIitem')
	returning id into new_action_id;
	INSERT INTO logs (action_id, client_id, row_id, new_value, old_value)
    VALUES (new_action_id, NEW.cart_id, NEW.id, NEW.quantity, OLD.quantity);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
/*
CREATE TRIGGER update_cart_trigger
AFTER UPDATE ON cartItem
FOR EACH ROW
EXECUTE FUNCTION log_update_quantity();
*/

CREATE OR REPLACE FUNCTION log_delete_from_cart()
RETURNS TRIGGER AS $$
DECLARE
new_action_id INT;
BEGIN
	INSERT INTO action(name, description, table_name)
	VALUES ('DELETE', 'client deleted product from cart', 'cartIitem')
	returning id into new_action_id;
	INSERT INTO logs (action_id, client_id, row_id, old_value, new_value)
    VALUES (new_action_id, OLD.cart_id, OLD.id, old.quantity, null);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
/*
CREATE TRIGGER delete_from_cart_trigger
AFTER DELETE ON cartItem
FOR EACH ROW
EXECUTE FUNCTION log_delete_from_cart();
*/
CREATE OR REPLACE FUNCTION log_new_client()
RETURNS TRIGGER AS $$
DECLARE
new_log_id INT;
BEGIN

	INSERT INTO action(name, description, table_name)
	VALUES ('INSERT', 'new client registered', 'client')
	returning id into new_log_id;
    INSERT INTO logs (action_id, client_id, row_id)
    VALUES (new_log_id, NEW.id, NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
/*
CREATE TRIGGER log_new_client_trigger
AFTER INSERT ON client
FOR EACH ROW
EXECUTE FUNCTION log_new_client();
*/
select * from client;


select * from employee;
select * from product_instance;


/*
INSERT INTO product_instance (id, product_id, quantity, pharmacy_id)
VALUES
    (17, 2, 15, 1), -- Амоксициллин в аптеке на Main Street
    (18, 3, 10, 2), -- Ибупрофен в аптеке на Baker Street
    (19, 4, 25, 3), -- Сироп от кашля в аптеке на Elm Street
    (20, 5, 18, 4), -- Витамин C в аптеке на Oak Avenue
    (21, 2, 35, 5), -- Амоксициллин в аптеке на Pine Street
    (22, 3, 50, 1), -- Ибупрофен в аптеке на Main Street
    (23, 4, 30, 2), -- Сироп от кашля в аптеке на Baker Street
    (24, 5, 12, 3), -- Витамин C в аптеке на Elm Street
    (25, 4, 40, 4), -- Сироп от кашля в аптеке на Oak Avenue
    (26, 2, 28, 5); -- Амоксициллин в аптеке на Pine Street

*/

select * from cartitem;

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

SELECT  
    p.name AS product_name,
    pt.name AS type,
    COALESCE(pi.quantity, 0) AS in_stock, -- Если товара нет, показать 0
    a.street AS pharmacy_street,
    a.building AS pharmacy_building,
    m.name AS manufacturer,
    m.country AS country,
    p.id AS product_id,
    p.price AS price
FROM 
    product p
LEFT JOIN 
    product_instance pi ON pi.product_id = p.id
LEFT JOIN 
    pharmacy ph ON pi.pharmacy_id = ph.id
LEFT JOIN 
    address a ON ph.address_id = a.id
LEFT JOIN 
    product_type pt ON p.product_type_id = pt.id
LEFT JOIN 
    manufacturer m ON p.manufacturer_id = m.id
ORDER BY 
    p.name;




CREATE OR REPLACE FUNCTION log_create_order()
RETURNS TRIGGER AS $$
DECLARE
new_action_id INT;
BEGIN
	INSERT INTO action(name, description, table_name)
	VALUES ('INSERT', 'client created new order', 'client_order')
	returning id into new_action_id;
	INSERT INTO logs (action_id, client_id, row_id)
    VALUES (new_action_id, NEW.client_id, NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
/*
CREATE TRIGGER log_create_order_trigger
AFTER INSERT ON client_order
FOR EACH ROW
EXECUTE FUNCTION log_create_order();

*/
select * from logs
join action on action.id = logs.action_id;
select * from product_instance;

--update product_instance set quantity = 1 where id = 50;
