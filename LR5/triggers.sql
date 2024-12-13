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

/*
CREATE OR REPLACE FUNCTION update_product_instance()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE product_instance
        SET quantity = quantity - NEW.quantity
        WHERE product_id = NEW.product_id AND pharmacy_id = (SELECT pharmacy_id FROM client_order WHERE id = NEW.order_id);
		RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE product_instance
        SET quantity = quantity + OLD.quantity
        WHERE product_id = OLD.product_id AND pharmacy_id = (SELECT pharmacy_id FROM client_order WHERE id = OLD.order_id);
		RETURN OLD;
    END IF;
   RAISE NOTICE 'Hererere';
END;
$$ LANGUAGE plpgsql;
*/

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


CREATE OR REPLACE FUNCTION log_new_client()
RETURNS TRIGGER AS $$
DECLARE
new_log_id INT;
BEGIN

	INSERT INTO action(name, description, table_name)
	VALUES ('INSERT', 'new client registered', 'client')
	returning id into new_log_id;
    INSERT INTO logs (action_id, client_id, new_value)
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