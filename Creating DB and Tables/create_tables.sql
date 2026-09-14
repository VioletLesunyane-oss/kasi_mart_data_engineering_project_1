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

-- 2.2. Products
create table de_project1.public.products(
product_id varchar (255), 
product_name varchar (255),
category varchar (255),
unit_price decimal
)

--Checking the table was created properly
select* from de_project1.public.products

-- 2.3. Orders
create table de_project1.public.orders(
order_id varchar (255), 
customer_id varchar (255), 
product_id varchar (255), 
order_date date, 
quantity int
)

--Checking the table was created properly
select* from de_project1.public.orders
