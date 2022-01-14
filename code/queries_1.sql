SET SEARCH_PATH TO VideoGame;

DROP TABLE IF exists TopSalesPerYear CASCADE;
DROP TABLE IF exists TopGamesReleasedPerYear CASCADE;
DROP TABLE IF exists TopSalesPerYear CASCADE;
DROP VIEW IF exists AllYears CASCADE;
DROP VIEW IF exists TotalSalesPerYear CASCADE;
DROP VIEW IF exists TotalNumNAGamesPerYear CASCADE;
DROP VIEW IF exists TotalNumJPGamesPerYear CASCADE;
DROP VIEW IF exists TotalNumEUGamesPerYear CASCADE;
DROP VIEW IF exists TotalNumOtherGamesPerYear CASCADE;
DROP VIEW IF exists NAGamesPerYear CASCADE;
DROP VIEW IF exists JPGamesPerYear CASCADE;
DROP VIEW IF exists EUGamesPerYear CASCADE;
DROP VIEW IF exists OtherGamesPerYear CASCADE;

CREATE TABLE TopSalesPerYear (
    year INT, 
    topRegion TEXT,
    totalSales FLOAT
);

CREATE TABLE TopGamesReleasedPerYear (
    year INT,
    topRegion TEXT,
    totalNumGames INT
);

-- All yearofRelease in dataset
CREATE VIEW AllYears AS 
    SELECT yearOfRelease AS year
    FROM Game
    GROUP BY yearOfRelease
    ORDER BY yearOfRelease;

-- Total region sales per yearOfRelease
CREATE VIEW TotalSalesPerYear AS 
    SELECT yearOfRelease, sum(NASales) as NA, sum(JPSales) as JP, sum(EUSales) AS EU, sum(otherSales) AS other
    FROM Game g, GamePlatform p, Sales s 
    WHERE g.GID = p.gID AND p.gID = game AND p.platform = s.platform
    GROUP BY yearOfRelease;

-- Total number of unique games sold in NA per yearOfRelease
CREATE VIEW TotalNumNAGamesPerYear AS 
    SELECT yearOfRelease, count(*) as NA
    FROM Game g, GamePlatform p, Sales s 
    WHERE g.GID = p.gID AND p.gID = game AND p.platform = s.platform AND NASales > 0 
    GROUP BY yearOfRelease;

-- Cleaned up total number of unique games sold in NA per yearOfRelease
CREATE VIEW NAGamesPerYear AS 
    SELECT year, 
    (CASE
        WHEN year IN (SELECT yearOfRelease FROM TotalNumNAGamesPerYear)
            THEN (SELECT NA FROM TotalNumNAGamesPerYear WHERE yearOfRelease = year)
        ELSE 0
    END) AS NA
    FROM AllYears;

-- Total number of unique games sold in JP per yearOfRelease
CREATE VIEW TotalNumJPGamesPerYear AS 
    SELECT yearOfRelease, count(*) as JP
    FROM Game g, GamePlatform p, Sales s 
    WHERE g.GID = p.gID AND p.gID = game AND p.platform = s.platform AND JPSales > 0 
    GROUP BY yearOfRelease;

-- Cleaned up total number of unique games sold in JP per yearOfRelease
CREATE VIEW JPGamesPerYear AS 
    SELECT year, 
    (CASE
        WHEN year IN (SELECT yearOfRelease FROM TotalNumJPGamesPerYear)
            THEN (SELECT JP FROM TotalNumJPGamesPerYear WHERE yearOfRelease = year)
        ELSE 0
    END) AS JP
    FROM AllYears;

-- Total number of unique games sold in EU per yearOfRelease
CREATE VIEW TotalNumEUGamesPerYear AS 
    SELECT yearOfRelease, count(*) as EU
    FROM Game g, GamePlatform p, Sales s 
    WHERE g.GID = p.gID AND p.gID = game AND p.platform = s.platform AND EUSales > 0 
    GROUP BY yearOfRelease;

-- Cleaned up total number of unique games sold in EU per yearOfRelease
CREATE VIEW EUGamesPerYear AS 
    SELECT year, 
    (CASE
        WHEN year IN (SELECT yearOfRelease FROM TotalNumEUGamesPerYear)
            THEN (SELECT EU FROM TotalNumEUGamesPerYear WHERE yearOfRelease = year)
        ELSE 0
    END) AS EU
    FROM AllYears;

-- Total number of unique games sold in Other per yearOfRelease
CREATE VIEW TotalNumOtherGamesPerYear AS 
    SELECT yearOfRelease, count(*) as other
    FROM Game g, GamePlatform p, Sales s 
    WHERE g.GID = p.gID AND p.gID = game AND p.platform = s.platform AND otherSales > 0 
    GROUP BY yearOfRelease;

-- Cleaned up total number of unique games sold in Other per yearOfRelease
CREATE VIEW OtherGamesPerYear AS 
    SELECT year, 
    (CASE
        WHEN year IN (SELECT yearOfRelease FROM TotalNumOtherGamesPerYear)
            THEN (SELECT other FROM TotalNumOtherGamesPerYear WHERE yearOfRelease = year)
        ELSE 0
    END) AS other
    FROM AllYears;

INSERT INTO TopSalesPerYear 
SELECT yearOfRelease AS year, 
    (CASE
        WHEN NA > JP AND NA > EU AND NA > other
            THEN 'NA'
        WHEN JP > NA AND JP > EU AND JP > other
            THEN 'JP'
        WHEN EU > JP AND EU > NA AND EU > other
            THEN 'EU'
        WHEN other > JP AND other > NA AND other > EU
            THEN 'other'
        ELSE NULL
    END) AS topRegion, 
    (CASE
        WHEN NA > JP AND NA > EU AND NA > other
            THEN NA
        WHEN JP > NA AND JP > EU AND JP > other
            THEN JP
        WHEN EU > JP AND EU > NA AND EU > other
            THEN EU
        WHEN other > JP AND other > NA AND other > EU
            THEN other
        ELSE NULL
    END) AS totalSales
FROM TotalSalesPerYear;

INSERT INTO TopGamesReleasedPerYear
SELECT na.year AS year,
    (CASE
        WHEN NA >= JP AND NA >= EU AND NA >= other
            THEN 'NA'
        WHEN JP >= NA AND JP >= EU AND JP >= other
            THEN 'JP'
        WHEN EU >= JP AND EU >= NA AND EU >= other
            THEN 'EU'
        WHEN other >= JP AND other >= NA AND other >= EU
            THEN 'other'
        ELSE NULL
    END) AS topRegion, 
    (CASE
        WHEN NA >= JP AND NA >= EU AND NA >= other
            THEN NA
        WHEN JP >= NA AND JP >= EU AND JP >= other
            THEN JP
        WHEN EU >= JP AND EU >= NA AND EU >= other
            THEN EU
        WHEN other >= JP AND other >= NA AND other >= EU
            THEN other
        ELSE NULL
    END) AS totalNumGames
FROM NAGamesPerYear na, JPGamesPerYear jp, OtherGamesPerYear o, EUGamesPerYear eu
WHERE na.year = jp.year AND jp.year = eu.year AND eu.year = o.year;

SELECT * FROM TopSalesPerYear ORDER BY year;
SELECT * FROM TopGamesReleasedPerYear ORDER BY year;
SELECT * FROM TotalSalesPerYear ORDER BY yearOfRelease;