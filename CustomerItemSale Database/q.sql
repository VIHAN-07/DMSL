-- ─────────────────────────────────────────────────────────────────────────────
-- 1) DDL: Create tables with integrity constraints
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE customer (
  cust_id    INT            PRIMARY KEY,
  cust_name  VARCHAR(100)   NOT NULL
);

CREATE TABLE item (
  item_id    INT            PRIMARY KEY,
  item_name  VARCHAR(100)   NOT NULL,
  price      INT            NOT NULL
);

CREATE TABLE sale (
  bill_no     INT            NOT NULL,
  bill_date   DATE           NOT NULL,
  cust_id     INT            NOT NULL,
  item_id     INT            NOT NULL,
  qty_sold    INT            NOT NULL,
  PRIMARY KEY (bill_no, item_id),
  FOREIGN KEY (cust_id) REFERENCES customer(cust_id),
  FOREIGN KEY (item_id) REFERENCES item(item_id)
);


-- ─────────────────────────────────────────────────────────────────────────────
-- 2) DML: Insert ~10 records in each table
-- ─────────────────────────────────────────────────────────────────────────────

-- Customers
INSERT INTO customer (cust_id, cust_name) VALUES
  (1,  'Alice'),
  (2,  'Bob'),
  (3,  'Carol'),
  (4,  'Dave'),
  (5,  'Eve'),
  (6,  'Frank'),
  (7,  'Grace'),
  (8,  'Heidi'),
  (9,  'Ivan'),
  (10, 'Judy');

-- Items
INSERT INTO item (item_id, item_name, price) VALUES
  (1,  'Pen',            50),
  (2,  'Notebook',      150),
  (3,  'Backpack',      300),
  (4,  'Calculator',    250),
  (5,  'Folder',         75),
  (6,  'Stapler',       225),
  (7,  'Marker',         40),
  (8,  'Desk Lamp',     400),
  (9,  'Chair',         800),
  (10, 'Desk',         1200);

-- Sales  
-- (Assume today = '2025-05-03')
INSERT INTO sale (bill_no, bill_date, cust_id, item_id, qty_sold) VALUES
  (1001, '2025-05-03', 5,  3, 2),
  (1001, '2025-05-03', 5,  8, 1),
  (1002, '2025-05-02', 1,  4, 5),
  (1003, '2025-05-03', 2,  6, 1),
  (1003, '2025-05-03', 2,  7, 3),
  (1004, '2025-05-03', 9, 10, 2),
  (1005, '2025-05-01',10,  2, 1),
  (1006, '2025-05-03', 4,  1, 1),
  (1007, '2025-05-03', 8,  9, 2),
  (1008, '2025-05-02', 3,  5, 4),
  (1009, '2025-05-03', 7,  4, 2),
  (1010, '2025-05-03', 6,  3, 3);


-- ─────────────────────────────────────────────────────────────────────────────
-- 3) DQL: Required queries
-- ─────────────────────────────────────────────────────────────────────────────

-- (c) List all the bills for today with customer names and item numbers
SELECT 
  s.bill_no,
  s.bill_date,
  c.cust_name,
  s.item_id
FROM sale   AS s
JOIN customer AS c ON s.cust_id = c.cust_id
WHERE s.bill_date = CURDATE()
;

-- (d) List total bill details with qty sold, price, and final amount (per line)
SELECT
  s.bill_no,
  s.item_id,
  s.qty_sold,
  i.price,
  (s.qty_sold * i.price) AS final_amount
FROM sale AS s
JOIN item AS i ON s.item_id = i.item_id
;

-- (e) Details of customers who bought a product priced > 200
SELECT DISTINCT
  c.cust_id,
  c.cust_name
FROM customer AS c
JOIN sale     AS s ON c.cust_id = s.cust_id
JOIN item     AS i ON s.item_id  = i.item_id
WHERE i.price > 200
;

-- (f) Item details and total quantity sold as of today
SELECT
  i.item_id,
  i.item_name,
  SUM(s.qty_sold) AS total_qty_sold
FROM item AS i
JOIN sale AS s ON i.item_id = s.item_id
WHERE s.bill_date = CURDATE()
GROUP BY i.item_id, i.item_name
;


-- ─────────────────────────────────────────────────────────────────────────────
-- 4) Procedure: List products bought by a given customer (e.g. cust_id = 5)
-- ─────────────────────────────────────────────────────────────────────────────

DELIMITER $$
CREATE PROCEDURE ProductsByCustomer(IN in_cust_id INT)
BEGIN
  SELECT DISTINCT
    i.item_id,
    i.item_name
  FROM sale AS s
  JOIN item AS i ON s.item_id = i.item_id
  WHERE s.cust_id = in_cust_id
  ;
END$$
DELIMITER ;

-- To invoke for customer 5:
-- CALL ProductsByCustomer(5);
