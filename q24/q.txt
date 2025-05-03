-- DDL: Create Tables

CREATE TABLE Emp (
  eid INT PRIMARY KEY,
  ename VARCHAR(100),
  salary DECIMAL(10,2)
);

CREATE TABLE Dept (
  did INT PRIMARY KEY,
  dname VARCHAR(100),
  managerid INT,
  floornum INT
);

CREATE TABLE Works (
  eid INT,
  did INT,
  PRIMARY KEY (eid, did),
  FOREIGN KEY (eid) REFERENCES Emp(eid),
  FOREIGN KEY (did) REFERENCES Dept(did)
);

-- DML: Insert Sample Data

INSERT INTO Emp VALUES
(1, 'Abhishek', 45000),
(2, 'Amar Arora', 60000),
(3, 'John', 30000),
(4, 'Ravi', 75000),
(5, 'Sita', 120000),
(6, 'Priya', 9500),
(7, 'Rohan', 48000),
(8, 'ManagerA', 110000),
(9, 'ManagerB', 105000);

INSERT INTO Dept VALUES
(101, 'Toys', 8, 5),
(102, 'Music', 9, 5),
(103, 'Books', 8, 10),
(104, 'Games', 8, 10),
(105, 'Gadgets', 8, 10);

INSERT INTO Works VALUES
(1, 101),
(1, 102),
(2, 103),
(2, 104),
(2, 105),
(3, 103),
(4, 101),
(5, 105),
(6, 102),
(7, 103);

-- DQL: Queries

-- 1. Employees on 10th floor with salary < 50000
SELECT DISTINCT e.ename
FROM Emp e
JOIN Works w ON e.eid = w.eid
JOIN Dept d ON w.did = d.did
WHERE d.floornum = 10 AND e.salary < 50000;

-- 2. Managers who manage 3 or more departments on the same floor
SELECT managerid
FROM Dept
GROUP BY managerid, floornum
HAVING COUNT(DISTINCT did) >= 3;

-- 3. Procedure to give 10% raise to employees in Toys department
DELIMITER $$
CREATE PROCEDURE Raise_Toy_Dept_Salary()
BEGIN
  UPDATE Emp
  SET salary = salary * 1.10
  WHERE eid IN (
    SELECT eid FROM Works WHERE did = (
      SELECT did FROM Dept WHERE dname = 'Toys'
    )
  );
END$$
DELIMITER ;

-- 4. Names and salaries of employees in both Toys and Music departments
SELECT e.ename, e.salary
FROM Emp e
WHERE e.eid IN (
  SELECT w1.eid
  FROM Works w1
  JOIN Works w2 ON w1.eid = w2.eid
  JOIN Dept d1 ON w1.did = d1.did
  JOIN Dept d2 ON w2.did = d2.did
  WHERE d1.dname = 'Toys' AND d2.dname = 'Music'
);

-- 5. Employees with salary < 10000 or > 100000
SELECT * FROM Emp WHERE salary < 10000 OR salary > 100000;

-- 6. Employees who work in same departments as Abhishek
SELECT DISTINCT e.*
FROM Emp e
JOIN Works w ON e.eid = w.eid
WHERE w.did IN (
  SELECT did FROM Works WHERE eid = (
    SELECT eid FROM Emp WHERE ename = 'Abhishek'
  )
);

-- 7. Procedure: Employees who work on floor(s) where Amar Arora works
DELIMITER $$
CREATE PROCEDURE Employees_On_Amar_Floors()
BEGIN
  SELECT DISTINCT e.ename
  FROM Emp e
  JOIN Works w ON e.eid = w.eid
  JOIN Dept d ON w.did = d.did
  WHERE d.floornum IN (
    SELECT DISTINCT d2.floornum
    FROM Works w2
    JOIN Dept d2 ON w2.did = d2.did
    JOIN Emp e2 ON w2.eid = e2.eid
    WHERE e2.ename = 'Amar Arora'
  );
END$$
DELIMITER ;
