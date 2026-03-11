# Library Management System Analysis using SQL

## Summary

Developed a Library Management System Analysis project using PostgreSQL to design and analyze a relational database for managing books, members, employees, branches, issued records, and returned records. 
The project involved database creation, relationship mapping, CRUD operations, CTAS tables, stored procedures, and analytical SQL queries to evaluate library operations and generate meaningful business 
insights. Using SQL queries, I analyzed book availability, issued and returned books, branch performance, active members, overdue books, damaged returns, and employee activity. The project demonstrates 
practical skills in database design, joins, aggregation, CTEs, stored procedures, foreign keys, and business-focused SQL analysis using structured library data.

<p align="center">
  <img src="library.JPG" width="700"/>
</p>

## Project Objectives

1. Design and build a relational library database to manage books, members, branches, employees, issue transactions, and return transactions.
2. Establish relationships between tables using primary keys and foreign keys to maintain data integrity.​
3. Perform CRUD operations to manage library records such as books, members, and issue activity.​
4. Use CTAS queries to create summary tables for reporting and analysis.
5. Analyze book circulation, overdue records, active members, branch performance, and employee productivity.
6. Implement stored procedures to automate book issuing and return handling while updating book availability status.
7. Generate operational reports that support better decision-making for library management.

## Project Structure

<p align="center">
  <img src="Library_Analysis_ERD.png" width="700"/>
</p>

#### 1. Database Setup

- Created a library database structure with six main tables: branch, employees, books, members, issuedstatus, and returnstatus.
- Defined primary keys for each table and foreign key relationships linking issued records to members, books, and employees, returns to issued records and books, and employees to branches.
- Updated selected column definitions such as booktitle, status, and issuedbookname to support longer text values.
- The database design is supported by an ERD showing relationships across all major entities in the system.

```sql
-- Library Analysis P2

-- Creating Tables

DROP TABLE IF EXISTS branch;
CREATE TABLE branch(
					branch_id VARCHAR(50) PRIMARY KEY,	
					manager_id VARCHAR(50),
					branch_address VARCHAR(50),
					contact_no VARCHAR(50)
);

DROP TABLE IF EXISTS employees;
CREATE TABLE employees(
			emp_id VARCHAR(25) PRIMARY KEY,	
			emp_name VARCHAR(50),
			position VARCHAR(50),
			salary INT,
			branch_id VARCHAR(50) 
);

DROP TABLE IF EXISTS books;
CREATE TABLE books (
			isbn VARCHAR(25) PRIMARY KEY,
			book_title VARCHAR(50),
			category VARCHAR(50),
			rental_price DECIMAL(10,3),
			status VARCHAR(15),
			author VARCHAR(50),
			publisher VARCHAR(55)

);
ALTER TABLE books
ALTER COLUMN status TYPE VARCHAR(50);

ALTER TABLE books
ALTER COLUMN book_title TYPE VARCHAR(100);

DROP TABLE IF EXISTS members;
CREATE TABLE members(
			 member_id VARCHAR(20) PRIMARY KEY,
			 member_name VARCHAR(50),
			 member_address VARCHAR(75),
			 reg_date DATE

);

DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status(
				issued_id VARCHAR(15) PRIMARY KEY,
				issued_member_id VARCHAR(20), -- FK
				issued_book_name VARCHAR(25),
				issued_date DATE,
				issued_book_isbn VARCHAR(25), -- FK
				issued_emp_id VARCHAR(25) -- FK

);

ALTER TABLE issued_status
ALTER COLUMN issued_book_name TYPE VARCHAR(100);

DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status(
			return_id VARCHAR(20) PRIMARY KEY,
			issued_id VARCHAR(15), -- FK
			return_book_name VARCHAR(25),
			return_date DATE,
			return_book_isbn VARCHAR(25) -- FK

);


-- Adding FK to build relationship
-- FOR issued_status table
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_emp
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);


-- For return_status table
ALTER TABLE return_status
ADD CONSTRAINT fk_issued
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_return_books
FOREIGN KEY (return_book_isbn)
REFERENCES books(isbn);

-- For employees table
ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);
```

#### 2. Project Description

The project uses structured data files for books, employees, branches, issued status, return status, and members, along with SQL scripts for schema creation and analysis. The attached files include Library_Analysis_Schema_P2.sql, Library_Analysis_Query.sql, books.csv, employees.csv, branch.csv, issued_status.csv, return_status.csv, members.csv, and the ERD image.

Main entities included in the project are:
- Books – Stores ISBN, title, category, rental price, status, author, and publisher.
- Members – Stores member ID, name, address, and registration date.
- Employees – Stores employee ID, name, position, salary, and branch assignment.
- Branch – Stores branch ID, manager ID, branch address, and contact number.
- Issued Status – Tracks which member issued which book, issue date, and responsible employee.
- Return Status – Tracks return transactions linked to issued records and returned books.

#### 3. CRUD Operations

The project includes practical CRUD tasks to simulate common library operations. These tasks include inserting a new book record, updating a member’s address, deleting an issued record, retrieving books issued by a specific employee, and identifying members who issued more than one book.

- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category,rental_price,status, author, publisher) 
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```

- Task 2: Update an Existing Member's Address

```sql
UPDATE members 
SET member_address = '125 Main St'
WHERE member_id = 'C101';
```

- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE 
FROM issued_status
WHERE issued_id = 'IS121';
```

- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with issued_emp_id = 'E101'.

```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';
```

- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT 
	issued_emp_id,
	COUNT(issued_id) as total_book_count
