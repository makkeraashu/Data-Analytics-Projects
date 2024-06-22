SQL PROJECT- MUSIC STORE DATA ANALYSIS

--Q1. Who is the senior most employee based on job title?

Select first_name, last_name, levels from employee
Order by levels Desc
limit 1

--Q2. Which countries have the most Invoices?

Select billing_country, Count(*) AS total from invoice
group by billing_country
order by total desc

--Q3. What are top 3 values of total invoice?

Select total from invoice
order by total desc
limit 3

--Q4. Which city has the best customers? We would like to throw a promotional Music
--Festival in the city we made the most money. Write a query that returns one city that
--has the highest sum of invoice totals. Return both the city name & sum of all invoice
--totals

Select billing_city, sum(total) AS totals from invoice
group by billing_city
order by totals desc
limit 1

--Q5. Who is the best customer? The customer who has spent the most money will be
--declared the best customer. Write a query that returns the person who has spent the
--most money
	
select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as invoice_total 
from customer
JOIN invoice ON customer.customer_id= invoice.customer_id
Group by customer.customer_id
Order by invoice_total desc
limit 1

--Q6. Write query to return the email, first name, last name, & Genre of all Rock Music
--listeners. Return your list ordered alphabetically by email starting with A

Select distinct email, first_name, last_name from customer
JOIN invoice ON customer.customer_id = invoice.customer_id
Join invoice_line ON invoice.invoice_id= invoice_line.invoice_id
where track_id in ( Select track_id from track
					join genre on track.genre_id= genre.genre_id
					where genre.name LIKE 'Rock')
Order by email

-- Q7. Let's invite the artists who have written the most rock music in our dataset. Write a
--query that returns the Artist name and total track count of the top 10 rock bands

Select * from artist

Select artist.artist_id, artist.name, sum(track.track_id), count(artist.artist_id) AS number_of_songs
from track
join album on album.album_id = track.album_id
join artist on album.artist_id = artist.artist_id
join genre on track.genre_id= genre.genre_id
where genre.name like 'Rock'
Group by artist.artist_id
Order by number_of_songs DESC
limit 10

--Q8. Return all the track names that have a song length longer than the average song length.
--Return the Name and Milliseconds for each track. Order by the song length with the
--longest songs listed first

select avg(milliseconds) from track

Select name, milliseconds from track
where milliseconds > (select avg(milliseconds) from track)
Order by milliseconds desc

--Q9. Find how much amount spent by each customer on artists? Write a query to return
--customer name, artist name and total spent

select * from track

WITH best_selling_artist AS (
	select artist.artist_id as artist_id, artist.name as artist_name, 
	sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
	from invoice_line
	Join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc)
Select c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
sum(il.unit_price * il.quantity) as amount_spent from invoice AS i
join customer AS c ON c.customer_id = i.customer_id
join invoice_line AS il ON il.invoice_id = i.invoice_id
join track AS t ON t.track_id= il.track_id
join album AS alb ON alb.album_id = t.album_id
join best_selling_artist AS bsa ON bsa.artist_id = alb.artist_id
Group by 1,2,3,4
order by 5 DESC

--Q10. We want to find out the most popular music Genre for each country. We determine the
--most popular genre as the genre with the highest amount of purchases. Write a query
--that returns each country along with the top Genre. For countries where the maximum
--number of purchases is shared return all Genres

With popular_genre as (
	Select count(invoice_line.quantity) AS purchases, customer.country, genre.name,genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
	FROM invoice_line
	JOIN invoice on invoice.invoice_id = invoice_line.invoice_id
	JOIN customer on customer.customer_id = invoice.customer_id
	JOIN track on track.track_id = invoice_line.track_id
	JOIN genre on genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
Select * from popular_genre WHERE RowNo<=1

-- Q11. Write a query that determines the customer that has spent the most on music for each
--country. Write a query that returns the country along with the top customer and how
--much they spent. For countries where the top amount spent is shared, provide all
--customers who spent this amount

With customer_with_country as (
	Select customer.customer_id, first_name, last_name, billing_country, SUM(total) AS total_spending,
	ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS Rowno
	FROM invoice
	JOIN customer on customer.customer_id = invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC, 5 DESC
)
Select * from  customer_with_country WHERE Rowno <= 1