CREATE table Food_orders (
    order_idx VARCHAR(20),
    customer_code VARCHAR(20) NOT NULL UNIQUE,
    placed_at DATETIME,
    restaurant_id VARCHAR(20),
    cuisine VARCHAR(20) NOT NULL UNIQUE,
    Order_status VARCHAR(20),
    Promo_code_Name VARCHAR(20)
);