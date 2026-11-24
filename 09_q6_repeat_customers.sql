-- Q6A: Customers by number of delivered orders
WITH cust AS (
  SELECT c.customer_unique_id,
         COUNT(DISTINCT o.order_id) AS orders
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
)
SELECT CASE WHEN orders = 1 THEN '1 order'
            WHEN orders = 2 THEN '2 orders'
            WHEN orders = 3 THEN '3 orders'
            ELSE '4 or more orders' END AS order_count,
       COUNT(*) AS customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_customers
FROM cust
GROUP BY 1
ORDER BY 1;

-- Q6B: Repeat customer summary
WITH cust AS (
  SELECT c.customer_unique_id,
         COUNT(DISTINCT o.order_id) AS orders
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
)
SELECT COUNT(*) AS customers,
       SUM(CASE WHEN orders > 1 THEN 1 ELSE 0 END) AS repeat_customers,
       ROUND(100.0 * SUM(CASE WHEN orders > 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_repeat_customers,
       SUM(orders) AS total_orders,
       ROUND(100.0 * SUM(CASE WHEN orders > 1 THEN orders ELSE 0 END) / SUM(orders), 1) AS pct_orders_from_repeat_customers
FROM cust;