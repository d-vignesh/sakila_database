-- create the database With Default CHARSET of utf8:
	Create Database If Not Exists sakila Default Character Set utf8 Collate utf8_unicode_ci;

-- switch to the database:
	use sakila;

-- Table Structures:

-- 1. Actor
	Create Table actor(
		ActorID    Smallint     Unsigned Not Null Auto_Increment, -- 16-bit unsigned int in the range of [0, 65535]
		FirstName  varchar(50)  Not Null,
		LastName   varchar(50)  Not Null,
		LastUpdate TimeStamp    Not Null Default Current_Timestamp On Update Current_Timestamp,
		Primary Key (ActorID),
		Key idx_actor_last_name	(Lastname) -- To build index (non-unique) on last name
	) Engine=InnoDB Default Charset=utf8;

-- 2. Language
	Create Table language (
		LanguageID  Tinyint     Unsigned Not Null Auto_Increment,
		Name        varchar(50)  Not Null,
		LastUpdate  TimeStamp    Not Null Default Current_Timestamp On Update Current_Timestamp,
		Primary Key (LanguageID)
	) Engine=InnoDB Default Charset=utf8;

-- 3. Film
	Create Table film (
		FilmID             Smallint      Unsigned Not Null Auto_Increment,
		Title              varchar(50)   Not Null,
		Description        Text          Default Null,
		ReleaseYear        Year          Default Null,
		LanguageID         Tinyint       Unsigned Not Null,
		OriginalLanguageID Tinyint       Unsigned Default Null,
		RentalDuration     Tinyint       Unsigned Not Null Default 3,
		RentalRate         Decimal(4, 2) Not Null Default 4.99,
		Length             Smallint      Unsigned Default Null,
		ReplacementCost    Decimal(5, 2) Not Null Default 19.99,
		Rating             ENUM("G", "PG", "PG-13", "R", "NC-17") Default "G",
		SpecialFeatures    Set("Trailers", "Commentaries", "Deleted Scenes", "Behind the Scenes") Default Null,
		LastUpdate         Timestamp     Not Null Default Current_Timestamp On Update Current_Timestamp,
		Primary Key (FilmID),
		Key idx_title (Title),
		Key idx_fk_language_id (LanguageID),
		Key idx_fk_original_language_id (OriginalLanguageID),
		Constraint fk_film_language Foreign Key (LanguageID) References language(LanguageID)
			On Delete Restrict On Update Cascade,
		Constraint fk_film_language_original Foreign Key (OriginalLanguageID) References language (LanguageID)
			On Delete Restrict On Update Cascade       
	) Engine=InnoDB Default Charset=utf8;

-- 4. film_actor
	Create Table film_actor (
		ActorID    Smallint  Unsigned Not Null,
		FilmID     Smallint  Unsigned Not Null,
		LastUpdate TimeStamp Not Null Default Current_Timestamp On Update Current_Timestamp,
		Primary Key (ActorID, FilmID),
		Key idx_fk_film_id (FilmID),
		Constraint fk_film_actor_actor Foreign Key (ActorID) References actor (ActorID)
			On Delete Restrict On Update Cascade,
		Constraint fk_film_actor_film Foreign Key (FilmID) References film (FilmID)
			On Delete Restrict On Update Cascade
	) Engine=InnoDB Default Charset=utf8;

-- 5. category
	Create Table category (
		CategoryID   Tinyint      Unsigned Not Null Auto_Increment,
		Name         varchar(50)  Not Null,
		LastUpdate   TimeStamp    Not Null Default Current_TimeStamp On Update Current_TimeStamp,
		Primary Key (CategoryID)
	) Engine=InnoDB Default Charset=utf8;

-- 6. film_category
	Create Table film_category (
		FilmID      Smallint  Unsigned Not Null,
		CategoryID  Tinyint   Unsigned Not Null,
		LastUpdate  TimeStamp Not Null Default Current_TimeStamp On Update Current_TimeStamp,
		Primary Key (FilmID, CategoryID),
		Constraint fk_film_category_film Foreign Key (FilmID) References film(FilmID)
			On Delete Restrict On Update Cascade,
		Constraint fk_film_category_category Foreign Key (CategoryID) References category(CategoryID)
			On Delete Restrict On Update Cascade
	) Engine=InnoDB Default Charset=utf8;

