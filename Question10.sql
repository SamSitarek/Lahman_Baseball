--Q10
--TOTAL SALARIES
SELECT schoolname, namefirst, namelast, SUM(salary::decimal::money) as total_salary
FROM schools
	LEFT JOIN (SELECT DISTINCT playerid, schoolid
			  FROM collegeplaying) AS cp
USING(schoolid)
LEFT JOIN people
USING(playerid)
LEFT JOIN salaries
USING(playerid)
WHERE schoolstate = 'TN'
AND salary IS NOT NULL
GROUP BY schoolname, namefirst, namelast
ORDER BY total_salary DESC;



--TOTAL GAMES
SELECT schoolstate, schoolname, SUM(g_all) as total_games
FROM schools
	LEFT JOIN (SELECT DISTINCT playerid, schoolid
			  FROM collegeplaying) AS cp
USING(schoolid)
LEFT JOIN appearances 
USING(playerid)
WHERE schoolstate = 'TN'
AND g_all IS NOT NULL
GROUP BY schoolstate, schoolname
ORDER BY total_games DESC;


--WORLD SERIES WINS
SELECT schoolname, COUNT(wswin) as total_wins
FROM schools
LEFT JOIN collegeplaying
USING(schoolid)
LEFT JOIN teams
USING(yearid)
WHERE schoolstate = 'TN'
AND wswin = 'Y'
GROUP BY schoolname
ORDER BY total_wins DESC;





