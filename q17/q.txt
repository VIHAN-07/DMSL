-- ========================================
-- DDL: Create schema
-- ========================================

-- 1) DEPT table
CREATE TABLE `dept` (
  `dno`   INT         NOT NULL,
  `dname` VARCHAR(100),
  `loc`   VARCHAR(100),
  PRIMARY KEY (`dno`)
);

-- 2) EMP table
CREATE TABLE `emp` (
  `eno`        INT           NOT NULL,
  `ename`      VARCHAR(100)  NOT NULL,
  `sal`        DECIMAL(10,2) NOT NULL,
  `contact_no` VARCHAR(20),
  `addr`       VARCHAR(200),
  `dno`        INT,
  PRIMARY KEY (`eno`),
  FOREIGN KEY (`dno`) REFERENCES `dept`(`dno`)
    ON UPDATE CASCADE
    ON DELETE SET NULL
);

-- 3) PROJECT table
CREATE TABLE `project` (
  `pno`   INT         NOT NULL,
  `pname` VARCHAR(200) NOT NULL,
  PRIMARY KEY (`pno`)
);

-- 4) ASSIGNED_TO table
CREATE TABLE `assigned_to` (
  `eno` INT NOT NULL,
  `pno` INT NOT NULL,
  PRIMARY KEY (`eno`,`pno`),
  FOREIGN KEY (`eno`) REFERENCES `emp`(`eno`)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (`pno`) REFERENCES `project`(`pno`)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);


-- ========================================
-- DML: Insert sample data
-- ========================================

-- Departments
INSERT INTO `dept` (`dno`,`dname`,`loc`) VALUES
  (10,'Sales','New York'),
  (20,'Engineering','San Francisco'),
  (30,'HR','Chicago');

-- Employees (including eno=107)
INSERT INTO `emp` (`eno`,`ename`,`sal`,`contact_no`,`addr`,`dno`) VALUES
  (101,'Alice',   70000.00,'555-1010','123 Maple St',10),
  (102,'Bob',     80000.00,'555-1020','456 Oak Ave',20),
  (103,'Carol',   65000.00,'555-1030','789 Pine Rd',20),
  (104,'Dave',    90000.00,'555-1040','321 Elm St',30),
  (105,'Eve',     72000.00,'555-1050','654 Cedar Blvd',20),
  (107,'Frank',   75000.00,'555-1070','987 Birch Dr',20);

-- Projects
INSERT INTO `project` (`pno`,`pname`) VALUES
  (353,'Database System'),
  (354,'Web Application'),
  (355,'AI Research'),
  (356,'Mobile App');

-- Assignments
-- Employee 107 works on 353 and 354
INSERT INTO `assigned_to` (`eno`,`pno`) VALUES
  (107,353),
  (107,354),
  (101,353),
  (102,354),
  (103,355),
  (104,353),
  (104,354),
  (105,354),
  (105,356);


-- ========================================
-- DQL: Queries
-- ========================================

-- 14) Gather details of employees working on project 353 and 354.
SELECT DISTINCT e.*
FROM emp e
JOIN assigned_to a ON e.eno = a.eno
WHERE a.pno IN (353, 354);

-- 15) Obtain the details of employees working on the "Database System" project.
SELECT e.*
FROM emp e
JOIN assigned_to a ON e.eno = a.eno
JOIN project p    ON a.pno = p.pno
WHERE p.pname = 'Database System';

-- 16) Find the employee nos of employees who work on at least one project that employee 107 works on.
SELECT DISTINCT a2.eno
FROM assigned_to a2
WHERE a2.pno IN (
  SELECT pno FROM assigned_to WHERE eno = 107
)
AND a2.eno <> 107;

-- 17) Find the employee nos of employees who work on all of the projects that employee 107 works on.
SELECT a2.eno
FROM assigned_to a2
WHERE a2.pno IN (
  SELECT pno FROM assigned_to WHERE eno = 107
)
GROUP BY a2.eno
HAVING COUNT(DISTINCT a2.pno) = (
  SELECT COUNT(*) FROM assigned_to WHERE eno = 107
)
AND a2.eno <> 107;

-- 18) Find the project with the minimum number of employees.
SELECT p.pno, p.pname, COUNT(a.eno) AS emp_count
FROM project p
LEFT JOIN assigned_to a ON p.pno = a.pno
GROUP BY p.pno, p.pname
ORDER BY emp_count ASC
LIMIT 1;

-- 19) Create view to store pno, pname and number of employees working on the project.
CREATE OR REPLACE VIEW `project_staff` AS
SELECT
  p.pno,
  p.pname,
  COUNT(a.eno) AS emp_count
FROM project p
LEFT JOIN assigned_to a ON p.pno = a.pno
GROUP BY p.pno, p.pname;


-- 20) Procedure using a cursor to display details of employees working on a particular project
DELIMITER $$
CREATE PROCEDURE `ShowProjectEmployees`(IN in_pno INT)
BEGIN
  DECLARE done     INT DEFAULT FALSE;
  DECLARE v_eno    INT;
  DECLARE v_ename  VARCHAR(100);
  DECLARE v_sal    DECIMAL(10,2);

  DECLARE emp_cursor CURSOR FOR
    SELECT e.eno, e.ename, e.sal
    FROM emp e
    JOIN assigned_to a ON e.eno = a.eno
    WHERE a.pno = in_pno;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN emp_cursor;
  read_loop: LOOP
    FETCH emp_cursor INTO v_eno, v_ename, v_sal;
    IF done THEN
      LEAVE read_loop;
    END IF;
    SELECT v_eno   AS EmployeeNo,
           v_ename AS EmployeeName,
           v_sal   AS Salary;
  END LOOP;
  CLOSE emp_cursor;
END$$
DELIMITER ;
