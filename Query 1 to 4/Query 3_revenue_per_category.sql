-- 4.3. Total revenue per product category.
SELECT
    p.category,
    SUM(o.quantity * p.unit_price) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

--This query groups all the orders by product category (like Electronics, Home, or Fashion) and adds up how much revenue each category brought in. 
--This query is important because it shows which categories are performing well and which ones aren't, which helps the business decide where to focus their attention or stock.