FROM issued_status
GROUP BY 1
HAVING COUNT(issued_id)>1;
```

#### 4. CTAS

The project uses Create Table As Select statements to build reusable reporting tables from query results. These CTAS tables support summary reporting and simplify further analysis.
​
CTAS tables created in the project include:
- bookcounts to count how many times each book has been issued.
- bookspricegreater7 to store books with rental prices above a selected threshold.
- branchreport to summarize branch-level book issues, returns, and total rental revenue.
- activemembers to identify members who issued at least one book in the last two months.
- An overdue-books table concept to calculate overdue counts and fines for members with delayed returns.

Task: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
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
```

#### 5. Data Analysis

The SQL analysis focuses on operational and performance-based questions across the library system. Queries examine books by category, category-level rental income, new member registrations, employee and branch performance, overdue books, damaged returns, and top issue-processing employees.

- Task 1: Retrieve All Books in a Specific Category:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

- Task 2: Find Total Rental Income by Category:

```sql
SELECT 
	b.category,
	SUM(b.rental_price) as total_rental_price,
	COUNT(*) as count_of_books
FROM books b 
JOIN issued_status ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1;
```

- Task 3: List Members Who Registered in the Last 180 Days:

```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

- Task 4: List Employees with Their Branch Manager's Name and their branch details:

```sql
SELECT 
	e1.*,
	e2.emp_id,
	e2.emp_name as manager
FROM employees as e1 
JOIN branch as b
ON b.branch_id = e1.branch_id
JOIN employees as e2
ON b.manager_id = e2.emp_id;
```

- Task 5: Create a Table of Books with Rental Price Above a Certain Threshold $7:

```sql
CREATE TABLE books_price_greater_7
AS
SELECT * FROM books
WHERE rental_price > 7;
```

- Task 6: Retrieve the List of Books Not Yet Returned

```sql
SELECT ist.issued_book_isbn, ist.issued_book_name
FROM issued_status as ist
LEFT JOIN return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL;
```

- Task 7: Identify Members with Overdue Books Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
	-- issued_status == members == books == return_status (need to join this)
	-- filter books which is return
	-- overdue > 30

```sql
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
ORDER BY 1;
```

- Task 8: Update Book Status on Return Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
	-- We can do it manually or using store procedure(easier is the stored procedure)

```sql
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
```

- Task 9: Branch Performance Report Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
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
```
  
- Task 10: CTAS: Create a Table of Active Members Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql
CREATE TABLE active_members
AS
	SELECT * FROM members
	WHERE member_id IN (
	SELECT 
		DISTINCT issued_member_id
	FROM issued_status
	WHERE issued_date >= CURRENT_DATE - INTERVAL '2 month')

SELECT * FROM active_members;
```

- Task 11: Find Employees with the Most Book Issues Processed Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
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
```

- Task 12: Identify Members Issuing High-Risk Books Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.

```sql
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
```

- Task 13: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
	The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
	The procedure should first check if the book is available (status = 'yes'). 
	If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
	If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql
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
```

- Task 14: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines. Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
	The table should include: The number of overdue books. 
	The total fines, with each day's fine calculated at $0.50. 
	The number of books issued by each member. 
	The resulting table should show: Member ID Number of overdue books Total fines

```sql
DROP TABLE IF EXISTS overdue_book;
CREATE TABLE overdue_book
AS
SELECT 
	m.member_id,
	SUM(CASE 
			WHEN (CASE 
                    WHEN rs.return_date IS NULL 
                    THEN CURRENT_DATE - ist.issued_date
                    ELSE rs.return_date - ist.issued_date
                END)>30
					THEN 1
					ELSE 0 
					END
					) AS no_of_overdue_books,
	 SUM(
        CASE 
            WHEN 
            (
                CASE 
                    WHEN rs.return_date IS NULL 
                    THEN CURRENT_DATE - ist.issued_date
                    ELSE rs.return_date - ist.issued_date
                END
            ) > 30
            THEN (
                (
                    CASE 
                        WHEN rs.return_date IS NULL 
                        THEN CURRENT_DATE - ist.issued_date
                        ELSE rs.return_date - ist.issued_date
                    END
                ) - 30
            ) * 0.50
            ELSE 0
        END
    ) as fine_collected,
	COUNT(ist.issued_id) AS total_books_issued
FROM members as m
JOIN issued_status as ist
	ON ist.issued_member_id = m.member_id
LEFT JOIN return_status as rs
	ON rs.issued_id = ist.issued_id
GROUP BY 1;

SELECT * FROM overdue_book;
```

#### 6. Findings & Reports

The analysis shows that the database can be used not only for transaction management but also for performance monitoring and operational reporting. The queries support branch-level revenue tracking, employee activity measurement, overdue monitoring, and member engagement analysis.
​
Main reports generated in the project include:
- Branch Performance Report – Shows branch ID, manager ID, books issued, books returned, and total rental revenue.
- Book Issue Summary Report – Counts how often each book has been issued.
- Active Members Report – Identifies members with recent issue activity.
- Overdue Books Report – Highlights members with overdue books and supports fine calculation logic.
- Employee Performance Report – Identifies employees with the highest number of processed book issues.
- Unreturned Books Report – Lists books that remain issued without a recorded return date.
- Damaged Return Monitoring Report – Identifies members linked to repeated damaged return patterns.
These reports help reveal circulation trends, staff contribution, and risk areas such as overdue books and damaged returns. They also show how transactional data can be transformed into actionable operational insight through SQL.

#### 7. Conclusion

The Library Management System Analysis project demonstrates how PostgreSQL can be used to build and analyze a complete relational database for a real-world business scenario. Through schema design, foreign key relationships, CRUD operations, CTAS tables, stored procedures, and analytical queries, the project turns raw library records into useful insights for tracking performance, improving operations, and supporting better library management decisions.

