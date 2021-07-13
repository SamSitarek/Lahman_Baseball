--q1
--darcy
SELECT MIN(yearid), MAX(yearid)
FROM pitching;
--robert
SELECT MIN(yearid), MAX(yearid)
FROM teams;
----------------------------------
--q2
--robert
SELECT namegiven, namefirst, namelast, MIN(height) AS min_height, teams.name
FROM people
LEFT JOIN batting
ON people.playerid = batting.playerid
LEFT JOIN teams
ON teams.teamid = batting.teamid
GROUP BY namegiven, namefirst, namelast, teams.name
ORDER BY min_height
LIMIT 1;
---------------------------------
--q3
--mallory
SELECT DISTINCT collegeplaying.playerid,
	people.namefirst,
	people.namelast,
	SUM(salaries.salary)::numeric::money
FROM collegeplaying
LEFT JOIN people
ON collegeplaying.playerid = people.playerid
LEFT JOIN salaries
ON collegeplaying.playerid = salaries.playerid
WHERE collegeplaying.schoolid = 'vandy'
AND salaries.salary IS NOT NULL
GROUP BY collegeplaying.playerid, people.namefirst, people.namelast
ORDER BY SUM(salaries.salary)::numeric::money DESC;
--josh

--from josh: the risk this one that almost everyone makes is the money someone makes,
--you have to make sure you're getting a distinct player and the year of college playing

--preston
SELECT namefirst, namelast, SUM(COALESCE(salary,0))::int::money AS earnings
FROM people
LEFT JOIN salaries
USING (playerid)
WHERE playerid IN (SELECT playerid FROM collegeplaying WHERE schoolid = 'vandy')
GROUP BY playerid
ORDER BY earnings DESC
--jonathan
WITH played_at_vandy AS (SELECT DISTINCT playerid
					                
                    FROM people AS p
					 INNER JOIN collegeplaying AS cp
                     USING(playerid)
                     WHERE schoolid ILIKE 'vandy')
SELECT namefirst,namelast,
SUM(s.salary)AS total_salary
FROM people AS p
      INNER JOIN salaries AS s
      USING(playerid)
                  WHERE playerid IN (SELECT * FROM played_at_vandy)
				  GROUP BY namefirst,namelast
				  ORDER BY total_salary DESC;
--chris
WITH vandy_players AS (SELECT DISTINCT(playerid)
FROM collegeplaying
WHERE schoolid ILIKE 'vandy'),
vandy_majors AS (SELECT people.playerid, CONCAT(namefirst, ' ', namelast) AS full_name
FROM people INNER JOIN vandy_players ON people.playerid = vandy_players.playerid)
SELECT vandy_majors.playerid, full_name, SUM(salary)::text::money AS total_salary
FROM salaries INNER JOIN vandy_majors ON salaries.playerid = vandy_majors.playerid
GROUP BY full_name, vandy_majors.playerid
ORDER BY total_salary DESC
----------------------------------------------------------------------
--q4
--me
WITH position_table AS (SELECT playerid,
				  		 	   pos,
				  		 	   po,
				         	   yearid,
						 	   CASE WHEN pos = 'OF' THEN 'Outfield'
						 	  	    WHEN pos = 'SS' THEN 'Infield'
							  		WHEN pos = '1B' THEN 'Infield'
							  		WHEN pos = '2B' THEN 'Infield'
							  		WHEN pos = '3B' THEN 'Infield'
							  		WHEN pos = 'P' THEN 'Battery'
							  		WHEN pos = 'C' THEN 'Battery' END AS position
				 		FROM fielding)
SELECT position, SUM(po)
FROM position_table
WHERE yearid = '2016'
GROUP BY position

--scott
Select sum(po),
case when pos = 'OF' then 'Outfield'
when pos IN ('SS', '1B', '2B', '3B') then 'Infield'
when pos IN ('P', 'C') then 'Battery'
end as position
from fielding
group by position;

--darcy
WITH grouped_positions as (SELECT *, CASE WHEN pos = 'OF' THEN 'Outfield'
									   	  WHEN pos = 'SS'
						   					OR pos = '1B'
						   					OR pos = '2B'
						   					OR pos = '3B'
						   					THEN 'Infield'
			                           	  WHEN pos = 'P'
						   					OR pos = 'C'
						   					THEN 'Battery' END as pos_group
						   FROM fielding)