-- 7. film_text
	Create Table film_text (
		FilmID      Smallint     Not Null,
		Title       varchar(255) Not Null,
		Description Text,
		Primary Key (FilmID),
		FullText Key idx_title_description (Title, Description)
	) Engine=MyISAM Default Charset=utf8;

-- 8. country 
	Create Table country (
		CountryID    Smallint     Unsigned Not Null Auto_Increment,
		Country      Varchar(50)  Not Null,
		LastUpdate   TimeStamp    Not Null Default Current_TimeStamp On Update Current_TimeStamp,
		Primary Key (CountryID)
	) Engine=InnoDB Default Charset=utf8;

-- 9. city
	Create Table city (
		CityID     Smallint     Unsigned Not Null Auto_Increment,
		City       Varchar(50)  Not Null,
		CountryID  Smallint     Unsigned Not Null,
		LastUpdate TimeStamp    Not Null Default Current_TimeStamp On Update Current_TimeStamp,
		Primary Key (CityID),
		Key idx_fk_country_id (CountryID),
		Constraint fk_city_country Foreign Key (CountryID) References country (CountryID)
			On Delete Restrict On Update Cascade
	) Engine=InnoDB Default Charset=utf8;

-- 10. address
	Create Table address (
		AddressID  Smallint     Unsigned Not Null Auto_Increment,
		Address    Varchar(50)  Not Null,
		Address2   Varchar(50)  Default Null,
		District   Varchar(20)  Not Null,
		CityID     Smallint     Unsigned Not Null,
		PostalCode Varchar(10)  Default Null,
		Phone      Varchar(20)  Not Null,
		LastUpdate TimeStamp    Not Null Default Current_TimeStamp On Update Current_TimeStamp,
		Primary Key (AddressID),
		Key idx_fk_city_id (CityID),
		Constraint fk_address_city Foreign Key (CityID) References city(CityID)
			On Delete Restrict On Update Cascade
	) Engine=InnoDB Default Charset=utf8;

-- 11. store
	Create Table store (
		StoreID         Tinyint   Unsigned Not Null Auto_Increment,
		ManagerStaffID  Tinyint   Unsigned Not Null,
		AddressID       Smallint  Unsigned Not Null,
		LastUpdate      TimeStamp Not Null Default Current_TimeStamp On Update Current_TimeStamp,
		Primary Key (StoreID),
		Unique Key idx_unique_manager (ManagerStaffID),
		Key idx_fk_address_id (AddressID),
		Constraint fk_store_address Foreign Key (AddressID) References address(AddressID)
			On Delete Restrict On Update Cascade
	) Engine=InnoDB Default Charset=utf8;

-- 12. staff
	Create Table staff (
		StaffID    Tinyint      Unsigned Not Null Auto_Increment,
		FirstName  Varchar(50)  Not Null,
		LastName   Varchar(50)  Not Null,
		AddressID  Smallint     Unsigned Not Null,
		Picture    Blob         Default Null,
		Email      Varchar(50)  Default Null,
		StoreID    Tinyint      Unsigned Not Null,
		Active     Boolean      Not Null Default True,
		Username   Varchar(20)  Not Null,
		Password   Varchar(40)  CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
		LastUpdate TimeStamp    Not Null Default Current_TimeStamp On Update Current_TimeStamp,
		Primary Key (StaffID),
		Key idx_fk_store_id (StoreID),
		Key idx_fk_address_id (AddressID),
		Constraint fk_staff_store Foreign Key (StoreID) References store(StoreID)
			On Delete Restrict On Update Cascade,
		Constraint fk_staff_address Foreign Key (AddressID) References address(AddressID)
			On Delete Restrict On Update Cascade
	) Engine=InnoDB Default Charset=utf8;

-- removed the fk constraint to add data initially
	Alter Table store Drop Foreign Key fk_store_staff;
    
-- alter the store table to add staff foreign key constraint
	Alter Table store Add Constraint fk_store_staff Foreign key (ManagerStaffID) References staff (StaffID)
		On Delete Restrict On Update Cascade;
        
