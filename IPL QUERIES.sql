-- 1. List all players
SELECT playerid, PlayerName FROM players;

-- 2. List players who participated in all seasons from the same team
SELECT DISTINCT playerid, teamid, PlayerName, YearInfo 
FROM (
    SELECT count(distinct teamid), playerid 
    FROM yearwiseplayerdetails 
    GROUP BY playerid 
    HAVING count(distinct teamid) = 1
) AS r2
NATURAL JOIN yearwiseplayerdetails
NATURAL JOIN players AS r1;

-- 3. Champions of a particular year/all years
-- All years
SELECT YearInfo, championteam, teamname 
FROM ipl JOIN teams ON championteam = teamid;
-- Particular year
SELECT YearInfo, championteam, teamname 
FROM ipl JOIN teams ON championteam = teamid 
WHERE YearInfo = 2022;

-- 4. Winning teams in all matches during an IPL season
SELECT * FROM (
    SELECT matchid, matchtype, teamid AS winning_team 
    FROM MatchInfo 
    NATURAL JOIN played 
    WHERE extract(year FROM MatchDate) = 2015 AND winner='1'
) AS r1
NATURAL JOIN (
    SELECT matchid, matchtype, teamid AS losing_team 
    FROM MatchInfo 
    NATURAL JOIN played 
    WHERE extract(year FROM MatchDate) = 2015 AND winner='0'
) AS r2;

-- 5. Details about Man of the Match for a particular match/all matches
-- All matches
SELECT r1.matchid, r1.manofthematch, r1.PlayerName AS ManOfTheMatch, r1.teamid AS WinningTeam, r1.yearinfo AS year, r2.PlayerName AS LosingTeam 
FROM (
    SELECT matchid, m.manofthematch, pl.PlayerName, y.teamid, p.teamid AS team1, y.YearInfo AS yearinfo 
    FROM played AS p 
    NATURAL JOIN MatchInfo AS m 
    JOIN YearWisePlayerDetails AS y ON m.manofthematch = y.playerid AND extract(year FROM m.MatchDate) = y.YearInfo 
    NATURAL JOIN players AS pl 
    WHERE p.winner = '1'
) AS r1
NATURAL JOIN (
    SELECT matchid, m.manofthematch, pl.PlayerName, y.teamid, p.teamid AS team2, y.YearInfo AS yearinfo 
    FROM played AS p 
    NATURAL JOIN MatchInfo AS m 
    JOIN YearWisePlayerDetails AS y ON m.manofthematch = y.playerid AND extract(year FROM m.MatchDate) = y.YearInfo 
    NATURAL JOIN players AS pl 
    WHERE p.winner = '0'
) AS r2;

-- Particular match
SELECT * FROM (
    SELECT matchid, m.manofthematch, pl.PlayerName, y.teamid, p.teamid AS team1 
    FROM played AS p 
    NATURAL JOIN MatchInfo AS m 
    JOIN YearWisePlayerDetails AS y ON m.manofthematch = y.playerid AND extract(year FROM m.MatchDate) = y.YearInfo 
    NATURAL JOIN players AS pl 
    WHERE p.winner = '1' AND (p.teamid = 'CSK' OR p.teamid = 'RCB') AND y.YearInfo = 2015
) AS r1
NATURAL JOIN (
    SELECT matchid, m.manofthematch, pl.PlayerName, y.teamid, p.teamid AS team2 
    FROM played AS p 
    NATURAL JOIN MatchInfo AS m 
    JOIN YearWisePlayerDetails AS y ON m.manofthematch = y.playerid AND extract(year FROM m.MatchDate) = y.YearInfo 
    NATURAL JOIN players AS pl 
    WHERE p.winner = '0' AND (p.teamid = 'CSK' OR p.teamid = 'RCB') AND y.YearInfo = 2015
) AS r2;

-- 6. Details of coaches for a particular year/particular team
-- Particular year
SELECT YearInfo, CoachID, CoachName, Teamid 
FROM headcoach 
NATURAL JOIN teamdetails 
WHERE YearInfo = 2019;
-- Particular team
SELECT Teamid, YearInfo, CoachID, CoachName 
FROM headcoach 
NATURAL JOIN teamdetails 
WHERE teamid = 'CSK';

-- 7. Details of IPL sponsor during specific year/all years
-- Particular year
SELECT YearInfo, teamid, sponsorCompany, businessdomain, country 
FROM teamdetails AS td 
JOIN Titlesponsor AS t ON td.sponsorcompany=t.companyname 
WHERE YearInfo = 2019;
-- All years
SELECT YearInfo, teamid, sponsorCompany, businessdomain, country 
FROM teamdetails AS td 
JOIN Titlesponsor AS t ON td.sponsorcompany=t.companyname;
-- Particular Team
SELECT YearInfo, teamid, sponsorCompany, businessdomain, country 
FROM teamdetails AS td 
JOIN Titlesponsor AS t ON td.sponsorcompany=t.companyname 
WHERE teamid = 'MI';

