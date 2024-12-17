--//////////////////// LOGS

/*ALTER TABLE logs
ADD COLUMN client_id INT REFERENCES client(id);
*/
select * from action;
CREATE OR REPLACE FUNCTION log_update_order_status()
RETURNS TRIGGER AS $$
DECLARE
new_action_id INT;
BEGIN
    INSERT INTO action(name, description, table_name)
	VALUES ('UPDATE', 'employee changed order_status', 'client_order')
	returning id into new_action_id;
	INSERT INTO logs (action_id, employee_id, client_id, row_id, new_value, old_value)
    VALUES (new_action_id, current_setting('app.employee_id')::INT, NEW.client_id, NEW.id, NEW.status, OLD.status);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/*
CREATE TRIGGER log_order_status_update
AFTER UPDATE OF status
ON client_order
FOR EACH ROW
EXECUTE FUNCTION log_update_order_status();

*/

CREATE OR REPLACE FUNCTION log_insert_order()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO logs (employee_id, client_id, action_id, action_date, new_value)
    VALUES (
        NULL, 
        NEW.client_id, 
        (SELECT id FROM action WHERE name = 'INSERT' AND table_name = 'client_order'),
        CURRENT_TIMESTAMP,
		NEW.id
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/*
CREATE TRIGGER log_order_insert
AFTER INSERT
ON client_order
FOR EACH ROW
EXECUTE FUNCTION log_insert_order();
*/

CREATE OR REPLACE FUNCTION log_delete_order()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO logs (employee_id, client_id, action_id, action_date, old_value)
    VALUES (
        NULL,
        OLD.client_id, 
        (SELECT id FROM action WHERE name = 'DELETE' AND table_name = 'client_order'),
        CURRENT_TIMESTAMP,
		OLD.id
    );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
/*
CREATE TRIGGER log_order_delete
AFTER DELETE
ON client_order
FOR EACH ROW
EXECUTE FUNCTION log_delete_order();
*/

CREATE OR REPLACE FUNCTION log_update_product_price()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO logs (employee_id, action_id, action_date, old_value, new_value)
    VALUES (
        current_setting('app.employee_id')::INT, 
        (SELECT id FROM action WHERE name = 'UPDATE' AND table_name = 'product'), 
        CURRENT_TIMESTAMP, 
        OLD.price, 
        NEW.price
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
/*
CREATE TRIGGER log_product_price_update
AFTER UPDATE OF price
ON product
FOR EACH ROW
EXECUTE FUNCTION log_update_product_price();
*/

SELECT set_config('app.employee_id', '1', true);
select * from client_order;
/*UPDATE client_order
SET status = 'Completed'
WHERE id = 10;*/
select * from logs;

/*INSERT INTO client_order ( client_id, order_date, total_price, pharmacy_id)
VALUES ( 1, CURRENT_TIMESTAMP, 100.50, 1);*/
/*DELETE FROM client_order WHERE id = 11;*/

/*select * from product;
UPDATE product
SET price = 10.05
WHERE id = 5;*/

CREATE OR REPLACE FUNCTION log_delete_order()
RETURNS TRIGGER AS $$
DECLARE
new_action_id INT;
BEGIN
    INSERT INTO action(name, description, table_name)
	VALUES ('DELETE', 'employee deleted order', 'client_order')
	returning id into new_action_id;
	INSERT INTO logs (action_id, employee_id, client_id, row_id)
    VALUES (new_action_id, current_setting('app.employee_id')::INT, OLD.client_id, OLD.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/*
CREATE TRIGGER log_delete_order_trigger
AFTER DELETE
ON client_order
FOR EACH ROW
EXECUTE FUNCTION log_delete_order();
*/


CREATE OR REPLACE FUNCTION log_apply_promocode()
RETURNS TRIGGER AS $$
DECLARE
new_action_id INT;
BEGIN
    INSERT INTO action(name, description, table_name)
	VALUES ('UPDATE', 'client applied promocode', 'cart')
	returning id into new_action_id;
	INSERT INTO logs (action_id, client_id, row_id, new_value, old_value)
    VALUES (new_action_id, NEW.client_id, NEW.client_id, NEW.promocode_id, OLD.promocode_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/*
CREATE TRIGGER log_apply_promocode
AFTER UPDATE of promocode_id
ON cart
FOR EACH ROW
EXECUTE FUNCTION log_apply_promocode();
*/




