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