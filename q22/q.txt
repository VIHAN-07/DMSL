-- ========================================
-- DDL: Create tables and trigger
-- ========================================

-- 1) STUDENT table
CREATE TABLE `Student` (
  `Roll_no`   VARCHAR(20) NOT NULL,
  `Name`      VARCHAR(100) NOT NULL,
  `Address`   VARCHAR(100),
  PRIMARY KEY (`Roll_no`)
);

-- 2) SUBJECT table
CREATE TABLE `Subject` (
  `Sub_code`  VARCHAR(20) NOT NULL,
  `Sub_name`  VARCHAR(100) NOT NULL,
  PRIMARY KEY (`Sub_code`)
);

-- 3) MARKS table
CREATE TABLE `Marks` (
  `Roll_no`   VARCHAR(20) NOT NULL,
  `Sub_code`  VARCHAR(20) NOT NULL,
  `marks`     INT          NOT NULL,
  PRIMARY KEY (`Roll_no`,`Sub_code`),
  FOREIGN KEY (`Roll_no`)  REFERENCES `Student`(`Roll_no`)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (`Sub_code`) REFERENCES `Subject`(`Sub_code`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- 4) Trigger: enforce that Roll_no starts with 'TE'
DELIMITER $$
CREATE TRIGGER `trg_student_roll_insert`
BEFORE INSERT ON `Student`
FOR EACH ROW
BEGIN
  IF NEW.Roll_no NOT LIKE 'TE%' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Roll_no must start with TE';
  END IF;
END$$

CREATE TRIGGER `trg_student_roll_update`
BEFORE UPDATE ON `Student`
FOR EACH ROW
BEGIN
  IF NEW.Roll_no NOT LIKE 'TE%' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Roll_no must start with TE';
  END IF;
END$$
DELIMITER ;


-- ========================================
-- DML: Insert sample data
-- ========================================

-- Subjects
INSERT INTO `Subject` (`Sub_code`,`Sub_name`) VALUES
  ('DBMS',    'Database Systems'),
  ('OS',      'Operating Systems'),
  ('MATH',    'Mathematics'),
  ('NET',     'Computer Networks');

-- Students (rolls must start with TE)
INSERT INTO `Student` (`Roll_no`,`Name`,`Address`) VALUES
  ('TE001', 'Alice Kumar',  'PUNE'),
  ('TE002', 'Bob Singh',    'MUMBAI'),
  ('TE003', 'Carol Das',    'PUNE'),
  ('TE004', 'David Patel',  'DELHI'),
  ('TE005', 'Esha Sharma',  'BANGALORE');

-- Marks
INSERT INTO `Marks` (`Roll_no`,`Sub_code`,`marks`) VALUES
  ('TE001','DBMS',  85),
  ('TE001','OS',    78),
  ('TE002','DBMS',  35),
  ('TE002','MATH',  92),
  ('TE003','DBMS',  40),
  ('TE003','NET',   75),
  ('TE004','OS',    58),
  ('TE004','DBMS',  30),
  ('TE005','MATH',  88),
  ('TE005','NET',   66);


-- ========================================
-- DQL: Required queries
-- ========================================

-- i) Find average marks of each student, along with the name of student.
SELECT
  s.Roll_no,
  s.Name,
  ROUND(AVG(m.marks),2) AS avg_marks
FROM Student s
JOIN Marks   m ON s.Roll_no = m.Roll_no
GROUP BY s.Roll_no, s.Name;

-- ii) Find how many students have failed in the subject “DBMS”.
--     (Assuming pass mark is 40, so fail < 40)
SELECT
  COUNT(*) AS num_failed_dbms
FROM Marks
WHERE Sub_code = 'DBMS'
  AND marks < 40;

-- iii) Find the students who get marks greater than 75
--      and also find students who get less than 40.
--      (Two separate lists)

--  iii.a) Marks > 75
SELECT DISTINCT
  s.Roll_no,
  s.Name
FROM Student s
JOIN Marks   m ON s.Roll_no = m.Roll_no
WHERE m.marks > 75;

--  iii.b) Marks < 40
SELECT DISTINCT
  s.Roll_no,
  s.Name
FROM Student s
JOIN Marks   m ON s.Roll_no = m.Roll_no
WHERE m.marks < 40;

-- iv) Find the students whose addresses are 'PUNE'
SELECT
  Roll_no,
  Name,
  Address
FROM Student
WHERE Address = 'PUNE';

-- v) (Trigger for roll number enforced above in DDL)