SELECT pos_group, SUM(po) as putouts
FROM grouped_positions
WHERE yearid = '2016'
GROUP BY pos_group;

--zenon
WITH grouped_fielding AS (SELECT DISTINCT pos, SUM(PO) AS total_po, fielding.yearid,
		CASE WHEN pos = 'OF' then 'Outfield'
			WHEN pos = 'SS' THEN 'Infield'
			WHEN pos = '1B' THEN 'Infield'
			WHEN pos = '2B' THEN 'Infield'
			WHEN pos = '3B' THEN 'Infield'
			WHEN pos = 'P' THEN 'Battery'
			WHEN pos = 'C' THEN 'Battery' END AS fielding_grouped
	FROM fielding
	WHERE yearid = (2016)
	GROUP BY fielding_grouped, fielding.pos, fielding.yearid
	ORDER BY yearid)
SELECT SUM(total_po), fielding_grouped
FROM grouped_fielding
GROUP BY fielding_grouped

---------------------------------------------------------
--q5
--patrick
WITH so_hr_by_decade AS (SELECT
						CONCAT(LEFT(yearid::text, 3), ‘0s’) AS decade,
						SUM(so)::numeric AS total_so_batting,
						SUM(soa)::numeric AS total_so_pitching,
						SUM(hr)::numeric AS total_hr_batting,
						SUM(hra)::numeric AS total_hra_pitching,
						(SUM(g)/2)::numeric AS total_games_played
					FROM teams
					 WHERE yearid>1919
					GROUP BY decade
					ORDER BY decade)
SELECT decade,
ROUND((total_so_batting/total_games_played),2) AS avg_so_game_bat,
ROUND((total_so_pitching/total_games_played),2) AS avg_so_game_pit,
ROUND((total_hr_batting/total_games_played),2) AS avg_hr_game_bat,
ROUND((total_hra_pitching/total_games_played),2) AS avg_hra_game_pit
FROM so_hr_by_decade

--scott
SELECT (yearid/10)*10 as decade, Round((SUM(so)::DECIMAL / SUM(ghome)::DECIMAL),2) AS so_per_game, Round((SUM(hr)::DECIMAL / SUM(ghome)::DECIMAL),2) AS hr_per_game
FROM teams
WHERE yearid >=1920
GROUP BY decade
ORDER BY decade;

--holly: We did decade this way since yearid is an integer:
--yearid/10*10 AS decade

---------------------------------------------
--q6
--darcy
SELECT namegiven, sb, cs,
	   ROUND(((sb::numeric/(sb::numeric + cs::numeric))*100),2) AS percent_successful_steal
FROM people FULL JOIN batting
	ON people.playerid = batting.playerid
WHERE (sb::numeric+cs::numeric) >= 20
AND yearid = 2016
ORDER BY percent_successful_steal DESC;

--julien
SELECT B.PLAYERID,
	PL.NAMEFIRST,
	PL.NAMELAST,
	B.SB::decimal,
	B.CS::decimal,
	ROUND((B.SB::decimal / (B.SB::decimal + B.CS::decimal)),2) AS SB_SUCCESS
FROM BATTING AS B
LEFT JOIN PEOPLE AS PL ON B.PLAYERID = PL.PLAYERID
WHERE B.YEARID = '2016'
	AND B.SB + B.CS >= 20
ORDER BY SB_SUCCESS DESC
---josh: another way you can cast to a decimal is to multiply it by 1.0 

--toni (did 2 different ways, first way like julien, second below)
WITH ps as (SELECT yearid,playerid,
			       SUM(sb) as post_sb,
			       SUM(cs) as post_cs
		           FROM battingpost
		     WHERE yearid = 2016
		     GROUP BY yearid,playerid
		     ORDER BY SUM(sb) DESC)
SELECT p.namefirst,
       p.namelast,
       b.yearid,
       sb::decimal,
	   cs::decimal,
	   post_sb,
	   post_cs,
	   CASE WHEN post_sb IS NULL THEN sb+cs
	        WHEN post_sb IS NOT NULL THEN sb+cs+post_sb+post_cs
			END AS total_attempt,
		CASE WHEN post_sb IS NULL THEN (sb::decimal/(sb+cs)::decimal)
		     WHEN post_sb IS NOT NULL THEN ROUND(((sb+post_sb)::decimal/(sb+cs+post_sb+post_cs)::decimal),4)
	         END AS success_rate
	  
	
	  
