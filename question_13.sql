/* QUESTION 13 - PITCHING

It is thought that since left-handed pitchers are more rare, 
causing batters to face them less often, that they are more effective. 
Investigate this claim and present evidence to either support or dispute this claim. 
First, determine just how rare left-handed pitchers are compared with right-handed pitchers. 
Are left-handed pitchers more likely to win the Cy Young Award?
Are they more likely to make it into the hall of fame?
*/

--First, determine just how rare left-handed pitchers are compared with right-handed pitchers.
SELECT *FROM people;

SELECT
COUNT(DISTINCT(playerid)) AS total_pitchers
FROM pitching LEFT JOIN people
USING(playerid)
WHERE people.throws IS NOT NULL;

SELECT
COUNT(DISTINCT(playerid)) AS total_RHP
FROM pitching LEFT JOIN people
USING(playerid)
WHERE people.throws = 'R';

SELECT
COUNT(DISTINCT(playerid)) AS total_LHP
FROM pitching LEFT JOIN people
USING(playerid)
WHERE people.throws = 'L';

SELECT
COUNT(DISTINCT(playerid)) AS total_SHP
FROM pitching LEFT JOIN people
USING(playerid)
WHERE people.throws = 'S';


--Number of LH, RH, S Pitchers all-time and the percentage of total pitcheers (9083)
WITH Distinct_pitchers AS (SELECT 
						  	DISTINCT(playerid) AS pitchers,
						  	people.throws AS throws,
						   	pitching.baopp AS baopp,
						   	pitching.era AS era
						  FROM pitching LEFT JOIN people
							USING(playerid)
						  WHERE throws IS NOT NULL)
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
"L"	2477	27.27%
"R"	6605	72.72%
"S"	1	0.01

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
WHERE people.throws = 'S'
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
						  AND awardsplayers.awardid = 'Cy Young Award')
SELECT
	DISTINCT(throws),
	COUNT(pitchers) AS COUNT_cy_young,
	ROUND((COUNT(pitchers)::decimal/(SELECT COUNT(DISTINCT(playerid))
								  FROM pitching INNER JOIN people
									USING(playerid)
								 INNER JOIN awardsplayers
									USING(playerid)
								  WHERE throws IS NOT NULL
								  AND awardsplayers.awardid = 'Cy Young Award')::decimal)*100, 2) AS percent_all
	FROM distinct_pitchers
	GROUP BY throws;

/*
"L"	24	31.17%
"R"	53	68.83% */

--SELECT* FROM teams
/*Are they more likely to make it into the hall of fame?*/

SELECT * FROM halloffame

WITH Distinct_pitchers AS (SELECT 
						  	DISTINCT(playerid) AS pitchers,
						  	people.throws AS throws
						  FROM pitching 
						   	INNER JOIN people
						   	USING(playerid)
						   	INNER JOIN halloffame
							USING(playerid)
						  WHERE throws IS NOT NULL
						  AND halloffame.inducted = 'Y')
SELECT
		DISTINCT(throws),
		COUNT(pitchers) AS COUNT_HOF_pitchers,
		ROUND((COUNT(pitchers)::decimal/(SELECT COUNT(DISTINCT(playerid))
									  FROM pitching INNER JOIN people
										USING(playerid)
									 INNER JOIN halloffame
										USING(playerid)
									  WHERE throws IS NOT NULL
									  AND halloffame.inducted = 'Y')::decimal)*100, 2) AS percent_all
		FROM distinct_pitchers
		GROUP BY throws;

/*
"L"	23	22.77
"R"	78	77.23*/


/*Conclusions: 

It's a right handed world out there! 
Out of 9082 recorded pitchers all time, 72% are right handed
Out of 77 Cy Young Award winners, 68.82% are right handed
Out of 101 pitchers in the HOF, 77.23% are right handed
With only .15 difference in opponent batting avg (avg) and 
.08 difference in era (avg) Between LHP and RHP, 
there does not seem to be a significant difference in batter success
when facing either LHP or RHP despite there being far more RHP than LHP
*/