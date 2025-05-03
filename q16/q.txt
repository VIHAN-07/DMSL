-- ========================================
-- DDL: Create tables, constraints, and triggers
-- ========================================

-- 1) CUSTOMER table
CREATE TABLE `Customer` (
  `customer_id`  INT           NOT NULL AUTO_INCREMENT,
  `name`         VARCHAR(100)  NOT NULL,
  `address`      VARCHAR(200),
  `age`          INT,
  `contact_no`   VARCHAR(20),
  `email`        VARCHAR(100),
  PRIMARY KEY (`customer_id`)
);

-- 2) ACCOUNT table
CREATE TABLE `Account` (
  `account_no`     VARCHAR(20)     NOT NULL,
  `customer_id`    INT             NOT NULL,
  `acc_type`       ENUM('savings','fixed','monthly') NOT NULL,
  `creation_date`  DATE            NOT NULL,
  `balance`        DECIMAL(12,2)   NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`account_no`),
  FOREIGN KEY (`customer_id`) REFERENCES `Customer`(`customer_id`)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- 3) TRANSACTION table
CREATE TABLE `Transaction` (
  `trans_id`     INT            NOT NULL AUTO_INCREMENT,
  `account_no`   VARCHAR(20)    NOT NULL,
  `trans_date`   DATE           NOT NULL,
  `amount`       DECIMAL(12,2)  NOT NULL,
  `trans_type`   ENUM('deposit','withdraw') NOT NULL,
  PRIMARY KEY (`trans_id`),
  FOREIGN KEY (`account_no`) REFERENCES `Account`(`account_no`)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- 4) LOAN table
CREATE TABLE `Loan` (
  `loan_id`      INT            NOT NULL AUTO_INCREMENT,
  `account_no`   VARCHAR(20)    NOT NULL,
  `loan_amount`  DECIMAL(12,2)  NOT NULL,
  `loan_date`    DATE           NOT NULL,
  PRIMARY KEY (`loan_id`),
  FOREIGN KEY (`account_no`) REFERENCES `Account`(`account_no`)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- 5) Trigger: after each transaction, update the account balance
DELIMITER $$
CREATE TRIGGER `trg_after_transaction`
AFTER INSERT ON `Transaction`
FOR EACH ROW
BEGIN
  IF NEW.trans_type = 'deposit' THEN
    UPDATE `Account`
      SET balance = balance + NEW.amount
      WHERE account_no = NEW.account_no;
  ELSE
    UPDATE `Account`
      SET balance = balance - NEW.amount
      WHERE account_no = NEW.account_no;
  END IF;
END$$
DELIMITER ;


-- ========================================
-- DML: Insert sample data
-- ========================================

-- Customers
INSERT INTO `Customer` (`name`,`address`,`age`,`contact_no`,`email`) VALUES
  ('John Doe','123 Elm St, Springfield',45,'555-0101','john.doe@example.com'),
  ('Jane Smith','456 Oak Ave, Riverdale',38,'555-0202','jane.smith@example.com'),
  ('Alice Johnson','789 Pine Rd, Bedford',29,'555-0303','alice.johnson@example.com'),
  ('Bob Williams','321 Maple Dr, Lakeside',52,'555-0404','bob.williams@example.com');

-- Accounts (including one 'TU001' for later update)
INSERT INTO `Account` (`account_no`,`customer_id`,`acc_type`,`creation_date`,`balance`) VALUES
  ('TU001',    1, 'savings', '2007-05-10',  50000.00),
  ('AC1001',   2, 'fixed',   '2008-01-15', 100000.00),
  ('AC2002',   2, 'savings', '2008-07-20',  20000.00),
  ('AC3003',   3, 'monthly', '2008-08-01',  15000.00),
  ('AC4004',   4, 'fixed',   '2006-09-30',  75000.00);

-- Transactions (including dates 2008-08-28 and 2008-08-29)
INSERT INTO `Transaction` (`account_no`,`trans_date`,`amount`,`trans_type`) VALUES
  ('TU001',   '2008-08-28',  30000.00, 'deposit'),
  ('TU001',   '2008-08-28',   5000.00, 'withdraw'),
  ('AC1001',  '2008-08-28',  40000.00, 'deposit'),
  ('AC2002',  '2008-08-29',  60000.00, 'deposit'),
  ('AC3003',  '2008-08-29',  10000.00, 'withdraw'),
  ('AC4004',  '2008-08-29',   5000.00, 'deposit');

-- Loans
INSERT INTO `Loan` (`account_no`,`loan_amount`,`loan_date`) VALUES
  ('TU001',  60000.00, '2009-02-15'),
  ('AC2002', 30000.00, '2010-06-01'),
  ('AC4004', 80000.00, '2008-12-20');


-- ========================================
-- DQL: Required Queries
-- ========================================

-- a) List the details of account holders who have a ‘savings’ account.
SELECT
  c.customer_id,
  c.name,
  c.address,
  a.account_no,
  a.balance
FROM Customer c
JOIN Account  a ON c.customer_id = a.customer_id
WHERE a.acc_type = 'savings';

-- b) List the Name and address of account holders with loan amount more than 50,000.
SELECT DISTINCT
  c.customer_id,
  c.name,
  c.address
FROM Customer c
JOIN Account  a ON c.customer_id = a.customer_id
JOIN Loan     l ON a.account_no = l.account_no
WHERE l.loan_amount > 50000.00;

-- c) Change the name of the customer to ‘ABC’ whose account number is ’TU001’.
UPDATE Customer c
JOIN Account a ON c.customer_id = a.customer_id
SET c.name = 'ABC'
WHERE a.account_no = 'TU001';

-- d) List the account numbers with total deposit more than 80,000.
SELECT
  t.account_no,
  SUM(t.amount) AS total_deposit
FROM Transaction t
WHERE t.trans_type = 'deposit'
GROUP BY t.account_no
HAVING SUM(t.amount) > 80000.00;

-- e) List the number of fixed deposit accounts in the bank.
SELECT
  COUNT(*) AS fixed_account_count
FROM Account
WHERE acc_type = 'fixed';

-- f) Display the detailed transactions on 28th Aug, 2008.
SELECT *
FROM Transaction
WHERE trans_date = '2008-08-28';

-- h) Display the total amount deposited and withdrawn on 29th Aug, 2008.
SELECT
  SUM(CASE WHEN trans_type = 'deposit'  THEN amount ELSE 0 END) AS total_deposited,
  SUM(CASE WHEN trans_type = 'withdraw' THEN amount ELSE 0 END) AS total_withdrawn
FROM Transaction
WHERE trans_date = '2008-08-29';

-- i) List the details of customers who have a loan.
SELECT DISTINCT
  c.customer_id,
  c.name,
  c.address,
  l.loan_amount,
  l.loan_date
FROM Customer c
JOIN Account a ON c.customer_id = a.customer_id
JOIN Loan    l ON a.account_no = l.account_no;

-- ========================================
-- PL/SQL: Procedure to display Savings and Loan info
-- ========================================

DELIMITER $$
CREATE PROCEDURE `ShowSavingsAndLoans`()
BEGIN
  SELECT
    c.customer_id,
    c.name,
    a.account_no     AS savings_account,
    a.balance        AS savings_balance,
    l.loan_id,
    l.loan_amount,
    l.loan_date
  FROM Customer c
  LEFT JOIN Account a 
    ON c.customer_id = a.customer_id
   AND a.acc_type = 'savings'
  LEFT JOIN Loan    l 
    ON a.account_no = l.account_no
  ORDER BY c.customer_id;
END$$
DELIMITER ;