FROM batting as b
LEFT JOIN people as p
ON b.playerid = p.playerid
LEFT JOIN ps
ON b.playerid = ps.playerid
WHERE b.yearid = 2016
AND sb+cs+post_sb+post_cs >20
ORDER BY success_rate DESC

------------------------------------------------
--q7: most wins, no world series
--robert
SELECT w, name, yearid, wswin
FROM teams
WHERE wswin = 'N'
AND yearid BETWEEN 1970 AND 2016
GROUP BY w, name, yearid, wswin
ORDER BY w DESC
LIMIT 1;

--q7: least wins, world series wins
--robert
SELECT w, name, yearid, wswin
FROM teams
WHERE wswin = 'Y'
AND yearid BETWEEN 1970 AND 2016
GROUP BY w, name, yearid, wswin
ORDER BY w
LIMIT 1;

--q7 minus 1981 as problem year
--robert
SELECT w, name, yearid, wswin
FROM teams
WHERE wswin = 'Y'
AND yearid BETWEEN 1970 AND 2016
AND yearid <>'1981'
GROUP BY w, name, yearid, wswin
ORDER BY w
LIMIT 1;

--q7 percentage of time
--robert
WITH ws_win_percentage AS (SELECT yearid, name, wswin,
					(CASE WHEN w = MAX(w) OVER (PARTITION BY yearid) AND wswin = 'Y' THEN 1 ELSE 0 END) AS max_win
				FROM teams
				WHERE yearid BETWEEN 1970 AND 2016
				AND yearid <> '1981')
SELECT ROUND(SUM(max_win)::DECIMAL / COUNT(wswin) * 100,1) AS max_win_perc
FROM ws_win_percentage
WHERE wswin = 'Y';

--julien

--preston
WITH winworld AS (
	SELECT yearID, name, (CASE WHEN W = MAX(W) OVER(PARTITION BY yearID) AND WSwin = 'Y' THEN 1 ELSE 0 END) AS max_wins, WSwin
	FROM teams
	WHERE yearid >= 1970 AND yearid <> 1981
	)
SELECT ROUND(SUM(max_wins)::DECIMAL / COUNT(WSwin) * 100,1) as max_win_percent
FROM winworld
WHERE WSwin = 'Y'
--josh
WITH max_wins AS (
	SELECT yearid,
			MAX(w) AS max_w
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	GROUP BY yearid
	ORDER BY yearid
	)
SELECT SUM(CASE WHEN wswin = 'Y' THEN 1 ELSE 0 END) AS ct_max_is_champ,
		ROUND(100*AVG(CASE WHEN wswin = 'Y' THEN 1 ELSE 0 END), 2) AS perc_max_is_champ
FROM max_wins AS m
INNER JOIN teams AS t
	ON m.yearid = t.yearid AND m.max_w = t.w
-------------------------------------------------------
--q8
--jonathan
(SELECT park_name,
       t.name AS team_name,
       ROUND((AVG(h.attendance)/h.games),0) AS avg_attendance,
       'TOP 5' AS ranking
FROM homegames AS h
INNER JOIN parks AS p
USING (park)
	LEFT JOIN teams AS t
	ON t.park =p.park_name
WHERE year= '2016'
AND games >'10'
AND t.yearid = '2016'
GROUP BY park_name,t.name,games
ORDER BY avg_attendance DESC
LIMIT 5)
UNION
(SELECT park_name,
       t.name AS team_name,
       ROUND((AVG(h.attendance)/h.games),0) AS avg_attendance,
       'BOTTOM 5' AS ranking
FROM homegames AS h
INNER JOIN parks AS p
USING (park)
	LEFT JOIN teams AS t
	ON t.park =p.park_name
WHERE year= '2016'
AND games >'10'
AND t.yearid = '2016'
GROUP BY park_name,t.name,games
ORDER BY avg_attendance ASC
LIMIT 5)
ORDER BY Avg_attendance DESC;

