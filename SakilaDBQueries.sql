-- Queries
-- 1a. Display the first and last names of all actors from the table actor.
	Select FirstName, LastName
    From actor;

-- 1b. Display the first and last name of each actor in a single column with only the first letter in upper case. Name the column Actor Name.
	Select 
		Concat(
			Upper(Substr(FirstName, 1, 1)),
            Lower(Substr(FirstName, 2, Length(FirstName))),
            " ",
            Upper(Substr(LastName, 1, 1)),
            Lower(Substr(LastName, 2, Length(LastName)))
            ) as ActorName
	From actor;
    
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
	Select ActorID, FirstName, LastName
    From actor
    Where Lower(FirstName) = "Joe";
    
-- 2b. Find all actors whose last name contain the letters GEN:
	Select *
    From actor
    Where LastName Like "%GEN%";
    
--  2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name:
	Select FirstName, LastName
    From actor
    Where LastName Like "%LI%"
    Order By LastName, FirstName;
    
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
	Select CountryID, Country
    From country
    Where Country In ("Afghanistan", "Bangladesh", "China");
    
-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
	Alter Table actor
    Add Column Description Blob;
    
    Desc actor;
    
-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
	Alter Table actor
    Drop Column Description;
    
    Desc actor;
    
-- 4a. List the last names of actors, as well as how many actors have that last name.
	Select LastName, Count(LastName) as Count
    From actor
    Group By LastName
    Order By Count Desc, LastName;
    
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
	Select LastName, Count(LastName) as Count
    From actor
    Group By LastName
    Having Count >= 2
    Order By Count Desc, LastName;
    
-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
	Update actor
    Set FirstName = "HARPO", LastName = "WILLIAMS"
    Where FirstName = "GROUCHO" AND LastName="WILLIAMS";
		
	Select * From actor Where FirstName = "HARPO" ;
    
--  4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
	Update actor
    Set FirstName = "GROUCHO"
    Where FirstName = "HARPO" And LastName = "WILLIAMS";
    
    Select * from actor Where FirstName = "GROUCHO";
    
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
	Show Create Table address;
    
--  6a. Use JOIN to display the first and last names, as well as the address, of each staff member.
	Select staff.FirstName, staff.LastName, address.Address, address.District, city.City, country.Country
    From staff
    Inner Join address On staff.AddressID = address.AddressID
    Inner Join city On address.CityID = city.CityID
    Inner Join country On city.CountryID = country.CountryID;
        
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005.
	Select staff.FirstName, staff.LastName, sum(payment.Amount)
    From staff 
    Left Join payment On staff.StaffID = payment.StaffID
    Where Month(payment.PaymentDate) = 8
    and Year(payment.PaymentDate) = 2005
    Group By staff.StaffID;
    
-- 6c. List each film and the number of actors who are listed for that film.
	Select 
		   f.Title,
           Count(a.ActorID) as No_of_Actors,
           Group_Concat(Concat(a.FirstName, " ", a.LastName) Order by a.FirstName Separator ", ") as Actors
	From film f
    Inner Join film_actor fa on f.FilmID = fa.FilmID
    Inner Join actor a on fa.ActorID = a.ActorID
    Group By f.Title;
    
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
	Select 
		film.FilmID,
        film.Title,
        Count(inventory.FilmID) as No_of_copies
	From film
    Inner Join inventory On film.FilmID = inventory.FilmID
    Where Lower(film.Title) = "hunchback Impossible";
    -- Group By film.FilmID
    -- Order By No_of_copies Desc, film.Title;
    
-- 6e. list the total paid by each customer.
	Select 
		p.CustomerID, 
        Concat(c.FirstName, " ", c.LastName) as Customer, 
        Sum(p.Amount) as totalPayment
    From payment p
    Inner Join customer c On p.CustomerID = c.CustomerID
    Group By p.CustomerID
    Order By totalPayment Desc, Customer;
    
