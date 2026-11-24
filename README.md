# Olist E-Commerce Analysis (SQL)

SQL analysis of the Olist Brazilian e-commerce dataset using PostgreSQL.

## Dataset
- Source: Kaggle, "Brazilian E-Commerce Public Dataset by Olist"
- 9 CSV files; 8 are loaded so far (the geolocation file is not used yet)
- Rows: orders 99,441, customers 99,441, order_items 112,650, order_payments 103,886, order_reviews 99,224, products 32,951, sellers 3,095, category translations 71

## Tools
PostgreSQL 18, pgAdmin 4

## Project Workflow
```mermaid
flowchart TD
    A([Start]) --> B[Download 9 Olist CSV files from Kaggle]
    B --> C[Create olist_db and import tables into PostgreSQL]
    C --> D[Clean data: dates, nulls, duplicates]
    D --> E[Answer business questions with SQL joins]
    E --> F[Build dashboard]
    F --> G[Write findings and recommendations in README]
    G --> H([End])
```

## How the Tables Connect
```mermaid
erDiagram
    CUSTOMERS ||--o{ ORDERS : places
    ORDERS ||--o{ ORDER_ITEMS : contains
    ORDERS ||--o{ ORDER_PAYMENTS : "paid by"
    ORDERS ||--o{ ORDER_REVIEWS : receives
    PRODUCTS ||--o{ ORDER_ITEMS : "appears in"
    SELLERS ||--o{ ORDER_ITEMS : sells
    PRODUCT_CATEGORY_NAME_TRANSLATION ||--o{ PRODUCTS : translates
```

## Files
- `01_create_tables.sql`: table definitions
- `02_data_cleaning.sql`: data quality checks
- `03_cleaning_fixes.sql`: fixes for the problems found

## Data Quality Checks and Fixes

**1. Repeated review IDs** (`check1.png`, `check5.png`)
99,224 review rows have only 98,410 unique review IDs, and 547 orders have more than one review. Fix: the view `order_reviews_clean` keeps the latest review per order, giving 98,673 orders with exactly one review each (`verify1.png`).

**2. Missing delivery dates** (`check2.png`)
Orders by status: delivered 96,478, shipped 1,107, canceled 625, unavailable 609, invoiced 314, processing 301, created 5, approved 2. Most orders that were not delivered have no delivery date, which is expected. Two oddities: 8 delivered orders have no delivery date, and 6 canceled orders do have one. Handling: delivery-time analysis will use only delivered orders that have a delivery date.

**3. Product categories without English names** (`check3.png`)
610 products (about 1.9%) have no category at all, and 13 products belong to 2 categories with no translation (`portateis_cozinha_e_preparadores_de_alimentos` and `pc_gamer`). Fix: added the two missing translations, translated manually (`verify2.png`). The 610 uncategorized products will be labeled `unknown` inside queries.

**4. Order items without a matching order** (`check4.png`)
None found (0 orphan items).

## Business Questions

### Q1: How do revenue and orders change month by month?
See `04_q1_monthly_revenue.sql`.

**Method:** Delivered orders only. Revenue is the sum of item prices in Brazilian reais, excluding freight. Each order is counted once with `COUNT(DISTINCT order_id)`.

**Finding:** The data has only three months in 2016 (Sep, Oct and Dec, with 1, 265 and 1 orders, and none in Nov), so those months and the percentage changes around them (over 1,000,000% in Jan 2017) are not meaningful. From Jan 2017, orders grew from 750 to 7,069 in Jan 2018, and revenue from about 112K to about 925K. The peak month was Nov 2017 with 7,289 orders and 987,765 in revenue (+52.4% on Oct 2017), followed by a 26.5% drop in Dec 2017. The data alone cannot explain the November spike. From Jan to Aug 2018, monthly revenue stayed between about 826K and 978K, so growth leveled off. Revenue per order stayed between about 124 and 149 from Jan 2017 on, so growth came from more orders rather than larger orders. Delivered orders in the data end in Aug 2018.

![Q1 result, first rows](q1_result_1.png)
![Q1 result, remaining rows](q1_result_2.png)

### Q2: Which product categories earn the most revenue?
See `05_q2_category_revenue.sql`.

**Method:** Delivered orders only. Revenue is the sum of item prices excluding freight. Category names were translated to English, and products with no category are grouped as `unknown`. Each category's share is calculated against revenue from all categories.

**Finding:** The top 10 categories earn about 62% of total revenue. health_beauty ranks first (1,233,132, 9.3% of total), followed by watches_gifts (1,166,177, 8.8%) and bed_bath_table (1,023,435, 7.7%). bed_bath_table sold the most items (10,953) but ranks third in revenue, while watches_gifts sold only 5,859 items and ranks second, so watches_gifts items cost more on average (roughly 199 per item against 93, calculated from these figures). Ranks 4 to 10 are sports_leisure, computers_accessories, furniture_decor, housewares, cool_stuff, auto and toys.

![Q2 result](q2_result.png)

### Q3: How long does delivery take, and what share of orders arrive late?
See `06_q3_delivery.sql`.

**Method:** Delivered orders that have a delivery date (96,470 orders; the 8 delivered orders with no delivery date are excluded). Delivery time is the number of days from purchase to delivery to the customer. An order counts as late if it arrived after the estimated delivery date.

**Finding:** Average delivery time was 12.6 days and the median was 10.2 days, so a minority of slow deliveries pull the average up. 7,826 orders (about 8.1%) arrived late. In 2017 the monthly late share was between about 3% and 8.4%, except in Nov 2017 (the busiest month), when it reached 14.3% and average delivery time rose to 15.2 days. It reached 16.0% in Feb 2018 and 21.4% in Mar 2018, the highest of any month with meaningful volume, then fell to 5.3% in Apr 2018 and 1.4% in Jun 2018. In Aug 2018 the average delivery time was the shortest (7.7 days), but 10.4% of orders were still late, so the late share does not move one-to-one with delivery time. The data alone cannot explain these changes. The 2016 months have too few orders to interpret. Monthly order counts can differ from Q1 by a few orders, because Q1 counts all delivered orders and this query counts only those with a delivery date.

![Q3 overall](q3a_result.png)
![Q3 by month, first rows](q3b_result_1.png)
![Q3 by month, remaining rows](q3b_result_2.png)

### Still to do (planned)
4. Do late deliveries get lower review scores?
5. Which payment methods do customers use?
6. How many customers order more than once (using `customer_unique_id`)?

*Results and a dashboard will be added as each question is completed.*
