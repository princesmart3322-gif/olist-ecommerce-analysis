-- Q3A: Overall delivery time and late share (delivered orders with a delivery date)
SELECT COUNT(*) AS delivered_orders,
       ROUND(AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp)) / 86400)::numeric, 1) AS avg_delivery_days,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (
         ORDER BY EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp)) / 86400)::numeric, 1) AS median_delivery_days,
       SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) AS late_orders,
       ROUND(100.0 * SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_late
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

-- Q3B: Delivery time and late share by purchase month
SELECT DATE_TRUNC('month', order_purchase_timestamp)::date AS month,
       COUNT(*) AS delivered_orders,
       ROUND(AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp)) / 86400)::numeric, 1) AS avg_delivery_days,
       ROUND(100.0 * SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_late
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
GROUP BY 1
ORDER BY 1;