-- 13. inventory
	Create Table inventory (
		InventoryID  Mediumint   Unsigned Not Null Auto_Increment,
		FilmID       Smallint    Unsigned Not Null,
		StoreID      Tinyint     Unsigned Not Null,
		LastUpdate   TimeStamp   Not Null Default Current_TimeStamp On Update Current_TimeStamp,
		Primary Key (InventroyID),
		Key idx_fk_film_id (FilmID),
		Key idx_store_id_film_id (StoreID, FilmID),
		Constraint fk_inventory_store Foreign Key (StoreID) References store (StoreID)
			On Delete Restrict On Update Cascade,
		Constraint fk_inventory_film Foreign Key (FilmID) References film (FilmID)
			On Delete Restrict On Update Cascade
	) Engine=InnoDB Default Charset=utf8;

-- 14. customer
	Create Table customer (
		CustomerID   Smallint    Unsigned Not Null Auto_Increment,
		StoreID      Tinyint     Unsigned Not Null,
		FirstName    Varchar(50) Not Null,
		LastName     Varchar(50) Not Null,
		Email        Varchar(50) Default Null,
		AddressID    Smallint    Unsigned Not Null,
		Active       Boolean     Not Null Default True,
		CreateDate   Datetime    Not Null,
		LastUpdate   TimeStamp   Not Null Default Current_TimeStamp On Update Current_TimeStamp,
		Primary Key (CustomerID),
		Key idx_fk_store_id (StoreID),
		Key idx_fk_address_id (AddressID),
		Key idx_last_name (LastName),
		Constraint fk_customer_address Foreign Key (AddressID) References address (AddressID)
			On Delete Restrict On Update Cascade,
		Constraint fk_customer_store Foreign Key (StoreID) References store (StoreID)
			On Delete Restrict On Update Cascade
	) Engine=InnoDB Default Charset=utf8;

	Alter table customer Modify CreateDate Datetime Default Null;

-- 15. rental 
	Create Table rental (
		RentalID     Int       Not Null Auto_Increment,
		RentalDate  Datetime  Not Null,
		InventoryID  Mediumint Unsigned Not Null,
		CustomerID   Smallint  Unsigned Not Null,
		ReturnDate   Datetime  Default Null,
		StaffID      Tinyint   Unsigned Not Null,
		LastUpdate   TimeStamp Not Null Default Current_TimeStamp On Update Current_TimeStamp,
		Primary Key (RentalID),
		Unique Key (RentalDate, InventoryID, CustomerID),
		Key idx_fk_inventory_id (InventoryID),
		Key idx_fk_customer_id (CustomerID),
		Key idx_fk_staff_id (StaffID),
		Constraint fk_rental_staff Foreign Key (StaffID) References staff (StaffID)
			On Delete Restrict On Update Cascade,
		Constraint fk_rental_inventory Foreign key (InventoryID) References inventory (InventoryID)
			On Delete Restrict On Update Cascade,
		Constraint fk_rental_customer Foreign Key (CustomerID) References customer (CustomerID)
			On Delete Restrict On Update Cascade
	) Engine=InnoDB Default Charset=utf8;
 

-- 16. payment
	Create Table payment (
		PaymentID   Smallint     Unsigned Not Null Auto_Increment,
		CustomerID  Smallint     Unsigned Not Null,
		StaffID     Tinyint      Unsigned Not Null,
		RentalID    Int          Default Null,
		Amount      Decimal(5,2) Not Null,
		PaymentDate Datetime     Not Null,
		LastUpdate  TimeStamp    Not Null Default Current_TimeStamp On Update Current_TimeStamp,
		Primary Key (PaymentID),
		Key idx_fk_staff_id (StaffID),
		key idx_fk_customer_id (CustomerID),
		Constraint fk_payment_rental Foreign Key (RentalID) References rental (RentalID)
			On Delete Restrict On Update Cascade,
		Constraint fk_payment_customer Foreign Key (CustomerID) References customer (CustomerID)
			On Delete Restrict On Update Cascade,
		Constraint fk_payment_staff Foreign Key (StaffID) References staff (StaffID)
			On Delete Restrict On Update Cascade
	) Engine=InnoDB Default Charset=utf8;

	Alter table payment Modify PaymentDate Datetime Default Null;

