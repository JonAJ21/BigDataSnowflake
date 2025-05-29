-- Скопируем mock_data/*.csv в таблицу mock_data

CREATE TABLE mock_data (
    id INT,
    
    customer_first_name VARCHAR(50),
    customer_last_name VARCHAR(50),
    customer_age INT,
    customer_email VARCHAR(100),
    customer_country VARCHAR(50),
    customer_postal_code VARCHAR(20),
    customer_pet_type VARCHAR(50),
    customer_pet_name VARCHAR(50),
    customer_pet_breed VARCHAR(50),
    seller_first_name VARCHAR(50),
    seller_last_name VARCHAR(50),
    seller_email VARCHAR(100),
    seller_country VARCHAR(50),
    seller_postal_code VARCHAR(20),
    product_name VARCHAR(100),
    product_category VARCHAR(50),
    product_price DECIMAL(10, 2),
    product_quantity INT,
    sale_date DATE,
    sale_customer_id INT,
    sale_seller_id INT,
    sale_product_id INT,
    sale_quantity INT,
    sale_total_price DECIMAL(10, 2),
    store_name VARCHAR(100),
    store_location VARCHAR(100),
    store_city VARCHAR(50),
    store_state VARCHAR(50),
    store_country VARCHAR(50),
    store_phone VARCHAR(20),
    store_email VARCHAR(100),
    pet_category VARCHAR(50),
    product_weight DECIMAL(10, 2),
    product_color VARCHAR(30),
    product_size VARCHAR(20),
    product_brand VARCHAR(50),
    product_material VARCHAR(50),
    product_description TEXT,
    product_rating DECIMAL(3, 1),
    product_reviews INT,
    product_release_date DATE,
    product_expiry_date DATE,
    supplier_name VARCHAR(100),
    supplier_contact VARCHAR(100),
    supplier_email VARCHAR(100),
    supplier_phone VARCHAR(20),
    supplier_address TEXT,
    supplier_city VARCHAR(50),
    supplier_country VARCHAR(50)
);


COPY mock_data FROM '/mock_data/MOCK_DATA.csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/mock_data/MOCK_DATA (1).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/mock_data/MOCK_DATA (2).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/mock_data/MOCK_DATA (3).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/mock_data/MOCK_DATA (4).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/mock_data/MOCK_DATA (5).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/mock_data/MOCK_DATA (6).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/mock_data/MOCK_DATA (7).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/mock_data/MOCK_DATA (8).csv' DELIMITER ',' CSV HEADER;
COPY mock_data FROM '/mock_data/MOCK_DATA (9).csv' DELIMITER ',' CSV HEADER;

-- Создадим таблицы фактов и измерений

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE dim_customer (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    age INT,
    email VARCHAR(100),
    country VARCHAR(50),
    postal_code VARCHAR(20)
);

CREATE TABLE dim_pet (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES dim_customer(id),
    pet_type VARCHAR(50),
    pet_name VARCHAR(50),
    pet_breed VARCHAR(50),
    pet_category VARCHAR(50)
);

CREATE TABLE dim_seller (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    country VARCHAR(50),
    postal_code VARCHAR(20)
);

CREATE TABLE dim_store (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100),
    location VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100)
);

CREATE TABLE dim_supplier (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100),
    contact VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE dim_product (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100),
    category VARCHAR(50),
    weight DECIMAL(10, 2),
    color VARCHAR(30),
    size VARCHAR(20),
    brand VARCHAR(50),
    material VARCHAR(50),
    description TEXT,
    rating DECIMAL(3, 1),
    reviews INT,
    release_date DATE,
    expiry_date DATE,
    supplier_id UUID REFERENCES dim_supplier(id),
    price DECIMAL(10, 2),
    quantity INT
);

CREATE TABLE fact_sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sale_date DATE,
    sale_customer_id UUID,
    sale_seller_id UUID,
    product_id UUID,
    store_id UUID,
    sale_quantity INT,
    sale_total_price DECIMAL(10, 2),
    FOREIGN KEY (sale_customer_id) REFERENCES dim_customer(id),
    FOREIGN KEY (sale_seller_id) REFERENCES dim_seller(id),
    FOREIGN KEY (product_id) REFERENCES dim_product(id),
    FOREIGN KEY (store_id) REFERENCES dim_store(id)
);

-- Перенесем данные из mock_datа в таблицы фактов и измерений

INSERT INTO dim_customer (first_name, last_name, age, email, country, postal_code)
SELECT DISTINCT
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code
FROM mock_data
WHERE customer_email IS NOT NULL;

INSERT INTO dim_seller (first_name, last_name, email, country, postal_code)
SELECT DISTINCT
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM mock_data
WHERE seller_email IS NOT NULL;

INSERT INTO dim_supplier (name, contact, email, phone, address, city, country)
SELECT DISTINCT
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM mock_data
WHERE supplier_name IS NOT NULL;

INSERT INTO dim_store (name, location, city, state, country, phone, email)
SELECT DISTINCT
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM mock_data
WHERE store_name IS NOT NULL;

INSERT INTO dim_product (
    name, category, weight, color, size, brand, material,
    description, rating, reviews, release_date, expiry_date,
    supplier_id, price, quantity
)
SELECT DISTINCT
    m.product_name,
    m.product_category,
    m.product_weight,
    m.product_color,
    m.product_size,
    m.product_brand,
    m.product_material,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    m.product_release_date,
    m.product_expiry_date,
    s.id,
    m.product_price,
    m.product_quantity
FROM mock_data m
JOIN dim_supplier s
    ON m.supplier_name = s.name
    AND m.supplier_email = s.email;

INSERT INTO dim_pet (customer_id, pet_type, pet_name, pet_breed, pet_category)
SELECT DISTINCT
    c.id,
    m.customer_pet_type,
    m.customer_pet_name,
    m.customer_pet_breed,
    m.pet_category
FROM mock_data m
JOIN dim_customer c
    ON m.customer_email = c.email;

WITH
customer_map AS (
    SELECT DISTINCT ON (email)
        id, email
    FROM dim_customer
),
seller_map AS (
    SELECT DISTINCT ON (email)
        id, email
    FROM dim_seller
),
store_map AS (
    SELECT DISTINCT ON (name, email)
        id, name, email
    FROM dim_store
),
product_map AS (
    SELECT DISTINCT ON (name, price, category)
        id, name, price, category
    FROM dim_product
)
INSERT INTO fact_sales (
    sale_date,
    sale_customer_id,
    sale_seller_id,
    product_id,
    store_id,
    sale_quantity,
    sale_total_price
)
SELECT
    m.sale_date,
    cm.id,
    sm.id,
    pm.id,
    stm.id,
    m.sale_quantity,
    m.sale_total_price
FROM mock_data m
JOIN customer_map cm
    ON m.customer_email = cm.email
JOIN seller_map sm
    ON m.seller_email = sm.email
JOIN product_map pm
    ON m.product_name = pm.name
    AND m.product_price = pm.price
    AND m.product_category = pm.category
JOIN store_map stm
    ON m.store_name = stm.name
    AND m.store_email = stm.email;