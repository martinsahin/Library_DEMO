/*


---2) CREATING FUNCTION
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
