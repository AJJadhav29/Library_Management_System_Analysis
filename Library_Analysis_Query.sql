
SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;


-- Project Task

-- CRUD Operation

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category,rental_price,status, author, publisher) 
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address

UPDATE members 
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE 
FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with issued_emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'; 

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
	issued_emp_id,
	COUNT(issued_id) as total_book_count
FROM issued_status
GROUP BY 1
HAVING COUNT(issued_id)>1;


-- CTAS(Create Table as Select)
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE book_counts 
AS
SELECT 
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id)
FROM books b 
JOIN issued_status ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;

SELECT * FROM book_counts;

-- Data Analysis
-- Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by Category:

SELECT 
	b.category,
	SUM(b.rental_price) as total_rental_price,
	COUNT(*) as count_of_books
FROM books b 
JOIN issued_status ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1;

-- Task 9: List Members Who Registered in the Last 180 Days:

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

INSERT INTO members(member_id,member_name,member_address,reg_date)
VALUES
('C117','John Smith','466 Mercer St','2025-03-05'),
('C212','Jose Boss','40 Journal Square','2025-09-17');

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT 
	e1.*,
	e2.emp_id,
	e2.emp_name as manager
FROM employees as e1 
JOIN branch as b
ON b.branch_id = e1.branch_id
JOIN employees as e2
ON b.manager_id = e2.emp_id;

-- Task 11: Create a Table of Books with Rental Price Above a Certain Threshold $7:
CREATE TABLE books_price_greater_7
AS
SELECT * FROM books
WHERE rental_price > 7;

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT ist.issued_book_isbn, ist.issued_book_name
FROM issued_status as ist
LEFT JOIN return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL;

---------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;

-- Advanced SQL Operations

/*Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.*/

-- issued_status == members == books == return_status (need to join this)
-- filter books which is return
-- overdue > 30


SELECT ist.issued_member_id,
		m.member_name,
		b.book_title,
		ist.issued_date,
		(current_date-ist.issued_date) AS over_due_days
FROM members as m
JOIN issued_status as ist
ON ist.issued_member_id = m.member_id
JOIN books as b
ON b.isbn = ist.issued_book_isbn
LEFT JOIN return_status rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL AND (current_date-ist.issued_date)>30
ORDER BY 1

/*Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).*/

-- We can do it manually or using store procedure(easier is the stored procedure)

-- The manual way

SELECT * FROM issued_status
WHERE issued_status.issued_book_isbn = '978-0-451-52994-2';

SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-451-52994-2';

SELECT * FROM return_status
WHERE issued_id = 'IS130';

INSERT INTO return_status(return_id,issued_id,return_date,book_quality)
VALUES ('RS128','IS130',CURRENT_DATE,'Good');


UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-451-52994-2';


-- Now using Store Procedure

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(20),p_issued_id VARCHAR(15),p_book_quality VARCHAR(15))
LANGUAGE plpgsql
AS $$
DECLARE
	v_isbn VARCHAR(25);
	v_book_name VARCHAR(100);
BEGIN

	-- Before updating into books table need to get book isbn
	SELECT issued_book_isbn,
		issued_book_name
			INTO
			v_isbn,
			v_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id;
	
	-- Inserting into return_status table
	INSERT INTO return_status(return_id,issued_id,return_date,book_quality)
	VALUES(p_return_id,p_issued_id,CURRENT_DATE,p_book_quality);

	-- Updated into books table
	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'Thank you for returning book: %', v_book_name; 
END;
$$

-- Testing Function 
SELECT * FROM issued_status
WHERE issued_id = 'IS140';

SELECT * FROM return_status
WHERE issued_id = 'IS140'

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM books
WHERE isbn = '978-0-330-25864-8';

CALL add_return_records('RS138','IS135','Good');

DELETE 
FROM return_status
WHERE return_id = 'RS125';


CALL add_return_records('RS125','IS140','Damaged');

/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.*/

CREATE TABLE branch_report
AS
	SELECT 
		b.branch_id,
		b.manager_id,
		SUM(bk.rental_price) as total_revenue,
		COUNT(ist.issued_id) as no_of_book_issued,
		COUNT(rs.return_id) as no_of_book_returned
	FROM issued_status as ist
	JOIN employees as e
	ON e.emp_id = ist.issued_emp_id
	JOIN branch as b
	ON b.branch_id = e.branch_id
	LEFT JOIN return_status as rs
	ON rs.issued_id = ist.issued_id
	JOIN books as bk
	ON bk.isbn = ist.issued_book_isbn
	GROUP BY 1,2;


