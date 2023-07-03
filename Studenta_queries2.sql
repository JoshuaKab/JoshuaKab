--- We'll be working with wit 3 different table in this project student table ,course table and score table.
--- let's go and explore the following tables

use school

SELECT *
FROM score

SELECT *
FROM course

SELECT *
FROM student

SELECT 
count(*) as student
FROM student
WHERE city = 'Cape town'

SELECT CONCAT(t.name, ' ' ,t.last_name) as name, t.birthdate,c.course, c.fees
FROM student as t
JOIN course as c
ON t.id = c.id
WHERE c.fees > 10000
ORDER BY 1,2


SELECT CONCAT(t.name, ' ' ,t.last_name) as name, t.birthdate,c.course, c.fees
FROM student as t
JOIN course as c
ON t.id = c.id
WHERE c.course = 'Data analyst' 
ORDER BY 1,2

--- let's check the city of the student that have more than 1 course

SELECT Count(c.course) AS num_course, t.city
FROM student as t
JOIN course as c
ON t.id = c.id
GROUP BY t.city
HAVING COUNT(c.course) > 1

--- Let's manupilate the cte statement and see the performance of the student with case statement


WITH cte AS (SELECT CONCAT(t.name, ' ' ,t.last_name) as name, c.course,
	CASE WHEN s.score > 90 then 'A+'
		WHEN s.score between 80 and 90 Then 'A'
		WHEN s.score between 60 and 80 then 'B'
		ELSE 'C' END AS performance
FROM student as t
JOIN course as c
ON t.id = c.id
LEFT JOIN score as s
ON s.course_id = c.course_id)

SELECT *
FROM cte
WHERE performance = 'A'

---- let's count how many male amd female in this data
--- Actually we have 4 females and 6 males

SELECT gender,
	COUNT(*) num_gender
FROM student
GROUP BY gender

--- let's see what gender has highest score by joining the tree tables
SELECT t.gender, s.continent,
 Max(s.score) as highest_score
FROM student as t
JOIN course as c
ON t.id = c.id
LEFT JOIN score as s
ON s.course_id = c.course_id
GROUP BY t.gender, s.continent
ORDER BY highest_score DESC

---Select the all important column from different table
SELECT t.id, t.birthdate,t.city, CONCAT(t.name, ' ' ,t.last_name) as name, t.birthdate,c.course, c.fees,s.score
FROM student as t
JOIN course as c
ON t.id = c.id
LEFT JOIN score as s
ON s.course_id = c.course_id
ORDER BY 1,2
--The table will be export for more analysis

--THANKS FOR YOUR TIME