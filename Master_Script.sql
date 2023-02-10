/*

----------------------------------------
CREATE SCRIPTS FOR THE SET OF TABLES BELOW FOR LIBRARY CHECK-OUT SYSTEM AS DESCRIBED IN THE TASK.
DATABASE NAME ASSIGNED AS "LIBRARY_DB"
----------------------------------------

*/


/*----- FOR THE INITIAL STEP WE NEED TO CREATE A DATABASE BY CHECKING IF DATABASE ALREADY EXIST. -----*/
USE MASTER
IF  DB_ID ('Library_DB') IS NOT NULL
	BEGIN
		ALTER DATABASE LIBRARY_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE
		DROP DATABASE Library_DB 
	END
GO

/*----------------------------------------------
------CREATING DATABASE FOR THE TASK-----------
----------------------------------------------*/


CREATE DATABASE Library_DB
GO
USE Library_DB
GO


/*----- HERE WE CREATE OUR SCHEMA BASED ON THE CONSEPTIONAL DESIGN AND WE SEED THE TABLES FOR TESTING PURPOSE -----*/

/* NOTES
	- ALL TABLES PRIMARY KEYS ARE ALSO IDENTITY COLUMN SO IT CREATES ID NUMBERS AS DATA INSERTED
	- STRING DATA TYPES ASSIGN AS ANSI STANDARD OFF FOR LOWER METADATA. IT CAN BE CHANGE LATER IF NEEDED
	
*/


/*----1)___CREATING TABLES
---------------------------------------------------------------
 - User TABLE ---------- IN THIS TABLE LIBRARY USERS WILL BE STORED WITH THEIR FULL NAME AND CONTACT INFORMATION
*/


CREATE TABLE [User] (
	UserID			INT				PRIMARY KEY		IDENTITY(1,1),			
	FirstName		VARCHAR(50)		NOT NULL,								
	LastName		VARCHAR(50)		NOT NULL,
	Email			VARCHAR(100)	NOT NULL,
	PhoneNumber		VARCHAR(10)		NOT NULL,								
	[Address]		VARCHAR(100)	NOT NULL
);
GO


-- RefAuthor TABLE ------- ALL AUTHORS WILL BE STORED IN THIS TABLE

CREATE TABLE [RefAuthor] (
	AuthorID		INT				PRIMARY KEY		IDENTITY(1,1),
	AuthorName		VARCHAR(100)	NOT NULL
);
GO

-- RefBookTitle TABLE----- ALL UNIQUE BOOK TITLES WILL BE STORED IN THIS TABLE

CREATE TABLE [RefBookTitle] (
	BookTitleID			INT				PRIMARY KEY		IDENTITY,
	BookTitle			VARCHAR(200)	NOT NULL,
	ISBN				BIGINT			NOT NULL,
	AuthorID			INT				NOT NULL,
	CONSTRAINT FK_RefBookTitle_AuthorID FOREIGN KEY (AuthorID) REFERENCES [RefAuthor](AuthorID)
);
GO

 
-- Book TABLE------------- ALL PHYSICAL COPIES WILL BE STORED IN THIS TABLE

CREATE TABLE [Book] (
	BookID				INT PRIMARY KEY IDENTITY,
	BookTitleID			INT NOT NULL,
	CONSTRAINT FK_Book_BookTitleID FOREIGN KEY (BookTitleID) REFERENCES [RefBookTitle](BookTitleID)
);
GO


--UserBookLoan TABLE--------- TABLE FOR CHECKOUT 

CREATE TABLE UserBookLoan (
	LoanID				INT IDENTITY,
	UserID				INT NOT NULL,
	BookID				INT NOT NULL,
	CheckOutDate		DATE NOT NULL,
	DueDate				DATE NOT NULL,
	ReturnedDate		DATE,
	CONSTRAINT FK_User_UserID FOREIGN KEY (UserID) REFERENCES [User](UserID),
	CONSTRAINT FK_Book_BookID FOREIGN KEY (BookID) REFERENCES Book(BookID)
);
GO



/* WE ARE GOING TO INSERT DATA SEEDS FOR TABLES. WE WILL NEED TO TEST/DEMONSTRATE THE INTEGRITY */
--------------------------------------------------------------------------------------------------


INSERT INTO RefAuthor (AuthorName)			
	VALUES ('Marcel Proust'),
			('James Joyce'),
			('Miguel de Cervantes'),
			('Gabriel Garcia Marquez'),
			('F. Scott Fitzgerald'),
			('Herman Melville'),
			('Leo Tolstoy'),
			('William Shakespeare'),
			('Homer'),
			('Gustave Flaubert'),
			('Dante Alighieri')
			;
GO

/* WE WILL INSERT SOME DUPLICATE BOOKS ON PURPOSE*/

