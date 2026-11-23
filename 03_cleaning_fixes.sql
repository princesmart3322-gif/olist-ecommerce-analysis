-- Check 5: How many orders have more than one review?
SELECT COUNT(*) AS orders_with_multiple_reviews
FROM (SELECT order_id FROM order_reviews
      GROUP BY order_id HAVING COUNT(*) > 1) t;

-- Fix 1: Add the two missing category translations (translated manually)
INSERT INTO product_category_name_translation VALUES
  ('pc_gamer', 'pc_gamer'),
  ('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_and_food_preparers');

-- Fix 2: One review per order (keep the latest)
CREATE OR REPLACE VIEW order_reviews_clean AS
SELECT review_id, order_id, review_score, review_creation_date
FROM (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY order_id
                            ORDER BY review_answer_timestamp DESC, review_id) AS rn
  FROM order_reviews
) r
WHERE rn = 1;