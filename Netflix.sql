-- 1. Count the Number of Movies vs TV Shows

SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;

-- 2. Find the Most Common Rating for Movies and TV Shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

-- 3. List All Movies Released in a Specific Year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020;

-- 4. Find the Top 5 Countries with the Most Content on Netflix

SELECT TOP 5
LTRIM(RTRIM(value)) AS country,
COUNT(*) AS content_count
FROM netflix_titles
CROSS APPLY string_split(country, ',')
WHERE value is not null
GROUP BY LTRIM(RTRIM(value)) 
ORDER BY content_count DESC

-- 5. Identify the Longest Movie

SELECT TOP 1 *
FROM netflix_titles
WHERE type = 'Movie'
ORDER BY CAST(LEFT(duration, CHARINDEX(' ', duration) -1) AS INT) DESC

-- 6. Find Content Added in the Last 5 Years

SELECT *
FROM netflix_titles
WHERE date_added >= DATEADD(YEAR, -5, GETDATE())

-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT *
FROM netflix_titles
WHERE director = '%Rajiv Chilaka%'

-- 8. List All TV Shows with More Than 5 Seasons

SELECT *
FROM netflix_titles
WHERE type = 'TV Show' and CAST(left(duration, CHARINDEX(' ', duration) -1) AS INT) > 5

-- 9. Count the Number of Content Items in Each Genre

SELECT TRIM(value) AS Gener,
COUNT(*) AS ContentCount
FROM netflix_titles
CROSS APPLY string_split(listed_in, ',')
WHERE value is not null
GROUP BY value
ORDER BY ContentCount DESC

-- 10.Find each year and the average numbers of content release in India on netflix.
-- return top 5 year with highest avg content release!

SELECT TOP 5
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC

-- 11. List All Movies that are Documentaries

SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

-- 12. Find All Content Without a Director

SELECT * 
FROM netflix
WHERE director IS NULL;

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT *
FROM netflix_titles
WHERE cast Like '%Salman Khan%' and date_added >= DATEADD(YEAR, -7, GETDATE())

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT TOP 10 TRIM(value) AS actor,
COUNT(*) AS MovieCount
FROM netflix_titles
CROSS APPLY string_split(cast, ',')
WHERE country = 'India'
GROUP BY TRIM(value)
ORDER BY 2 DESC

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