INSERT INTO RefBookTitle (BookTitle, ISBN, AuthorID)
	VALUES	('In Search of Lost Time',			9780679600060,	1),
			('In Search of Lost Time',			9780679600060,	1),
			('In Search of Lost Time',			9780679600060,	1),
			('Ulysses',							9780330352291,	2),
			('Ulysses',							9780330352291,	2),
			('Don Quixote',						9788497403573,	3),
			('Don Quixote',						9788497403573,	3),
			('Don Quixote',						9788497403573,	3),
			('Don Quixote',						9788497403573,	3),
			('One Hundred Years of Solitude',	9780141184999,	4),
			('One Hundred Years of Solitude',	9780141184999,	4),
			('The Great Gatsby',				9798409130329,	5),
			('The Great Gatsby',				9798409130329,	5),
			('The Great Gatsby',				9798409130329,	5),
			('The Great Gatsby',				9798409130329,	5),
			('The Great Gatsby',				9798409130329,	5),
			('Moby Dick',						9781840228304,	6),
			('War and Peace',					9780486816432,	7),
			('Hamlet',							9780486816432,	8),
			('Hamlet',							9780486816432,	8),
			('Hamlet',							9780486816432,	8),
			('Hamlet',							9780486816432,	8),
			('The Odyssey',						9780312866693,	9),
			('Madame Bovary',					9783649636397,	10),
			('The Divine Comedy',				9783111168104,	11)
			;
GO

INSERT INTO [User] (FirstName, LastName, Email, PhoneNumber, [Address])
	VALUES	('KEVIN',	'SMITH',	'K.SMITH@EMAIL.COM',	5417543010,		'USA'),
			('BILL',	'TAYLOR',	'B.TAYLOR@EMAIL.COM',	6843745905 ,	'USA'),	
			('JOHN',	'ANDERSON', 'J.ANDERSON@EMAIL.COM', 2376498254,		'USA'),
			('STEVE',	'ALLEN',	'S.ALLEN@EMAIL.COM',	3548863545,		'USA'),
			('SARAH',	'KING',		'S.KING@EMAIL.COM',		5326783357,		'USA'),
			('MARIE',	'GREEN',	'M.GREEN@EMAIL.COM',	5479126544,		'USA')
GO

INSERT INTO [Book] (BookTitleID)
	VALUES	(1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11) 
GO


/*---2) CREATING FUNCTION
---------------------------------------------------------------


THIS FUNCTION WILL RETURN THE DUE DATES WHEN USER (UserID) AND/OR BOOK (BookID) IS PASSED.

MULTIPLE BOOKS COULD BE ASSIGNED TO ONE USER. THEREFORE WE MAY NEED TO RETURN A LIST. 
HENCE, TABLE-VALUED FUNCTION CREATED.
*/


CREATE FUNCTION ufn_GetDueDate (@UserID INT, @BookID INT)
		RETURNS @retDueDates TABLE								--	TempTable created on the go
		(
			BookTitle			VARCHAR(200)	NOT NULL,		--   Columns returned by the function
			DueDate				DATE			NOT NULL		
		) 
		AS
		BEGIN

					/* We have 3 circumstances with 2 parameters. 		
					
					Case 1 = UserID and BookID vales are BOTH inserted
					Case 2= UserID is inserted but BookID is NOT
					Case 3= UserID is NOT inserted but BookID is
					
					*/

		 IF @UserID IS NOT NULL AND @BookID IS NOT NULL					--	Case 1
			BEGIN
			INSERT @retDueDates
			SELECT REFB.BookTitle ,U.DueDate 
				FROM RefBookTitle AS REFB, 
					UserBookLoan AS U,
					Book AS B 
					WHERE B.BookID=U.BookID AND REFB.BookTitleID=B.BookTitleID 
							AND U.UserID=@UserID AND B.BookID=@BookID
							AND U.ReturnedDate IS NULL
		
		END		
				
				 ELSE IF @UserID IS NOT NULL AND @BOOKid IS NULL		--	Case 2
			BEGIN
			INSERT @retDueDates
			SELECT REFB.BookTitle ,U.DueDate 
				FROM RefBookTitle AS REFB, 
					UserBookLoan AS U,
					Book AS B 
					WHERE B.BookID=U.BookID AND REFB.BookTitleID=B.BookTitleID 
					AND U.UserID=@UserID
					AND U.ReturnedDate IS NULL
		END
				
				ELSE IF @UserID IS  NULL AND @BOOKid IS NOT NULL		--	Case 3
			BEGIN
			INSERT @retDueDates
			SELECT REFB.BookTitle ,U.DueDate 
				FROM RefBookTitle AS REFB, 
					UserBookLoan AS U,
					Book AS B 
					WHERE B.BookID=U.BookID AND REFB.BookTitleID=B.BookTitleID 
					AND B.BookID=@BookID
					AND U.ReturnedDate IS NULL
		END
		RETURN 
		END;
GO


/*---3)___CREATING STORED PROCEDURE
---------------------------------------------------------------


THIS STORED PROCEDURE CREATED FOR CHECK OUT.

WHEN USER (UserID) AND BOOK (BookID) IS PASSED, DUE DATE IS CREATED.
DUE DATE WILL BE 2 WEEKS LATER FROM THE THE DAY BOOK ASSIGNED. 

ALSO, IN ORDER TO ASSIGN THE BOOK WE NEED TO CHECK IF IT IS AVAILABLE. 
WE CHECK THE RETURNED DATE COLUMN. IF RETURNED DATE IS NULL WHICH MEANS BOOK IS NOT
AVAILABLE THEN A MESSAGE WILL APPEAR ON THE RESULTS. 

*/

