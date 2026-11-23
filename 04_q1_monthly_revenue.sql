-- Q1: Monthly revenue and orders (delivered orders only, item prices excluding freight)
WITH monthly AS (
  SELECT DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
         COUNT(DISTINCT o.order_id) AS orders,
         ROUND(SUM(oi.price), 0) AS revenue
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY 1
)
SELECT month,
       orders,
       revenue,
       ROUND(revenue / orders, 0) AS revenue_per_order,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month) * 100, 1) AS pct_change
FROM monthly
ORDER BY month;