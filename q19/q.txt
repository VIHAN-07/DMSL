-- ========================================
-- DDL: Define tables and audit table for trigger
-- ========================================

-- 1) EMPLOYEE table
CREATE TABLE `Employee` (
  `person_name` VARCHAR(100) NOT NULL,
  `street`      VARCHAR(200),
  `city`        VARCHAR(100),
  PRIMARY KEY (`person_name`)
);

-- 2) COMPANY table
CREATE TABLE `Company` (
  `company_name` VARCHAR(100) NOT NULL,
  `city`         VARCHAR(100),
  PRIMARY KEY (`company_name`)
);

-- 3) WORKS table
CREATE TABLE `Works` (
  `person_name`  VARCHAR(100) NOT NULL,
  `company_name` VARCHAR(100) NOT NULL,
  `salary`       DECIMAL(12,2),
  PRIMARY KEY (`person_name`,`company_name`),
  FOREIGN KEY (`person_name`)  REFERENCES `Employee`(`person_name`)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (`company_name`) REFERENCES `Company`(`company_name`)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 4) MANAGES table
CREATE TABLE `Manages` (
  `person_name`  VARCHAR(100) NOT NULL,
  `manager_name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`person_name`),
  FOREIGN KEY (`person_name`)  REFERENCES `Employee`(`person_name`)
    ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (`manager_name`) REFERENCES `Employee`(`person_name`)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 5) WORKS_AUDIT table—to log changes to company_name in WORKS
CREATE TABLE `Works_Audit` (
  `audit_id`      INT            NOT NULL AUTO_INCREMENT,
  `person_name`   VARCHAR(100)   NOT NULL,
  `old_company`   VARCHAR(100)   NOT NULL,
  `new_company`   VARCHAR(100)   NOT NULL,
  `changed_at`    TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`audit_id`)
);


-- ========================================
-- DML: Insert sample data
-- ========================================

-- Employees
INSERT INTO `Employee` (`person_name`,`street`,`city`) VALUES
  ('John Doe',    '123 Elm St',     'Metropolis'),
  ('Mary Smith',  '456 Oak Ave',    'Metropolis'),
  ('Alice Jones', '789 Pine Rd',    'Gotham'),
  ('Bob Brown',   '321 Maple Dr',   'Gotham'),
  ('Carol White', '654 Cedar Blvd', 'Metropolis');

-- Companies
INSERT INTO `Company` (`company_name`,`city`) VALUES
  ('First Bank Corporation', 'Metropolis'),
  ('Acme Industries',        'Gotham'),
  ('Global Tech',            'Metropolis');

-- Works assignments
INSERT INTO `Works` (`person_name`,`company_name`,`salary`) VALUES
  ('John Doe',    'First Bank Corporation', 12000.00),
  ('Mary Smith',  'First Bank Corporation',  9000.00),
  ('Bob Brown',   'First Bank Corporation', 11000.00),
  ('Alice Jones', 'Acme Industries',        15000.00),
  ('Carol White', 'Global Tech',            13000.00);

-- Management hierarchy
INSERT INTO `Manages` (`person_name`,`manager_name`) VALUES
  ('John Doe',    'Mary Smith'),
  ('Alice Jones', 'Bob Brown'),
  ('Carol White', 'Mary Smith');


-- ========================================
-- DQL: Required queries
-- ========================================

-- 1) Employees who work for First Bank Corporation and earn > 10000
SELECT
  e.person_name,
  e.street,
  e.city
FROM Employee e
JOIN Works    w ON e.person_name = w.person_name
WHERE w.company_name = 'First Bank Corporation'
  AND w.salary       > 10000;

-- 2) Employees who live in the same city as the company they work for
SELECT DISTINCT
  e.person_name
FROM Employee e
JOIN Works    w ON e.person_name = w.person_name
JOIN Company  c ON w.company_name = c.company_name
WHERE e.city = c.city;

-- 3) Employees who live on the same street and in the same city as their manager
SELECT
  e.person_name
FROM Employee e
JOIN Manages  m ON e.person_name = m.person_name
JOIN Employee mgr ON m.manager_name = mgr.person_name
WHERE e.city   = mgr.city
  AND e.street = mgr.street;

-- 4) Trigger on update of Works.company_name to log old and new values
DELIMITER $$
CREATE TRIGGER `trg_after_works_update`
AFTER UPDATE ON `Works`
FOR EACH ROW
BEGIN
  IF OLD.company_name <> NEW.company_name THEN
    INSERT INTO `Works_Audit` (person_name, old_company, new_company)
    VALUES (OLD.person_name, OLD.company_name, NEW.company_name);
  END IF;
END$$
DELIMITER ;
