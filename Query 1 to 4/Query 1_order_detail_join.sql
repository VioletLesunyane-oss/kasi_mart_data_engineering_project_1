
-----QUESTION 4-----

-- 4. Write and run these four queries, and keep the SQL for each:
-- 4.1. Every order joined to customer name, product name, category, and a calculated line_revenue (quantity times unit_price).

   SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    p.product_name,
    p.category,
    o.quantity,
    p.unit_price,
    o.quantity * p.unit_price AS line_revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id;

--Imagine you have three separate notebooks: one with a list of customers, one with a list of products, and one with a list of orders. The problem is, the orders notebook doesn't say "John bought a Bluetooth Speaker", it just says something like "Customer C016 bought Product P016," which means nothing to a normal person reading it. This query takes those three notebooks and combines them into one single, easy-to-read list, so instead of confusing codes, you actually see the customer's real name, the product's real name, and what category it belongs to. We also added a new column called line_revenue, which is just the price of the item multiplied by how many were bought, so you can see how much money that one order actually made. As for why we left out the ID codes (like C016 and P016) in the final result, those codes are only needed as a kind of "matching tool" to connect the three notebooks together correctly behind the scenes. Once the notebooks are connected and we already know which name and product matches which order, there's no need to keep showing the codes anymore, because the real names give the same information in a way that's actually easy for a person to read and understand.
