use sakila;
-- 1a. First and last name of actors
select first_name,last_name from actor;

-- 1b. Actor first abd last name in single column
select concat (first_name," ",last_name)
 as "Actor Name" from actor;
 
 -- 2a. Find I.D, first name and last name of actor
 --     named Joe
 select actor_id,first_name,last_name from actor
 where first_name = "Joe";
 
 -- 2b. Actors with last name containing GEN
 select first_name,last_name from actor where
 last_name like '%GEN%';
 
 -- 2c. Actors with last name containing LI
 select last_name,first_name from actor where
 last_name like '%LI%';
 
 -- 2d. Country I.D and country for Afghanistan,
 --     Bangladesh, China
 select country_id, country from country
 where country in ("Afghanistan","Bangladesh","China"
                   );
-- 3a. Create description column in actor table
alter table actor
add description blob;

-- 3b. Delete description column in actor table
alter table actor
drop column description;

-- 4a. last name of actors and count
select last_name, count(last_name) as frequency
 from actor group by last_name;
 
 -- 4b. Last name of actors and number of actors sharing that name 
 select last_name, count(last_name) as Number_of_actors from actor
 group by last_name Having Number_of_actors >= 2;
 
 -- 4c. Change Groucho williams to Harpo Williams
 update actor
 set first_name = "HARPO" where (
 first_name = "GROUCHO" and last_name = "WILLIAMS");
 
 -- 4d. Change Harpo Williams back to Groucho Williams 
 update actor
 set first_name = "GROUCHO" where (
 first_name = "HARPO" and last_name = "WILLIAMS");
 
 -- 5a. Schema of address table
 show create table address;
 
 -- 6a.Display first & last name of staff members
 -- and their addresses
 select staff.first_name,staff.last_name,
 address.address from staff join address
 on staff.address_id = address.address_id;
 
 -- 6b. Total payment rung up by staff members
 select staff.staff_id,staff.first_name,staff.last_name,sum(payment.amount) from staff 
 join payment on staff.staff_id = payment.staff_id where payment.payment_date like '2005-08%'
 group by staff.staff_id;
 
 -- 6c. Film and number of actors for that film
 select film.film_id,film.title,count(film_actor.film_id) as Number_of_actors
 from film inner join film_actor on film.film_id = film_actor.film_id
 group by film_actor.film_id;
 
 -- 6d. Number of copies of Hunchback Impossible
 select film_id,count(film_id) as Number_in_Inventory from inventory where film_id = 439;
 -- Number of copies = 6
 
 -- 6e. Total paid by each customer
 select customer.first_name,customer.last_name,sum(payment.amount) as total_payment
 from customer inner join payment on customer.customer_id = payment.customer_id
 group by payment.customer_id order by customer.last_name asc;
 
 -- 7a. Movies starting with K or Q whose language is english
 select title,language_id from film where ((title like 'k%' or title like 'q%') and language_id in
	(select language_id from language where name = 'English'));
     
 -- 7b. Actors who appear in the film alone trip
 select first_name,last_name from actor where actor_id in
	(select actor_id from film_actor where film_id in
		(select film_id from film where title = "Alone Trip")
	);
 
 -- 7c. Names and email addresses of all Canadian customers
 select D.first_name,D.last_name,D.email from country as A
	inner join city as B on B.country_id = A.country_id
		inner join address as C on B.city_id = C.city_id
			inner join customer as D on C.address_id = D.address_id
				where A.country = "canada";

-- 7d. Movies categorized as family films
select title from film where film_id in
	(select film_id from film_category where category_id in
		(select category_id from category where name = "family")
	);

-- 7e. Most frequently rented movies in descending order
select film.title,count(film.film_id) as number_of_rentals from rental
inner join inventory on rental.inventory_id = inventory.inventory_id
inner join film on film.film_id = inventory.film_id group by film.film_id
order by number_of_rentals desc;

-- 7f. Businees in dollars by each tore
select store.store_id,sum(payment.amount) as Store_Amounts from store
inner join staff on store.store_id = staff.store_id
inner join payment on payment.staff_id = staff.staff_id group by store.store_id;

-- 7g. Store id, city and Country for each store
select A.store_id,B.city_id,D.country from store as A
inner join address as B on A.address_id = B.address_id
inner join city as C on B.city_id = C.city_id
inner join country as D on C.country_id = D.country_id;

-- 7h. Top 5 genres in gross revenue in descending order
select A.name,sum(E.amount) as Gross_Revenue from category as A
inner join film_category as B on A.category_id = B.category_id
inner join inventory as C on B.film_id = C.film_id
inner join rental as D on C.inventory_id = D.inventory_id
inner join payment as E on D.rental_id = E.rental_id
group by A.category_id order by Gross_Revenue desc;

-- 8a. View for top 5 genres by gross revenue
create view top_five_genres as 
select A.name,sum(E.amount) as Gross_Revenue from category as A
inner join film_category as B on A.category_id = B.category_id
inner join inventory as C on B.film_id = C.film_id
inner join rental as D on C.inventory_id = D.inventory_id
inner join payment as E on D.rental_id = E.rental_id
group by A.category_id order by Gross_Revenue desc;

-- 8b. Display created view for top 5 genres
select * from top_five_genres;

-- 8c. Delete created view
drop view top_five_genres;