-- 8. Details of Owner Company of a particular team
SELECT teamid, o.* 
FROM TeamOwner AS o 
JOIN Teams ON o.companyname = teams.ownercompany 
WHERE TeamID = 'CSK';

-- 9. Details of sponsor of a particular team in a particular year
SELECT teamid, YearInfo, CompanyName, businessdomain, Country 
FROM TitleSponsor AS s 
JOIN teamdetails AS t ON s.companyname = t.sponsorcompany 
WHERE TeamID = 'RCB' AND YearInfo = 2019;

-- 10. Information of a particular player
SELECT * FROM Players WHERE PlayerName = 'Hardik Pandya';

-- 11. Details of a particular player for a particular season
SELECT PlayerName, TotalWickets, TotalRuns 
FROM YearwisePlayerDetails 
NATURAL JOIN Players 
WHERE PlayerID = '00012' AND YearInfo = 2019;

-- 12. Details of a player with performance stats over the years
SELECT playerid, PlayerName, "Total Wickets Taken", "Total Runs", MostWicketTaken, strikerate 
FROM (
    SELECT PlayerID, SUM(TotalWickets) AS "Total Wickets Taken", SUM(TotalRuns) AS "Total Runs", MAX(MaximumWickets) AS MostWicketTaken 
    FROM YearwisePlayerDetails 
    WHERE PlayerID = '00012' 
    GROUP BY PlayerID
) AS r1
NATURAL JOIN players AS p;

-- 13. Details about all stadiums where IPL has been conducted
SELECT DISTINCT s.* FROM Stadium AS s NATURAL JOIN MatchInfo AS m;

-- 14. Total number of matches played in a particular stadium
SELECT StadiumName, City, COUNT(MatchID) AS "Number of matches played" 
FROM MatchInfo 
GROUP BY StadiumName, City;

-- 15. Total number of different teams handled by a particular coach over all seasons
SELECT CoachID, Coachname, "No. of Teams Handled" 
FROM (
    SELECT coachID, COUNT(DISTINCT TeamID) AS "No. of Teams Handled" 
    FROM TeamDetails 
    GROUP BY CoachID
) AS r 
NATURAL JOIN Headcoach AS h;

-- 16. Teams sponsored by a particular sponsor over all seasons
SELECT SponsorCompany, YearInfo, TeamID 
FROM TeamDetails 
WHERE SponsorCompany = 'Royal Stag';

-- 17. Yearwise budget spent by teams on player purchase
SELECT teamid, YearInfo, (SUM(playerprice)/10000000) AS "Budget Spent to buy Players (in Crores)" 
FROM YearWisePlayerDetails 
GROUP BY Teamid, YearInfo 
ORDER BY YearInfo;

-- 18. Total budget spent in IPL seasons
SELECT YearInfo, SUM("Budget Spent to buy Players") AS "Total Budget Spent" 
FROM (
    SELECT YearInfo, SUM(playerprice) AS "Budget Spent to buy Players" 
    FROM YearWisePlayerDetails 
    GROUP BY YearInfo 
    UNION 
    SELECT EXTRACT(YEAR FROM MatchDate) AS YearInfo, SUM(RentAmount) 
    FROM MatchInfo AS m 
    NATURAL JOIN STADIUM AS s 
    GROUP BY EXTRACT(YEAR FROM MatchDate)
) AS r 
GROUP BY YearInfo;

-- 19. Winning statistics of a team
SELECT TeamID, YearInfo, COUNT(winner) 
FROM (
    SELECT td.teamid, td.YearInfo, winner 
    FROM TeamDetails AS td 
    LEFT JOIN (
        (SELECT MatchID, EXTRACT(YEAR FROM MatchDate) AS YearInfo FROM MatchInfo AS m) AS r 
        NATURAL JOIN (
            SELECT * FROM Played AS p 
            WHERE p.winner='1'
        ) AS t
    ) ON td.teamid=t.teamid AND td.YearInfo=r.YearInfo
) AS rel 
GROUP BY TeamID, YearInfo 
ORDER BY YearInfo;

-- 20. Coaching statistics of a coach over the past five years
SELECT CoachID, CoachName, Years_of_Experience, "No. of times his team won IPL match" 
FROM HeadCoach AS h 
NATURAL JOIN (
    SELECT CoachID, COUNT(Winner) AS "No. of times his team won IPL match" 
    FROM TeamDetails AS td 
    NATURAL JOIN (
        SELECT TeamID, EXTRACT(YEAR FROM MatchDate) AS YearInfo, Winner 
        FROM MatchInfo AS m 
        NATURAL JOIN PLAYED AS p 
        WHERE Winner='1'
    ) AS r2 
    GROUP BY CoachID
) AS r;

