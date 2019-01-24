USE sakila;

#Display the first and last names of all actors from the table actor.
SELECT  
	first_name,
    last_name
FROM actor;

#Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name
SELECT  
	CONCAT (
		first_name,
		' ',
		last_name) AS actor_name 
FROM actor;

#You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
#What is one query would you use to obtain this information?
SELECT 
	actor_id,
    first_name,
    last_name
FROM actor
WHERE first_name = 'JOE';

#Find all actors whose last name contain the letters GEN
SELECT *
FROM actor
WHERE last_name LIKE '%GEN%';

#Find all actors whose last names contain the letters LI. 
#This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name ASC;

#Using IN, display the country_id and country columns of the following countries: 
#Afghanistan, Bangladesh, and China:
SELECT
	country_id,
    country
FROM country
WHERE country = 
	'Afghanistan'
    OR 'Bangladesh'
    OR 'China'
;

#You want to keep a description of each actor. 
#You don't think you will be performing queries on a description, so 
#create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant)

#You use BLOB to store binary data like an image, audio and other multimedia data.
#and VARCHAR to store text of any size up to the limit.
ALTER TABLE actor
	ADD COLUMN description BLOB;
SELECT * FROM actor;

#Very quickly you realize that entering descriptions for each actor is too much effort. 
#Delete the description column.
ALTER TABLE actor
	DROP description;
SELECT * FROM actor;

#List the last names of actors, as well as how many actors have that last name.
SELECT last_name,
    COUNT(last_name)
FROM actor GROUP BY last_name;

#4b. List last names of actors and the number of actors who have that last name, 
#but only for names that are shared by at least two actors

SELECT last_name,
	COUNT(*) COUNT
FROM actor GROUP BY last_name
HAVING COUNT > 1;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
#Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the 
#correct name after all! In a single query, 
#if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
#Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;

#6a. Use JOIN to display the first and last names, as well as the address, of each 
#staff member. Use the tables staff and address:
SELECT first_name, last_name, address
FROM staff
JOIN address ON staff.address_id = address.address_id;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
#Use tables staff and payment.
SELECT SUM(amount) AS total_ringup, first_name, last_name
FROM payment
JOIN staff ON payment.staff_id = staff.staff_id;

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and 
#film. Use inner join.
SELECT title, COUNT(actor_id) AS number_of_actors_in_film
FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY title;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT title, COUNT(inventory_id) AS number_of_copies
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
WHERE title = "Hunchback Impossible";

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
#List the customers alphabetically by last name:
SELECT SUM(amount), last_name
FROM payment
JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY last_name;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended 
#consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries 
#to display the titles of movies starting with the letters K and Q whose language is English.
SELECT *
FROM language;

SELECT title
FROM film
WHERE language_id IN (SELECT language_id
FROM language WHERE name = "English") 
AND title LIKE "K%" OR "Q%";

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT actor_name FROM actor; #actor_name appears to only contain null values...

SELECT first_name, last_name 
FROM actor 
WHERE actor_id 
	IN (SELECT actor_id 
		FROM film_actor 
        WHERE film_id 
			IN (SELECT film_id 
				FROM film 
                WHERE title = "Alone Trip"));


#7c. You want to run an email marketing campaign in Canada, for which you will need the names and 
#email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT * FROM customer; #has customer_id, first_name, last_name, email, address_id
SELECT * FROM address; #has address_id, city_id
SELECT * FROM city; #has city_id, city name, and country_id
SELECT * FROM country; #has country_id and country(name)

SELECT first_name, last_name, email, country
FROM customer 
JOIN address ON address.address_id = customer.address_id
JOIN city ON city.city_id = address.city_id
JOIN country ON city.country_id = country.country_id
WHERE country.country = "Canada";

#correlated subquery method...
#SELECT address_id
#FROM address 
#WHERE city_id in 
#(SELECT city_id 
	#FROM city
		#WHERE country_id IN
		#(SELECT country_id 
			#FROM country 
				#WHERE country = "Canada"));

#7d. Sales have been lagging among young families, and you wish to target all family movies for a 
#promotion. Identify all movies categorized as family films.
SELECT title, film.film_id, cat.category_id
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category cat ON film_category.category_id = cat.category_id
WHERE name = "Family";

#7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(rental.inventory_id), rental_rate
FROM inventory
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN film_text ON inventory.film_id = film_text.film_id
JOIN film ON film_text.film_id = film.film_id
GROUP BY film.title
ORDER BY (rental_rate) DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT * FROM store; #confirming that there are only 2 different store ids

SELECT store.store_id, SUM(amount)
FROM store
JOIN staff ON staff.store_id = store.store_id
JOIN payment ON payment.staff_id = staff.staff_id
GROUP BY store_id;

#7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM store
JOIN address ON address.address_id = store.address_id
JOIN city ON city.city_id = address.city_id
JOIN country ON country.country_id = city.country_id
GROUP BY store_id;

#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the 
#following tables: category, film_category, inventory, payment, and rental.)

SELECT name, SUM(amount) 
FROM category
JOIN film_category ON film_category.category_id = category.category_id
JOIN inventory ON inventory.film_id = film_category.film_id
JOIN rental ON rental.inventory_id = inventory.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY name
ORDER BY SUM(amount) DESC
LIMIT 5;

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres
#by gross revenue. Use the solution from the problem above to create a view. 
#If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top5view
AS SELECT name, SUM(amount) 
	FROM category
		JOIN film_category ON film_category.category_id = category.category_id
			JOIN inventory ON inventory.film_id = film_category.film_id
				JOIN rental ON rental.inventory_id = inventory.inventory_id
					JOIN payment ON rental.rental_id = payment.rental_id
	GROUP BY name
	ORDER BY SUM(amount) DESC
	LIMIT 5;

#8b. How would you display the view that you created in 8a?
SELECT * FROM top5view;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top5view;

