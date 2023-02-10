/* 

--------------------------------------------------------------------------------------------------
WE ARE GOING TO INSERT DATA SEEDS FOR TABLES. WE WILL NEED TO TEST/DEMONSTRATE THE INTEGRITY */
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