--josh
SELECT team,
			name,
			park_name,
			ROUND(hg.attendance::numeric/ hg.games) AS avg_att
	FROM homegames AS hg
	LEFT JOIN parks
	USING (park)
	LEFT JOIN teams AS t
	ON hg.team = t.teamid AND hg.year = t.yearid
	WHERE year = 2016 AND games >= 10
	ORDER BY hg.attendance/hg.games DESC
	LIMIT 5;

------------------------------------------
--q9
--me
WITH managers_awards		AS (SELECT DISTINCT am1.yearid AS yearid1,
									am1.playerid AS playerid,
									am1.lgid AS lgid1,
									am2.lgid AS lgid2,
									am1.awardid AS awardid1
						 		FROM awardsmanagers as am1
						 	 	 INNER JOIN awardsmanagers AS am2
						 	 	 USING (playerid)
								 WHERE am1.awardid = 'TSN Manager of the Year'
								 	AND am2.awardid = am1.awardid
									AND am1.lgid <> 'ML'
									AND am2.lgid <> 'ML'
							   		AND am1.lgid <> am2.lgid),
managers_names			AS (SELECT ma.yearid1 AS yearid,
							       ma.playerid AS playerid,
								   ma.lgid1 AS lgid1,
								   ma.lgid2 AS lgid2,
								   ma.awardid1 AS awardid,
								   p.namefirst AS namefirst,
								   p.namelast AS namelast
							   FROM managers_awards as ma
							   LEFT JOIN people as p
							   ON ma.playerid=p.playerid),
managers_table			AS (SELECT DISTINCT mn.yearid AS yearid,
							       mn.playerid AS playerid,
								   mn.namefirst AS namefirst,
								   mn.namelast AS namelast,
								   m.teamid AS teamid
						   FROM managers_names AS mn
						   LEFT JOIN managers AS m
						   ON mn.playerid=m.playerid
						   AND mn.yearid=m.yearid
						   GROUP BY mn.yearid, mn.playerid,namefirst,namelast,teamid),					     	
managers_and_teams		AS(SELECT DISTINCT t.yearid AS yearid,
							       mn.playerid AS playerid,
								   mn.namefirst AS namefirst,
								   mn.namelast AS namelast,
						   		   t.name AS name
						  FROM managers_table AS mn
						  LEFT JOIN teams AS t
						  ON mn.yearid=t.yearid
						  AND mn.teamid=t.teamid)
							
SELECT *
FROM managers_and_teams

--preston
SELECT CONCAT(namefirst,' ', namelast) AS fullname, teams.name, awardid, awardsmanagers.lgid, awardsmanagers.yearid
FROM awardsmanagers
LEFT JOIN people
	ON awardsmanagers.playerid = people.playerid
LEFT JOIN managers
	ON managers.playerid = awardsmanagers.playerid
	AND managers.yearid = awardsmanagers.yearid
LEFT JOIN teams
	ON managers.teamid = teams.teamid
	AND managers.yearid = teams.yearid
WHERE awardsmanagers.playerid IN (
			SELECT playerid
			FROM awardsmanagers
			WHERE awardid ILIKE 'TSN%'
			AND lgid = 'AL'
			INTERSECT
			SELECT playerid
			FROM awardsmanagers
			WHERE awardid ILIKE 'TSN%'
			AND lgid = 'NL'
			)
AND awardid ILIKE 'TSN%'

--scott
Select people.namefirst, people.namelast, teams.name, awardsmanagers.lgid, awardsmanagers.yearid
from awardsmanagers
left join people
on awardsmanagers.playerid = people.playerid
left join managers
on managers.playerid = awardsmanagers.playerid
and managers.yearid = awardsmanagers.yearid
left join teams
on managers.yearid = teams.yearid
and managers.teamid = teams.teamid
WHERE awardsmanagers.playerid in (
			SELECT playerid
			FROM awardsmanagers
			WHERE awardid ILIKE 'TSN%'
			AND lgid = 'AL'
			INTERSECT
			SELECT playerid
			FROM awardsmanagers
			WHERE awardid ILIKE 'TSN%'
			AND lgid = 'NL')
and awardsmanagers.awardid ILIKE 'TSN%';

