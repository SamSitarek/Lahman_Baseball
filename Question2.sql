--Q2
SELECT namefirst, namelast, name, yearid, MIN(height) AS min_height, SUM(appearances.g_all) as total_games 
FROM people
LEFT JOIN appearances
USING(playerid)
LEFT JOIN teams
USING(teamid, yearid)
GROUP BY namefirst, namelast, playerid, appearances.teamid, yearid, name
ORDER BY min_height ASC;