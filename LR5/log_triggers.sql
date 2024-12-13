--//////////////////// LOGS

/*ALTER TABLE logs
ADD COLUMN client_id INT REFERENCES client(id);
*/
select * from action;
CREATE OR REPLACE FUNCTION log_update_order_status()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO logs (employee_id, action_id, action_date, old_value, new_value)
    VALUES (
        current_setting('app.employee_id')::INT, 
        (SELECT id FROM action WHERE name = 'UPDATE' AND table_name = 'client_order'), 
        CURRENT_TIMESTAMP,
		OLD.status,
		NEW.status
    );
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


