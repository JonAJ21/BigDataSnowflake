-- Проверим, что у все индексы id = 1,2, ..., 1000 повторяются ровно 10 раз 

WITH same_ids_count AS (
    SELECT id, count(*) AS cnt
    FROM mock_data 
    GROUP BY id
    ORDER BY id
)
SELECT count(id) FROM same_ids_count
WHERE same_ids_count.cnt <> 10; -- 0