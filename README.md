# Data Engineering Project 1 — Snowflake Sales Data Pipeline

## Table of Contents
1. [Project Overview](#project-overview)
2. [Database Architecture and Schema](#database-architecture-and-schema)
3. [Repository Structure & Content](#repository-structure--content)
4. [Validation Screenshots](#validation-screenshots)
5. [Executed Analytical Queries](#executed-analytical-queries)
6. [Technical Learning Applied](#technical-learning-applied)

---

## Project Overview

This project simulates a small e-commerce sales environment inside **Snowflake**, using three source files: `customers.csv`, `products.csv`, and `orders.csv`. The goal was to design a simple relational data model, load the data into Snowflake with appropriate data types, confirm the load was successful, and then write analytical SQL queries to answer real business questions — such as which customers spend the most and which product categories generate the most revenue.

All work for this project was completed **exclusively in Snowflake**, per the project requirements. No external tools (Excel, Python, etc.) were used to transform or load the data.

**Business questions this project answers:**
- What does a complete, human-readable order record look like (customer + product + revenue)?
- How much has each customer spent in total?
- Which product categories generate the most revenue?
- Who are the top 5 highest-spending customers?

---

## Database Architecture and Schema

The project uses a classic **star-schema-style** model with two dimension tables and one fact table.

| Table | Type | Grain | Key Columns |
|---|---|---|---|
| `customers` | Dimension | One row per customer | `customer_id` (PK), `customer_name`, `email`, `province`, `signup_date` |
| `products` | Dimension | One row per product | `product_id` (PK), `product_name`, `category`, `unit_price` |
| `orders` | Fact | One row per order | `order_id` (PK), `customer_id` (FK → customers), `product_id` (FK → products), `order_date`, `quantity` |

**Database & Schema:**
```sql
CREATE DATABASE de_project1;
```
All tables were created under `de_project1.public`.

**Table definitions** (with correct, purpose-fit data types rather than defaulting everything to `VARCHAR`):

```sql
-- Customers
CREATE TABLE de_project1.public.customers (
    customer_id   VARCHAR(255),
    customer_name VARCHAR(255),
    email         VARCHAR(255),
    province      VARCHAR(255),
    signup_date   DATE
);

-- Products
CREATE TABLE de_project1.public.products (
    product_id    VARCHAR(255),
    product_name  VARCHAR(255),
    category      VARCHAR(255),
    unit_price    DECIMAL
);

-- Orders
CREATE TABLE de_project1.public.orders (
    order_id      VARCHAR(255),
    customer_id   VARCHAR(255),
    product_id    VARCHAR(255),
    order_date    DATE,
    quantity      INT
);
```

**Design notes:**
- IDs (`customer_id`, `product_id`, `order_id`) are kept as `VARCHAR` since they are alphanumeric codes (e.g. `C001`, `P016`, `O0001`), not numeric identifiers.
- `signup_date` and `order_date` are stored as `DATE`, not text, so date-based filtering and sorting work correctly.
- `unit_price` is stored as `DECIMAL` to preserve currency precision.
- `quantity` is stored as `INT` since it's a whole-number count used directly in revenue calculations.

---

## Repository Structure & Content

```
├── README.md                  # This file
├── de_project1_setup.sql      # Database, schema, and table creation statements
├── de_project1_load.sql       # Data load statements (INSERT INTO — see note below)
├── de_project1_queries.sql    # The four required analytical queries
└── screenshots/               # Validation and query result screenshots
```

**Note on data loading:** Because the dataset is small (50 / 20 / 150 rows) and was provided inline rather than as files staged in Snowflake, the load step was performed using `INSERT INTO ... VALUES (...)` statements rather than `COPY INTO` from a staged file. This is functionally equivalent for this project's purposes — all rows land in the correct table with the correct types — but in a production pipeline with larger files, the CSVs would instead be staged (internal or external stage) and loaded with `COPY INTO`.

---

## Validation Screenshots

After creating each table and loading the data, the load was validated using row counts, per the project's success criteria:

```sql
SELECT COUNT(*) FROM de_project1.public.customers;  -- expected: 50
SELECT COUNT(*) FROM de_project1.public.products;   -- expected: 20
SELECT COUNT(*) FROM de_project1.public.orders;     -- expected: 150
```

> 📸 *Insert screenshots here of:*
> - *The Snowflake database/schema/table hierarchy in the sidebar*
> - *Each `SELECT COUNT(*)` result confirming 50 / 20 / 150 rows*
> - *A `SELECT *` sample from each table showing correct data types*

---

## Executed Analytical Queries

### 1. Order Detail Join (customer, product, category, line revenue)

```sql
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
```

**Write-up:** Think of this as combining three separate notebooks — one for customers, one for products, one for orders — into a single readable list. On their own, the orders table just says something like "customer C016 bought product P016," which means nothing to a person reading it. This query joins all three tables on their ID columns so the output shows the actual customer name, product name, and category instead of codes. It also adds a calculated `line_revenue` column (quantity × unit price) so you can see exactly how much money each individual order generated. The ID columns are dropped from the final output because they only exist to link the tables together behind the scenes — once the join has matched everything correctly, the human-readable names carry the same information more usefully.

### 2. Total Revenue Per Customer

```sql
SELECT
    c.customer_id,
    c.customer_name,
    SUM(o.quantity * p.unit_price) AS total_revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_revenue DESC;
```

**Write-up:** This query adds up everything each individual customer has spent across all of their orders. It matters because it lets the business immediately see which customers are the most valuable, rather than having to scroll through every order line by line and calculate totals manually. Sorting by `total_revenue DESC` puts the highest-value customers at the top, making it easy to spot the business's best relationships at a glance.

### 3. Total Revenue Per Product Category

```sql
SELECT
    p.category,
    SUM(o.quantity * p.unit_price) AS total_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;
```

**Write-up:** This query groups all orders by product category — Electronics, Home, Fashion, Beauty — and sums up how much revenue each category generated. It's important because it shows which categories are actually performing well and which are underperforming, giving the business a clear basis for deciding where to focus stock, marketing, or pricing attention.

### 4. Top 5 Customers by Total Spend

```sql
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
```

**Write-up:** This builds directly on Query 2 but narrows the result down to just the five customers who spent the most overall, using `ORDER BY ... DESC` combined with `LIMIT 5`. It's useful because it highlights the business's most loyal, highest-value customers — the people most worth rewarding with loyalty perks or targeting with focused marketing, since they already contribute the most to overall revenue.

> 📸 *Insert screenshots or CSV exports of each query's result set here.*

---

## Technical Learning Applied

- **Schema design:** Applying a dimension/fact model (customers + products as dimensions, orders as the fact table) rather than a single flat table, which mirrors how real analytical warehouses are structured.
- **Data typing discipline:** Choosing `DATE`, `DECIMAL`, and `INT` where appropriate instead of defaulting every column to `VARCHAR`, which keeps calculations and date logic valid.
- **Joins:** Using `JOIN` across three tables to resolve foreign-key codes (`customer_id`, `product_id`) into meaningful, human-readable output.
- **Aggregation:** Using `SUM()` with `GROUP BY` to roll fact-table rows up to the customer and category level.
- **Sorting & limiting:** Using `ORDER BY ... DESC` and `LIMIT` together to surface top performers (top 5 customers).
- **Calculated fields:** Deriving `line_revenue` and `total_revenue`/`total_spend` on the fly (`quantity * unit_price`) rather than storing pre-computed values, keeping the data normalized.
- **Load validation:** Confirming a successful data load with `SELECT COUNT(*)` against expected row counts (50 / 20 / 150) before moving on to analysis — a basic but essential data quality check.

This project lays the groundwork for the capstone (`BrightLearn_Snowflake_Capstone.md`), which assumes comfort with loading, joining, and analyzing data independently in Snowflake.
