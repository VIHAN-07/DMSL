-- ─────────────────────────────────────────────────────────────────────────────
-- Complete SQL Script: DDL, DML, Queries, and Triggers for Supplier–Parts–Catalog
-- ─────────────────────────────────────────────────────────────────────────────

-- 1) DDL: Create tables with integrity constraints
CREATE TABLE Supplier (
  sid      INT            PRIMARY KEY,
  sname    VARCHAR(100)   NOT NULL,
  address  VARCHAR(200)
);

CREATE TABLE Parts (
  pid      INT            PRIMARY KEY,
  pname    VARCHAR(100)   NOT NULL,
  color    VARCHAR(50)    NOT NULL
);

CREATE TABLE Catalog (
  sid      INT            NOT NULL,
  pid      INT            NOT NULL,
  cost     DECIMAL(10,2)  NOT NULL,
  PRIMARY KEY (sid, pid),
  FOREIGN KEY (sid) REFERENCES Supplier(sid),
  FOREIGN KEY (pid) REFERENCES Parts(pid)
);

-- Backup table for cost changes
CREATE TABLE Catalog_Cost_Backup (
  sid        INT        NOT NULL,
  pid        INT        NOT NULL,
  old_cost   DECIMAL(10,2),
  new_cost   DECIMAL(10,2),
  changed_at DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- 2) DML: Insert sample data

-- Suppliers
INSERT INTO Supplier (sid, sname, address) VALUES
  (1, 'John Supplies',   'Mumbai'),
  (2, 'ABC Traders',     'Delhi'),
  (3, 'RedLine Co',      'Chennai'),
  (4, 'Green Goods',     'Bengaluru'),
  (5, 'Universal Parts', 'Kolkata');

-- Parts
INSERT INTO Parts (pid, pname, color) VALUES
  (101, 'Bolt',     'Red'),
  (102, 'Nut',      'Green'),
  (103, 'Screw',    'Blue'),
  (104, 'Washer',   'Red'),
  (105, 'Pin',      'Green'),
  (106, 'Rivet',    'Silver'),
  (107, 'Bracket',  'Red'),
  (108, 'Spacer',   'Black'),
  (109, 'Clip',     'Green'),
  (110, 'Gasket',   'Yellow');

-- Catalog entries
INSERT INTO Catalog (sid, pid, cost) VALUES
  (1, 101, 30.00),
  (1, 102, 20.00),
  (2, 103, 15.00),
  (2, 104, 40.00),
  (3, 104, 35.00),
  (3, 101, 32.00),
  (4, 105, 25.00),
  (4, 109, 22.00),
  (5, 106, 18.50),
  (5, 107, 45.00);


-- 3) DQL: Required queries

-- i)  Names of suppliers who supply some red parts
SELECT DISTINCT s.sname
FROM Supplier s
JOIN Catalog  c ON s.sid = c.sid
JOIN Parts    p ON c.pid = p.pid
WHERE p.color = 'Red'
;

-- ii) Names of all parts whose cost is more than Rs. 25
SELECT DISTINCT p.pname
FROM Parts    p
JOIN Catalog  c ON p.pid = c.pid
WHERE c.cost > 25
;

-- iii) Names of all parts whose color is green
SELECT pname
FROM Parts
WHERE color = 'Green'
;

-- iv) Supplier name, part name, color, and cost
SELECT s.sname,
       p.pname,
       p.color,
       c.cost
FROM Supplier s
JOIN Catalog  c ON s.sid = c.sid
JOIN Parts    p ON c.pid = p.pid
;


-- 4) Triggers

-- v) Backup cost changes before update
DELIMITER $$
CREATE TRIGGER trg_backup_cost
BEFORE UPDATE ON Catalog
FOR EACH ROW
BEGIN
  INSERT INTO Catalog_Cost_Backup (sid, pid, old_cost, new_cost)
  VALUES (OLD.sid, OLD.pid, OLD.cost, NEW.cost);
END$$
DELIMITER ;

-- vi) Prevent insertion of negative cost
DELIMITER $$
CREATE TRIGGER trg_prevent_negative_cost
BEFORE INSERT ON Catalog
FOR EACH ROW
BEGIN
  IF NEW.cost < 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Cannot insert negative cost into Catalog';
  END IF;
END$$
DELIMITER ;
