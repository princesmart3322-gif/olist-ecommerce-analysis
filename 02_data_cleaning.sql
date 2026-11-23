-- Check 1: Are review IDs repeated?
SELECT COUNT(*) AS total_reviews,
       COUNT(DISTINCT review_id) AS unique_review_ids
FROM order_reviews;

-- Check 2: Order status and missing delivery dates
SELECT order_status,
       COUNT(*) AS orders,
       COUNT(*) - COUNT(order_delivered_customer_date) AS missing_delivery_date
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

-- Check 3: Product categories with no English translation
SELECT p.product_category_name, COUNT(*) AS products
FROM products p
LEFT JOIN product_category_name_translation t
  ON p.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL
GROUP BY p.product_category_name
ORDER BY products DESC;

-- Check 4: Order items with no matching order
SELECT COUNT(*) AS orphan_items
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;