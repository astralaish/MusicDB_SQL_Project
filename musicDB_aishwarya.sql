--EASY

--Q1: Who is senior most employee based on job title?
SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

--Q2: Which countries have the most invoices?
SELECT billing_country as Country, COUNT(billing_country) AS c
FROM invoice
GROUP BY Country
ORDER BY c DESC
LIMIT 5;

--Q3: What are the top 3 values of total invoice?
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;

--Q4: Which city has best customers? We would like to throw a promotional Music festival in the city we made
--the most money. Write a query that returns one city that has the highest sum of invoice totals.
--Return both the city name & sum of all invoice totals
SELECT billing_city, sum(total) as sum_invoice
FROM invoice
GROUP BY billing_city
ORDER BY sum_invoice DESC
LIMIT 1;

--Q5: Who is the best customer with highest spent money? 
--Not optimal as it's not Dynamic

-- Select first_name,last_name,
-- (
-- select SUM(total) AS highest_invoice
-- from invoice i 
-- JOIN customer c ON c.customer_id= i.customer_id
-- GROUP BY i.customer_id
-- ORDER BY highest_invoice DESC
-- limit 1
-- )
-- From customer
-- Where customer_id=5

SELECT a.customer_id, a.first_name, a.last_name, SUM(b.total) as s 
FROM customer AS a
INNER JOIN invoice AS b
ON a.customer_id=b.customer_id
GROUP BY a.customer_id
ORDER BY s DESC
LIMIT 1;






--MODERATE





--Q1:email,first_name,last_name, genre for rock_music listeners
--order by email starting with a

select c.first_name,c.last_name,c.email
from customer c
JOIN invoice i ON c.customer_id = c.customer_id
JOIN invoice_line l ON l.invoice_id=i.invoice_id
JOIN track t ON t.track_id=l.track_id
JOIN genre g ON g.genre_id=t.genre_id
WHERE g.name='Rock'
ORDER BY c.email

--Approach 2

select first_name, last_name, email from customer where customer_id IN(
	select customer_id from invoice where invoice_id IN(
		select invoice_id from invoice_line where track_id IN(
			select track_id from track where genre_id IN(
				select genre_id from genre where name IN ('Rock')))))
				order by email;
				

--Approach 3 : Guided Approach
SELECT DISTINCT first_name, last_name, email 
FROM customer 
JOIN invoice ON customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
WHERE track_id IN(
SELECT a.track_id 
FROM track AS a
JOIN genre AS b
ON a.genre_id = b.genre_id
WHERE b.name='Rock')
ORDER BY email;

-- Q2: artist who wrote most rock music
--returns artist name and total track count of top 10 rock bands(meaning here)
--top rock bands-band with most no. of songs/tracks

SELECT at.artist_id,at.name, COUNT(at.artist_id) AS total
FROM track t
JOIN genre g ON g.genre_id = t.genre_id
JOIN ALBUM A ON A.ALBUM_ID =T.ALBUM_ID
JOIN ARTIST AT ON AT.ARTIST_ID=A.ARTIST_ID
WHERE G.name='Rock'
GROUP BY at.artist_id
ORDER BY total desc
LIMIT 10

-- Q3: return song length>average song length
--return name and millisec of track
--order by longest song first

select name,milliseconds
from track
WHERE milliseconds>(Select AVG(milliseconds) AS avg_len
from track)
Order by milliseconds





-- ADVANCE






/* Q1: amt spent by each customer on a top selling artist
--return customer name, artist name, total amt
--can't be done with subquery (if we want to make it dynamic),use CTEs*/


WITH top_artist as
(
select SUM(l.unit_price*l.quantity) as total,at.artist_id,at.name
from invoice_line l
JOIN track t ON t.track_id=l.track_id
JOIN genre g ON g.genre_id = t.genre_id
JOIN ALBUM A ON A.ALBUM_ID =T.ALBUM_ID
JOIN ARTIST AT ON AT.ARTIST_ID=A.ARTIST_ID
Group BY 2
Order by total desc
limit 1
)
select c.customer_id, c.first_name, c.last_name,ta.name,
SUM(l.unit_price*l.quantity) as total
from invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line l ON l.invoice_id=i.invoice_id
JOIN track t ON t.track_id=l.track_id
JOIN genre g ON g.genre_id = t.genre_id
JOIN ALBUM A ON A.ALBUM_ID =T.ALBUM_ID
JOIN Top_artist ta on ta.artist_id=a.artist_id
GROUP BY 1,2,3,4
Order by 5 DESC


-- Q3: most popular genre of each country,
--most popular means-genre with highest amt of purchase
--(its asking for highest not 'total' so we need COUNT)
--return each country +top genre
--in countries if max purchase is same ,return all genre
--(using row number so each country gets displayed only once.)
--can also be done with recursive

WITH top_genre AS
(
select COUNT(l.quantity) as high,c.country,g.name,g.genre_id,
ROW_NUMBER() OVER(PARTITION BY c.country 
				 ORDER BY COUNT(quantity) DESC) AS row_num
from invoice_line l
JOIN invoice i ON i.invoice_id=i.invoice_id
JOIN customer c ON c.customer_id = i.customer_id
JOIN track t ON t.track_id=l.track_id
JOIN genre g ON g.genre_id = t.genre_id
Group BY 2,3,4
Order by 2 ASC,1 desc
)
Select *
FROM top_genre
WHERE row_num<=1




-- Q3: customer spent most on music for each country
--returns country n their top customer n how much they spent
--if top amount is shared return all customers who spent this amt

WITH customer_music AS
(
SELECT c.customer_id,c.first_name,c.last_name,i.billing_country, 
SUM(total) AS total_spent,
ROW_NUMBER() OVER(PARTITION BY i.billing_country 
				 ORDER BY SUM(total) DESC) AS row_num
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
GROUP BY 1,2,3,4
ORDER by 4 ASC,5 desc
)
SELECT * from customer_music
WHERE row_num<=1

















