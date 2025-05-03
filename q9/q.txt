-- ─────────────────────────────────────────────────────────────────────────────
-- 1) DDL: Create tables & define integrity constraints
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE Book (
  Book_No       INT            PRIMARY KEY,
  Book_Name     VARCHAR(200)   NOT NULL,
  Author_name   VARCHAR(100)   NOT NULL,
  Cost          DECIMAL(10,2)  NOT NULL,
  Category      VARCHAR(50)    NOT NULL
);

CREATE TABLE Member (
  M_Id               INT            PRIMARY KEY,
  M_Name             VARCHAR(100)   NOT NULL,
  Mship_type         VARCHAR(20)    NOT NULL,
  Fees_paid          DECIMAL(10,2)  NOT NULL,
  Max_Books_Allowed  INT            NOT NULL,
  Penalty_Amount     DECIMAL(10,2)  NOT NULL
);

CREATE TABLE Issue (
  Lib_Issue_Id   INT            PRIMARY KEY,
  Book_No        INT            NOT NULL,
  M_Id           INT            NOT NULL,
  Issue_Date     DATE           NOT NULL,
  Return_date    DATE,
  FOREIGN KEY (Book_No) REFERENCES Book(Book_No),
  FOREIGN KEY (M_Id)    REFERENCES Member(M_Id)
);


-- ─────────────────────────────────────────────────────────────────────────────
-- 2) DML: Insert sample data
-- ─────────────────────────────────────────────────────────────────────────────

-- Books
INSERT INTO Book (Book_No, Book_Name,       Author_name,     Cost,   Category) VALUES
  (1,  'Deep Learning',    'Ian Goodfellow', 350.00, 'Technology'),
  (2,  'Data Mining',      'Jiawei Han',     280.00, 'Technology'),
  (3,  'Modern Art',       'Scott Urman',    320.00, 'Art'),
  (4,  'Ancient History',  'Scott Urman',    150.00, 'History'),
  (5,  'Cooking Basics',   'Jamie Oliver',    90.00, 'Cooking'),
  (6,  'Quantum Physics',  'Brian Greene',   400.00, 'Science'),
  (7,  'Python 101',       'Mark Lutz',      250.00, 'Technology'),
  (8,  'World Atlas',      'National Geo',   200.00, 'Reference'),
  (9,  'Graphic Design',   'Scott Urman',    310.00, 'Art'),
  (10, 'Gardening Tips',   'Alan Titchmarsh',80.00, 'Hobby');

-- Members
INSERT INTO Member (M_Id, M_Name,      Mship_type, Fees_paid, Max_Books_Allowed, Penalty_Amount) VALUES
  (101, 'Alice',    'Annual',  1200.00, 3,  0.00),
  (102, 'Bob',      'Monthly',  100.00, 2,  0.00),
  (103, 'Carol',    'Annual',  1200.00, 4,  0.00),  -- over limit, for trigger test
  (104, 'Dave',     'Weekly',   30.00, 1,  0.00),
  (105, 'Eve',      'Annual',  1200.00, 3,  0.00),
  (106, 'Frank',    'Monthly',  100.00, 2,  0.00),
  (107, 'Grace',    'Annual',  1200.00, 3,  0.00),
  (108, 'Heidi',    'Weekly',   30.00, 1,  0.00),
  (109, 'Ivan',     'Monthly',  100.00, 2,  0.00),
  (110, 'Judy',     'Annual',  1200.00, 3,  0.00);

-- Issue Records (assume today = '2025-05-03')
INSERT INTO Issue (Lib_Issue_Id, Book_No, M_Id, Issue_Date, Return_date) VALUES
  (1001, 1,  101, '2025-05-01', '2025-05-10'),
  (1002, 3,  101, '2025-05-02', '2025-05-12'),
  (1003, 6,  101, '2025-05-03', NULL),
  (1004, 3,  103, '2025-05-01', '2025-05-08'),
  (1005, 9,  105, '2025-05-02', NULL),
  (1006, 2,  102, '2025-05-03', NULL),
  (1007, 4,  107, '2025-05-03', NULL),
  (1008, 6,  105, '2025-05-01', '2025-05-05'),
  (1009, 7,  109, '2025-05-02', '2025-05-06'),
  (1010, 6,  107, '2025-05-03', NULL),
  (1011, 3,  110, '2025-05-03', NULL),
  (1012, 9,  101, '2025-05-03', NULL),
  (1013, 1,  105, '2025-05-03', NULL);


-- ─────────────────────────────────────────────────────────────────────────────
-- 3) DQL: Required queries
-- ─────────────────────────────────────────────────────────────────────────────

-- a) Top 5 books issued by Annual members
SELECT 
  b.Book_No,
  b.Book_Name,
  COUNT(*) AS issue_count
FROM Issue AS i
JOIN Member AS m ON i.M_Id = m.M_Id
JOIN Book   AS b ON i.Book_No = b.Book_No
WHERE m.Mship_type = 'Annual'
GROUP BY b.Book_No, b.Book_Name
ORDER BY issue_count DESC
LIMIT 5
;

-- b) Names of members who issued books costing > 300 by author “Scott Urman”
SELECT DISTINCT
  m.M_Name
FROM Issue AS i
JOIN Member AS m ON i.M_Id   = m.M_Id
JOIN Book   AS b ON i.Book_No = b.Book_No
WHERE b.Cost > 300
  AND b.Author_name = 'Scott Urman'
;

-- c) Number of books issued in each category by membership type
SELECT
  b.Category,
  m.Mship_type,
  COUNT(*) AS total_issued
FROM Issue AS i
JOIN Member AS m ON i.M_Id   = m.M_Id
JOIN Book   AS b ON i.Book_No = b.Book_No
GROUP BY b.Category, m.Mship_type
ORDER BY b.Category, m.Mship_type
;


-- ─────────────────────────────────────────────────────────────────────────────
-- 4) Triggers
-- ─────────────────────────────────────────────────────────────────────────────

-- i) Uppercase Book_Name and Author_name on INSERT or UPDATE
DELIMITER $$
CREATE TRIGGER trg_book_upcase
BEFORE INSERT ON Book
FOR EACH ROW
BEGIN
  SET NEW.Book_Name   = UPPER(NEW.Book_Name),
      NEW.Author_name = UPPER(NEW.Author_name);
END$$

CREATE TRIGGER trg_book_upcase_u
BEFORE UPDATE ON Book
FOR EACH ROW
BEGIN
  SET NEW.Book_Name   = UPPER(NEW.Book_Name),
      NEW.Author_name = UPPER(NEW.Author_name);
END$$
DELIMITER ;

-- ii) Prompt error if Max_Books_Allowed > 3
DELIMITER $$
CREATE TRIGGER trg_member_maxbooks
BEFORE INSERT ON Member
FOR EACH ROW
BEGIN
  IF NEW.Max_Books_Allowed > 3 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Max_Books_Allowed cannot exceed 3';
  END IF;
END$$

CREATE TRIGGER trg_member_maxbooks_u
BEFORE UPDATE ON Member
FOR EACH ROW
BEGIN
  IF NEW.Max_Books_Allowed > 3 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Max_Books_Allowed cannot exceed 3';
  END IF;
END$$
DELIMITER ;
