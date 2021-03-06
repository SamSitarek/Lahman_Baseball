---Question 6
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