--holly
WITH qualifying_managers AS (SELECT playerid,
									yearid,
									awardid,
									lgid
							FROM awardsmanagers
							WHERE awardid = 'TSN Manager of the Year'
							AND lgid IN ('NL','AL')
							AND playerid IN (	SELECT 	playerid
											FROM awardsmanagers
											WHERE awardid = 'TSN Manager of the Year'
											AND lgid IN ('NL','AL')
											GROUP BY playerid
											HAVING COUNT(DISTINCT(lgid))=2)
							 ),
							
qm_with_names AS (	SELECT 	namefirst,
				  			namelast,
				  			qm.*
				  	FROM qualifying_managers AS qm
				  	LEFT JOIN people AS p
				  	USING(playerid)
				 ),
					
qm_with_teamid AS (	SELECT 	DISTINCT q.*,
							m.teamid
					FROM qm_with_names AS q
					LEFT JOIN managers AS m
					USING(playerid)
					LEFT JOIN teams AS t
					USING(teamid)
					WHERE m.yearid=q.yearid
					AND m.lgid IN (SELECT lgid
								   FROM qm_with_names))
								  
SELECT 	qmt.namefirst || ' ' || qmt.namelast AS full_name,
		t.name,
		qmt.yearid,
		awardid,
		qmt.lgid
FROM qm_with_teamid AS qmt
LEFT JOIN teams AS t
USING(teamid)
WHERE qmt.yearid = t.yearid
ORDER BY namefirst, yearid;

--eric
WITH aw AS (SELECT DISTINCT
				p.namefirst AS first,
				p.namelast AS last,
				aw1.playerid AS pid,
				aw1.yearid AS alyear,
				aw2.yearid AS nlyear,
				aw1.lgid AS nl,
				aw2.lgid AS al
	FROM awardsmanagers AS aw1
	INNER JOIN awardsmanagers AS aw2
	USING (playerid)
	INNER JOIN people AS p
	USING (playerid)
	WHERE aw1.awardid = 'TSN Manager of the Year'
	AND aw2.awardid = 'TSN Manager of the Year'
	AND aw1.lgid <>'ML'
	AND aw2.lgid <>'ML'
	AND aw1.lgid = 'NL'
	AND aw2.lgid = 'AL'),
mt1 AS (SELECT DISTINCT
	   			t.teamid AS tid1,
				m.yearid AS myearid1,
				t.name AS tname1,
	   			m.playerid AS pid1
	FROM teams AS t
	INNER JOIN managers as m
	using (teamid)
	INNER JOIN awardsmanagers as ap
	ON m.playerid=ap.playerid AND m.yearid=t.yearid),
mt2 AS (SELECT DISTINCT
	   			t.teamid AS tid2,
				m.yearid AS myearid2,
				t.name AS tname2,
	   			m.playerid AS pid2
	FROM teams AS t
	INNER JOIN managers as m
	using (teamid)
	INNER JOIN awardsmanagers as ap
	ON m.playerid=ap.playerid AND m.yearid=t.yearid)
SELECT
	aw.first,
	aw.last,
	aw.nlyear,
	mt1.tname1 AS nlteam,
	aw.alyear,
	mt2.tname2 AS alteam
		
 	FROM aw JOIN mt2
	ON aw.pid = mt2.pid2 AND mt2.myearid2=aw.alyear
	JOIN mt1
	ON aw.pid=mt1.pid1 AND mt1.myearid1=aw.nlyear;

----------------------------------------------
--q10
--sudeep
-- Analyze all the colleges in the state of Tennessee.
-- Which college has had the most success in the major leagues. Use whatever metric for success you like
-- - number of players, number of games, salaries, world series wins, etc.
with removeyear as (
select distinct playerid, schoolid
	from collegeplaying
)
select  schoolname, count(distinct playerid) as player_count,
 sum(g_all) as total_games, avg(salary)::numeric::money as avg_salary,
 count(case when wswin='Y' then 'asdfdafdsa' end)
 as players_ws_wins
--select distinct appearances.teamid,teams.yearid, wswin
from appearances
left join removeyear
	using(playerid)
	
left join salaries
using (playerid, yearid)
	
left join schools
	using (schoolid)
left join teams
on(appearances.teamid = teams.teamid and appearances.yearid = teams.yearid)
where schoolstate = 'TN'
 group by schoolname
 order by players_ws_wins desc
 
