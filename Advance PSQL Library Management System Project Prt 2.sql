-- SQL Library Management System Project Prt 2

Select * from books;
Select * from branch;
Select * from employees;
Select * from issued_status;
Select * from members;
Select * from return_status;

/*
Task 13: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.*/

-- issued_status == members table == books table == return status
-- filters returned books
-- check if the overdue is > 30 days

select CURRENT_DATE;

Select 
		ist.issued_member_id,
		m.member_name,
		bk.book_title,
		ist.issued_date,
		-- rst.return_date,
-- To get overdue day subtract ist.issued date from the current date
		CURRENT_DATE - ist.issued_date as overdue_days
-- Join all issued_status, members, books and return_status table
	from issued_status as ist
	join
	members as m
		on ist.issued_member_id = m.member_id
	join
	books as bk
		on bk.isbn = ist.issued_book_isbn
-- You need to join will all the records in the return_status table so LEFT JOIN to join with the table created earlier
	LEFT JOIN
	return_status as rst
		ON rst.issued_id = ist.issued_id
where 
	rst.return_date is null
	and 

	current_date - ist.issued_date > 30 
order by overdue_days;
		

/*
Task 14: 
Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" 
when they are returned (based on entries in the return_status table).
*/
-- books table == issued status == return status

Select * from books;
Select * from issued_status;
Select * from return_status;

-- Manual Method
select * from books
	where isbn = '978-0-451-52994-2';

-- Update a specific book status in the books table

update books
	set status = 'No'
	where isbn = '978-0-451-52994-2';

Select * from issued_status
	where issued_book_isbn = '978-0-451-52994-2' ;

Select * from return_status
	where return_book_isbn = '978-0-451-52994-2';

--
insert into return_status(return_id, issued_id,return_date,book_quality)
values ('RS125','IS130',current_date,'Good');

Select * from return_status
	where issued_id = 'IS130';

update books
	set status = 'Yes'
	where isbn = '978-0-451-52994-2';


-- Stored Procedures
create or replace procedure add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10),p_book_quality VARCHAR(15))
-- Syntax to add stored procedure create a function and give it a name i.e add_return_record()
-- Enter parameter that is going to be entered by the user i.e p_return_id, p_issued_id, p_book_quality an

language plpgsql 	-- procedure language posgtresql(plpgsql)
		AS $$				-- Add delimiters
		DECLARE					-- Declare a variable i.e (v_)
		v_isbn varchar(50);
		v_book_name varchar(80);
			BEGIN
				-- All your logic and code
				-- Inserting into returns based on users input
				insert into return_status(return_id, issued_id,return_date,book_quality)
				values 
					(p_return_id,p_issued_id,current_date,p_book_quality);
					
				select 
						issued_book_isbn,
						issued_book_name
						into 
						v_isbn,
						v_book_name
					from issued_status
					where issued_id = p_issued_id;
				
					
				update books
				set status = 'Yes'
				where isbn = v_isbn;
	
				Raise notice 'Thank you for returning the book: %', v_book_name;
	
	
			END;
		$$
call add_return_records( )

Select * from books
	WHERE isbn = '978-0-307-58837-1';
Select * from branch;
Select * from employees;
Select * from issued_status;
Select * from members;
Select * from return_status;

-- Testing functions : add_return_records()
Select * from books
	WHERE isbn = '978-0-307-58837-1';

Select * from issued_status
	where issued_id = 'IS135';

Select * from return_status
-- delete from return_status
	where issued_id = 'IS135';

call add_return_records('RS138','IS135','Good');

Select * from books
	where isbn = '978-0-330-25864-8';

update books
	set status = 'No'
	where isbn = '978-0-330-25864-8';

Select * from issued_status
	where issued_book_isbn = '978-0-330-25864-8';

Select * from return_status
-- delete from return_status
	where issued_id = 'IS140';
	


call add_return_records('RS139','IS140','Good');

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, 
showing the number of books issued, 
the number of books returned, and 
the total revenue generated from book rentals.
*/

-- issued_status == employees == branch == return_status == books
Create table branch_performance 
as
	select  
			br.branch_id,
			br.manager_id,
			count(ist.issued_id) as books_issued,
			count(rst.return_id) as books_returned,
			sum(bk. rental_price) as revenue
		from issued_status as ist
			JOIN 
				employees as emp
				ON 
					emp.emp_id = ist.issued_emp_id
			JOIN
				branch as br
				ON
					br.branch_id = emp.branch_id
			LEFT JOIN
				return_status as rst
				ON
					rst.issued_id = ist.issued_id
			JOIN
				books as bk
				ON bk.isbn = ist.issued_book_isbn
		group by br.branch_id,br.manager_id
		order by branch_id;
					
