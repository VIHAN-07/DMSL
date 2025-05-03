-- ─────────────────────────────────────────────────────────────────────────────
-- 1) DDL: Create tables with constraints
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE sailors (
  SID     INT             PRIMARY KEY,
  SNAME   VARCHAR(100)    NOT NULL,
  RATING  INT             NOT NULL 
                      CHECK (RATING BETWEEN 1 AND 10),
  AGE     REAL
);

CREATE TABLE boats (
  BID     INT             PRIMARY KEY,
  BNAME   VARCHAR(100)    NOT NULL,
  COLOR   VARCHAR(50)     NOT NULL
);

CREATE TABLE reserves (
  SID     INT             NOT NULL,
  BID     INT             NOT NULL,
  DAY     DATE            NOT NULL,
  PRIMARY KEY (SID, BID, DAY),
  FOREIGN KEY (SID) REFERENCES sailors(SID),
  FOREIGN KEY (BID) REFERENCES boats(BID)
);


-- ─────────────────────────────────────────────────────────────────────────────
-- 2) DML: Insert sample data
-- ─────────────────────────────────────────────────────────────────────────────

-- Sailors
INSERT INTO sailors (SID, SNAME,    RATING, AGE) VALUES
  (1,    'John',     4,      25.5),
  (2,    'Alice',    5,      30.0),
  (3,    'Bob',      6,      22.0),
  (4,    'Carol',    9,      28.0),
  (5,    'Dave',     10,     35.0),
  (6,    'Eve',      8,      32.0);

-- Boats
INSERT INTO boats (BID, BNAME,          COLOR) VALUES
  (123,  'Sea Queen',     'Red'),
  (456,  'Ocean Breeze',  'Blue'),
  (789,  'Wave Rider',    'White');

-- Reservations
INSERT INTO reserves (SID, BID, DAY) VALUES
  (1,  123, '2025-05-01'),
  (2,  456, '2025-05-02'),
  (3,  123, '2025-05-03'),
  (4,  789, '2025-05-01'),
  (5,  456, '2025-05-04'),
  (6,  123, '2025-05-03');


-- ─────────────────────────────────────────────────────────────────────────────
-- 3) DQL: Queries
-- ─────────────────────────────────────────────────────────────────────────────

-- 1. Names of sailors who have reserved boat number 123
SELECT DISTINCT SNAME
FROM sailors AS s
JOIN reserves AS r ON s.SID = r.SID
WHERE r.BID = 123
;

-- 2. Names of sailors who have reserved at least one boat
SELECT DISTINCT SNAME
FROM sailors AS s
JOIN reserves AS r ON s.SID = r.SID
;

-- 3. Average age of Expert sailors
--    (Define “Expert” as rating ≥ 8)
SELECT AVG(AGE) AS avg_expert_age
FROM sailors
WHERE RATING >= 8
;

-- 4) Create Expert_Sailor view, then queries on it
CREATE OR REPLACE VIEW Expert_Sailor AS
SELECT *
FROM sailors
WHERE RATING >= 8
;

-- 4.1 Sailors with age > 25 and rating = 10
SELECT SNAME, AGE, RATING
FROM Expert_Sailor
WHERE AGE > 25
  AND RATING = 10
;

-- 4.2 Total number of sailors in Expert_Sailor view
SELECT COUNT(*) AS expert_count
FROM Expert_Sailor
;

-- 4.3 Number of sailors at each rating level (8, 9, 10)
SELECT RATING, COUNT(*) AS count_per_rating
FROM Expert_Sailor
GROUP BY RATING
ORDER BY RATING
;


-- 5) Procedure: Update sailor ratings per rules
DELIMITER $$
CREATE PROCEDURE Update_Sailor_Ratings()
BEGIN
  -- If rating < 5, increase by 2
  UPDATE sailors
  SET RATING = RATING + 2
  WHERE RATING < 5
  ;

  -- If rating > 5 but < 10, increase by 1
  UPDATE sailors
  SET RATING = RATING + 1
  WHERE RATING > 5
    AND RATING < 10
  ;

  -- Ratings of 5 or 10 remain unchanged
END$$
DELIMITER ;

-- To run the procedure:
-- CALL Update_Sailor_Ratings();
