CREATE table Food_orders (
    order_idx VARCHAR(20),
    customer_code VARCHAR(20) NOT NULL UNIQUE,
    placed_at DATETIME,
    restaurant_id VARCHAR(20),
    cuisine VARCHAR(20) NOT NULL UNIQUE,
    Order_status VARCHAR(20),
    Promo_code_Name VARCHAR(20)
);


CREATE database food_delivery_order;


DROP database fooddelivery;

USE food_delivery_order;


CREATE TABLE food_orders (
    order_idx VARCHAR(20),
    customer_code VARCHAR(20),
    placed_at DATETIME,
    restaurant_id VARCHAR(10),
    cuisine VARCHAR(20),
    order_status VARCHAR(20),
    promo_code_name VARCHAR(20)
);

DESCRIBE food_orders;

SELECT * FROM food_orders;

RENAME TABLE orders TO food_orders;


ALTER TABLE food_orders
RENAME COLUMN Order_id TO order_idx,
RENAME COLUMN Customer_code TO customer_code,
RENAME COLUMN Placed_at TO placed_at,
RENAME COLUMN Restaurant_id TO restaurant_id,
RENAME COLUMN Cuisine TO cuisine,
RENAME COLUMN Order_status TO order_status,
RENAME COLUMN Promo_code_Name TO promo_code_name;


-- INSERT INTO food_orders (order_idx, customer_code, placed_at, restaurant_id, cuisine, order_status, promo_code_name)



WITH CTE AS (
SELECT cuisine, restaurant_id, COUNT(*) AS no_of_orders
FROM food_orders
GROUP BY cuisine, restaurant_id
)
SELECT * FROM (SELECT *, ROW_NUMBER() OVER(partition by cuisine ORDER BY no_of_orders DESC) AS rn FROM CTE) 
WHERE rn <= 3;


-- the daily new customer count from the launch date (everyday how many new customers are we acquiring)
WITH CTE AS(
SELECT customer_code, CAST(MIN(placed_at) AS DATE) AS first_order_date
FROM food_orders
GROUP BY customer_code)

SELECT first_order_date, COUNT(*) AS no_of_new_customers
FROM CTE
GROUP BY first_order_date
ORDER BY first_order_date;

SELECT * FROM food_orders;

-- the count of all the users who were acquired in JAN 2025 and 
-- only placed one order in JAN and did not place any other order

SELECT customer_code, COUNT(*) AS no_of_orders
FROM food_orders

WHERE MONTH(placed_at) = 1 AND YEAR(placed_at) = 2025
AND customer_code NOT IN (SELECT DISTINCT customer_code
FROM food_orders WHERE NOT (MONTH(placed_at) = 1 AND YEAR(placed_at) = 2025)
) 
GROUP BY customer_code
HAVING COUNT(*) = 1;


-- list all the customers with no order in the last 7 days but were acquired one month 
-- ago with their first order on promo

WITH CTE AS(
SELECT customer_code, MIN(placed_at) AS first_order_date, MAX(placed_at) AS lastest_order_date
FROM food_orders
GROUP BY customer_code
)
SELECT CTE.*, food_orders.promo_code_name AS first_order_promo FROM CTE
inner join food_orders on CTE.customer_code=food_orders.customer_code AND CTE.first_order_date=food_orders.placed_at
WHERE lastest_order_date < DATE_ADD(NOW(), INTERVAL -7 DAY)
AND first_order_date < DATE_ADD(NOW(), INTERVAL -1 MONTH) AND food_orders.promo_code_name IS NOT NULL;



-- the growth team is planning to create a trigger that will target customers after their every
-- third order with a personalized communication and they have asked you to create a query this

WITH CTE AS (
SELECT *, ROW_NUMBER() OVER(PARTITION BY customer_code ORDER BY placed_at) AS order_number
FROM food_orders
)

SELECT * FROM CTE
WHERE order_number % 3 = 0 AND CAST(placed_at AS DATE) = CAST(NOW() AS DATE);


WITH customer_order_sequence AS (
    SELECT customer_code, order_idx, placed_at, 
    ROW_NUMBER() OVER(PARTITION BY customer_code ORDER BY placed_at) AS order_number
    FROM food_orders
)
SELECT 
    customer_code, order_idx,
    placed_at AS milestone_order_date,
    order_number AS milestone_number
FROM customer_order_sequence
WHERE order_number % 3 = 0
ORDER BY placed_at DESC;


ALTER TABLE food_orders
RENAME COLUMN Order_id TO order_idx,
RENAME COLUMN Customer_code TO customer_code,
RENAME COLUMN Placed_at TO placed_at,
RENAME COLUMN Restaurant_id TO restaurant_id,
RENAME COLUMN Cuisine TO cuisine,
RENAME COLUMN Order_status TO order_status,
RENAME COLUMN Promo_code_Name TO promo_code_name;


-- list customers who placed more than 1 order and all their orders on a promo only
SELECT customer_code, COUNT(*) AS no_of_orders, COUNT(promo_code_name) AS promo_orders
FROM food_orders
GROUP BY customer_code
HAVING COUNT(*) > 1 AND COUNT(*) = COUNT(promo_code_name);


-- what percent of consumers were organically acquired in JAN 2025

WITH CTE AS (
SELECT *, ROW_NUMBER() OVER (partition by customer_code ORDER BY placed_at) AS rn
FROM food_orders
WHERE MONTH(placed_at) = 1
)

SELECT COUNT(CASE WHEN rn = 1 AND promo_code_name IS NULL THEN customer_code END)*100.0 / COUNT(DISTINCT customer_code)
FROM CTE;