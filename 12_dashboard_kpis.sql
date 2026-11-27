WITH delivered AS (
    SELECT order_id, order_purchase_timestamp,
        order_delivered_customer_date, order_estimated_delivery_date
    FROM orders
    WHERE order_status = 'delivered'
)
SELECT
    (SELECT ROUND(SUM(i.price)::numeric, 2)
        FROM order_items i
        JOIN delivered d ON d.order_id = i.order_id) AS total_revenue,
    (SELECT COUNT(*) FROM delivered) AS delivered_orders,
    (SELECT ROUND(AVG(EXTRACT(EPOCH FROM
            (order_delivered_customer_date - order_purchase_timestamp)) / 86400)::numeric, 1)
        FROM delivered
        WHERE order_delivered_customer_date IS NOT NULL) AS avg_delivery_days,
    (SELECT ROUND(100.0 * COUNT(*) FILTER (
                WHERE order_delivered_customer_date > order_estimated_delivery_date)
            / COUNT(*), 1)
        FROM delivered
        WHERE order_delivered_customer_date IS NOT NULL) AS late_pct,
    (SELECT ROUND(AVG(r.review_score), 2)
        FROM order_reviews_clean r
        JOIN delivered d ON d.order_id = r.order_id) AS avg_review_score