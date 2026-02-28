-- 1. Count the Number of Movies vs TV Shows

select type,
count(*)
from netflix_titles
group by type;

-- 2. Find the Most Common Rating for Movies and TV Shows

With rating_rank as (
select type,
rating, 
COUNT(*) as rating_count,
rank() over(partition by type order by count(*) DESC) as rank
from netflix_titles
group by type, rating
)
select type,
rating
from rating_rank
where rank = 1

-- 3. List All Movies Released in a Specific Year (e.g., 2020)

select *
from netflix_titles
where type = 'Movie' and release_year = '2020';

-- 4. Find the Top 5 Countries with the Most Content on Netflix


select top 5
LTRIM(rtrim(value)) as country,
count(*) as content_count
from netflix_titles
cross apply string_split(country, ',')
where value is not null
group by LTRIM(rtrim(value)) 
order by content_count desc


-- 5. Identify the Longest Movie

select top 1 *
from netflix_titles
where type = 'Movie'
order by cast(left(duration, charindex(' ', duration) -1) as int) desc


-- 6. Find Content Added in the Last 5 Years

select *
from netflix_titles
where date_added >= DATEADD(year, -5, GETDATE())


-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

select *
from netflix_titles
where director = '%Rajiv Chilaka%'

-- 8. List All TV Shows with More Than 5 Seasons

select *
from netflix_titles
where type = 'TV Show' and cast(left(duration, charindex(' ', duration) -1) as int) > 5


-- 9. Count the Number of Content Items in Each Genre

select trim(value) as Gener,
count(*) as ContentCount
from netflix_titles
cross apply string_split(listed_in, ',')
where value is not null
group by value
order by ContentCount desc


-- 10.Find each year and the average numbers of content release in India on netflix.
-- return top 5 year with highest avg content release!

select year(CAST(date_added as date)),
COUNT(*) as contentcount,
round(cast(count(*) as float) / cast((select count(*) from netflix_titles where country = 'India') as float) * 100, 2)
from netflix_titles
where country = 'India'
group by year(CAST(date_added as date))
order by 2 desc


-- 11. List All Movies that are Documentaries

select *
from netflix_titles
where type = 'Movie' and listed_in like '%Documentaries%'


-- 12. Find All Content Without a Director

select * 
from netflix_titles
where director is null


-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

select *
from netflix_titles
where cast Like '%Salman Khan%' and date_added >= DATEADD(year, -7, GETDATE())


-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

select top 10 TRIM(value) as actor,
count(*) as MovieCount
from netflix_titles
cross apply string_split(cast, ',')
where country = 'India'
group by TRIM(value)
order by 2 desc


-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

select category,
COUNT(*) as contentcount
from(
select 
	case
		when description like ('%kill%') or description like ('%violence%') then 'Bad'
		else 'Good' 
		end as category
from netflix_titles
) as t
group by category
