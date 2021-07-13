/*
Q4 [S]
Using the fielding table,
group players into three groups based on their position:
	label players with position OF as "Outfield",
	those with position "SS", "1B", "2B", and "3B" as "Infield",
	and those with position "P" or "C" as "Battery".
Determine the number of putouts
			  made by each of these three groups
			  in 2016.
			  
group players with case when for outfield, infield, battery
sum po
year=2016
*/

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

--BATTERY: 41,424
--INFIELD: 58,934
--OUTFIELD: 29,560