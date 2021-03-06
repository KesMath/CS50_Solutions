-- In 6.sql, write a SQL query to determine the average rating of all movies released in 2012.
-- Your query should output a table with a single column and a single row (not including the header) containing the average rating.
SELECT AVG(rating) AS ""
FROM ratings
JOIN movies
on ratings.movie_id = movies.id
WHERE movies.year = 2012