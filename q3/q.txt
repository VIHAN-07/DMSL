-- ─────────────────────────────────────────────────────────────────────────────
-- 1) DDL: Define tables & relationships for Video Library
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE customer (
  cust_no     INT            PRIMARY KEY,
  cust_name   VARCHAR(100)   NOT NULL
);

CREATE TABLE membership (
  mem_no      INT            PRIMARY KEY,
  cust_no     INT            NOT NULL,
  FOREIGN KEY (cust_no) REFERENCES customer(cust_no)
);

CREATE TABLE cassette (
  cass_no     INT            PRIMARY KEY,
  cass_name   VARCHAR(200)   NOT NULL,
  language    VARCHAR(50)    NOT NULL
);

CREATE TABLE iss_rec (
  iss_no      INT            PRIMARY KEY,
  iss_date    DATE           NOT NULL,
  mem_no      INT            NOT NULL,
  cass_no     INT            NOT NULL,
  FOREIGN KEY (mem_no)  REFERENCES membership(mem_no),
  FOREIGN KEY (cass_no) REFERENCES cassette(cass_no)
);


-- ─────────────────────────────────────────────────────────────────────────────
-- 2) DML: Insert sample data (remember to include DML for every scenario)
-- ─────────────────────────────────────────────────────────────────────────────

-- Customers
INSERT INTO customer (cust_no, cust_name) VALUES
  (1, 'Alice'),
  (2, 'Bob'),
  (3, 'Carol'),
  (4, 'Dave');

-- Memberships
INSERT INTO membership (mem_no, cust_no) VALUES
  (101, 1),
  (102, 2),
  (103, 3),
  (104, 4);

-- Cassettes
INSERT INTO cassette (cass_no, cass_name, language) VALUES
  (201, 'The Legend',    'English'),
  (202, 'Fast Cars',     'English'),
  (203, 'Cooking 101',   'Hindi');

-- Issue Records
-- Assume today is 2025‑05‑03
INSERT INTO iss_rec (iss_no, iss_date, mem_no, cass_no) VALUES
  (301, '2025-05-03', 101, 201),
  (302, '2025-05-03', 102, 202),
  (303, '2025-05-02', 101, 203),
  (304, '2025-05-03', 103, 201),
  (305, '2025-05-03', 104, 203);


-- ─────────────────────────────────────────────────────────────────────────────
-- 3) DQL: Required queries
-- ─────────────────────────────────────────────────────────────────────────────

-- a) List all customer names with their membership numbers
SELECT c.cust_name,
       m.mem_no
FROM customer AS c
JOIN membership AS m ON m.cust_no = c.cust_no
;

-- b) List all issues for TODAY with customer names and cassette names
SELECT i.iss_no,
       i.iss_date,
       c.cust_name,
       cas.cass_name
FROM iss_rec AS i
JOIN membership  AS m   ON i.mem_no    = m.mem_no
JOIN customer    AS c   ON m.cust_no   = c.cust_no
JOIN cassette    AS cas ON i.cass_no   = cas.cass_no
WHERE i.iss_date = CURDATE()
;

-- c) Details of the customer who borrowed the cassette titled “The Legend”
SELECT DISTINCT c.cust_no,
                c.cust_name
FROM customer AS c
JOIN membership AS m   ON m.cust_no = c.cust_no
JOIN iss_rec    AS i   ON i.mem_no  = m.mem_no
JOIN cassette   AS cas ON cas.cass_no = i.cass_no
WHERE cas.cass_name = 'The Legend'
;

-- d) Count of how many cassettes have been borrowed by each customer
SELECT c.cust_name,
       COUNT(*) AS total_borrowed
FROM customer AS c
JOIN membership  AS m   ON m.cust_no = c.cust_no
JOIN iss_rec     AS i   ON i.mem_no  = m.mem_no
GROUP BY c.cust_no, c.cust_name
;


-- ─────────────────────────────────────────────────────────────────────────────
-- 4) Trigger: Cascade‐delete a customer’s related memberships & issues
-- ─────────────────────────────────────────────────────────────────────────────

DELIMITER $$
CREATE TRIGGER trg_before_customer_delete
BEFORE DELETE ON customer
FOR EACH ROW
BEGIN
  -- delete all issue records for this customer's memberships
  DELETE FROM iss_rec
   WHERE mem_no IN (
     SELECT mem_no
     FROM membership
     WHERE cust_no = OLD.cust_no
   );
  -- delete all membership records for this customer
  DELETE FROM membership
   WHERE cust_no = OLD.cust_no;
END$$
DELIMITER ;

-- To test the trigger, e.g.:
-- DELETE FROM customer WHERE cust_no = 2;
