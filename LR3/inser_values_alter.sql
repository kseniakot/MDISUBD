/*INSERT INTO description (name) VALUES
('Pain relievers'),
('Antibiotics'),
('Vitamins'),
('Cough medicine'),
('Antihistamines');

INSERT INTO product_type (name) VALUES
('Pill'),
('Syrup'),
('Injection'),
('Cream'),
('Capsule');

ALTER TABLE manufacturer
DROP COLUMN last_name;


INSERT INTO manufacturer (name, phone, email, country) VALUES
('Johnson Pharmaceuticals', '123-456-7890', 'contact@johnsonpharma.com', 'USA'),
('Smith Labs', '098-765-4321', 'info@smithlabs.com', 'UK'),
('Anderson Pharma Inc.', '333-456-7890', 'sales@andersonpharma.ca', 'Canada'),
('Eliza Healthcare', '444-765-4321', 'support@elizacare.de', 'Germany'),
('Williams Pharmaceuticals', '555-123-7890', 'info@williamspharma.fr', 'France');


INSERT INTO product (name, description_id, price, product_type_id, photo, manufacturer_id, analog_code) VALUES
('Aspirin', 1, 5.99, 1, 'aspirin.jpg', 1, 1001),
('Amoxicillin', 2, 12.49, 2, 'amoxicillin.jpg', 2, 2001),
('Ibuprofen', 3, 8.99, 3, 'ibuprofen.jpg', 3, 1001),  
('Cough Syrup', 4, 15.99, 2, 'cough_syrup.jpg', 4, 3001),
('Vitamin C', 3, 9.99, 5, 'vitamin_c.jpg', 5, 4001),
('Paracetamol', 1, 6.99, 1, 'paracetamol.jpg', 1, 1001),
('Penicillin', 2, 11.99, 2, 'penicillin.jpg', 2, 2001);  


INSERT INTO address (street, building) VALUES
('Main Street', 12),
('Baker Street', 221),
('Elm Street', 45),
('Oak Avenue', 88),
('Pine Street', 102);


INSERT INTO pharmacy (address_id) VALUES
(1),
(2),
(3),
(4),
(5);


INSERT INTO product_instance (product_id, quantity, pharmacy_id) VALUES
(1, 50, 1),
(2, 30, 2),
(3, 40, 3),
(4, 20, 4),
(5, 25, 5);


ALTER TABLE promocode
ALTER COLUMN discount TYPE INT;


INSERT INTO promocode (code, discount) VALUES
('SUMMER2024', 10),  
('WINTER2024', 15),  
('SPRING2024', 5),    
('AUTUMN2024', 20),   
('NEWYEAR2024', 25); 



INSERT INTO client (first_name, last_name, date_of_birth, phone, email, password) VALUES
('John', 'Doe', '1990-05-20', '123-456-7890', 'john.doe@example.com', 'password123'),
('Alice', 'Smith', '1985-07-15', '098-765-4321', 'alice.smith@example.com', 'securePass!'),
('Bob', 'Johnson', '1992-03-12', '111-222-3333', 'bob.johnson@example.com', 'password456'),
('Emily', 'Clark', '1987-08-19', '555-666-7777', 'emily.clark@example.com', 'password789'),
('James', 'Brown', '1995-09-30', '888-999-0000', 'james.brown@example.com', 'password321');


INSERT INTO client_order (status, client_id, order_date, promocode_id, total_price, pharmacy_id) VALUES
('Shipped', 1, '2024-10-05', 1, 49.99, 1),
('Pending', 2, '2024-10-06', 2, 74.99, 2),
('Delivered', 3, '2024-10-07', 3, 24.99, 3),
('Shipped', 4, '2024-10-08', 4, 54.99, 4),
('Cancelled', 5, '2024-10-09', 5, 19.99, 5);


INSERT INTO orderItem (product_id, quantity, order_id) VALUES
(1, 2, 1),
(2, 3, 2),
(3, 1, 3),
(4, 4, 4),
(5, 5, 5);


INSERT INTO review (client_id, rating, text, date) VALUES
(1, 5, 'Great product!', '2024-10-07'),
(2, 4, 'Works well, but shipping was slow.', '2024-10-08'),
(3, 3, 'Average product.', '2024-10-09'),
(4, 5, 'Highly recommended!', '2024-10-10'),
(5, 2, 'Not satisfied.', '2024-10-11');


INSERT INTO role (name, description) VALUES
('Admin', 'Has full access'),
('Pharmacist', 'Can manage products and orders'),
('Manager', 'Manages employees and logistics'),
('Support', 'Provides customer support'),
('Technician', 'Manages technical operations');


INSERT INTO employee (role_id, first_name, last_name, phone, email, password_hash, passport) VALUES
(1, 'Admin', 'User', '123-555-7890', 'admin@example.com', 'hashedpass1', 123456),
(2, 'Jane', 'Pharmacist', '234-555-7890', 'jane@example.com', 'hashedpass2', 234567),
(3, 'Emily', 'Manager', '345-555-7890', 'emily@example.com', 'hashedpass3', 345678),
(4, 'Tom', 'Support', '456-555-7890', 'tom@example.com', 'hashedpass4', 456789),
(5, 'Alex', 'Technician', '567-555-7890', 'alex@example.com', 'hashedpass5', 567890);



INSERT INTO action (name, description, table_name) VALUES
('Update', 'Update record in table', 'product'),
('Insert', 'Insert new record', 'client_order'),
('Delete', 'Delete record from table', 'orderItem'),
('Login', 'Employee logged in', 'employee'),
('Logout', 'Employee logged out', 'employee');


INSERT INTO logs (employee_id, action_id, action_date) VALUES
(1, 1, '2024-10-10 10:00:00'),  -- Админ (id=1) выполнил действие 'Update'
(1, 2, '2024-10-10 10:15:00'),  -- Админ (id=1) выполнил действие 'Insert'
(1, 3, '2024-10-10 10:30:00'),  -- Админ (id=1) выполнил действие 'Delete'
(1, 4, '2024-10-10 11:00:00'),  -- Админ (id=1) выполнил действие 'Login'
(1, 5, '2024-10-10 11:30:00');  -- Админ (id=1) выполнил действие 'Logout'



INSERT INTO cart (client_id, total_price) VALUES
(1, 29.99),
(2, 44.99),
(3, 39.99),
(4, 49.99),
(5, 24.99);

ALTER TABLE product_instance
ALTER COLUMN quantity SET DEFAULT 0;
*/
