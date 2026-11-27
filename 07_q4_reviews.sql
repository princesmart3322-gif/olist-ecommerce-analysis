-- Q4A: Review scores for late vs on-time orders
SELECT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'Late' ELSE 'On time' END AS delivery_status,
       COUNT(*) AS reviewed_orders,
       ROUND(AVG(r.review_score), 2) AS avg_review_score,
       ROUND(100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_1_2_stars,
       ROUND(100.0 * SUM(CASE WHEN r.review_score = 5 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_5_stars
FROM orders o
JOIN order_reviews_clean r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 1
ORDER BY 1 DESC;

-- Q4B: Review scores by how late the order was
WITH d AS (
  SELECT r.review_score,
         EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date)) / 86400 AS days_late
  FROM orders o
  JOIN order_reviews_clean r ON o.order_id = r.order_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
)
SELECT CASE WHEN days_late <= 0 THEN '1. On time or early'
            WHEN days_late <= 3 THEN '2. Up to 3 days late'
            WHEN days_late <= 7 THEN '3. 3 to 7 days late'
            ELSE '4. More than 7 days late' END AS lateness,
       COUNT(*) AS reviewed_orders,
       ROUND(AVG(review_score), 2) AS avg_review_score
FROM d
GROUP BY 1
ORDER BY 1;