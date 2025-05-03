-- ─────────────────────────────────────────────────────────────────────────────
-- 1) DDL: Create tables with integrity constraints
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE student (
  stud_no    INT            PRIMARY KEY,
  stud_name  VARCHAR(100)   NOT NULL
);

CREATE TABLE membership (
  mem_no     INT            PRIMARY KEY,
  stud_no    INT            NOT NULL,
  FOREIGN KEY (stud_no)     REFERENCES student(stud_no)
);

CREATE TABLE book (
  book_no    INT            PRIMARY KEY,
  book_name  VARCHAR(200)   NOT NULL,
  author     VARCHAR(100)   NOT NULL
);

CREATE TABLE iss_rec (
  iss_no     INT            PRIMARY KEY,
  iss_date   DATE           NOT NULL,
  mem_no     INT            NOT NULL,
  book_no    INT            NOT NULL,
  FOREIGN KEY (mem_no)      REFERENCES membership(mem_no),
  FOREIGN KEY (book_no)     REFERENCES book(book_no)
);


-- ─────────────────────────────────────────────────────────────────────────────
-- 2) DML: Insert ~10 records into each table
-- ─────────────────────────────────────────────────────────────────────────────

-- Students
INSERT INTO student (stud_no, stud_name) VALUES
  (1, 'Alice'),
  (2, 'Bob'),
  (3, 'Carol'),
  (4, 'Dave'),
  (5, 'Eve'),
  (6, 'Frank'),
  (7, 'Grace'),
  (8, 'Heidi'),
  (9, 'Ivan'),
  (10,'Judy');

-- Memberships
INSERT INTO membership (mem_no, stud_no) VALUES
  (301, 1),
  (302, 2),
  (303, 3),
  (304, 4),
  (305, 5),
  (306, 6),
  (307, 7),
  (308, 8),
  (309, 9),
  (310,10);

-- Books
INSERT INTO book (book_no, book_name,           author) VALUES
  (401, 'Database Systems',       'Korth'),
  (402, 'Operating Systems',      'Silberschatz'),
  (403, 'Computer Networks',      'Tanenbaum'),
  (404, 'Software Engineering',    'Pressman'),
  (405, 'Algorithms',              'CLRS'),
  (406, 'Data Structures',         'Langsam'),
  (407, 'Discrete Math',           'Rosen'),
  (408, 'Compiler Design',         'Aho'),
  (409, 'CJDATE Volume 1',         'CJDATE'),
  (410, 'CJDATE Volume 2',         'CJDATE');

-- Issue Records
-- (Assume today is 2025‑05‑03)
INSERT INTO iss_rec (iss_no, iss_date, mem_no, book_no) VALUES
  (501, '2025-05-03', 301, 401),
  (502, '2025-05-03', 302, 409),
  (503, '2025-05-02', 303, 402),
  (504, '2025-05-03', 304, 410),
  (505, '2025-05-01', 305, 403),
  (506, '2025-05-03', 306, 404),
  (507, '2025-05-02', 307, 405),
  (508, '2025-05-03', 308, 406),
  (509, '2025-05-02', 309, 407),
  (510, '2025-05-03', 310, 408);


-- ─────────────────────────────────────────────────────────────────────────────
-- 3) DQL: Queries
-- ─────────────────────────────────────────────────────────────────────────────

-- (c) List all student names with their membership numbers
SELECT s.stud_name,
       m.mem_no
FROM student     AS s
JOIN membership  AS m  ON s.stud_no = m.stud_no
;

-- (d) List all issues for today with student & book names
SELECT i.iss_no,
       i.iss_date,
       s.stud_name,
       b.book_name
FROM iss_rec     AS i
JOIN membership  AS m  ON i.mem_no   = m.mem_no
JOIN student     AS s  ON m.stud_no  = s.stud_no
JOIN book        AS b  ON i.book_no  = b.book_no
WHERE i.iss_date = CURDATE()
;

-- (e) Details of students who borrowed books by author 'CJDATE'
SELECT DISTINCT
       s.stud_no,
       s.stud_name
FROM student     AS s
JOIN membership  AS m  ON s.stud_no = m.stud_no
JOIN iss_rec     AS i  ON m.mem_no  = i.mem_no
JOIN book        AS b  ON i.book_no = b.book_no
WHERE b.author = 'CJDATE'
;


-- ─────────────────────────────────────────────────────────────────────────────
-- 4) Create View: issued_books
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE VIEW issued_books AS
SELECT
  i.iss_no,
  i.iss_date,
  s.stud_name,
  b.book_name
FROM iss_rec     AS i
JOIN membership  AS m  ON i.mem_no   = m.mem_no
JOIN student     AS s  ON m.stud_no  = s.stud_no
JOIN book        AS b  ON i.book_no  = b.book_no
;

-- Now you can:
-- SELECT * FROM issued_books;