--preston
WITH countawards AS (
	SELECT playerid,  COUNT(awardid) AS numawards
	FROM awardsplayers
	--WHERE awardid IN ('Most Valuable Player', 'Rookie of the Year' ,'Gold Glove', 'TSN Major League Player of the Year', 'ALCS MVP', 'NLCS MVP' )
	GROUP BY playerid
	ORDER BY numawards DESC
	)
	,
WSplayers AS (
			SELECT playerid, yearid, teamid
			FROM battingpost
			WHERE round = 'WS'
			UNION
			SELECT playerid, yearid, teamid
			FROM fieldingpost
			WHERE round = 'WS'
			UNION
			SELECT playerid, yearid, teamid
			FROM pitchingpost
			WHERE round = 'WS'
			)
			,
wsplayer AS (
	SELECT playerid, COUNT(*) AS wsapp
	FROM (
		SELECT *
		FROM WSplayers
		UNION
		SELECT playerid, yearid, teamid
	FROM (
		SELECT yearid, teamid
		FROM managers
		INTERSECT
		SELECT yearid, teamid
		FROM WSplayers
			) as sub
	LEFT JOIN managers
	USING (yearid, teamid)
		) AS sub
		GROUP BY playerid
	),	
avgsalary AS (
	SELECT salaries.playerid, (SUM(salary) / COUNT(DISTINCT salaries.yearid)) AS avg_salary
	FROM salaries
		GROUP BY salaries.playerid
	ORDER BY avg_salary DESC
)
,
tnplayers AS (
	SELECT collegeplaying.playerid, collegeplaying.schoolid
	FROM collegeplaying
	INNER JOIN ( SELECT playerid, max(yearid) AS yearmax
			   FROM collegeplaying
				GROUP BY playerid
			   ) AS maxyear
		ON collegeplaying.playerid = maxyear.playerid
		AND collegeplaying.yearid = maxyear.yearmax
	WHERE collegeplaying.schoolid IN (SELECT schoolid FROM schools WHERE schoolstate = 'TN')
	)
	
SELECT schoolname, count(playerid),
	(sum(avg_salary)::DECIMAL / COUNT(playerid))::MONEY,
	sum(numawards) AS sumawards, sum(wsapp) AS WSapp
FROM tnplayers
INNER JOIN avgsalary
USING (playerid)
LEFT JOIN countawards
USING (playerid)
LEFT JOIN wsplayer
USING (playerid)
LEFT JOIN schools
USING (schoolid)
GROUP BY schoolname
ORDER BY sum(avg_salary) DESC;


--------------------------------------------------
--q11
--darcy
WITH team_wins_salaries as (SELECT s.teamid, s.yearid as year, SUM(s.salary) as team_salary, (t.w) as wins
							FROM salaries AS s LEFT JOIN teams AS t
								ON s.teamid=t.teamid
								AND s.yearid=t.yearid
							WHERE s.yearid >= 2000
							GROUP BY s.teamid, s.yearid, t.w
							ORDER BY s.teamid, s.yearid)
SELECT DISTINCT year, CORR(wins, team_salary) OVER(PARTITION BY year) as correlation
FROM team_wins_salaries
ORDER BY year;
--yes but i couldn't defend that to you very much if you asked me to


--chris quick walkthrough on correlation
/* we talk about significance and tell you not to do that unless you mean in a specific way (the statistical def)
correlation coefficient: a way to measure 2 values against eachother.
let's say i want to roll a 20 sided die and i want to count how many items someone has at the grocery store. what i can expect is that the correlation between the two is 0. but what i can expect is because of chance, there will be some that match. the more i do this the closer it will get to 0. a positive correlation coefficient means as one goes up the other goes up, a negative correlation means as one goes up the other goes down. the closer you get to 1 or -1 the stronger the correlation is, the closer  you get to 0 means the weaker the correlation is. correlation is not causation. the # of minutes spent on a smart phone and the housing prices going up doesn't mean it's causation.
*/
--darcy: how much of an understanding of statistics should we have?
--chris: the further you get into it the more into data science you're getting into. statistical significance and standard deviation would be good ones to know.
--josh: law of large numbers
--preston    https://www.tylervigen.com/spurious-correlations

