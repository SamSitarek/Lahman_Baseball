--1
select MIN(span_first), MAX(span_last),
MAX(span_last) - MIN(span_first) as span_of_days
from homegames

SELECT MIN(DEBUT), MAX (finalgame)
from people

--1
SELECT
MAX (year),
MIN(year),
MAX (year)-MIN(year) AS span_of_years
FROM homegames;

--7
select *
from teams


select name, yearid, w, wswin
from teams
where yearid BETWEEN 1970 AND 2016
AND wswin = 'N'
ORDER BY w DESC
---largest number of wins for a team that didnt win the world series was the Mariners in 2001 (116 wins)

select name yearid, w, wswin
from teams
where yearid BETWEEN 1970 AND 2016
AND wswin = 'Y'
ORDER BY w ASC
---smallest number of wins for a team winnig the world series was the Dodgers in 1981 (63 wins)
---this unusually low number of wins was due to the players strike in 1981 that split the season in half

---redo excluding 1981
select name, yearid, w, l, wswin
from teams
where yearid BETWEEN 1970 AND 2016
AND yearid <> 1981
and wswin IS NOT NULL
ORDER BY yearid, name

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
group by yearid, wswin
order by yearid, max(w) DESC

