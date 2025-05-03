-- DDL: Create Tables

CREATE TABLE Customer (
  Cust_no     INT PRIMARY KEY,
  name        VARCHAR(100),
  Street      VARCHAR(100),
  city        VARCHAR(50),
  state       VARCHAR(50)
);

CREATE TABLE `Order` (
  Order_no    INT PRIMARY KEY,
  Cust_no     INT,
  Order_date  DATE,
  Ship_date   DATE,
  ToCity      VARCHAR(50),
  ToState     VARCHAR(50),
  ToZip       VARCHAR(10),
  FOREIGN KEY (Cust_no) REFERENCES Customer(Cust_no) ON DELETE CASCADE
);

CREATE TABLE Stock (
  Stock_no    INT PRIMARY KEY,
  price       DECIMAL(10,2),
  tax         DECIMAL(5,2),
  quantity    INT DEFAULT 0
);

CREATE TABLE Contain (
  Order_no    INT,
  Stock_no    INT,
  quantity    INT,
  Discount    DECIMAL(5,2),
  PRIMARY KEY (Order_no, Stock_no),
  FOREIGN KEY (Order_no) REFERENCES `Order`(Order_no) ON DELETE CASCADE,
  FOREIGN KEY (Stock_no) REFERENCES Stock(Stock_no) ON DELETE CASCADE
);

-- Trigger: Update Stock quantity after insert into Contain

DELIMITER $$

CREATE TRIGGER trg_update_stock_quantity
AFTER INSERT ON Contain
FOR EACH ROW
BEGIN
  UPDATE Stock
  SET quantity = quantity - NEW.quantity
  WHERE Stock_no = NEW.Stock_no;
END$$

DELIMITER ;

-- DML: Insert Sample Data

INSERT INTO Customer VALUES
(1, 'Alice', '123 Maple St', 'New York', 'NY'),
(2, 'Bob',   '456 Oak St',   'Los Angeles', 'CA'),
(3, 'Charlie','789 Pine St', 'Houston', 'TX');

INSERT INTO Stock (Stock_no, price, tax, quantity) VALUES
(101, 100.00, 5.00, 50),
(102, 250.00, 10.00, 30),
(103, 75.00,  8.00, 100);

INSERT INTO `Order` VALUES
(1001, 1, '2024-04-01', '2024-04-03', 'Chicago', 'IL', '60616'),
(1002, 2, '2024-04-02', '2024-04-04', 'Seattle', 'WA', '98101'),
(1003, 1, '2024-04-03', '2024-04-05', 'Boston',  'MA', '02118');

INSERT INTO Contain VALUES
(1001, 101, 2, 5.0),
(1001, 102, 1, 0.0),
(1002, 103, 5, 10.0),
(1003, 101, 1, 5.0);

-- DQL: Required Queries

-- 1. Display all the Purchase orders of a specific Customer (Customer 1)
SELECT * FROM `Order` WHERE Cust_no = 1;

-- 2. Get the Total Value of Purchase Orders
SELECT
  c.Order_no,
  SUM(s.price * c.quantity * (1 - c.Discount / 100)) AS Total_Value
FROM Contain c
JOIN Stock s ON c.Stock_no = s.Stock_no
GROUP BY c.Order_no;

-- 3. List the Purchase Orders in descending order as per total
SELECT
  c.Order_no,
  SUM(s.price * c.quantity * (1 - c.Discount / 100)) AS Total_Value
FROM Contain c
JOIN Stock s ON c.Stock_no = s.Stock_no
GROUP BY c.Order_no
ORDER BY Total_Value DESC;

-- 4. Delete Purchase Order 1001
DELETE FROM `Order` WHERE Order_no = 1001;

-- 5. Create index on table order with column order_no
CREATE INDEX idx_order_no ON `Order`(Order_no);

-- 6. Create View on columns Order_no and Cust_no with order table
CREATE VIEW order_customer_view AS
SELECT Order_no, Cust_no FROM `Order`;
