select * from teams
--7.From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
select name, yearid, w, wswin
from teams
where yearid BETWEEN 1970 AND 2016
AND wswin = 'N'
ORDER BY w DESC
---ANSWER: The largest number of wins for a team that didnt win the world series were the Mariners in 2001 (116 wins)


--What is the smallest number of wins for a team that did win the world series? 
select name yearid, w, wswin
from teams
where yearid BETWEEN 1970 AND 2016
AND wswin = 'Y'
ORDER BY w ASC
---ANSWER: The smallest number of wins for a team winnig the world series were the Dodgers in 1981 (63 wins)
---ANSWER: This unusually low number of wins was due to the players strike in 1981 that split the season in half

--Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. 

select name, yearid, w, wswin
from teams
where yearid BETWEEN 1970 AND 2016
AND wswin = 'Y'
AND yearid <> 1981
ORDER BY w ASC
---ANSWER: Excluding the year 1981, the world series winning team with the lowest amount of wins were the Cardinals in 2006 (83 wins)

--How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
--subquery
SELECT yearid, max(w), wswin
FROM
	(SELECT NAME,
			YEARID, W,
			L,
			WSWIN
		FROM TEAMS
		WHERE YEARID BETWEEN 1970 AND 2016
			AND YEARID <> 1981
			AND WSWIN IS NOT NULL) AS Z
group by yearid, z.wswin
order by yearid, max(w) DESC
------subquery without wswin
SELECT YEARID, MAX(W) AS MAX_W
FROM TEAMS
WHERE YEARID BETWEEN 1970 AND 2016
AND YEARID <> 1981
AND WSWIN IS NOT NULL
GROUP BY YEARID
ORDER BY YEARID
------CTE with join
WITH max_wins_ws AS (SELECT YEARID,
			MAX(W) AS MAX_W
		FROM TEAMS
		WHERE YEARID BETWEEN 1970 AND 2016
			AND YEARID <> 1981
			AND WSWIN IS NOT NULL
		GROUP BY YEARID
		ORDER BY YEARID)
SELECT SUM(CASE WHEN wswin = 'Y' THEN 1 ELSE 0 END) as count_max_wins_ws
FROM max_wins_ws AS m
INNER JOIN teams AS t
ON t.yearid = m.yearid AND m.max_w = t.w
---ANSWER: There have been 12 teams that have won the world series while having the most amount of wins, which is 26% of the world series winning teams in the dataset	

