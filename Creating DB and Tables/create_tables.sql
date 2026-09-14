-----QUESTION 2-----

-- 2. CREATING TABLES
-- 2.1. Customers 
create table de_project1.public.customers(
customer_id varchar (255), 
customer_name varchar (255), 
email varchar (255), 
province varchar (255), 
signup_date date
)

--Checking the table was created properly
select* from de_project1.public.customers
