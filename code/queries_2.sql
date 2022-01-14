SET SEARCH_PATH TO VideoGame;
-- DROP VIEW IF EXISTS UniqueGameNames CASCADE; 
DROP VIEW IF EXISTS gpSales CASCADE; 
DROP VIEW IF EXISTS gpMostSales CASCADE; 

-- average global sales each genre in each platform
CREATE VIEW gpSales AS
SELECT g.genre as genre, p.platform as platform, avg(s.globalSales) as sales
FROM Game g, Sales s, GamePlatform p
where g.gID = s.Game and g.gID = p.gID
GROUP BY g.genre, p.platform
ORDER BY p.platform;

-- the genre with most global sales for each platform
CREATE VIEW gpMostSales AS
SELECT platform, MAX(sales) as mostSales
from gpSales
GROUP BY platform;

SELECT g.genre, g.platform, m.mostSales
FROM gpMostSales m, gpSales g
WHERE m.mostSales = g.sales and m.platform = g.platform;

-- average global sale by genre
SELECT g.genre as genre, avg(s.globalSales) as sales
FROM Game g, Sales s
where g.gID = s.Game
GROUP BY g.genre;


