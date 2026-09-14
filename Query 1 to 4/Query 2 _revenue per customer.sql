
-- 4.2. Total revenue per customer.
SELECT
    c.customer_id,
    c.customer_name,
    SUM(o.quantity * p.unit_price) AS total_revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_revenue DESC;

--This query adds up all the amount each individual customer has spent across every order they've made. 
--This query is crucial because it lets us quickly see which customers are the most valuable to the business, instead of having to look through every single order one by one and calculate it yourself.