--preston: I did the same but with a pivot table:
WITH teamwinper AS (
	SELECT DISTINCT s.yearid, s.teamid,
		(ROUND((w::DECIMAL/g::DECIMAL)*100,0)::INT)/5*5 AS winper,
		sum(salary) OVER(PARTITION BY (s.yearid, s.teamid)) AS teamsal
	FROM salaries AS s
	LEFT JOIN teams
	ON s.yearid = teams.yearid
		AND s.teamid = teams.teamid
	WHERE s.yearid >= 2000
	ORDER BY teamsal
	)
SELECT yearid, winper, avg(teamsal)::DECIMAL::MONEY, COUNT(teamid)
FROM teamwinper
GROUP BY yearid, ROLLUP (winper)
ORDER BY yearid, winper

---------------------------------------------------
--q12
--me
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



--josh   Here's another version summarizing rankings and then comparing them:
WITH w_att_rk AS (
SELECT yearid,
		teamid,
		w,
		attendance / ghome AS avg_h_att,
		RANK() OVER(PARTITION BY yearid ORDER BY w) AS w_rk,
		RANK() OVER(PARTITION BY yearid ORDER BY attendance / ghome) AS avg_h_att_rk
FROM teams
WHERE attendance / ghome IS NOT NULL
AND yearid >= 1961 						--MLB institutes 162 game season
ORDER BY yearid, teamid
)
SELECT avg_h_att_rk,
		ROUND(AVG(w_rk), 1) AS avg_w_rk,
		CORR(avg_h_att_rk, AVG(w_rk)) OVER() as correlation
FROM w_att_rk
GROUP BY avg_h_att_rk
ORDER BY avg_h_att_rk

--josh
--After World Series Win
WITH att_comp AS (
SELECT yearid,
		name,
		attendance / ghome AS att_g,
		lead(attendance / ghome) OVER(PARTITION BY name ORDER BY yearid) AS att_g_next_year,
		lead(attendance / ghome) OVER(PARTITION BY name ORDER BY yearid) - (attendance/ghome) AS difference
FROM teams AS t
)
SELECT ROUND(AVG(difference), 1) AS avg_att_dif
FROM att_comp
INNER JOIN teams AS t
USING (yearid, name)
WHERE wswin = 'Y'
--Attendance improves, on average, by 267.1 people per home game.

--After Playoff Berth
WITH att_comp AS (
SELECT yearid,
		name,
		attendance / ghome AS att_g,
		lead(attendance / ghome) OVER(PARTITION BY name ORDER BY yearid) AS att_g_next_year,
		lead(attendance / ghome) OVER(PARTITION BY name ORDER BY yearid) - (attendance/ghome) AS difference
FROM teams AS t
)
SELECT ROUND(AVG(difference), 1) AS avg_att_dif
FROM att_comp
INNER JOIN teams AS t
USING (yearid, name)
WHERE wcwin = 'Y' OR divwin = 'Y'
--Attendance improves, on average, by 561.9 people per home game.

-----------------------------------------
--q13
--patrick
--Number of LH, RH, S Pitchers all-time and the percentage of total pitcheers (9083)
WITH Distinct_pitchers AS (SELECT
						  	DISTINCT(playerid) AS pitchers,
						  	people.throws AS throws,
						   AVG(pitching.baopp) AS baopp,
						   AVG(pitching.era) AS era
						  FROM pitching LEFT JOIN people
							USING(playerid)
						  WHERE throws IS NOT NULL
						   GROUP BY throws, pitchers
						  )
SELECT
	DISTINCT(throws),
	COUNT(pitchers) AS COUNT_pitchers,
	ROUND((COUNT(pitchers)::decimal/(SELECT COUNT(DISTINCT(playerid))
								  FROM pitching LEFT JOIN people
									USING(playerid)
								  WHERE throws IS NOT NULL)::decimal)*100, 2) AS percent_all,
  	ROUND(AVG(baopp)::decimal,3) AS avg_baopp,
	ROUND(AVG(era)::decimal, 2) AS avg_era
	FROM distinct_pitchers
	GROUP BY throws;