CREATE PROCEDURE sp_CheckOut (@UserID INT, @BookID INT)
		AS
		BEGIN
		DECLARE @DueDate DATE,	@BOOKED INT;
		
			SET @BOOKED = (SELECT COUNT(*) FROM UserBookLoan WHERE BookID=@BookID AND ReturnedDate IS NULL)
				
			IF (@BOOKED = 1)   
			BEGIN
					RAISERROR (N'THE BOOK IS NOT AVAILABLE',  10, 1 )
				   END
				ELSE
		BEGIN
		
		SET @DueDate = DATEADD(week, 2, GETDATE());
		
		INSERT INTO UserBookLoan (UserID, BookID, CheckOutDate, DueDate)
		VALUES (@UserID, @BookID, GETDATE(), @DueDate);
		
		SELECT @DueDate
		END
END;


/*---4)___QUERY:
---------------------------------------------------------------


THIS QUERY WILL GIVE A RESULT SET FOR ALL THE BOOKS THAT ARE AVAILABLE FOR CHECK OUT.

SINCE ALL BOOKS HAVE UNIQUE IDs (EVEN IF THEY ARE COMPLETELY IDENTICAL) THIS QUERY WILL 
SORT BOOK TITLES AND COUNT THEM BY CHECKING THE RETURNED DATE COLUMN IN USER BOOK LOAN TABLE.


*/

SELECT  RBT.BookTitle, COUNT(RBT.BookTitle) AS Total_Available
	FROM RefBookTitle  RBT
		INNER JOIN Book  BK 
		ON RBT.BookTitleID = BK.BookTitleID  
		WHERE BK.BookID NOT IN (SELECT BookID FROM UserBookLoan WHERE ReturnedDate IS NULL) 
		GROUP BY RBT.BookTitle
		order by Total_Available desc

/*
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
*/
/*

HERE YOU WILL FIND TESTING SCRIPTS

*/

USE Library_DB
GO


/*CHECKING DATA IN TABLES*/

/* WE WILL LOOK INTO THE TABLES THAT WERE CREATED AND SEEDED*/

SELECT * FROM Book
SELECT * FROM RefAuthor
SELECT * FROM RefBookTitle
SELECT * FROM [User]
SELECT * FROM UserBookLoan



/*TESTING STORED PROCEDURE*/

/* 
WE WILL PASS SOME DATA INTO USERBOOKLOAN TABLE BY USING STORED PROCEDURE.
IN THIS PROCEDURE EXECETUCING THE SP ASSIGN BOOKS TO THEIR USERS AND RETURNS DUE DATE WHICH IS WITHIN 2 WEEK

 */

EXEC DBO.sp_CheckOut @USERID=1, @BOOKiD=3		--USER 1 LOANS BOOK3
EXEC DBO.sp_CheckOut @USERID=3, @BOOKiD=5		--USER 3 LOANS BOOK5
EXEC DBO.sp_CheckOut @USERID=3, @BOOKiD=6		--USER 3 LOANS BOOK5
EXEC DBO.sp_CheckOut @USERID=4, @BOOKiD=10		--USER 4 LOANS BOOK10
EXEC DBO.sp_CheckOut @USERID=4, @BOOKiD=8		--USER 4 LOANS BOOK8
EXEC DBO.sp_CheckOut @USERID=4, @BOOKiD=11		--USER 4 LOANS BOOK11
EXEC DBO.sp_CheckOut @USERID=6, @BOOKiD=7		--USER 9 LOANS BOOK7


/*WE DONT HAVE STORED PROCEDURE FOR RETURNED BOOKS SO WE WILL MANUALLY RETURN SOME BOOKS FOR TEST*/

UPDATE [UserBookLoan]							--USER 4 RETURNS BOOK 8
   SET [ReturnedDate] = GETDATE()
 WHERE [UserID] = 4 AND [BookID] = 8
GO


UPDATE [UserBookLoan]							--USER 3 RETURNS BOOK 6
   SET [ReturnedDate] = GETDATE()
 WHERE [UserID] = 3 AND [BookID] = 6
GO

------------------------------------------------------

/*TESTING FUNCTION*/

SELECT * FROM [dbo].[ufn_GetDueDate] (1,3)			--GIVING DUEDATE FOR USER 1 AND BOOK 3
GO
SELECT * FROM [dbo].[ufn_GetDueDate] (NULL,3)		--GIVING DUEDATE BOOK 3
GO
SELECT * FROM [dbo].[ufn_GetDueDate] (1,null)		--GIVING DUEDATES FOR ALL BOOKS FOR USER 1
GO
SELECT * FROM [dbo].[ufn_GetDueDate] (null,null)	-- NO INPUT RETURNS NO RESULT. THIS IS ONLY CHECKING FOR ERROR HANDLING
GO