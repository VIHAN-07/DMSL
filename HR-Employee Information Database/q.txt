-- ========================================
-- DDL: Create schema, audit table, procedure & triggers
-- ========================================

-- 1) LOCATIONS table
CREATE TABLE `Locations` (
  `Location_id` INT          NOT NULL,
  `street`      VARCHAR(100),
  `city`        VARCHAR(50),
  `state`       VARCHAR(50),
  `country`     VARCHAR(50),
  PRIMARY KEY (`Location_id`)
);

-- 2) DEPARTMENTS table
CREATE TABLE `Departments` (
  `Department_id` INT          NOT NULL,
  `dept_name`     VARCHAR(100) NOT NULL,
  `location_id`   INT          NOT NULL,
  PRIMARY KEY (`Department_id`),
  FOREIGN KEY (`location_id`) REFERENCES `Locations`(`Location_id`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- 3) JOBS table
CREATE TABLE `Jobs` (
  `Job_id`     VARCHAR(10) NOT NULL,
  `job_title`  VARCHAR(100) NOT NULL,
  `min_salary` DECIMAL(10,2),
  `max_salary` DECIMAL(10,2),
  PRIMARY KEY (`Job_id`)
);

-- 4) EMPLOYEES table
CREATE TABLE `Employees` (
  `Employee_id`   INT           NOT NULL,
  `first_name`    VARCHAR(50)   NOT NULL,
  `last_name`     VARCHAR(50)   NOT NULL,
  `email`         VARCHAR(100)  NOT NULL,
  `ph_no`         VARCHAR(20),
  `hire_date`     DATE          NOT NULL,
  `Job_id`        VARCHAR(10)   NOT NULL,
  `Salary`        DECIMAL(10,2) NOT NULL,
  `department_id` INT           NOT NULL,
  PRIMARY KEY (`Employee_id`),
  FOREIGN KEY (`Job_id`)        REFERENCES `Jobs`(`Job_id`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  FOREIGN KEY (`department_id`) REFERENCES `Departments`(`Department_id`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- 5) WORKS table (employee–manager relationship)
CREATE TABLE `Works` (
  `Employee_id` INT NOT NULL,
  `manager_id`  INT,
  PRIMARY KEY (`Employee_id`),
  FOREIGN KEY (`Employee_id`) REFERENCES `Employees`(`Employee_id`)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (`manager_id`)  REFERENCES `Employees`(`Employee_id`)
    ON UPDATE CASCADE
    ON DELETE SET NULL
);

-- 6) JOB_HISTORY table
CREATE TABLE `Job_history` (
  `Employee_id`   INT           NOT NULL,
  `hire_date`     DATE          NOT NULL,
  `leaving_date`  DATE,
  `salary`        DECIMAL(10,2),
  `job_id`        VARCHAR(10),
  `department_id` INT,
  PRIMARY KEY (`Employee_id`,`hire_date`),
  FOREIGN KEY (`Employee_id`)   REFERENCES `Employees`(`Employee_id`)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (`job_id`)        REFERENCES `Jobs`(`Job_id`)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  FOREIGN KEY (`department_id`) REFERENCES `Departments`(`Department_id`)
    ON UPDATE CASCADE
    ON DELETE SET NULL
);

-- 7) SALARY_AUDIT table (to track old/new salaries)
CREATE TABLE `Salary_audit` (
  `audit_id`     INT           NOT NULL AUTO_INCREMENT,
  `Employee_id`  INT           NOT NULL,
  `old_salary`   DECIMAL(10,2) NOT NULL,
  `new_salary`   DECIMAL(10,2) NOT NULL,
  `changed_at`   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`audit_id`),
  FOREIGN KEY (`Employee_id`) REFERENCES `Employees`(`Employee_id`)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- 8) Stored procedure: max/min salary per department
DELIMITER $$
CREATE PROCEDURE `GetDeptSalaryStats`(IN p_dept INT)
BEGIN
  SELECT
    p_dept    AS department_id,
    MAX(Salary) AS max_salary,
    MIN(Salary) AS min_salary
  FROM `Employees`
  WHERE department_id = p_dept;
END$$
DELIMITER ;

