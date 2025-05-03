-- ===========================
-- DDL: Create Tables
-- ===========================

-- 1. Painter Table
CREATE TABLE Painter (
  Painter_Cd     INT PRIMARY KEY,                -- Unique identifier for painter
  Painter_Name   VARCHAR(100) NOT NULL,          -- Painter's name
  Address        VARCHAR(100),                    -- Painter's address
  Contact_No     VARCHAR(20) NOT NULL            -- Painter's contact number
);

-- 2. Gallery Table
CREATE TABLE Gallery (
  Gallery_No     INT PRIMARY KEY,                -- Unique identifier for gallery
  Gallery_Name   VARCHAR(100) NOT NULL,          -- Name of the gallery
  Gallery_address VARCHAR(100) NOT NULL          -- Address of the gallery
);

-- 3. Painting Table
CREATE TABLE Painting (
  Painting_id    INT PRIMARY KEY,                -- Unique identifier for the painting
  Painting_De    VARCHAR(100) NOT NULL,          -- Description of the painting
  PaintingTheme  VARCHAR(50),                     -- Theme of the painting
  Painter_Cd     INT,                             -- Foreign Key to Painter
  FOREIGN KEY (Painter_Cd) REFERENCES Painter(Painter_Cd) ON DELETE CASCADE -- Foreign key constraint to Painter
);

-- 4. Display Table (Association between Paintings and Galleries)
CREATE TABLE Display (
  Painting_id    INT,                             -- Foreign Key to Painting
  Gallery_No     INT,                             -- Foreign Key to Gallery
  PRIMARY KEY (Painting_id, Gallery_No),         -- Composite Primary Key
  FOREIGN KEY (Painting_id) REFERENCES Painting(Painting_id) ON DELETE CASCADE, -- Foreign key constraint to Painting
  FOREIGN KEY (Gallery_No) REFERENCES Gallery(Gallery_No) ON DELETE CASCADE -- Foreign key constraint to Gallery
);

-- ===========================
-- DML: Insert Sample Data
-- ===========================

-- Insert sample data into the Painter table
INSERT INTO Painter (Painter_Cd, Painter_Name, Address, Contact_No) VALUES
  (1, 'Ravi Varma', 'Delhi, India', '9999111111'),
  (2, 'MF Hussain', 'Mumbai, India', '8888222222'),
  (3, 'Pablo Picasso', 'Barcelona, Spain', '7777333333');

-- Insert sample data into the Gallery table
INSERT INTO Gallery (Gallery_No, Gallery_Name, Gallery_address) VALUES
  (101, 'Modern Art Gallery', 'Bangalore, India'),
  (102, 'Classic Art Gallery', 'Mumbai, India'),
  (103, 'Global Art Museum', 'New York, USA');

-- Insert sample data into the Painting table
INSERT INTO Painting (Painting_id, Painting_De, PaintingTheme, Painter_Cd) VALUES
  (1001, 'Royal Portrait', 'Royalty', 1),
  (1002, 'Running Horse', 'Action', 2),
  (1003, 'Peaceful Nature', 'Nature', 1),
  (1004, 'Abstract Art', 'Abstract', 3);

-- Insert sample data into the Display table
INSERT INTO Display (Painting_id, Gallery_No) VALUES
  (1001, 101),
  (1002, 101),
  (1003, 102),
  (1004, 103);

-- ===========================
-- DQL: Queries
-- ===========================

-- 1. List all painters
SELECT Painter_Cd, Painter_Name, Address, Contact_No
FROM Painter;

-- 2. Show all galleries and their address
SELECT Gallery_No, Gallery_Name, Gallery_address
FROM Gallery;

-- 3. List all paintings with their themes
SELECT Painting_id, Painting_De, PaintingTheme
FROM Painting;

-- 4. Show all paintings along with the gallery name where they are displayed
SELECT p.Painting_De, g.Gallery_Name
FROM Painting p
JOIN Display d ON p.Painting_id = d.Painting_id
JOIN Gallery g ON d.Gallery_No = g.Gallery_No;

-- 5. List painter names along with the count of paintings they have
SELECT pt.Painter_Name, COUNT(p.Painting_id) AS Painting_Count
FROM Painter pt
JOIN Painting p ON pt.Painter_Cd = p.Painter_Cd
GROUP BY pt.Painter_Name;

-- 6. List all paintings of a specific painter (e.g., 'Ravi Varma')
SELECT p.Painting_De
FROM Painting p
JOIN Painter pt ON p.Painter_Cd = pt.Painter_Cd
WHERE pt.Painter_Name = 'Ravi Varma';

-- 7. Display galleries where a specific painting is displayed (e.g., 'Running Horse')
SELECT g.Gallery_Name
FROM Gallery g
JOIN Display d ON g.Gallery_No = d.Gallery_No
WHERE d.Painting_id = 1002;

-- 8. Show the paintings that belong to a specific theme (e.g., 'Nature')
SELECT Painting_De
FROM Painting
WHERE PaintingTheme = 'Nature';

-- 9. Count the number of paintings displayed in each gallery
SELECT g.Gallery_Name, COUNT(d.Painting_id) AS Paintings_Display_Count
FROM Gallery g
JOIN Display d ON g.Gallery_No = d.Gallery_No
GROUP BY g.Gallery_Name;