-- Triggers

	-- 1. customer_create_date trigger
	Delimiter $$
	Create Trigger customer_create_date
	Before Insert On customer
	For each row
	Begin
		set New.CreateDate = Current_TimeStamp;
	End$$
	Delimiter ;

	-- 2. payment_date trigger
	Delimiter $$
	Create Trigger payment_date
	Before Insert On payment
	For each row
	Begin
		set New.PaymentDate = Current_TimeStamp;
	End$$
	Delimiter ;

	-- 3. rental_date trigger
	Delimiter $$
	Create Trigger rental_date
	Before Insert On rental
	For each row
	Begin
		set New.RentalDate = Current_TimeStamp;
	End$$
	Delimiter ;

	-- 4. ins_film trigger
	Delimiter $$
	Create Trigger ins_film
	After Insert On film
	For each row
	Begin
		Insert into film_text(FilmID, Title, Description) Values(New.FilmID, New.Title, New.Description);
	End$$
	Delimiter ;

	-- 5. upd_film trigger
	Delimiter $$
	Create Trigger upd_film
	After Update On film
	For each row
	Begin
		If (Old.Title != New.Title) Or (Old.FilmID != New.FilmID) Or (Old.Description != New.Description)
		Then
			Update film_text
			Set FilmID = New.FilmID,
				Title = New.Title,
				Description = New.Description
			Where FilmID = Old.FilmID;
		End If;
	End$$
	Delimiter ;

	-- 6. del_film trigger
	Delimiter $$
	Create Trigger del_film
	After Delete On film
	For each row
	Begin
		Delete From film_text Where FilmID = Old.FilmID;
	End$$
	Delimiter;

