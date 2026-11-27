WITH scored AS (
    SELECT
        r.review_score,
        CASE
            WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 1
            WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date + INTERVAL '3 days' THEN 2
            WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date + INTERVAL '7 days' THEN 3
            ELSE 4
        END AS sort_order
    FROM orders o
    JOIN order_reviews_clean r ON r.order_id = o.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
)
SELECT
    sort_order,
    CASE sort_order
        WHEN 1 THEN 'On time'
        WHEN 2 THEN 'Up to 3 days late'
        WHEN 3 THEN '3 to 7 days late'
        ELSE 'Over 7 days late'
    END AS lateness_group,
    COUNT(*) AS orders,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM scored
GROUP BY sort_order
ORDER BY sort_order