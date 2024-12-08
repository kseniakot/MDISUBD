/*CREATE TABLE description (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE product_type (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE manufacturer (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE product (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description_id INT REFERENCES description(id),
    price DECIMAL(10, 2) NOT NULL,
    product_type_id INT REFERENCES product_type(id),
    photo VARCHAR(255),
    manufacturer_id INT REFERENCES manufacturer(id),
    analog_code INT
);

CREATE TABLE address (
    id SERIAL PRIMARY KEY,
    street VARCHAR(255) NOT NULL,
    building INT NOT NULL
);

CREATE TABLE pharmacy (
    id SERIAL PRIMARY KEY,
    address_id INT REFERENCES address(id)
);

CREATE TABLE product_instance (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES product(id),
    quantity INT NOT NULL,
    pharmacy_id INT REFERENCES pharmacy(id)
);

CREATE TABLE promocode (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL,
    discount DECIMAL(5, 2) NOT NULL
);

CREATE TABLE client (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    phone VARCHAR(20),
    email VARCHAR(255),
    password VARCHAR(255)
);

CREATE TABLE client_order (
    id SERIAL PRIMARY KEY,
    status VARCHAR(50) NOT NULL,
    client_id INT REFERENCES client(id) ON DELETE CASCADE,
    order_date TIMESTAMP NOT NULL,
    promocode_id INT REFERENCES Promocode(id),
    total_price DECIMAL(10, 2),
    pharmacy_id INT REFERENCES Pharmacy(id)
);

CREATE TABLE orderItem (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES product(id),
    quantity INT NOT NULL,
    order_id INT NOT NULL,
    order_date TIMESTAMP NOT NULL,
    FOREIGN KEY (order_id, order_date) REFERENCES client_order(id, order_date) ON DELETE CASCADE
);


CREATE TABLE review (
    id SERIAL PRIMARY KEY,
    client_id INT REFERENCES client(id),
    rating INT NOT NULL,
    text TEXT,
    date TIMESTAMP NOT NULL
);

CREATE TABLE cart (
    client_id INT PRIMARY KEY REFERENCES client(id) ON DELETE CASCADE,
    total_price DECIMAL(10, 2)
);

CREATE TABLE cartItem (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES product(id),
    quantity INT NOT NULL,
    cart_id INT REFERENCES cart(client_id)
);

CREATE TABLE role (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE employee (
    id SERIAL PRIMARY KEY,
    role_id INT REFERENCES role(id),
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    password_hash VARCHAR(255),
    passport INT
);

CREATE TABLE action (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    table_name VARCHAR(100)
);

CREATE TABLE logs (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employee(id),
    action_id INT REFERENCES action(id),
    action_date TIMESTAMP NOT NULL
);*/
