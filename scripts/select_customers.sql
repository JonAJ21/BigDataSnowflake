-- Выберка всех клиентов с их данными

SELECT 
    sale_customer_id, 
    customer_first_name, 
    customer_last_name, 
    customer_age, 
    customer_email,
    customer_country,
    customer_postal_code,
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed
FROM
    mock_data
ORDER BY sale_customer_id

-- Из этого видно, что sale_customer_id не соответствует различным id клиентов