-- 9) Trigger: audit salary changes
DELIMITER $$
CREATE TRIGGER `trg_after_salary_update`
AFTER UPDATE ON `Employees`
FOR EACH ROW
BEGIN
  IF OLD.Salary <> NEW.Salary THEN
    INSERT INTO `Salary_audit` (`Employee_id`,`old_salary`,`new_salary`)
      VALUES (OLD.Employee_id, OLD.Salary, NEW.Salary);
  END IF;
END$$
DELIMITER ;


-- ========================================
-- DML: Insert sample data
-- ========================================

-- Locations
INSERT INTO `Locations` (`Location_id`,`street`,`city`,`state`,`country`) VALUES
  (10,'123 Main St','New York','NY','USA'),
  (20,'456 Oak Ave','Los Angeles','CA','USA'),
  (30,'789 Pine Rd','Chicago','IL','USA'),
  (50,'321 Maple Ln','Houston','TX','USA');

-- Departments
INSERT INTO `Departments` (`Department_id`,`dept_name`,`location_id`) VALUES
  (100,'Sales',20),
  (200,'HR',30),
  (300,'IT',50),
  (400,'Finance',10);

-- Jobs
INSERT INTO `Jobs` (`Job_id`,`job_title`,`min_salary`,`max_salary`) VALUES
  ('DEV','Developer',40000.00,120000.00),
  ('HRM','HR Manager',50000.00,90000.00),
  ('SAL','Sales Rep',30000.00,80000.00),
  ('FIN','Financial Analyst',55000.00,100000.00);

-- Employees (some joined in 2006)
INSERT INTO `Employees` (`Employee_id`,`first_name`,`last_name`,`email`,`ph_no`,`hire_date`,`Job_id`,`Salary`,`department_id`) VALUES
  (1,'Alice','Johnson','alice.j@example.com','555-1234','2005-11-20','DEV',75000.00,300),
  (2,'Bob','Anderson','bob.a@example.com','555-2345','2006-01-15','HRM',80000.00,200),
  (3,'Carol','Smith','carol.s@example.com','555-3456','2006-06-10','SAL',45000.00,100),
  (4,'David','Brown','david.b@example.com','555-4567','2007-03-05','FIN',65000.00,400),
  (5,'Eve','Davis','eve.d@example.com','555-5678','2006-12-01','DEV',70000.00,300);

-- Works (manager relationships)
INSERT INTO `Works` (`Employee_id`,`manager_id`) VALUES
  (1, 5),
  (2, 5),
  (3, 2),
  (4, 3),
  (5, NULL);

-- Job history
INSERT INTO `Job_history` (`Employee_id`,`hire_date`,`leaving_date`,`salary`,`job_id`,`department_id`) VALUES
  (2,'2006-01-15','2008-04-30',80000.00,'HRM',200),
  (3,'2006-06-10','2009-08-31',45000.00,'SAL',100),
  (5,'2006-12-01','2010-05-15',70000.00,'DEV',300);


-- ========================================
-- DQL: Queries
-- ========================================

-- 1] Display all the employees in descending order of their salary.
SELECT
  Employee_id,
  first_name,
  last_name,
  Salary
FROM `Employees`
ORDER BY Salary DESC;

-- 2] Display employee_id, full name and salary of all employees
--    who joined in year 2006 ordered by hire_date (seniority).
SELECT
  Employee_id,
  CONCAT(first_name,' ',last_name) AS full_name,
  Salary,
  hire_date
FROM `Employees`
WHERE YEAR(hire_date) = 2006
ORDER BY hire_date;

-- 3] List name of all departments in locations 20, 30 and 50
SELECT
  dept_name
FROM `Departments`
WHERE location_id IN (20,30,50);

-- 4] Display the full name of all employees whose first_name or last_name contains 'a'.
SELECT
  Employee_id,
  CONCAT(first_name,' ',last_name) AS full_name
FROM `Employees`
WHERE first_name LIKE '%a%' OR last_name LIKE '%a%';

-- 5] (Procedure defined above: call with CALL GetDeptSalaryStats(300);)

-- 6] (Salary changes are automatically logged in `Salary_audit` by the trigger)