-- 21. Coach whose team won the maximum number of times
SELECT CoachID, CoachName, Years_of_Experience, "No. of times his team won the IPL" 
FROM HeadCoach AS h 
NATURAL JOIN (
    SELECT CoachID, COUNT(Winner) AS "No. of times his team won the IPL" 
    FROM TeamDetails AS td 
    NATURAL JOIN (
        SELECT TeamID, EXTRACT(YEAR FROM MatchDate) AS YearInfo, Winner 
        FROM MatchInfo AS m 
        NATURAL JOIN PLAYED AS p 
        WHERE Winner='1'
    ) AS r2 
    GROUP BY CoachID
) AS r 
ORDER BY "No. of times his team won the IPL" DESC 
LIMIT 2;

-- 22. Players who earned the title of "Man of the match" multiple times during a particular year
SELECT p.* 
FROM players AS p 
JOIN (
    SELECT ManOfTheMatch 
    FROM MatchInfo 
    WHERE extract(year FROM MatchDate)=2019 
    GROUP BY ManOfTheMatch 
    HAVING count(ManOfTheMatch)>1
) AS r1 
ON manofthematch = playerid;

-- 23. Players who earned the title of "Man of the match" in multiple seasons of the IPL
SELECT p.* 
FROM players AS p 
JOIN (
    SELECT COUNT(DISTINCT EXTRACT(YEAR FROM MatchDate)), manofthematch 
    FROM MatchInfo 
    GROUP BY manofthematch 
    HAVING COUNT(DISTINCT EXTRACT(YEAR FROM MatchDate))>1
) AS r 
ON playerid=manofthematch;

-- 24. Teams who reached the finals maximum number of times
SELECT teamid, count(teamid) as No_of_times_team_reached_finals 
FROM played 
NATURAL JOIN MatchInfo 
WHERE matchtype = 'Final' 
GROUP BY teamid 
ORDER BY No_of_times_team_reached_finals DESC 
LIMIT 1;

-- 25. Coaches who mentored winning teams of the IPL
SELECT championteam as WinnerTeam, ipl.YearInfo, headcoach.coachid, coachname 
FROM ipl 
JOIN teamdetails on championteam = teamid and ipl.YearInfo = teamdetails.YearInfo 
JOIN headcoach on headcoach.coachid = teamdetails.coachid;

-- 26. Coaches who mentored runners-up teams of the IPL
SELECT teamid, YearInfo, coachid, coachname 
FROM (
    SELECT teamid, extract(year FROM MatchDate) as YearInfo 
    FROM MatchInfo 
    NATURAL JOIN played 
    WHERE winner='0' and matchtype = 'Final'
) as r 
NATURAL JOIN teamdetails 
NATURAL JOIN headcoach;

-- 27. Players with best bowling statistics in a particular season
SELECT * FROM (
    SELECT playerid, YearInfo, teamid, maximumwickets, maximumwicketsruns 
    FROM yearwiseplayerdetails 
    WHERE YearInfo = 2015 and maximumwickets is not null 
    ORDER BY maximumwickets DESC
) as r1 
JOIN (
    SELECT max(maximumwickets) as max_wickets
    FROM yearwiseplayerdetails 
    WHERE YearInfo = 2015 and maximumwickets is not null
) as r2 
ON r1.maximumwickets = r2.max_wickets 
ORDER BY maximumwicketsruns 
LIMIT 1;


-- 28. Players who scored most runs in particular season
SELECT * FROM (
    SELECT playerid, YearInfo, teamid, maximumruns, out_notout 
    FROM yearwiseplayerdetails 
    WHERE YearInfo = 2022 and maximumruns is not null 
    ORDER BY maximumruns DESC
) as r1 
JOIN (
    SELECT max(maximumruns) 
    FROM yearwiseplayerdetails 
    WHERE YearInfo = 2022 and maximumruns is not null
) as r2 
ON r1.maximumruns = r2.max 
ORDER BY out_notout DESC 
LIMIT 1;

-- 29. Count of total wickets taken by all bowlers
SELECT SUM(TotalWickets) 
FROM yearwiseplayerdetails 
NATURAL JOIN players 
WHERE "Role" = 'Bowler';

-- 30. Umpires who worked in finals of the IPL
SELECT u.*, EXTRACT(YEAR FROM MatchInfo.MatchDate) as year 
FROM MatchInfo 
NATURAL JOIN UmpiredBy 
NATURAL JOIN Umpire as u 
WHERE MatchType = 'Final';

-- 31. Teams who won all matches during a particular season
SELECT DISTINCT TeamID, EXTRACT(YEAR FROM MatchDate) 
FROM MatchInfo AS m 
NATURAL JOIN Played AS p 
WHERE EXTRACT(YEAR FROM MatchDate)='2019' AND p.winner='1' 
EXCEPT 
SELECT DISTINCT TeamID, EXTRACT(YEAR FROM MatchDate) 
FROM MatchInfo AS m 
NATURAL JOIN Played AS p 
WHERE EXTRACT(YEAR FROM MatchDate)='2019' AND p.winner='0';
