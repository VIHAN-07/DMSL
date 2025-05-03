-- ========================================
-- DDL: Create schema and triggers
-- ========================================

-- 1) PROJECT table
CREATE TABLE `PROJECT` (
  `PNO`   VARCHAR(20) NOT NULL,
  `PNAME` VARCHAR(100) NOT NULL,
  `CHIEF` INT           NOT NULL,
  PRIMARY KEY (`PNO`)
);

-- 2) EMPLOYEE table
CREATE TABLE `EMPLOYEE` (
  `EMPNO`   INT         NOT NULL,
  `EMPNAME` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`EMPNO`)
);

-- 3) ASSIGNED table
CREATE TABLE `ASSIGNED` (
  `PNO`   VARCHAR(20) NOT NULL,
  `EMPNO` INT         NOT NULL,
  PRIMARY KEY (`PNO`,`EMPNO`),
  FOREIGN KEY (`PNO`)   REFERENCES `PROJECT`(`PNO`)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (`EMPNO`) REFERENCES `EMPLOYEE`(`EMPNO`)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- 4) Backup table for ASSIGNED
CREATE TABLE `ASSIGNED_BACKUP` (
  `PNO`        VARCHAR(20) NOT NULL,
  `EMPNO`      INT         NOT NULL,
  `deleted_at` TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 5) Trigger: after deleting an EMPLOYEE, remove its ASSIGNED records
DELIMITER $$
CREATE TRIGGER `trg_after_emp_delete`
AFTER DELETE ON `EMPLOYEE`
FOR EACH ROW
BEGIN
  DELETE FROM `ASSIGNED`
    WHERE `EMPNO` = OLD.`EMPNO`;
END$$
DELIMITER ;

-- 6) Trigger: before deleting a PROJECT, back up and remove its ASSIGNED records
DELIMITER $$
CREATE TRIGGER `trg_before_proj_delete`
BEFORE DELETE ON `PROJECT`
FOR EACH ROW
BEGIN
  INSERT INTO `ASSIGNED_BACKUP` (`PNO`,`EMPNO`)
    SELECT `PNO`,`EMPNO`
    FROM `ASSIGNED`
    WHERE `PNO` = OLD.`PNO`;
  DELETE FROM `ASSIGNED`
    WHERE `PNO` = OLD.`PNO`;
END$$
DELIMITER ;


-- ========================================
-- DML: Insert sample data (14 statements)
-- ========================================

INSERT INTO `PROJECT`  (`PNO`,`PNAME`,`CHIEF`) VALUES ('pr001','Inventory','1');
INSERT INTO `PROJECT`  (`PNO`,`PNAME`,`CHIEF`) VALUES ('pr002','WebsiteRevamp','2');
INSERT INTO `PROJECT`  (`PNO`,`PNAME`,`CHIEF`) VALUES ('pr003','DBMS','3');

INSERT INTO `EMPLOYEE` (`EMPNO`,`EMPNAME`)     VALUES (1,'Alice Kumar');
INSERT INTO `EMPLOYEE` (`EMPNO`,`EMPNAME`)     VALUES (2,'Bob Singh');
INSERT INTO `EMPLOYEE` (`EMPNO`,`EMPNAME`)     VALUES (3,'Carol Das');
INSERT INTO `EMPLOYEE` (`EMPNO`,`EMPNAME`)     VALUES (4,'David Patel');
INSERT INTO `EMPLOYEE` (`EMPNO`,`EMPNAME`)     VALUES (5,'Esha Sharma');

INSERT INTO `ASSIGNED` (`PNO`,`EMPNO`) VALUES ('pr001',1);
INSERT INTO `ASSIGNED` (`PNO`,`EMPNO`) VALUES ('pr001',2);
INSERT INTO `ASSIGNED` (`PNO`,`EMPNO`) VALUES ('pr002',2);
INSERT INTO `ASSIGNED` (`PNO`,`EMPNO`) VALUES ('pr002',3);
INSERT INTO `ASSIGNED` (`PNO`,`EMPNO`) VALUES ('pr002',5);
INSERT INTO `ASSIGNED` (`PNO`,`EMPNO`) VALUES ('pr003',3);
INSERT INTO `ASSIGNED` (`PNO`,`EMPNO`) VALUES ('pr003',4);


-- ========================================
-- DQL: Queries
-- ========================================

-- A) Get count of employees working on each project
SELECT
  p.PNO,
  p.PNAME,
  COUNT(a.EMPNO) AS employee_count
FROM `PROJECT` p
LEFT JOIN `ASSIGNED` a ON p.PNO = a.PNO
GROUP BY p.PNO, p.PNAME;

-- B) Get details of employees working on project 'pr002'
SELECT
  e.EMPNO,
  e.EMPNAME
FROM `EMPLOYEE` e
JOIN `ASSIGNED` a ON e.EMPNO = a.EMPNO
WHERE a.PNO = 'pr002';

-- C) Get details of employees working on project named 'DBMS'
SELECT
  e.EMPNO,
  e.EMPNAME
FROM `EMPLOYEE` e
JOIN `ASSIGNED` a ON e.EMPNO = a.EMPNO
JOIN `PROJECT` p  ON a.PNO = p.PNO
WHERE p.PNAME = 'DBMS';

-- D & E) (Triggers already defined above in DDL)

-- F) Get all employees assigned to a given project number
--    Replace :proj_no with your project code, e.g. 'pr001'
SELECT
  e.EMPNO,
  e.EMPNAME
FROM `EMPLOYEE` e
JOIN `ASSIGNED` a ON e.EMPNO = a.EMPNO
WHERE a.PNO = :proj_no;
