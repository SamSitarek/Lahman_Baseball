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