-- Stored Functions:
	
	-- 1. get_customer_balance.
	Delimiter $$
	Create Function get_customer_balance(p_customer_id Int, p_effective_date Datetime) 
		Returns Decimal(5, 2)
		Deterministic
		Reads SQL Data
	Begin
		Declare v_rentfees Decimal(5, 2);
		Declare v_overfees Integer;
		Declare v_payments Decimal(5, 2);

		Select IFNULL(Sum(film.RentalRate), 0) Into v_rentfees
		From film, inventory, rental
		Where film.FilmID = inventory.FilmID
			And inventory.InventoryID = rental.InventoryID
			And rental.RentalDate <= p_effective_date
			And rental.CustomerID = p_customer_id;

		Select IFNULL(
				Sum(
					If((To_Days(rental.ReturnDate) - To_Days(rental.RentalDate)) > film.RentalDuration, 
						((To_Days(rental.ReturnDate) - To_Days(rental.RentalDate)) - film.RentalDuration), 0)),
				0)
				Into v_overfees
		From film, rental, inventory
		Where file.FilmID = inventory.FilmID
			And inventory.InventoryID = rental.InventoryID
			And rental.RentalDate <= p_effective_date
			And rental.CustomerID = p_customer_id;
		
		Select IFNULL(Sum(payment.Amount), 0) Into v_payments
		From payment
		Where payment.PaymentDate <= p_effective_date
			And payment.CustomerID = p_customer_id;

		Return v_rentfees + v_overfees - v_payments;

	End $$
	Delimiter ; 

	-- 2. inventory_held_by_customer function
	Delimiter $$
	Create Function inventory_held_by_customer(p_inventory_id Int)
	Returns Int
	Reads SQL Data
	Begin
		Declare v_customer_id Int;
		Declare Exit Handler For Not Found Return Null;

		Select CustomerID into v_customer_id
		From rental 
		Where ReturnDate is Null And InventoryID = p_inventory_id;

		Return v_customer_id;
	End$$
	Delimiter ;

	-- 3. inventory_in_stock function
	Delimiter $$
	Create Function inventory_in_stock(p_inventory_id Int)
	Returns Boolean
	Reads SQL Data
	Begin
		Declare v_rentals Int;
		Declare v_out Int;

		Select Count(RentalID) into v_rentals
		From rental
		Where InventoryID = p_inventory_id;

		If v_rentals = 0 Then
			Return True;
		End If;

		Select Count(RentalID) Into v_out
		From inventory Left Join rental Using(InventoryID)
		Where inventory.InventoryID = p_inventory_id 
			And rental.ReturnDate Is Null;

		If v_out > 0 Then
			Return False;
		Else
			Return True;
		End If;
	End$$
	Delimiter ; 

  -- Stored Procedures
  -- 1. film_in_stock sp
  Delimiter $$
  Create Procedure film_in_stock(In p_film_id Int, In p_store_id Int, Out p_film_count Int)
  Reads SQL Data
  Begin
  	Select InventoryID
  	From inventory 
  	Where FilmID = p_film_id
  		And StoreID = p_store_id
  		And inventory_in_stock(InventoryID);

  	Select Count(InventoryID)
  	From inventory
  	Where FilmID = p_film_id
  		And StoreID = p_store_id
  		And inventory_in_stock(InventoryID)
  	Into p_film_count;

  End $$
  Delimiter ;

  -- 2. film_not_in_stock sp
  Delimiter $$
  Create Procedure film_not_in_stock(In p_film_id Int, In p_store_id Int, Out p_film_count Int)
  Reads SQL Data
  Begin 
  	Select InventoryID
  	From inventory
  	Where FilmID = p_film_id
  		And StoreID = p_store_id
  		And Not inventory_in_stock(InventoryID);

  	Select Count(InventoryID)
  	From inventory
  	Where FilmID = p_film_id
  		And StoreID = p_store_id
  		And Not inventory_in_stock(InventoryID)
  	Into p_film_count;

  End $$
  Delimiter ;

  -- 3. rewards_report sp
  Delimiter $$
  Create Procedure rewards_report(
  		In min_monthly_purchases TinyInt Unsigned, 
  		In min_dollar_amount_purchased Decimal(10, 2) Unsigned,
  		Out rewardees_count Int
  		)
  Language SQL
  Not Deterministic
  Reads SQL Data
  SQL Security Definer
  Comment 'Provides a customizable report on best customers'

  proc: Begin

  	 Declare last_month_start Date;
  	 Declare last_month_end Date;

  	 If min_monthly_purchases = 0 Then
  	 	Select "Minimum monthly purchases must be > 0";
  	 	Leave proc;
  	 End If;

  	 If min_dollar_amount_purchased = 0 Then
  	 	Select "Minimum monthly dollar amount purchased must be > 0";
  	 	Leave proc;
  	 End If;

  	 Set last_month_start = Date_Sub(Current_Date(), Interval 1 Month);
  	 Set last_month_start = Str_to_Date(
  	 							Concat(Year(last_month_start), "-", Month(last_month_start), "-01"),
  	 							-- Concat("2006", "-", "2", "-01"), // to check with provided data
  	 							"%Y-%m-%d"
  	 						);
  	 Set last_month_end = Last_Day(last_month_start);

  	 Select last_month_start, last_month_end;

  	 Create Temporary Table tempCustomer(CustomerID SmallInt Unsigned Not Null Primary Key);

  	 Insert into tempCustomer (CustomerID)
  	 	Select p.CustomerID
  	 	From payment as p
  	 	Where Date(p.PaymentDate) Between last_month_start And last_month_end
  	 	Group By CustomerID
  	 	Having
  	 		Sum(p.Amount) > min_dollar_amount_purchased
  	 		And Count(CustomerID) > min_monthly_purchases;

  	 	Select Count(CustomerID) From tempCustomer Into rewardees_count;

  	 	Select c.*
  	 	From tempCustomer As t
  	 	Inner join customer As c
  	 	On t.CustomerID = c.CustomerID;

  	 	Drop table tempCustomer;
  	End $$
  	Delimiter ;

 -- views:
 -- 1. actor_info
 Create 
 	Definer=Current_User
 	SQL Security Invoker
 	View actor_info
 As
 Select 
 	a.ActorID,
 	a.FirstName,
 	a.LastName,
 	Group_Concat(
 		Distinct
 		Concat(c.Name, " : ",
 				(
 					Select 
 						Group_Concat(f.Title Order by f.Title Separator ", ")
 						From sakila.film f
 						Inner Join sakila.film_category fc On f.FilmID = fc.FilmID
 						Inner Join sakila.film_actor fa On f.FilmID = fa.FilmID
 						Where fc.CategoryID = c.categoryID And fa.ActorID = a.ActorID
 				)
 			  )
 		Order By c.Name
 		Separator "; "
 		)
 	As film_info
 	From sakila.actor a
 	Left Join sakila.film_actor fa On a.ActorID = fa.ActorID
 	Left Join sakila.film_category fc On fa.FilmID = fc.FilmID
 	Left Join sakila.Category c On fc.CategoryID = c.CategoryID
 	Group By 
 		a.ActorID,
 		a.FirstName,
 		a.LastName;


