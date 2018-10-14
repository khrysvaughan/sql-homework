/* SQL Homework */

-- 1a. Display the first and last names of all actors from the table actor.
select first_name as "First Name", last_name as "Last Name"
from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
-- The names are already in upper case
select upper(concat(first_name,' ', last_name)) as "Actor Name"
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name
from actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN
select * 
from actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select *
from actor
where last_name like '%LI%'
order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country in ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table actor
	add description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor
	drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name as "Last Name", count(*) as "Count"
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name as "Last Name", count(*) as "Count"
from actor
group by last_name
having count > 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
-- This query finds the actor id for Groucho Williams (id 172)
select actor_id
    from actor
    where first_name = "GROUCHO" and last_name = "WILLIAMS";
    
-- This query updates the name based on the actor id found
update actor
set first_name = "HARPO"
where actor_id in ("172");

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor
set first_name = "GROUCHO"
where first_name = "HARPO";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
describe sakila.address;

-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select first_name as "First Name", last_name as "Last Name", address as "Address"
from staff
left join address
on staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select concat(first_name,' ', last_name) as "Staff Member",
sum(payment.amount) as "Total"
from staff
left join payment
on staff.staff_id = payment.staff_id
group by last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select title as "Title", count(film_actor.actor_id) as "Number of Actors"
from film
inner join film_actor
on film.film_id = film_actor.film_id
group by title;

/*The next two queries are to check if the count is correct
select film_id
from film
where title = "academy dinosaur";

-- This produces 10 actors so the main query is correct
select actor_id
from film_actor
where film_id = "1";
*/

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
-- Based on the query below, there are 6 copies
select count(*) as "Copies"
from inventory
where inventory.film_id in
	(select film_id
    from film
    where title = "Hunchback Impossible");

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select concat(first_name,' ', last_name) as "Customer",
sum(payment.amount) as "Total Paid"
from customer
left join payment
on customer.customer_id = payment.customer_id
group by customer.last_name
order by customer.last_name;

-- Total amount paid

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title
from film
where (title like "K%" or title like "Q%")
and language_id in
	(select language_id from language where name = "English");

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select concat(first_name,' ', last_name) as "Actor"
from actor
where actor_id in 
	(select actor_id from film_actor where film_id in 
		(select film_id from film where title = "Alone Trip"));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
select concat(first_name,' ', last_name) as "Customer",
email
from customer
left join address on customer.address_id = address.address_id
left join city on city.city_id = address.city_id
left join country on country.country_id = city.country_id
where country.country = "Canada";

/* The following queries are to verify is the main query is correct
select country_id from country where country = "Canada";
-- answer is 20

select city_id from city where country_id = "20";
-- results are 179, 196, 300, 313, 383, 430, 565

select address_id from address where city_id in (179, 196, 300, 313, 383, 430, 565);
-- results are 481, 468, 1, 3, 193, 415, 441

select first_name from customer where address_id in (481, 468, 1, 3, 193, 415, 441);
*/

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
select title
from film
where film_id in 
	(select film_id from film_category where category_id in 
		(select category_id from category where name = "Family"));

-- 7e. Display the most frequently rented movies in descending order.
select title as "Title", count(film.film_id) as "Count"
from film
left join inventory on inventory.film_id = film.film_id
left join rental on rental.inventory_id = inventory.inventory_id
group by title
order by count desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select staff.store_id as "Store", sum(payment.amount) as "Amount"
from payment
left join staff on payment.staff_id = staff.staff_id
group by staff.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select store_id, city.city, country.country
from store
left join address on address.address_id = store.address_id
left join city on city.city_id = address.city_id
left join country on country.country_id = city.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select category.name as "Genre", sum(payment.amount) as "Gross"
from category 
left join film_category on film_category.category_id = category.category_id
left join film on film.film_id = film_category.film_id
left join inventory on inventory.film_id = film.film_id
left join rental on rental.inventory_id = inventory.inventory_id
left join payment on payment.rental_id = rental.rental_id
group by category.name
order by Gross desc
Limit 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view TopFiveGenres as
select category.name as "Genre", sum(payment.amount) as "Gross"
from category 
left join film_category on film_category.category_id = category.category_id
left join film on film.film_id = film_category.film_id
left join inventory on inventory.film_id = film.film_id
left join rental on rental.inventory_id = inventory.inventory_id
left join payment on payment.rental_id = rental.rental_id
group by category.name
order by Gross desc
Limit 5;


-- 8b. How would you display the view that you created in 8a?
select * from topfivegenres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view topfivegenres;
