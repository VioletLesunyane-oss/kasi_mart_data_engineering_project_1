-- 4.4 Top 5 customers by total spend.
SELECT
    c.customer_id,
    c.customer_name,
    SUM(o.quantity * p.unit_price) AS total_spend
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spend DESC
LIMIT 5;

--This query is basically the same idea as Query 2, but it only shows the 5 customers who spent the most money overall. It matters because it highlights your best, most loyal customers, which is useful if the business wants to reward them or focus marketing efforts on the people who matter most to their income.
