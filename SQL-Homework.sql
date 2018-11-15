USE sakila;

-- INTRO QUERIES

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT upper(concat(first_name, " ", last_name)) as "Actor Name"
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name LIKE "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT upper(last_name) as "Last Name", upper(first_name) as "First Name"
FROM actor
WHERE last_name LIKE "%L%" or "%I%"
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT c.country_id as "Country ID", c.country as "Country Name"
FROM country c
WHERE c.country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- BLOB vs VARCHAR: https://stackoverflow.com/questions/2023481/mysql-large-varchar-vs-text
ALTER TABLE actor ADD COLUMN description BLOB; 

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name) as last_name_count
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(last_name) as last_name_count
FROM actor
GROUP BY last_name
HAVING last_name_count >1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS' ;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address
FROM staff
LEFT JOIN address ON (staff.address_id = address.address_id);

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT first_name, last_name, sum(amount) as total_amount
FROM staff
LEFT JOIN payment ON (staff.staff_id = payment.staff_id)
GROUP BY staff.first_name, staff.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.film_id, f.title, count(fa.film_id)
FROM film f
JOIN film_actor fa ON (f.film_id = fa.film_id)
GROUP BY f.title, f.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT count(film_id) as "Count of Hunback Impossible"
FROM inventory
WHERE film_id = (
	SELECT film_id
    FROM film
    WHERE title like '%Hunchback Impossible%'
    );

-- ADVANCED QUERIES

-- 6e. REVENUE INFO: BY CUSTOMER 
-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, sum(p.amount)
FROM customer c
LEFT JOIN payment p ON (c.customer_id = p.customer_id)
GROUP BY c.first_name, c.last_name;
-- sum = 67416.51

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE (title LIKE 'K%' or title LIKE 'Q%') AND language_id = (
	SELECT language_id
    FROM language
    WHERE name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT a.first_name, a.last_name
FROM actor a
WHERE  a.actor_id IN (   
	SELECT fa.actor_id
	FROM film_actor fa
	WHERE fa.film_id = (
		SELECT f.film_id
		FROM film f
		WHERE f.title = 'Alone Trip'
		)
	);
    
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT first_name, last_name, email, country
FROM customer
JOIN address on (customer.address_id = address.address_id)
JOIN city on (address.city_id = city.city_id)
JOIN country on (country.country_id = city.country_id)
WHERE country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title, name
FROM film
JOIN film_category ON (film.film_id = film_category.film_id)
JOIN category ON (film_category.category_id = category.category_id)
WHERE name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT title, count(title) as rental_count
FROM film
JOIN inventory on (inventory.film_id = film.film_id)
JOIN rental on (rental.inventory_id = inventory.inventory_id)
GROUP BY title
ORDER BY rental_count desc;

-- REVENUE INFO: BY STORE 
-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, sum(amount) as "Total Sales"
FROM staff
JOIN rental on (staff.staff_id = rental.staff_id)
JOIN payment on (rental.rental_id = payment.rental_id)
GROUP BY store_id;
-- store 1: 33524.62 + store 2: 33881.94 = Total: 67405.56 

-- check: summing the payment table = 67416.51
select sum(amount)
from payment;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, ct.country
FROM store s
JOIN address a ON (a.address_id = s.address_id)
JOIN city c ON (c.city_id = a.city_id)
JOIN country ct ON (ct.country_id = c.country_id);

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT name, sum(amount) as revenue
FROM payment
JOIN rental
	ON (payment.rental_id = rental.rental_id)
JOIN inventory
	ON (rental.inventory_id = inventory.inventory_id)
JOIN film
	ON (inventory.film_id = film.film_id)
JOIN film_category
	ON (film.film_id = film_category.film_id)
JOIN category
	ON (category.category_id = film_category.category_id)
GROUP BY name
ORDER BY revenue desc
LIMIT 5;
-- sum of all genres = 67406.56

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
CREATE VIEW top_genres AS (
	SELECT name, sum(amount) as revenue
	FROM payment
	JOIN rental ON (payment.rental_id = rental.rental_id)
	JOIN inventory ON (rental.inventory_id = inventory.inventory_id)
	JOIN film ON (inventory.film_id = film.film_id)
	JOIN film_category ON (film.film_id = film_category.film_id)
	JOIN category ON (category.category_id = film_category.category_id)
	GROUP BY name
	ORDER BY revenue desc
	LIMIT 5);

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM top_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_genres;


SELECT * FROM PAYMENT
WHERE rental_id is null
ORDER BY rental_id asc 