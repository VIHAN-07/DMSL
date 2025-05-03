-- ─────────────── 1) DDL: Define tables ────────────────────────────────────────

CREATE TABLE customers (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  mobile     VARCHAR(15)  NOT NULL,
  city       VARCHAR(50)  NOT NULL
);

CREATE TABLE products (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(50)  NOT NULL,
  price      DECIMAL(10,2) NOT NULL
);

CREATE TABLE orders (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  customer_id  INT NOT NULL,
  order_date   DATE      NOT NULL,
  FOREIGN KEY(customer_id) REFERENCES customers(id)
);

CREATE TABLE order_items (
  order_id    INT NOT NULL,
  product_id  INT NOT NULL,
  quantity    INT NOT NULL,
  PRIMARY KEY(order_id, product_id),
  FOREIGN KEY(order_id)   REFERENCES orders(id),
  FOREIGN KEY(product_id) REFERENCES products(id)
);


-- ─────────────── 2) DML: Insert sample data ─────────────────────────────────

-- Customers
INSERT INTO customers (name, mobile, city) VALUES
  ('Alice', '9999000001', 'Pune'),
  ('Bob',   '9999000002', 'Mumbai'),
  ('Carol', '9999000003', 'Pune'),
  ('Dave',  '9999000004', 'Delhi'),
  ('Eve',   '9999000005', 'Pune');

-- Products
INSERT INTO products (name, price) VALUES
  ('Shoes', 200.00),
  ('Cloth', 100.00),
  ('Watch', 500.00),
  ('Bag',   300.00);

-- Orders
INSERT INTO orders (customer_id, order_date) VALUES
  (1, '2025-04-10'),  -- Alice
  (1, '2025-04-15'),
  (2, '2025-04-12'),  -- Bob
  (3, '2025-04-13'),  -- Carol
  (1, '2025-04-20'),
  (4, '2025-04-22'),  -- Dave
  (5, '2025-04-20');  -- Eve

-- Order_Items
INSERT INTO order_items (order_id, product_id, quantity) VALUES
  (1, 1, 1),  -- Alice: Shoes ×1
  (1, 2, 2),  -- Alice: Cloth ×2
  (2, 3, 1),  -- Alice: Watch ×1
  (3, 4, 1),  -- Bob:   Bag   ×1
  (3, 1, 1),  -- Bob:   Shoes ×1
  (4, 2, 5),  -- Carol: Cloth ×5
  (5, 4, 5),  -- Alice: Bag   ×5  (5×300 = 1500)
  (6, 1, 1),  -- Dave:  Shoes ×1
  (6, 3, 1),  -- Dave:  Watch ×1
  (7, 2,10);  -- Eve:   Cloth ×10


-- ─────────────── 3) Queries & Procedure ─────────────────────────────────────

-- 1. Name of customer with the most orders
SELECT c.name
FROM customers AS c
JOIN orders    AS o  ON o.customer_id = c.id
GROUP BY c.id
ORDER BY COUNT(*) DESC
LIMIT 1
;

-- 2. Mobile no. of customer with the highest total spend
SELECT c.mobile
FROM customers   AS c
JOIN orders      AS o  ON o.customer_id = c.id
JOIN order_items AS oi ON oi.order_id   = o.id
JOIN products    AS p  ON p.id            = oi.product_id
GROUP BY c.id
ORDER BY SUM(oi.quantity * p.price) DESC
LIMIT 1
;

-- 3. Total number of customers
SELECT COUNT(*) AS total_customers
FROM customers
;

-- 4. How many customers are from Pune?
SELECT COUNT(*) AS pune_customers
FROM customers
WHERE city = 'Pune'
;

-- 5. Customers who purchased both “Shoes” AND “Cloth”
SELECT c.name
FROM customers   AS c
JOIN orders      AS o  ON o.customer_id = c.id
JOIN order_items AS oi ON oi.order_id   = o.id
JOIN products    AS p  ON p.id            = oi.product_id
WHERE p.name IN ('Shoes','Cloth')
GROUP BY c.id
HAVING COUNT(DISTINCT p.name) = 2
;

-- 6. Top 10 buyers by total spend
SELECT c.name,
       SUM(oi.quantity * p.price) AS total_spent
FROM customers   AS c
JOIN orders      AS o  ON o.customer_id = c.id
JOIN order_items AS oi ON oi.order_id   = o.id
JOIN products    AS p  ON p.id            = oi.product_id
GROUP BY c.id
ORDER BY total_spent DESC
LIMIT 10
;

-- 7. All orders whose total > 1000
SELECT o.id             AS order_id,
       SUM(oi.quantity * p.price) AS order_total
FROM orders      AS o
JOIN order_items AS oi ON oi.order_id   = o.id
JOIN products    AS p  ON p.id            = oi.product_id
GROUP BY o.id
HAVING order_total > 1000
;

-- 8. Every customer with their total buying amount (0 if none)
SELECT c.name,
       COALESCE(SUM(oi.quantity * p.price), 0) AS total_bought
FROM customers   AS c
LEFT JOIN orders      AS o  ON o.customer_id = c.id
LEFT JOIN order_items AS oi ON oi.order_id   = o.id
LEFT JOIN products    AS p  ON p.id            = oi.product_id
GROUP BY c.id
;

-- 9. PROCEDURE: return total spend PER customer
DELIMITER $$
CREATE PROCEDURE TotalPricePerCustomer()
BEGIN
  SELECT
    c.id,
    c.name,
    COALESCE(SUM(oi.quantity * p.price),0) AS total_spent
  FROM customers   AS c
  LEFT JOIN orders      AS o  ON o.customer_id = c.id
  LEFT JOIN order_items AS oi ON oi.order_id   = o.id
  LEFT JOIN products    AS p  ON p.id            = oi.product_id
  GROUP BY c.id;
END $$
DELIMITER ;

-- To call it:
-- CALL TotalPricePerCustomer();
