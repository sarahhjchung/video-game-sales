DROP SCHEMA IF EXISTS VideoGame CASCADE;
CREATE SCHEMA VideoGame;
SET SEARCH_PATH TO VideoGame;

-- A published game. 
-- gID is the ID of the game; it is unique and used to identify the game in case 
-- two games share the same name. Name, publisher, yearOfRelease and genre are obvious.
CREATE TABLE Game (
    gID INT,
    name TEXT NOT NULL,
    publisher TEXT NOT NULL,
    genre TEXT,
    yearOfRelease INT,
    PRIMARY KEY (gID)
);


-- A game and the platform it is avaliable on. 
-- gID is the ID of the game. Platform is the name of the device that the 
-- game is played on, such as PS2 and xbox.
CREATE TABLE GamePlatform (
    gID INT,
    platform TEXT,
    PRIMARY KEY(gID, platform),
    FOREIGN KEY (gID) REFERENCES Game(gID)
);

-- The sale of a published game.
-- Game is the ID of the published game. Platform is the name of the device that 
-- the game is played on, such as PS2 and xbox. NASales, EUSales, JPSales, 
-- otherSales, and globalSales each describe the sales in the region that is 
-- specified in the attribute name (ie. North America, European Union, Japan, 
-- Other, Global). Sales from all regions must be non-negative.
CREATE TABLE Sales (
    game INT,
    platform TEXT,
    NASales FLOAT,
    JPSales FLOAT,
    EUSales FLOAT,
    otherSales FLOAT,
    globalSales FLOAT,
    PRIMARY KEY (game, platform),
    FOREIGN KEY (game, platform) REFERENCES GamePlatform(gID, platform)
);

-- The ratings of a published game.
-- Game is the ID of the published game. Platform is the name of the device that 
-- the game is played on, such as PS2 and xbox. criticScore and userScore 
-- are the average of all scores given by critics and users. 
-- criticCount and userCount are the number of critics and users who 
-- provided a rating for the game. criticScore is a score between 0 and
-- 100. userScore is a (float) score between 0 and 10.
CREATE TABLE Ratings (
    game INT,
    platform TEXT,
    criticScore INT,
    criticCount INT,
    userScore FLOAT,
    userCount INT,
    PRIMARY KEY (game, platform),
    FOREIGN KEY (game, platform) REFERENCES GamePlatform(gID, platform)
);