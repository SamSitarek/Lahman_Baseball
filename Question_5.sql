/*Question 5

5. Find the average number of strikeouts per game by decade since 1920. 
Round the numbers you report to 2 decimal places. 
Do the same for home runs per game. Do you see any trends?

*/

SELECT *
FROM teams;
--Strikeouts by decade
WITH so_hr_by_decade AS (SELECT 
						CONCAT(LEFT(yearid::text, 3), '0s') AS decade,
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

