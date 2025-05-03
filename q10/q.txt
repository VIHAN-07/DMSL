-- ========================================
-- DDL: Create schema for Student–Lab scenario
-- ========================================

CREATE TABLE `Class` (
  `class_id`   VARCHAR(20) NOT NULL,       
  `descrip`    VARCHAR(100) NOT NULL,
  PRIMARY KEY (`class_id`)
);

CREATE TABLE `Student` (
  `stud_no`    INT         NOT NULL,
  `stud_name`  VARCHAR(100) NOT NULL,
  `class_id`   VARCHAR(20)  NOT NULL,
  PRIMARY KEY (`stud_no`),
  FOREIGN KEY (`class_id`) REFERENCES `Class`(`class_id`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE TABLE `Lab` (
  `mach_no`    INT         NOT NULL,
  `lab_no`     INT         NOT NULL,
  `description` VARCHAR(200) NOT NULL,
  PRIMARY KEY (`mach_no`, `lab_no`)
);

CREATE TABLE `Allotment` (
  `stud_no`     INT         NOT NULL,
  `mach_no`     INT         NOT NULL,
  `lab_no`      INT         NOT NULL,
  `day_of_week` ENUM('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') NOT NULL,
  PRIMARY KEY (`stud_no`,`mach_no`,`lab_no`,`day_of_week`),
  FOREIGN KEY (`stud_no`)     REFERENCES `Student`(`stud_no`)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (`mach_no`,`lab_no`) REFERENCES `Lab`(`mach_no`,`lab_no`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

-- ========================================
-- DML: Insert sample data into tables
-- ========================================

-- Classes
INSERT INTO `Class` (`class_id`,`descrip`) VALUES
  ('CSIT','Computer Science & IT'),
  ('EE','Electrical Engineering'),
  ('ME','Mechanical Engineering');

-- Students
INSERT INTO `Student` (`stud_no`,`stud_name`,`class_id`) VALUES
  (1, 'Alice Kumar',   'CSIT'),
  (2, 'Bob Singh',     'EE'),
  (3, 'Carol Das',     'ME'),
  (4, 'David Patel',   'CSIT'),
  (5, 'Esha Sharma',   'CSIT');

-- Labs and Machines
INSERT INTO `Lab` (`mach_no`,`lab_no`,`description`) VALUES
  (101, 1, 'Dell Workstation'),
  (102, 1, 'HP Workstation'),
  (201, 2, 'Lenovo Workstation'),
  (202, 2, 'Asus Workstation');

-- Allotments
INSERT INTO `Allotment` (`stud_no`,`mach_no`,`lab_no`,`day_of_week`) VALUES
  (1, 101, 1, 'Monday'),
  (2, 102, 1, 'Monday'),
  (3, 201, 2, 'Tuesday'),
  (4, 101, 1, 'Thursday'),
  (5, 202, 2, 'Thursday'),
  (5, 101, 1, 'Monday'),
  (4, 201, 2, 'Friday');

-- ========================================
-- DQL: Queries for the required reports
-- ========================================

-- a) List all the machine allotments with student names, lab and machine numbers
SELECT
  a.day_of_week,
  s.stud_no,
  s.stud_name,
  s.class_id,
  a.lab_no,
  a.mach_no
FROM Allotment AS a
JOIN Student   AS s ON a.stud_no = s.stud_no
ORDER BY a.day_of_week, s.stud_no, a.lab_no;

-- b) List the total number of lab allotments day-wise
SELECT
  day_of_week,
  COUNT(*) AS total_allotments
FROM Allotment
GROUP BY day_of_week
ORDER BY FIELD(day_of_week,
  'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');

-- c) Count how many machines have been allocated to the ‘CSIT’ class
SELECT
  COUNT(*) AS csit_machine_allocations
FROM Allotment AS a
JOIN Student   AS s ON a.stud_no = s.stud_no
WHERE s.class_id = 'CSIT';

-- d) Machine allotment details for student number 5, with personal and class details
SELECT
  s.stud_no,
  s.stud_name,
  s.class_id,
  c.descrip         AS class_description,
  a.day_of_week,
  a.lab_no,
  a.mach_no
FROM Student     AS s
JOIN Class       AS c ON s.class_id = c.class_id
LEFT JOIN Allotment AS a ON s.stud_no = a.stud_no
WHERE s.stud_no = 5;

-- e) Count how many machines have been allocated in Lab_no 1 on “Monday”
SELECT
  COUNT(*) AS machines_lab1_monday
FROM Allotment
WHERE lab_no = 1
  AND day_of_week = 'Monday';

-- f) Create a view listing the machine allotment details for “Thursday”
CREATE OR REPLACE VIEW `Thursday_Allotments` AS
SELECT
  a.stud_no,
  s.stud_name,
  s.class_id,
  a.lab_no,
  a.mach_no,
  a.day_of_week
FROM Allotment AS a
JOIN Student   AS s ON a.stud_no = s.stud_no
WHERE a.day_of_week = 'Thursday';

-- To query the view:
-- SELECT * FROM `Thursday_Allotments`;
