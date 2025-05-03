-- ========================================
-- DDL: Create schema, procedure, and trigger
-- ========================================

-- 1) Branch table
CREATE TABLE `Branch` (
  `B_No`   INT           NOT NULL,
  `B_name` VARCHAR(100)  NOT NULL,
  `B_city` VARCHAR(100),
  `asset`  DECIMAL(15,2),
  PRIMARY KEY (`B_No`),
  UNIQUE KEY (`B_name`)
);

-- 2) Customer table
CREATE TABLE `Customer` (
  `C_No`    INT          NOT NULL,
  `C_Name`  VARCHAR(100) NOT NULL,
  `C_city`  VARCHAR(100),
  `street`  VARCHAR(200),
  PRIMARY KEY (`C_No`)
);

-- 3) Loan table
CREATE TABLE `Loan` (
  `Loan_no` INT           NOT NULL,
  `B_name`  VARCHAR(100)  NOT NULL,
  `amount`  DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (`Loan_no`),
  FOREIGN KEY (`B_name`) REFERENCES `Branch`(`B_name`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- 4) Borrower table
CREATE TABLE `Borrower` (
  `C_No`     INT NOT NULL,
  `Loan_no`  INT NOT NULL,
  PRIMARY KEY (`C_No`,`Loan_no`),
  FOREIGN KEY (`C_No`)    REFERENCES `Customer`(`C_No`)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (`Loan_no`) REFERENCES `Loan`(`Loan_no`)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- 5) Audit table for loan amount changes
CREATE TABLE `Loan_Audit` (
  `audit_id`   INT           NOT NULL AUTO_INCREMENT,
  `Loan_no`    INT           NOT NULL,
  `old_amount` DECIMAL(12,2) NOT NULL,
  `new_amount` DECIMAL(12,2) NOT NULL,
  `changed_at` TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`audit_id`)
);

-- 6) Procedure: total loan amount for a given branch name
DELIMITER $$
CREATE PROCEDURE `GetBranchTotalLoan`(IN in_branch_name VARCHAR(100))
BEGIN
  SELECT
    in_branch_name   AS branch,
    SUM(amount)      AS total_loan_amount
  FROM `Loan`
  WHERE B_name = in_branch_name;
END$$
DELIMITER ;

-- 7) Trigger: log updates to loan amounts
DELIMITER $$
CREATE TRIGGER `trg_after_loan_update`
AFTER UPDATE ON `Loan`
FOR EACH ROW
BEGIN
  IF OLD.amount <> NEW.amount THEN
    INSERT INTO `Loan_Audit` (Loan_no, old_amount, new_amount)
    VALUES (OLD.Loan_no, OLD.amount, NEW.amount);
  END IF;
END$$
DELIMITER ;


-- ========================================
-- DML: Insert sample data
-- ========================================

-- Branches
INSERT INTO `Branch` (B_No, B_name,   B_city,       asset) VALUES
  (1,   'Downtown',   'Metropolis', 5000000.00),
  (2,   'Uptown',     'Metropolis', 3000000.00),
  (3,   'WestSide',   'Gotham',     4000000.00);

-- Customers
INSERT INTO `Customer` (C_No, C_Name,       C_city,      street) VALUES
  (100, 'Alice Johnson','Metropolis','123 Elm St'),
  (101, 'Bob Smith',    'Metropolis','123 Elm St'),
  (102, 'Carol White',  'Gotham',     '456 Oak Ave'),
  (103, 'David Brown',  'Gotham',     '789 Pine Rd'),
  (104, 'Eve Davis',    'Metropolis','321 Maple Dr');

-- Loans
INSERT INTO `Loan` (Loan_no, B_name,     amount) VALUES
  (5001,    'Downtown',  25000.00),
  (5002,    'Downtown',  60000.00),
  (5003,    'Uptown',    15000.00),
  (5004,    'WestSide',  80000.00),
  (5005,    'WestSide',  30000.00);

-- Borrowers
INSERT INTO `Borrower` (C_No, Loan_no) VALUES
  (100,5001),
  (100,5002),
  (101,5003),
  (102,5004),
  (103,5004),
  (104,5005);


-- ========================================
-- DQL: Queries
-- ========================================

-- 1) Names and addresses of customers who have a loan.
SELECT
  c.C_Name,
  c.street,
  c.C_city
FROM Customer c
JOIN Borrower b ON c.C_No = b.C_No;

-- 2) Loan data ordered by decreasing amounts, then increasing loan numbers.
SELECT
  Loan_no,
  B_name,
  amount
FROM `Loan`
ORDER BY amount DESC, Loan_no ASC;

-- 3) Pairs of distinct customers living at the same address but borrowing at different branches.
SELECT
  c1.C_Name AS customer1,
  c2.C_Name AS customer2,
  l1.B_name  AS branch1,
  l2.B_name  AS branch2
FROM Customer c1
JOIN Borrower b1 ON c1.C_No = b1.C_No
JOIN Loan     l1 ON b1.Loan_no = l1.Loan_no
JOIN Customer c2
  ON c2.C_city = c1.C_city
 AND c2.street = c1.street
  AND c2.C_No  > c1.C_No               -- avoid duplicate/self-pair
JOIN Borrower b2 ON c2.C_No = b2.C_No
JOIN Loan     l2 ON b2.Loan_no = l2.Loan_no
WHERE l1.B_name <> l2.B_name;

-- 4) (Procedure defined above: CALL GetBranchTotalLoan('Downtown');)

-- 5) (Trigger defined above to track updated loan amounts)