-- 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
	Select Title 
    From film 
    Where Title Like "K%" Or "Q%"
		And LanguageID = ( Select LanguageID From language Where Name = "English")
	Order by Title;
    
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
	Select ActorID, Concat(FirstName, " ", LastName) as ActorName
    From actor
    Where ActorID in (
			Select ActorID 
            From film_actor
            Where FilmID = ( Select FilmID From film Where Lower(Title) = "alone trip")
            )
	Order By ActorName;
    
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
	Select cs.CustomerID, cs.FirstName, cs.LastName, cs.Email, ct.City
    From customer cs
    Inner Join address a On cs.AddressID = a.AddressID
    Inner Join city ct On a.CityID = ct.CityID
    Inner Join country cu On ct.CountryID = cu.CountryID
    Where cu.Country = "Canada";
    
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
	Select FilmID, Title 
    From film 
    Where FilmID in (
			Select FilmID 
            from film_category
            Where CategoryID = (Select CategoryID From category Where Name = "Family")
            )
	Order by FilmID;
    
-- 7e. Display the most frequently rented movies in descending order
	Select f.FilmID, f.Title, Count(r.rentalID) as TimesRented
    From rental r
    Inner Join inventory i On r.InventoryID = i.InventoryID
    Inner Join film f On i.FilmID = f.FilmID
    Group By f.FilmID
    Order By TimesRented Desc, f.Title;
    
    Select f.FilmID, f.Title, rentInfo.TimesRented
    From film f
    join (
		Select i.FilmID, count(r.RentalID) as TimesRented
        from rental r
        Join inventory i On r.InventoryID = i.InventoryID
        Group By i.FilmID
        ) as rentInfo
	On f.FilmID = rentInfo.FilmID
    Order by rentInfo.TimesRented Desc, f.Title;
    
    
-- 7f. Write a query to display how much business, in dollars, each store brought in.
	Select st.StoreID, sales.TrunOver
    From store st
    Join (
		Select c.StoreID, Sum(p.Amount) As TrunOver
        From payment p
        Left Join customer c On p.CustomerID = c.CustomerID
        Group By c.StoreID
        ) as sales
	On st.StoreID = sales.StoreID
	Order By TrunOver Desc, st.StoreID;
    
-- 7g. Write a query to display for each store its store ID, city, and country.
	Select s.StoreID, ct.City, cu.Country
    From store s
    Inner Join address a On s.AddressID = a.AddressID
    Inner Join city ct On a.CityID = ct.CityID
    Inner Join country cu On ct.countryID = cu.CountryID
    Order by cu.Country, ct.City;
	
-- 7h. List the top five genres in gross revenue in descending order. 
	Select cat.CategoryID, cat.Name, Sum(IfNull(p.Amount, 0)) As revenue
    From payment p
    Inner Join rental r On p.RentalID = r.RentalID
    Inner Join inventory i On r.InventoryID = i.InventoryID
    Inner Join film f On i.FilmID = f.FilmID
    Inner Join film_category fa On f.FilmID = fa.FilmID
    Inner Join category cat On fa.CategoryID = cat.CategoryID
    Group By cat.CategoryID
    Order By revenue Desc
    Limit 5;
    
-- 8a. Create a View for top 5 genres.
	Create View top_five_genres
    As
    Select cat.CategoryID, cat.Name, Sum(IfNull(p.Amount, 0)) As revenue
    From payment p
    Inner Join rental r On p.RentalID = r.RentalID
    Inner Join inventory i On r.InventoryID = i.InventoryID
    Inner Join film f On i.FilmID = f.FilmID
    Inner Join film_category fa On f.FilmID = fa.FilmID
    Inner Join category cat On fa.CategoryID = cat.CategoryID
    Group By cat.CategoryID
    Order By revenue Desc
    Limit 5;
    
-- 8b. How would you display the view that you created in 8a?
    Select * from top_five_genres;
    
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
	drop View top_five_genres;