--senior most employee
select * from employee
order by levels desc
limit 1;

--countries with most invoices
select count(*) as num_invoices, billing_country 
from invoice
group by billing_country
order by num_invoices desc
limit 1;

--top 3 values of total invoices
select total from invoice
order by total desc
limit 3;

--city that has highest sum of total invoices
select distinct(billing_city) as city, sum(total) as total_invoices
from invoice
group by city
order by total_invoices desc
limit 1;

--customer who spent most money
select c.customer_id,c.first_name,c.last_name, sum(i.total) as money_spent
from customer c join invoice i
on c.customer_id = i.customer_id
group by c.customer_id
order by money_spent desc
limit 1;

--rock music listeners
select distinct c.email, c.first_name,c.last_name
from customer c join invoice i
on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
where track_id in(
	select t.track_id from track t
	join genre g on t.genre_id = g.genre_id
	where g.name = 'Rock'
)
order by email;

--artist name and total track count of top 10 rock bands
select art.artist_id,art.name, count(art.artist_id) as num_of_songs
from track t 
join album a on a.album_id = t.album_id
join artist art on a.artist_id = art.artist_id
join genre g on g.genre_id = t.genre_id
where g.name like 'Rock'
group by art.artist_id
order by num_of_songs desc
limit 10;

--longest song length
select name,milliseconds
from track
where milliseconds>(
	select avg(milliseconds)
	from track
)
order by milliseconds desc;

--amount spent by each customer on artists
with best_selling_artist as(
	select art.artist_id,art.name as artist_name, sum(inl.unit_price*inl.quantity) as total_sales
	from invoice_line inl
	join track t on t.track_id = inl.track_id
	join album a on a.album_id = t.album_id
	join artist art on art.artist_id = a.artist_id
	group by 1
	order by 3 desc
	--limit 1
)
select c.customer_id, c.first_name,c.last_name,bsa.artist_name,sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track on track.track_id = il.track_id
join album alb on alb.album_id = track.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

--most popular music genre for each country
with popular_genre as(
	select count(il.quantity) as purchases, c.country,g.name,g.genre_id,
	row_number() over(partition by c.country order by count(il.quantity) desc) as row_num
	from invoice_line il
	join invoice i on i.invoice_id = il.invoice_id
	join customer c on c.customer_id = i.customer_id
	join track t on t.track_id = il.track_id
	join genre g on g.genre_id = t.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where row_num<=1;

--customer that has spent most by country
with customer_with_country as(
	select c.customer_id,c.first_name,c.last_name,i.billing_country as country,sum(i.total) as total_spent,
	row_number() over(partition by i.billing_country order by sum(i.total) desc) as row_num
	from invoice i
	join customer c on c.customer_id = i.customer_id
	group by 1,2,3,4
	order by 1 asc,5 desc
)
select * from customer_with_country where row_num<=1;