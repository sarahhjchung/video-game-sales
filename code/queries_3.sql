SET SEARCH_PATH TO VideoGame;
DROP VIEW IF EXISTS ppSales CASCADE; 
DROP VIEW IF EXISTS ppMostSales CASCADE; 
DROP VIEW IF EXISTS pgSales CASCADE; 
DROP VIEW IF EXISTS pgMostSales CASCADE; 

-- average global sales each publisher in each platform
CREATE VIEW ppSales AS
SELECT g.publisher as publisher, p.platform as platform, avg(s.globalSales) as sales
FROM Game g, Sales s, GamePlatform p
where g.gID = s.Game and g.gID = p.gID
GROUP BY g.publisher, p.platform
ORDER BY p.platform;

-- the publisher with most global sales for each platform
CREATE VIEW ppMostSales AS
SELECT platform, MAX(sales) as mostSales
from ppSales
GROUP BY platform;

SELECT g.publisher, g.platform, m.mostSales
FROM ppMostSales m, ppSales g
WHERE m.mostSales = g.sales and m.platform = g.platform;

-- -- average global sale by platform
-- SELECT p.platform as platform, avg(s.globalSales) as sales
-- FROM Game g, Sales s, GamePlatform p
-- where g.gID = s.Game and g.gID = p.gID
-- GROUP BY p.platform;

--average global sales each publisher in each genre
CREATE VIEW pgSales AS
SELECT g.publisher as publisher, g.genre as genre, avg(s.globalSales) as sales
FROM Game g, Sales s
where g.gID = s.Game
GROUP BY g.publisher, g.genre
ORDER BY g.genre;

-- the publisher with most global sales for each genre
CREATE VIEW pgMostSales AS
SELECT genre, MAX(sales) as mostSales
from pgSales
GROUP BY genre;

SELECT g.publisher, g.genre, m.mostSales
FROM pgMostSales m, pgSales g
WHERE m.mostSales = g.sales and m.genre = g.genre;

-- the average global sales of games sold by Nintendo by genre
SELECT g.genre as genre, avg(s.globalSales) as nintendoSales
FROM Game g, Sales s
WHERE g.gID = s.game and g.publisher = 'Nintendo'
GROUP BY g.genre;

-- the average critic and user score on all platforms for sports games published by Nintendo
SELECT platform, avg(criticScore) as avgCriticScore, avg(userScore) as avgUserScore
FROM Game g, Ratings r
WHERE gID = game AND publisher = 'Nintendo' AND genre = 'Sports'
GROUP BY platform;

-- the average critic and user score of ALL publishers for sports games on the Wii
CREATE VIEW nintendoSportsRatings AS
SELECT avg(criticScore) as avgCriticScore, avg(userScore) as avgUserScore
FROM Game g, Ratings r
WHERE gID = game AND platform = 'Wii' AND genre = 'Sports';