select *
	from branch_performance;


/*
Task 16: 
CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing 
members who have issued at least one book in the last 2 months.
*/

-- Use sub-query to find the unique active members in the last two months
-- Then generate the members report in the main query
-- Create Table As Statement

Create table active_members
as
	select * 
		from members
		where member_id in (select 
									distinct issued_member_id
								from issued_status
									where 
										issued_date >= current_date-interval '2 months'
								);

/*
Task 17: 
Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/

select * from employees;

select * from issued_status;

select 
	emp.emp_name,
	br.*,
	count(ist.issued_id) as books_processed
	from issued_status as ist
		JOIN employees as emp
			on emp.emp_id=ist.issued_emp_id
		JOIN branch as br
			on emp.branch_id = br.branch_id
	group by emp.emp_name,2
	order by books_processed desc
	limit 3;

/*
Task 18: 
Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.
*/

select * from members;
select * from return_status;
select * from issued_status;

select 
		mb.member_name,
		ist.issued_book_name,
		rst.book_quality,
		count(rst.book_quality) as quality_count
	from members as mb
	join 
		issued_status as ist
			on mb.member_id = ist.issued_member_id
	join 
		return_status as rst
			on rst.issued_id = ist.issued_id
	where book_quality = 'Damaged'
	group by mb.member_name,ist.issued_book_name, rst.book_quality
	having count(rst.book_quality) >= 2;

/*
Task 19: 
Stored Procedure Objective: 
Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
	The procedure should function as follows: 
		- The stored procedure should take the book_id as an input parameter. 
		- The procedure should first check if the book is available (status = 'yes'). 
		- If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
		- If the book is not available (status = 'no'), 
		- The procedure should return an error message indicating that the book is currently not available.
*/

Select * from books;
Select * from issued_status;

create or replace procedure issue_book(p_issued_id varchar(10),p_issued_member_id varchar(30), p_issued_book_isbn varchar(50), p_issued_emp_id varchar(10))
language plpgsql
	as $$
	declare
	-- Declare all the variable
	v_status varchar(10);
		Begin
		-- Write all the codes here
		
			-- checking  if the book is vailable, status 'yes'
			select status
					into
					v_status
				from books
				where isbn = p_issued_book_isbn;

			-- if the book is available
			if v_status = 'yes' then

				insert into issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
					values (p_issued_id, p_issued_member_id, current_date, p_issued_book_isbn, p_issued_emp_id);

				update books
					set status = 'no'
					where isbn = p_issued_book_isbn;

				raise notice 'Book records added successfully for book_isbn : %', p_issued_book_isbn;

			else
				raise notice 'Sorry to inform you the book you have requested is unavailabe book_isbn: %', p_issued_book_isbn;
			end if;
		
		end;
	$$


select * from books;
-- "978-0-553-29698-2" --yes
-- "978-0-375-41398-8"  -- no
select * from issued_status;

select * from books
 where isbn = '978-0-553-29698-2';

select * from issued_status
	where issued_book_isbn = '978-0-553-29698-2';

Call issue_book('IS155','C108','978-0-553-29698-2','E104');

/*
Task 20: 
Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
 The table should include: 
 						-The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
						- The number of books issued by each member. 
						- The resulting table should show: Member ID, Number of overdue books, Total fines
*/

select * from books;
select * from members;
select * from issued_status;
select * from return_status;

Create table fine_table as
	select 
			mb2.member_id,
			count(ist.issued_member_id) as issued_count,
			-- count(ist.issued_book_name) as issued_book
			ist.issued_date,
			sum(current_date-ist.issued_date) as overdue_days,
			sum(current_date-ist.issued_date)*0.5 as fine,
			sum((current_date-ist.issued_date)*0.5) 
					over(partition by ist.issued_member_id 
							order by ist.issued_date) as Total_fine
		from issued_status as ist
			join
				members as mb1
					on mb1.member_id=ist.issued_member_id
			join members as mb2
					on ist.issued_member_id = mb2.member_id
			left join
				return_status as rst
					on ist.issued_id = rst.issued_id
		where rst.return_id is null
			and current_date-ist.issued_date > 30
		group by mb2.member_id,ist.issued_date,ist.issued_date, ist.issued_member_id
		order by overdue_days desc;


select * from branch_performance;

select * from fine_table;



/*
Additional tasks personal
*/


select * from issued_status;

select ist1.issued_member_id,
		count(ist2.issued_book_isbn) as issued_count
	from issued_status as ist1
	 join issued_status as ist2
	 	on ist1.issued_id = ist2.issued_id
	group by ist1.issued_member_id
	order by 2 desc;








	