-- 2. customer_list view
Create View customer_list
As
Select 
	c.CustomerID as ID,
	Concat(c.FirstName, " ", c.LastName) as Name,
	a.PostalCode as zipCode,
	a.Address,
	ct.City,
	cu.Country,
	If(cu.Active, "active", "inactive") as status,
	cu.StoreID as store
From customer c
Left Join address a On c.AddressID = a.AddressID
Left Join city ct On a.CityID = ct.CityID
Left Join country cu On ct.CountryID = cu.CountryID
Group By Name;

-- 3. film_list view
Create View film_list
As
Select
	f.FilmID as FilmID,
	f.Title as Title,
	f.Description as Description,
	c.Name as category,
	f.RentalRate as price,
	f.Length as length,
	f.Rating as rating,
	Group_Concat(Concat(a.FirstName, " ", a.LastName) Separator ", ") as Actors
From film f
Left Join film_actor fa On f.FilmID = fa.FilmID
Left Join actor a On fa.ActorID = a.ActorID
Left Join film_catory fc On f.FilmID = fc.FilmID
Left Join category c On fc.CategoryID = c.CategoryID
Group By f.FilmID, c.Name;

-- 4. nicer_but_slower_film_list view
Create View nicer_but_slower_film_list
As
Select
	f.FilmID as FilmID,
	f.Title as Title,
	f.Description as Description,
	c.Name as Category,
	f.RentalRate as Price,
	f.Length as Length,
	f.Rating as Rating,
	Group_Concat(
		Concat(
				Upper(Substr(a.FirstName, 1, 1)),
				Lower(Substr(a.FirstName, 2, Length(a.FirstName))),
				" ",
				Upper(Substr(a.LastName, 1, 1)),
				Lower(Substr(a.LastName, 2, Length(a.LastName)))
			) Separator ", "
		) As Actors
	-- Group_Concat (
	-- 		Concat (
	-- 		Concat(
	-- 			UCASE(SUBSTR(a.FirstName,1,1)), 
	-- 			LCASE(SUBSTR(a.FirstName,2,Length(a.FirstName))),
	-- 			" ",
	-- 			Concat(
	-- 				UCASE(SUBSTR(a.LastName,1,1)), 
	-- 				LCASE(SUBSTR(a.LastName,2,Length(a.LastName)))
	-- 			)
	-- 			)
	-- 		) Separator ", " ) as Actorss
	From film f
	Left Join film_actor fa On f.FilmID = fa.FilmID
	Left Join actor a On fa.ActorID = a.ActorID
	Left Join film_category fc On f.FilmID = fc.FilmID
	Left Join category c On fc.CategoryID = c.CategoryID
	Group By f.FilmID, c.Name;

	-- sales_by_film_category view
	Create View sales_by_film_category
	As
	Select c.Name, Sum(p.Amount) as totalSale
	From payment p
	Inner Join rental r On p.RentalID = r.RentalID
	Inner Join inventory i On r.InventoryID = i.InventoryID
	Inner Join film_category fc On i.FilmID = fc.FilmID
	Inner Join category c On fc.CategoryID = c.CategoryID
	Group By c.Name
	Order by totalSale Desc;

-- 5. sales_by_store view
Create View sales_by_store
As 
Select 
	s.StoreID as StoreID, 
	sum(p.Amount) as TotalSale,
	sf.StaffID as ManagerID,
	Concat(sf.FirstName, " ", sf.LastName) as ManagerName,
	a.Address as Address,
	a.District as District,
	a.PostalCode as zipCode,
	ct.City as City,
	cu.Country as Country
From payment p
Inner Join rental r On p.RentalID = r.RentalID
Inner Join inventory i On r.InventoryID = i.InventoryID
Inner Join store s On i.StoreID = s.StoreID
Inner Join address a On s.AddressID = a.AddressID
Inner Join city ct On  a.CityID = ct.CityID
Inner Join country cu On ct.CountryID = cu.CountryID
Inner Join staff sf On s.ManagerID = sf.StaffID;

-- 6. staff_list view
Create View staff_list
As 
Select 
	s.StaffID as StaffID,
	Concat(s.FirstName, " ", s.LastName) as Name,
	a.Address as Address,
	a.District as District,
	a.PostalCode as zipCode,
	ct.City as City,
	cu.Country as Country
From staff s
Inner Join address a On s.AddressID = a.AddressID
Inner Join city ct On a.CityID = ct.CityID
Inner Join country cu On ct.CountryID = cu.CountryID; 


