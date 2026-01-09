-- PROJECT 2: SQL Analytics Case Study (SQLite)

-- Q1: Total revenue
SELECT ROUND(SUM(o.quantity * p.unit_price), 2) AS total_revenue
FROM orders o
JOIN products p ON p.product_id = o.product_id;

-- Q2: Revenue by month
SELECT substr(o.order_date, 1, 7) AS month,
       ROUND(SUM(o.quantity * p.unit_price), 2) AS revenue
FROM orders o
JOIN products p ON p.product_id = o.product_id
GROUP BY month
ORDER BY month;

-- Q3: Top 5 customers by revenue
SELECT c.customer_id, c.full_name,
       ROUND(SUM(o.quantity * p.unit_price), 2) AS revenue
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN products p ON p.product_id = o.product_id
GROUP BY c.customer_id, c.full_name
ORDER BY revenue DESC
LIMIT 5;

-- Q4: Orders count per customer
SELECT c.customer_id, c.full_name,
       COUNT(DISTINCT o.order_id) AS orders_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY orders_count DESC;

-- Q5: Average order value (AOV)
WITH order_totals AS (
  SELECT o.order_id,
         SUM(o.quantity * p.unit_price) AS order_total
  FROM orders o
  JOIN products p ON p.product_id = o.product_id
  GROUP BY o.order_id
)
SELECT ROUND(AVG(order_total), 2) AS avg_order_value
FROM order_totals;

-- Q6: Revenue by category
SELECT p.category,
       ROUND(SUM(o.quantity * p.unit_price), 2) AS revenue
FROM orders o
JOIN products p ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- Q7: Most sold products (by quantity)
SELECT p.product_id, p.product_name,
       SUM(o.quantity) AS total_units
FROM orders o
JOIN products p ON p.product_id = o.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_units DESC
LIMIT 5;

-- Q8: Country revenue
SELECT c.country,
       ROUND(SUM(o.quantity * p.unit_price), 2) AS revenue
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN products p ON p.product_id = o.product_id
GROUP BY c.country
ORDER BY revenue DESC;

-- Q9: New vs returning customers per month (simple heuristic)
WITH customer_month AS (
  SELECT customer_id,
         substr(order_date, 1, 7) AS month,
         MIN(substr(order_date, 1, 7)) OVER (PARTITION BY customer_id) AS first_month
  FROM orders
)
SELECT month,
       SUM(CASE WHEN month = first_month THEN 1 ELSE 0 END) AS new_customers,
       SUM(CASE WHEN month != first_month THEN 1 ELSE 0 END) AS returning_customers
FROM (SELECT DISTINCT customer_id, month, first_month FROM customer_month)
GROUP BY month
ORDER BY month;

-- Q10: Daily revenue
SELECT o.order_date,
       ROUND(SUM(o.quantity * p.unit_price), 2) AS revenue
FROM orders o
JOIN products p ON p.product_id = o.product_id
GROUP BY o.order_date
ORDER BY o.order_date;

-- Q11: Rank customers by revenue (window function)
WITH customer_rev AS (
  SELECT c.customer_id, c.full_name,
         SUM(o.quantity * p.unit_price) AS revenue
  FROM orders o
  JOIN customers c ON c.customer_id = o.customer_id
  JOIN products p ON p.product_id = o.product_id
  GROUP BY c.customer_id, c.full_name
)
SELECT customer_id, full_name,
       ROUND(revenue, 2) AS revenue,
       DENSE_RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM customer_rev
ORDER BY revenue_rank;

-- Q12: Running monthly revenue (window function)
WITH monthly AS (
  SELECT substr(o.order_date, 1, 7) AS month,
         SUM(o.quantity * p.unit_price) AS revenue
  FROM orders o
  JOIN products p ON p.product_id = o.product_id
  GROUP BY month
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS running_revenue
FROM monthly
ORDER BY month;

-- Q13: Customers with no orders
SELECT c.customer_id, c.full_name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

-- Q14: Category share of total revenue
WITH totals AS (
  SELECT SUM(o.quantity * p.unit_price) AS total_rev
  FROM orders o JOIN products p ON p.product_id = o.product_id
),
cat AS (
  SELECT p.category,
         SUM(o.quantity * p.unit_price) AS rev
  FROM orders o JOIN products p ON p.product_id = o.product_id
  GROUP BY p.category
)
SELECT category,
       ROUND(rev, 2) AS revenue,
       ROUND((rev / (SELECT total_rev FROM totals)) * 100, 2) AS revenue_share_pct
FROM cat
ORDER BY revenue DESC;

-- Q15: Top product per category (window function)
WITH prod_rev AS (
  SELECT p.category, p.product_id, p.product_name,
         SUM(o.quantity) AS units_sold,
         SUM(o.quantity * p.unit_price) AS revenue
  FROM orders o
  JOIN products p ON p.product_id = o.product_id
  GROUP BY p.category, p.product_id, p.product_name
),
ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
  FROM prod_rev
)
SELECT category, product_id, product_name,
       units_sold,
       ROUND(revenue, 2) AS revenue
FROM ranked
WHERE rn = 1
ORDER BY category;