/*
“L”	2477	27.27%
“R”	6605	72.72%
“S”	1	0.01
Performance stats
avg_baopp	avg_era
0.308		5.12
0.323		5.04
0.257		5.22
*/
--1 SWITCH PITCHER???
SELECT
DISTINCT(playerid), namefirst, namelast, throws, AVG(pitching.ERA) AS Career_avg_ERA
FROM pitching LEFT JOIN people
USING(playerid)
WHERE people.throws = ‘S’
GROUP BY playerid, namefirst, namelast, throws;
--Pat Venditte only player to throw switch on record,
/*Are left-handed pitchers more likely to win the Cy Young Award?
*/
--SELECT DISTINCT(awardid) FROM awardsplayers
--ORDER BY awardid
WITH Distinct_pitchers AS (SELECT
						  	DISTINCT(playerid) AS pitchers,
						  	people.throws AS throws
						  FROM pitching
						   	INNER JOIN people
						   	USING(playerid)
						   	INNER JOIN awardsplayers
							USING(playerid)
						  WHERE throws IS NOT NULL
						  AND awardsplayers.awardid = ‘Cy Young Award’)
SELECT
	DISTINCT(throws),
	COUNT(pitchers) AS COUNT_cy_young,
	ROUND((COUNT(pitchers)::decimal/(SELECT COUNT(DISTINCT(playerid))
								  FROM pitching INNER JOIN people
									USING(playerid)
								 INNER JOIN awardsplayers
									USING(playerid)
								  WHERE throws IS NOT NULL
								  AND awardsplayers.awardid = ‘Cy Young Award’)::decimal)*100, 2) AS percent_all
	FROM distinct_pitchers
	GROUP BY throws;
/*
“L”	24	31.17%
“R”	53	68.83% */
--SELECT* FROM teams
/*Are they more likely to make it into the hall of fame?*/
--SELECT * FROM halloffame
WITH Distinct_pitchers AS (SELECT
						  	DISTINCT(playerid) AS pitchers,
						  	people.throws AS throws
						  FROM pitching
						   	INNER JOIN people
						   	USING(playerid)
						   	INNER JOIN halloffame
							USING(playerid)
						  WHERE throws IS NOT NULL
						  AND halloffame.inducted = ‘Y’)
SELECT
		DISTINCT(throws),
		COUNT(pitchers) AS COUNT_HOF_pitchers,
		ROUND((COUNT(pitchers)::decimal/(SELECT COUNT(DISTINCT(playerid))
									  FROM pitching INNER JOIN people
										USING(playerid)
									 INNER JOIN halloffame
										USING(playerid)
									  WHERE throws IS NOT NULL
									  AND halloffame.inducted = ‘Y’)::decimal)*100, 2) AS percent_all
		FROM distinct_pitchers
		GROUP BY throws;
/*
“L”	23	22.77
“R”	78	77.23*/

--josh
--A fairly quick way to figure out proportion of lefthanded vs righthanded pitchers. (Switch pitcher not broken out.)
SELECT SUM(CASE WHEN throws = 'L' THEN 1 ELSE 0 END) AS ct_L,
		ROUND(AVG(CASE WHEN throws = 'L' THEN 1 ELSE 0 END), 4) AS perc_L,
		SUM(CASE WHEN throws = 'R' THEN 1 ELSE 0 END) AS ct_R,
		ROUND(AVG(CASE WHEN throws = 'R' THEN 1 ELSE 0 END), 4) AS perc_R
FROM people
WHERE playerid IN
	(SELECT DISTINCT playerid
	FROM pitching
	)

--preston
WITH lrpitch AS (
	SELECT pitching.playerid, pitching.yearid, IPOuts, ERA, throws, awardid, inducted
	FROM pitching
	LEFT JOIN people
	USING (playerid)
	LEFT JOIN (SELECT * FROM awardsplayers WHERE awardid ILIKE 'CY%') AS awards
	ON pitching.playerid = awards.playerid
	AND pitching.yearid = awards.yearid
	LEFT JOIN (SELECT playerid, inducted FROM halloffame WHERE inducted = 'Y') AS fame
	ON pitching.playerid = fame.playerid
	WHERE pitching.yearid >1970
	ORDER BY awardid, playerid
	)
SELECT throws, SUM(IPouts) AS Outsplayed, AVG(ERA) AS ERAavg,
	COUNT(DISTINCT playerid) AS numplayers,
	COUNT(awardid) AS CYwinners,
	COUNT(inducted) AS HoF
FROM lrpitch
GROUP BY ROLLUP (throws)


