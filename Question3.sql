--Q3
SELECT schoolname, namefirst, namelast, SUM(salary) as total_salary
FROM schools
	LEFT JOIN (SELECT DISTINCT playerid, schoolid
			  FROM collegeplaying) AS cp
USING(schoolid)
LEFT JOIN people
USING(playerid)
LEFT JOIN salaries
USING(playerid)
WHERE schoolname = 'Vanderbilt University'
AND salary IS NOT NULL
GROUP BY schoolname, namefirst, namelast
ORDER BY total_salary DESC;