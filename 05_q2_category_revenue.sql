-- Q2: Top 10 product categories by revenue (delivered orders, item prices excluding freight)
WITH category_revenue AS (
  SELECT COALESCE(t.product_category_name_english, 'unknown') AS category,
         COUNT(*) AS items_sold,
         ROUND(SUM(oi.price), 0) AS revenue
  FROM order_items oi
  JOIN orders o ON oi.order_id = o.order_id
  LEFT JOIN products p ON oi.product_id = p.product_id
  LEFT JOIN product_category_name_translation t
    ON p.product_category_name = t.product_category_name
  WHERE o.order_status = 'delivered'
  GROUP BY 1
)
SELECT RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
       category,
       items_sold,
       revenue,
       ROUND(revenue / SUM(revenue) OVER () * 100, 1) AS pct_of_total
FROM category_revenue
ORDER BY revenue DESC
LIMIT 10;