CREATE SCHEMA IPL;

USE IPL;

CREATE TABLE Players(
    PlayerID CHARACTER(5) PRIMARY KEY,
    PlayerName VARCHAR(30) NOT NULL, 
    Nationality  VARCHAR(30) NOT NULL,
    DoB DATE NOT NULL,
    PlayerRole  VARCHAR(30),
    StrikeRate DECIMAL(5,2),
    BowlingStyle  VARCHAR(30),
    BattingStyle  VARCHAR(30)
);

CREATE TABLE TitleSponsor(
    CompanyName VARCHAR(30) PRIMARY KEY,
    BusinessDomain VARCHAR(30) NOT NULL,
    Country VARCHAR(30) NOT NULL    
);

CREATE TABLE TeamOwner(
    CompanyName VARCHAR(30) PRIMARY KEY,
    BusinessDomain VARCHAR(30) NOT NULL,
    Country VARCHAR(30) NOT NULL    
);

CREATE TABLE HeadCoach(
    CoachID CHARACTER(5) PRIMARY KEY,
    CoachName VARCHAR(30) NOT NULL,
    Years_of_Experience SMALLINT,
    DoB DATE NOT NULL,
    Country VARCHAR(30) NOT NULL
);

CREATE TABLE Teams(
    TeamID VARCHAR(5) PRIMARY KEY,
    TeamName VARCHAR(30) UNIQUE NOT NULL,
    OwnerCompany VARCHAR(30) NOT NULL,
    FOREIGN KEY(OwnerCompany) REFERENCES TeamOwner (CompanyName)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Umpire(
    UmpireID CHARACTER(5) PRIMARY KEY,
    PlayerName VARCHAR(30) NOT NULL,
    YearsOfExperience SMALLINT,
    Country VARCHAR(30) NOT NULL    
);

CREATE TABLE Stadium(
    StadiumName VARCHAR(30),
    City VARCHAR(30),
    Country VARCHAR(30) NOT NULL,
    Capacity INT,
    RentAmount BIGINT,
    PRIMARY KEY (StadiumName, City)
);

CREATE TABLE MatchInfo(
    MatchID CHARACTER(7) PRIMARY KEY,
    MatchType VARCHAR(10) NOT NULL,
    MatchDate DATE NOT NULL,
    StadiumName VARCHAR(30) NOT NULL,
    City VARCHAR(30) NOT NULL,
    ManOfTheMatch CHARACTER(5) NOT NULL,
    FOREIGN KEY (StadiumName, City) REFERENCES Stadium (StadiumName, City)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ManOfTheMatch) REFERENCES Players (PlayerID)
        ON DELETE CASCADE ON UPDATE CASCADE    
);

CREATE TABLE UmpiredBy(
    MatchID CHARACTER(7),
    UmpireID CHARACTER(5),
    PRIMARY KEY (MatchID, UmpireID),
    FOREIGN KEY (MatchID) REFERENCES MatchInfo (MatchID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (UmpireID) REFERENCES Umpire (UmpireID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IPL(
    YearInfo SMALLINT PRIMARY KEY, 
    TitleSponsor VARCHAR(30) NOT NULL,
    ManOfTheSeries CHARACTER(5) NOT NULL,
    ChampionTeam VARCHAR(5) NOT NULL,
    FOREIGN KEY (ChampionTeam) REFERENCES Teams (TeamID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (TitleSponsor) REFERENCES TitleSponsor (CompanyName)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ManOfTheSeries) REFERENCES Players (PlayerID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE TeamDetails(
    TeamID VARCHAR(5),
    YearInfo SMALLINT,
    CaptainID CHARACTER(5) NOT NULL,
    CoachID CHARACTER(5) NOT NULL,
    SponsorCompany VARCHAR(30) NOT NULL,
    SponsorAmount BIGINT NOT NULL,    
    PRIMARY KEY (TeamID, YearInfo),
    FOREIGN KEY (CaptainID) REFERENCES Players (PlayerID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (CoachID) REFERENCES HeadCoach (CoachID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (SponsorCompany) REFERENCES TitleSponsor (CompanyName)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (TeamID) REFERENCES Teams (TeamID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (YearInfo) REFERENCES IPL (YearInfo)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE YearwisePlayerDetails(
    PlayerID CHARACTER(5),
    YearInfo SMALLINT, 
    TeamID VARCHAR(5) NOT NULL,
    TotalWickets INT,
    TotalRuns INT,
    MaximumWickets INT,
    MaximumWicketsRuns INT,
    MaximumRuns INT,
    PlayerPrice BIGINT,
    Out_NotOut BOOLEAN,
    PRIMARY KEY(PlayerID,YearInfo),
    FOREIGN KEY (PlayerID) REFERENCES Players (PlayerID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (TeamID,YearInfo) REFERENCES TeamDetails (TeamID,YearInfo)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Played(
    MatchID CHARACTER(7),
    TeamID VARCHAR(5),
    TeamRuns INT NOT NULL,
    Fours INT NOT NULL,
    Sixes INT NOT NULL,
    Wickets INT NOT NULL,
    Winner CHARACTER(1) NOT NULL, 
    PRIMARY KEY(MatchID,TeamID),
    FOREIGN KEY (TeamID) REFERENCES Teams (TeamID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (MatchID) REFERENCES MatchInfo (MatchID)
        ON DELETE CASCADE ON UPDATE CASCADE
);