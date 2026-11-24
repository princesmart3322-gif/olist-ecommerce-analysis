-- Q5A: Payment methods (delivered orders)
WITH by_type AS (
  SELECT p.payment_type,
         COUNT(DISTINCT p.order_id) AS orders,
         COUNT(*) AS payments,
         SUM(p.payment_value) AS total_value
  FROM order_payments p
  JOIN orders o ON p.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY p.payment_type
)
SELECT payment_type,
       orders,
       ROUND(100.0 * orders / (SELECT COUNT(*) FROM orders WHERE order_status = 'delivered'), 1) AS pct_of_orders,
       payments,
       ROUND(total_value, 0) AS total_value,
       ROUND(total_value / SUM(total_value) OVER () * 100, 1) AS pct_of_value
FROM by_type
ORDER BY total_value DESC;

-- Q5B: Credit card payments by number of installments (delivered orders)
WITH card AS (
  SELECT CASE WHEN p.payment_installments <= 1 THEN '1. One installment'
              WHEN p.payment_installments <= 3 THEN '2. 2 to 3 installments'
              WHEN p.payment_installments <= 6 THEN '3. 4 to 6 installments'
              ELSE '4. 7 or more installments' END AS installments,
         COUNT(*) AS payments,
         AVG(p.payment_value) AS avg_payment_value
  FROM order_payments p
  JOIN orders o ON p.order_id = o.order_id
  WHERE o.order_status = 'delivered'
    AND p.payment_type = 'credit_card'
  GROUP BY 1
)
SELECT installments,
       payments,
       ROUND(100.0 * payments / SUM(payments) OVER (), 1) AS pct_of_card_payments,
       ROUND(avg_payment_value, 0) AS avg_payment_value
FROM card
ORDER BY installments;