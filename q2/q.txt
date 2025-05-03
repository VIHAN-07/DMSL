-- ─────────────────────────────────────────────────────────────────────────────
-- 1) DDL: Define tables and relationships
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE dept (
  dept_no   INT           PRIMARY KEY,
  dname     VARCHAR(50)   NOT NULL,
  loc       VARCHAR(50)   NOT NULL
);

CREATE TABLE project (
  proj_no    INT           PRIMARY KEY,
  proj_name  VARCHAR(100)  NOT NULL,
  status     VARCHAR(20)   NOT NULL
);

CREATE TABLE emp (
  emp_no       INT           PRIMARY KEY,
  ename        VARCHAR(100)  NOT NULL,
  designation  VARCHAR(50)   NOT NULL,
  sal          DECIMAL(10,2) NOT NULL,
  dept_no      INT           NOT NULL,
  proj_no      INT           NOT NULL,
  FOREIGN KEY(dept_no)  REFERENCES dept(dept_no),
  FOREIGN KEY(proj_no)  REFERENCES project(proj_no)
);


-- ─────────────────────────────────────────────────────────────────────────────
-- 2) DML: Insert sample data
-- ─────────────────────────────────────────────────────────────────────────────

-- Departments
INSERT INTO dept (dept_no, dname,     loc) VALUES
  (10,    'INVENTORY', 'PUNE'),
  (20,    'MARKETING', 'MUMBAI'),
  (30,    'HR',        'DELHI');

-- Projects
INSERT INTO project (proj_no, proj_name,            status) VALUES
  (1,       'Blood Bank',           'INCOMPLETE'),
  (2,       'Inventory System',     'COMPLETE'),
  (3,       'Marketing Campaign',   'INCOMPLETE');

-- Employees
INSERT INTO emp (emp_no, ename,  designation, sal,    dept_no, proj_no) VALUES
  (101,    'Alice',   'CLERK',      2000.00, 10,      2),  -- Inventory/Pune, complete
  (102,    'Bob',     'MANAGER',    5000.00, 20,      3),  -- Marketing/Mumbai, incomplete
  (103,    'Carol',   'ANALYST',    3000.00, 10,      1),  -- Inventory/Pune, incomplete (Blood Bank)
  (104,    'Dave',    'CLERK',      1800.00, 20,      1),  -- Marketing/Mumbai, incomplete (Blood Bank)
  (105,    'Eve',     'MANAGER',    5500.00, 20,      1),  -- Marketing/Mumbai, incomplete (Blood Bank)
  (106,    'Frank',   'CLERK',      2100.00, 10,      3);  -- Inventory/Pune, incomplete (Marketing Campaign)


-- ─────────────────────────────────────────────────────────────────────────────
-- 3) DQL: The required queries
-- ─────────────────────────────────────────────────────────────────────────────

-- i)  List all employees of ‘INVENTORY’ department at ‘PUNE’
SELECT e.ename
FROM emp e
JOIN dept d ON e.dept_no = d.dept_no
WHERE d.dname = 'INVENTORY'
  AND d.loc   = 'PUNE'
;

-- ii) Names of employees working on ‘Blood Bank’ project
SELECT DISTINCT e.ename
FROM emp e
JOIN project p ON e.proj_no = p.proj_no
WHERE p.proj_name = 'Blood Bank'
;

-- iii) Names of MANAGERs in the ‘MARKETING’ department
SELECT e.ename
FROM emp e
JOIN dept d ON e.dept_no = d.dept_no
WHERE e.designation = 'MANAGER'
  AND d.dname       = 'MARKETING'
;

-- iv) All employees on projects whose status = ‘INCOMPLETE’
SELECT DISTINCT e.ename
FROM emp e
JOIN project p ON e.proj_no = p.proj_no
WHERE p.status = 'INCOMPLETE'
;


-- ─────────────────────────────────────────────────────────────────────────────
-- 4) Procedure: Update salaries per given rules
-- ─────────────────────────────────────────────────────────────────────────────

DELIMITER $$
CREATE PROCEDURE UpdateSalRules()
BEGIN
  -- CLERKs in dept 10 get +20%
  UPDATE emp
  SET sal = sal * 1.20
  WHERE designation = 'CLERK'
    AND dept_no     = 10
  ;

  -- MANAGERs in dept 20 get +5%
  UPDATE emp
  SET sal = sal * 1.05
  WHERE designation = 'MANAGER'
    AND dept_no     = 20
  ;
END$$
DELIMITER ;

-- To execute the procedure:
-- CALL UpdateSalRules();
