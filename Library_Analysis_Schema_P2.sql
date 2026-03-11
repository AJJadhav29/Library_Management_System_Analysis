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
