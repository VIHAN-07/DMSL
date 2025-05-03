-- ─────────────────────────────────────────────────────────────────────────────
-- Complete SQL Script: DDL, DML, Queries (DQL) and Procedure for Employee‑Pay
-- ─────────────────────────────────────────────────────────────────────────────

-- 1) DDL: Create tables with integrity constraints
CREATE TABLE department (
  dept_id     INT            PRIMARY KEY,
  dept_name   VARCHAR(100)   NOT NULL
);

CREATE TABLE employee (
  emp_id      INT            PRIMARY KEY,
  emp_name    VARCHAR(100)   NOT NULL
);

CREATE TABLE paydetails (
  emp_id       INT            PRIMARY KEY,
  dept_id      INT            NOT NULL,
  basic        INT            NOT NULL,
  deductions   INT            NOT NULL,
  additions    INT            NOT NULL,
  DOJ          DATE           NOT NULL,
  FOREIGN KEY (emp_id)    REFERENCES employee(emp_id),
  FOREIGN KEY (dept_id)   REFERENCES department(dept_id)
);

CREATE TABLE payroll (
  emp_id      INT            NOT NULL,
  pay_date    DATE           NOT NULL,
  PRIMARY KEY (emp_id, pay_date),
  FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);


-- 2) DML: Insert sample data into each table

-- Departments
INSERT INTO department (dept_id, dept_name) VALUES
  (10, 'HR'),
  (20, 'IT'),
  (30, 'Finance'),
  (40, 'Marketing');

-- Employees
INSERT INTO employee (emp_id, emp_name) VALUES
  (101, 'Alice'),
  (102, 'Bob'),
  (103, 'Carol'),
  (104, 'Dave'),
  (105, 'Eve'),
  (106, 'Frank'),
  (107, 'Grace'),
  (108, 'Heidi'),
  (109, 'Ivan'),
  (110, 'Judy');

-- Pay details
INSERT INTO paydetails (emp_id, dept_id, basic, deductions, additions, DOJ) VALUES
  (101, 10, 12000,  2000,  500,  '2024-01-15'),
  (102, 20, 25000,  3000, 1000,  '2023-06-01'),
  (103, 20, 18000,  1500,  700,  '2024-03-20'),
  (104, 30, 22000,  2500,  800,  '2022-11-05'),
  (105, 30,  9500,  1000,  400,  '2025-02-10'),
  (106, 40, 30000,  5000, 1500,  '2021-07-30'),
  (107, 10, 15000,  1200,  600,  '2023-09-12'),
  (108, 40, 28000,  3500, 1200,  '2024-05-25'),
  (109, 20, 16000,  1800,  700,  '2025-01-02'),
  (110, 30, 20000,  2200,  900,  '2022-02-14');

-- Payroll entries (e.g., for April 2025)
INSERT INTO payroll (emp_id, pay_date) VALUES
  (101, '2025-04-30'),
  (102, '2025-04-30'),
  (103, '2025-04-30'),
  (104, '2025-04-30'),
  (105, '2025-04-30'),
  (106, '2025-04-30'),
  (107, '2025-04-30'),
  (108, '2025-04-30'),
  (109, '2025-04-30'),
  (110, '2025-04-30');


-- 3) DQL: Required queries

-- a) List the employee details department‑wise
SELECT 
  e.emp_id,
  e.emp_name,
  d.dept_name,
  pd.basic,
  pd.deductions,
  pd.additions,
  (pd.basic - pd.deductions + pd.additions) AS net_salary,
  pd.DOJ
FROM employee    AS e
JOIN paydetails AS pd  ON e.emp_id   = pd.emp_id
JOIN department AS d   ON pd.dept_id = d.dept_id
ORDER BY d.dept_name, e.emp_name
;

-- b) List all the employee names who joined after a particular date (e.g. '2025-01-01')
SELECT 
  e.emp_id,
  e.emp_name,
  pd.DOJ
FROM employee    AS e
JOIN paydetails AS pd ON e.emp_id = pd.emp_id
WHERE pd.DOJ > '2025-01-01'
ORDER BY pd.DOJ
;

-- c) List details of employees whose basic salary is between 10,000 and 20,000
SELECT 
  e.emp_id,
  e.emp_name,
  pd.basic
FROM employee    AS e
JOIN paydetails AS pd ON e.emp_id = pd.emp_id
WHERE pd.basic BETWEEN 10000 AND 20000
ORDER BY pd.basic
;

-- d) Count how many employees are working in each department
SELECT 
  d.dept_name,
  COUNT(*) AS employee_count
FROM paydetails AS pd
JOIN department AS d  ON pd.dept_id = d.dept_id
GROUP BY d.dept_name
;

-- e) Names of the employees whose net salary > 10,000
SELECT 
  e.emp_id,
  e.emp_name,
  (pd.basic - pd.deductions + pd.additions) AS net_salary
FROM employee    AS e
JOIN paydetails AS pd ON e.emp_id = pd.emp_id
WHERE (pd.basic - pd.deductions + pd.additions) > 10000
ORDER BY net_salary DESC
;


-- 4) Procedure: List pay details for all employees
DELIMITER $$
CREATE PROCEDURE ListAllPayDetails()
BEGIN
  SELECT 
    e.emp_id,
    e.emp_name,
    d.dept_name,
    pd.basic,
    pd.deductions,
    pd.additions,
    (pd.basic - pd.deductions + pd.additions) AS net_salary,
    pd.DOJ
  FROM employee    AS e
  JOIN paydetails AS pd  ON e.emp_id   = pd.emp_id
  JOIN department AS d   ON pd.dept_id = d.dept_id
  ORDER BY e.emp_id;
END$$
DELIMITER ;

-- To execute the procedure:
-- CALL ListAllPayDetails();
