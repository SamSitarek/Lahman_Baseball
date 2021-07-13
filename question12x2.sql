/*Q12
In this question, you will explore the connection between number of wins and attendance.

A. Does there appear to be any correlation between attendance at home games and number of wins?
B. 1. Do teams that win the world series see a boost in attendance the following year?
   2. What about teams that made the playoffs?
Making the playoffs means either being a division winner or a wild card winner
*/

/*
A. Does there appear to be any correlation between attendance at home games and number of wins?
*/

---attendance up and wins up
SELECT DISTINCT t1.yearid AS year_1,
	   t2.yearid AS year_2,
	   t1.name AS team_names,
	   t1.w AS wins_year_1,
	   t2.w AS wins_year_2,
	   t1.attendance AS attendance_year_1,
	   t2.attendance AS attendance_year_2,
	   t1.l AS losses_year_1,
	   t2.l AS losses_year_2
FROM teams AS t1 INNER JOIN teams AS t2
USING(teamid)
WHERE t1.attendance IS NOT NULL
AND t1.ghome IS NOT NULL
AND t2. attendance IS NOT NULL
AND t2.ghome IS NOT NULL
AND t1.yearid<t2.yearid
AND t2.yearid=(t1.yearid+1)
AND t1.attendance<t2.attendance
AND t1.w<t2.w
--822 rows

---attendance up and wins down
SELECT DISTINCT t1.yearid AS year_1,
	   t2.yearid AS year_2,
	   t1.name AS team_names,
	   t1.w AS wins_year_1,
	   t2.w AS wins_year_2,
	   t1.attendance AS attendance_year_1,
	   t2.attendance AS attendance_year_2,
	   t1.l AS losses_year_1,
	   t2.l AS losses_year_2
FROM teams AS t1 INNER JOIN teams AS t2
USING(teamid)
WHERE t1.attendance IS NOT NULL
AND t1.ghome IS NOT NULL
AND t2. attendance IS NOT NULL
AND t2.ghome IS NOT NULL
AND t1.yearid<t2.yearid
AND t2.yearid=(t1.yearid+1)
AND t1.attendance<t2.attendance
AND t1.w>t2.w
--350 rows


--Answer: yes, attendance tends to go up as wins go up 

/*
B. 1. Do teams that win the world series see a boost in attendance the following year?
*/




--teams that won world series and attendance higher following year:
SELECT t1.name,t1.yearid,t1.attendance,t2.yearid,t2.attendance
FROM teams AS t1 INNER JOIN teams AS t2
USING(teamid)
WHERE t1.wswin='Y'
AND t1.yearid<t2.yearid
AND t2.yearid=(t1.yearid+1)
AND t1.attendance<t2.attendance
--57 rows


--teams that won world series and attendance lower following year:
SELECT t1.name,t1.yearid,t1.attendance,t2.yearid,t2.attendance
FROM teams AS t1 INNER JOIN teams AS t2
USING(teamid)
WHERE t1.wswin='Y'
AND t1.yearid<t2.yearid
AND t2.yearid=(t1.yearid+1)
AND t1.attendance>t2.attendance
--54 rows

--Answer: not a strong enough difference for there to be a connection

/*
B. 2. What about teams that made the playoffs?
Making the playoffs means either being a division winner or a wild card winner*/

--combined wcwin OR divwin and att higher
SELECT t1.name,t1.yearid,t1.attendance,t2.yearid,t2.attendance
FROM teams AS t1 INNER JOIN teams AS t2
USING(teamid)
WHERE (t1.wcwin='Y'
AND t1.yearid<t2.yearid
AND t2.yearid=(t1.yearid+1)
AND t1.attendance<t2.attendance)
OR (t1.divwin='Y'
AND t1.yearid<t2.yearid
AND t2.yearid=(t1.yearid+1)
AND t1.attendance<t2.attendance)
--162 rows


--combined wcwin OR divwin and att lower
SELECT t1.name,t1.yearid,t1.attendance,t2.yearid,t2.attendance
FROM teams AS t1 INNER JOIN teams AS t2
USING(teamid)
WHERE (t1.wcwin='Y'
AND t1.yearid<t2.yearid
AND t2.yearid=(t1.yearid+1)
AND t1.attendance>t2.attendance)
OR (t1.divwin='Y'
AND t1.yearid<t2.yearid
AND t2.yearid=(t1.yearid+1)
AND t1.attendance>t2.attendance)
--117 rows


--Answer: when a team sees a post season their attendance appears to go up the following year