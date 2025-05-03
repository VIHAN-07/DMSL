-- ========================================
-- DDL: Create tables and trigger
-- ========================================

-- 1) ACTORS table
CREATE TABLE `actors` (
  `AID`   INT          NOT NULL,
  `name`  VARCHAR(100) NOT NULL,
  PRIMARY KEY (`AID`)
);

-- 2) MOVIES table
CREATE TABLE `movies` (
  `MID`    INT          NOT NULL,
  `title`  VARCHAR(200) NOT NULL,
  PRIMARY KEY (`MID`)
);

-- 3) ACTOR_ROLE table
CREATE TABLE `actor_role` (
  `MID`      INT          NOT NULL,
  `AID`      INT          NOT NULL,
  `rolename` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`MID`,`AID`,`rolename`),
  FOREIGN KEY (`MID`) REFERENCES `movies`(`MID`)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (`AID`) REFERENCES `actors`(`AID`)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

-- 4) Trigger: convert actor name to uppercase before insert or update
DELIMITER $$
CREATE TRIGGER `trg_actors_name_upper_ins`
BEFORE INSERT ON `actors`
FOR EACH ROW
BEGIN
  SET NEW.name = UPPER(NEW.name);
END$$

CREATE TRIGGER `trg_actors_name_upper_upd`
BEFORE UPDATE ON `actors`
FOR EACH ROW
BEGIN
  SET NEW.name = UPPER(NEW.name);
END$$
DELIMITER ;


-- ========================================
-- DML: Insert sample data
-- ========================================

-- Actors (including Charlie Chaplin and yourself)
INSERT INTO `actors`     (`AID`,`name`) VALUES (1, 'Charlie Chaplin');
INSERT INTO `actors`     (`AID`,`name`) VALUES (2, 'Audrey Hepburn');
INSERT INTO `actors`     (`AID`,`name`) VALUES (3, 'Humphrey Bogart');
INSERT INTO `actors`     (`AID`,`name`) VALUES (4, 'Orphan Actor');
INSERT INTO `actors`     (`AID`,`name`) VALUES (54321, 'Your Name');

-- Movies
INSERT INTO `movies`     (`MID`,`title`) VALUES (10, 'The Great Dictator');
INSERT INTO `movies`     (`MID`,`title`) VALUES (20, 'Modern Times');
INSERT INTO `movies`     (`MID`,`title`) VALUES (30, 'Breakfast at Tiffany''s');
INSERT INTO `movies`     (`MID`,`title`) VALUES (40, 'Casablanca');

-- Roles
-- Charlie has two roles in 'The Great Dictator' to illustrate counting
INSERT INTO `actor_role`  (`MID`,`AID`,`rolename`) VALUES (10, 1, 'Adenoid Hynkel');
INSERT INTO `actor_role`  (`MID`,`AID`,`rolename`) VALUES (10, 1, 'Dictator’s Double');
-- Charlie in Modern Times
INSERT INTO `actor_role`  (`MID`,`AID`,`rolename`) VALUES (20, 1, 'The Tramp');
-- Other actors in other movies
INSERT INTO `actor_role`  (`MID`,`AID`,`rolename`) VALUES (30, 2, 'Holly Golightly');
INSERT INTO `actor_role`  (`MID`,`AID`,`rolename`) VALUES (40, 3, 'Rick Blaine');
-- Yourself in one movie
INSERT INTO `actor_role`  (`MID`,`AID`,`rolename`) VALUES (30, 54321, 'Cameo Self');


-- ========================================
-- DQL: Queries
-- ========================================

-- 1) List all movies in which actor "Charlie Chaplin" has acted,
--    along with the number of roles he had in each movie.
SELECT
  m.MID,
  m.title,
  COUNT(ar.rolename) AS role_count
FROM actors a
JOIN actor_role ar ON a.AID = ar.AID
JOIN movies m     ON ar.MID = m.MID
WHERE a.name = 'CHARLIE CHAPLIN'
GROUP BY m.MID, m.title;

-- 2) List all actors who have not acted in any movie.
SELECT
  a.AID,
  a.name
FROM actors a
LEFT JOIN actor_role ar ON a.AID = ar.AID
WHERE ar.AID IS NULL;

-- 3) List names of actors, along with titles of movies they have acted in.
--    If they have not acted in any movie, show the movie title as NULL.
SELECT
  a.AID,
  a.name,
  m.title
FROM actors a
LEFT JOIN actor_role ar ON a.AID = ar.AID
LEFT JOIN movies     m  ON ar.MID = m.MID
ORDER BY a.AID, m.title;

-- 4) List all roles of a given actor.
--    Replace :given_aid with the desired actor ID.
SELECT
  m.MID,
  m.title,
  ar.rolename
FROM actor_role ar
JOIN movies       m ON ar.MID = m.MID
WHERE ar.AID = :given_aid;
