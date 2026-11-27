WITH paid AS (
    SELECT p.order_id, p.payment_type, p.payment_value
    FROM order_payments p
    JOIN orders o ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
)
SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(100.0 * COUNT(DISTINCT order_id)
        / (SELECT COUNT(DISTINCT order_id) FROM paid), 1) AS pct_orders,
    ROUND(SUM(payment_value)::numeric, 2) AS payment_value,
    ROUND((100.0 * SUM(payment_value)
        / (SELECT SUM(payment_value) FROM paid))::numeric, 1) AS pct_value
FROM paid
GROUP BY payment_type
ORDER BY orders DESC