SELECT * FROM branch_report;


/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.*/

CREATE TABLE active_members
AS
	SELECT * FROM members
	WHERE member_id IN (
	SELECT 
		DISTINCT issued_member_id
	FROM issued_status
	WHERE issued_date >= CURRENT_DATE - INTERVAL '2 month')

SELECT * FROM active_members;

/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.*/


SELECT 
	e.emp_name,
	b.*,
	COUNT(ist.issued_id) as no_of_book_issued
FROM issued_status as ist
JOIN employees as e
ON e.emp_id = ist.issued_emp_id
JOIN branch as b
ON b.branch_id = e.branch_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 3


/* Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.*/
WITH member_damaged AS (
SELECT 
		m.member_id,
		m.member_name,
		ist.issued_book_name,
		COUNT(rs.book_quality) as no_of_damaged_book_issued
FROM members as m
JOIN issued_status as ist
ON ist.issued_member_id = m.member_id
JOIN return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.book_quality = 'Damaged'
GROUP BY 1,2,3
)

SELECT * 
FROM member_damaged
WHERE member_name IN(
	SELECT member_name
	FROM member_damaged
	GROUP BY 1
	HAVING COUNT(*) = 2
)
ORDER BY member_name;

/* Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.*/

SELECT * FROM books;

SELECT * FROM issued_status;

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(15), p_issued_member_id VARCHAR(20), p_issued_book_isbn VARCHAR(25), p_issued_emp_id VARCHAR(25))
LANGUAGE plpgsql
AS $$

DECLARE
	v_status VARCHAR(50);
	v_book_name VARCHAR(100);
BEGIN
	-- Checking if book is available

	SELECT 
		status,
		book_title
		INTO
		v_status,
		v_book_name
	FROM books
	WHERE isbn = p_issued_book_isbn;

	IF v_status = 'yes' THEN 

		INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		VALUES(p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

		UPDATE books
		SET status = 'no'
		WHERE isbn = p_issued_book_isbn;
		
		RAISE NOTICE 'Book records added successfully for book isbn: %', p_issued_book_isbn;
		
	ELSE 
		RAISE NOTICE 'Sorry this book % is currently unavailable', v_book_name;
	END IF;
		
END
$$

SELECT * FROM books WHERE isbn = '978-0-553-29698-2';
SELECT * FROM books WHERE isbn = '978-0-375-41398-8';

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

/* Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
The table should include: The number of overdue books. 
The total fines, with each day's fine calculated at $0.50. 
The number of books issued by each member. 
The resulting table should show: Member ID Number of overdue books Total fines*/

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;

-- WRONG
CREATE TABLE overdue_book
AS

SELECT 
	m.member_id,
	COUNT((CASE 
			WHEN rs.return_date IS NULL THEN (CURRENT_DATE-ist.issued_date)
			ELSE (rs.return_date-ist.issued_date)
		END)>30) AS no_of_overdue_books,
	SUM((CASE 
			WHEN rs.return_date IS NULL THEN (CURRENT_DATE-ist.issued_date)
			ELSE (rs.return_date-ist.issued_date)
		END)-30) as fine_collected,
	COUNT(ist.issued_id) AS total_books_issued
FROM members as m
JOIN issued_status as ist
	ON ist.issued_member_id = m.member_id
LEFT JOIN return_status as rs
	ON rs.issued_id = ist.issued_id
WHERE ( 
		CASE
		WHEN rs.return_date IS NULL THEN (CURRENT_DATE-ist.issued_date)
		ELSE (rs.return_date-ist.issued_date)
		END)>30
GROUP BY 1



---------------------------------

SELECT 
	m.member_id,
	COUNT(ist.issued_id) as no_of_book_issued,
	COUNT((CURRENT_DATE - ist.issued_date)-30) AS no_of_overdue_days, 
	COUNT((CURRENT_DATE - ist.issued_date)-30)*0.50 AS fine_collected
FROM members as m 
JOIN issued_status as ist 
	ON ist.issued_member_id = m.member_id 
JOIN books as bk 
	ON bk.isbn = ist.issued_book_isbn 
LEFT JOIN return_status as rs 
	ON rs.issued_id = ist.issued_id 
WHERE rs.return_date IS NULL AND ((CURRENT_DATE - ist.issued_date)-30 )>0 
GROUP BY 1



SELECT m.member_id,
	COUNT(ist.issued_id)
FROM members as m
JOIN issued_status as ist
ON ist.issued_member_id = m.member_id
GROUP BY 1