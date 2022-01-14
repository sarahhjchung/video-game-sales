SET SEARCH_PATH TO VideoGame;

DROP TABLE IF EXISTS VideoGameSales CASCADE; 
DROP VIEW IF EXISTS UniqueGameNames CASCADE; 
DROP SEQUENCE IF EXISTS id CASCADE; 

-- Table for copying over all the data from csv file
CREATE TABLE VideoGameSales (
  Name TEXT,
  Platform TEXT,
  Year_of_Release TEXT,
  Genre TEXT,
  Publisher TEXT,
  NA_Sales TEXT,
  EU_Sales TEXT,
  JP_Sales TEXT,
  Other_Sales TEXT,
  Global_Sales TEXT,
  Critic_Score TEXT,
  Critic_Count TEXT,
  User_Score TEXT,
  User_Count TEXT,
  Developer TEXT,
  Rating TEXT
);

-- Importing data from csv file to VideoGameSales
\COPY VideoGameSales FROM Video_Games_Sales.csv with (format csv,header true, delimiter ',');

-- Clean up data with NULL values in GameName
DELETE FROM VideoGameSales WHERE Name is NULL;

-- Clean up data where the same (Name, Platform) pair has different Year, Genre, or Publisher
DELETE FROM VideoGameSales 
    WHERE Name IN (
        SELECT a.Name 
        FROM VideoGameSales a, VideoGameSales b
        WHERE a.Name=b.Name AND (
            a.Genre != b.Genre OR a.Year_of_Release != b.Year_of_Release OR a.Publisher != b.Publisher
        )
    );

-- Clean up rows that violated constraints 
DELETE FROM VideoGameSales 
    WHERE Name='Madden NFL 13' AND Platform='PS3';

-- A sequence for unique game IDs
CREATE sequence id AS INT START 1;


-- A view to get unique game names from VideoGameSales
CREATE VIEW UniqueGameNames AS 
    SELECT DISTINCT Name, Publisher, Genre, (CASE
        WHEN Year_of_Release = 'N/A'
            THEN NULL
        ELSE 
            CAST(Year_of_Release AS INT) 
    END) AS yearOfRelease FROM VideoGameSales;

-- Inserting values from Video_Game_Sales.csv into Game table
INSERT INTO Game 
(
    SELECT setval('id', nextval('id')) AS gID, name, Publisher, 
    Genre, yearOfRelease
    FROM UniqueGameNames
);

-- Inserting values from Video_Game_Sales.csv into GamePlatform table
INSERT INTO GamePlatform 
(
    SELECT DISTINCT g.gID, platform
    FROM Game g, VideoGameSales v
    WHERE g.name = v.name
);

-- Inserting values from Video_Game_Sales.csv into Sales table
INSERT INTO Sales 
(
    SELECT p.gID AS game, p.platform AS platform, 
    CAST(NA_Sales AS FLOAT) AS NASales,
    CAST(JP_Sales AS FLOAT) AS JPSales,
    CAST(EU_Sales AS FLOAT) AS EUSales,
    CAST(Other_Sales AS FLOAT) AS otherSales,
    CAST(Global_Sales AS FLOAT) AS globalSales
    FROM Game g, GamePlatform p, VideoGameSales v
    WHERE g.gID = p.gID AND v.name = g.name AND v.platform = p.platform
);

-- Inserting values from Video_Game_Sales.csv into Ratings table
INSERT INTO Ratings 
(
    SELECT p.gID AS game, p.platform AS platform, 
    CAST(Critic_Score AS INT) AS criticScore,
    CAST(Critic_Count AS INT) AS criticCount,
    (CASE
        WHEN User_Score = 'tbd'
            THEN NULL
        ELSE 
            CAST(User_Score AS FLOAT) 
    END) AS userScore,
    (CASE
        WHEN User_Score = 'tbd'
            THEN NULL
        ELSE 
            CAST(User_Count AS INT) 
    END) AS userCount
    FROM Game g, GamePlatform p, VideoGameSales v
    WHERE g.gID = p.gID AND v.name = g.name AND v.platform = p.platform
);