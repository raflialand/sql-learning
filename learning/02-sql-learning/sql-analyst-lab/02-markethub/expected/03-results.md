# Case 02 — Verified Expected Results

Captured by executing `03-queries.sql` statement-by-statement against `sql-skill-push/datasets/02-intermediate/ecommerce.db` (read-only, reused) with the `run_query.py` output format. Re-running the same queries reproduces these rows and counts exactly.

## Q1 (Overall Trends) — Monthly GMV + order count

```sql
SELECT strftime('%Y-%m', order_date) AS month,
       COUNT(*) AS order_count,
       ROUND(SUM(total_amount), 2) AS gmv
FROM orders
WHERE status IN ('Completed', 'Shipped')
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month;
```

| month | order_count | gmv |
| --- | --- | --- |
| 2025-01 | 143 | 415212.33 |
| 2025-02 | 134 | 403891.37 |
| 2025-03 | 146 | 445340.06 |
| 2025-04 | 138 | 422146.35 |
| 2025-05 | 123 | 362875.01 |
| 2025-06 | 154 | 450704.06 |
| 2025-07 | 155 | 487874.98 |
| 2025-08 | 178 | 502558.50 |
| 2025-09 | 124 | 369541.76 |
| 2025-10 | 145 | 407592.82 |

(13 rows total; 10 shown)

## Q2 (Overall Trends) — GMV by top-level category

```sql
SELECT parent.cat_name AS category,
       COUNT(DISTINCT o.order_id) AS order_count,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS gmv
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.prod_id
JOIN categories sub ON p.cat_id = sub.cat_id
JOIN categories parent ON sub.parent_cat_id = parent.cat_id
WHERE o.status IN ('Completed', 'Shipped')
GROUP BY parent.cat_name
ORDER BY gmv DESC;
```

| category | order_count | gmv |
| --- | --- | --- |
| Electronics | 1204 | 2010913.91 |
| Clothing | 982 | 1546327.67 |
| Home & Kitchen | 943 | 1295606.68 |
| Sports & Outdoors | 415 | 695292.36 |

(4 rows)

## Q3 (Growth Rates) — Month-over-month GMV growth %

```sql
WITH monthly AS (
    SELECT strftime('%Y-%m', order_date) AS month,
           SUM(total_amount) AS gmv
    FROM orders
    WHERE status IN ('Completed', 'Shipped')
    GROUP BY month
)
SELECT month,
       ROUND(gmv, 2) AS gmv,
       ROUND((gmv - LAG(gmv) OVER (ORDER BY month)) / LAG(gmv) OVER (ORDER BY month) * 100, 2) AS mom_growth_pct
FROM monthly
ORDER BY month;
```

| month | gmv | mom_growth_pct |
| --- | --- | --- |
| 2025-01 | 415212.33 | NULL |
| 2025-02 | 403891.37 | -2.73 |
| 2025-03 | 445340.06 | 10.26 |
| 2025-04 | 422146.35 | -5.21 |
| 2025-05 | 362875.01 | -14.04 |
| 2025-06 | 450704.06 | 24.20 |
| 2025-07 | 487874.98 | 8.25 |
| 2025-08 | 502558.50 | 3.01 |
| 2025-09 | 369541.76 | -26.47 |
| 2025-10 | 407592.82 | 10.30 |

(13 rows total; 10 shown)

## Q4 (Growth Rates) — YoY: Jan-2025 vs Jan-2026

```sql
SELECT strftime('%Y', order_date) AS year,
       COUNT(*) AS order_count,
       ROUND(SUM(total_amount), 2) AS gmv,
       ROUND(SUM(total_amount) / COUNT(*), 2) AS aov
FROM orders
WHERE status IN ('Completed', 'Shipped')
  AND strftime('%Y-%m', order_date) IN ('2025-01', '2026-01')
GROUP BY strftime('%Y', order_date)
ORDER BY year;
```

| year | order_count | gmv | aov |
| --- | --- | --- | --- |
| 2025 | 143 | 415212.33 | 2903.58 |
| 2026 | 151 | 435492.71 | 2884.06 |

(2 rows)

## Q5 (Performance Measurement) — GMV + AOV by buyer country

```sql
SELECT c.country,
       COUNT(*) AS order_count,
       ROUND(SUM(o.total_amount), 2) AS gmv,
       ROUND(SUM(o.total_amount) / COUNT(*), 2) AS aov
FROM orders o
JOIN customers c ON o.customer_id = c.cust_id
WHERE o.status IN ('Completed', 'Shipped')
GROUP BY c.country
ORDER BY gmv DESC;
```

| country | order_count | gmv | aov |
| --- | --- | --- | --- |
| USA | 289 | 929335.20 | 3215.69 |
| Australia | 272 | 856436.55 | 3148.66 |
| Canada | 290 | 850945.65 | 2934.30 |
| Netherlands | 274 | 766255.86 | 2796.55 |
| UK | 253 | 747073.53 | 2952.86 |
| France | 249 | 723540.59 | 2905.79 |
| Germany | 237 | 674553.24 | 2846.22 |

(7 rows)

## Q6 (Performance Measurement) — Repeat purchase rate by country

Fixed definition: buyers with ≥2 Completed/Shipped orders ÷ buyers with ≥1 Completed/Shipped order (full history).

```sql
WITH buyer_orders AS (
    SELECT c.country,
           o.customer_id,
           COUNT(*) AS order_count
    FROM orders o
    JOIN customers c ON o.customer_id = c.cust_id
    WHERE o.status IN ('Completed', 'Shipped')
    GROUP BY c.country, o.customer_id
)
SELECT country,
       SUM(CASE WHEN order_count >= 2 THEN 1 ELSE 0 END) AS repeat_buyers,
       COUNT(*) AS total_buyers,
       ROUND(100.0 * SUM(CASE WHEN order_count >= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_rate_pct
FROM buyer_orders
GROUP BY country
ORDER BY repeat_rate_pct DESC;
```

| country | repeat_buyers | total_buyers | repeat_rate_pct |
| --- | --- | --- | --- |
| Australia | 64 | 66 | 96.97 |
| Canada | 71 | 75 | 94.67 |
| UK | 59 | 64 | 92.19 |
| Netherlands | 68 | 74 | 91.89 |
| USA | 69 | 76 | 90.79 |
| Germany | 57 | 64 | 89.06 |
| France | 60 | 70 | 85.71 |

(7 rows)

## Q7 (KPI Reporting) — Payment failure rate by method (the "why")

```sql
SELECT method,
       COUNT(*) AS attempts,
       SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END) AS failed,
       ROUND(100.0 * SUM(CASE WHEN status = 'Failed' THEN 1 ELSE 0 END) / COUNT(*), 2) AS failure_rate_pct
FROM payments
GROUP BY method
ORDER BY failure_rate_pct DESC;
```

| method | attempts | failed | failure_rate_pct |
| --- | --- | --- | --- |
| Card | 911 | 208 | 22.83 |
| COD | 486 | 102 | 20.99 |
| Bank Transfer | 408 | 84 | 20.59 |
| PayPal | 478 | 88 | 18.41 |

(4 rows)

## Q8 (KPI Reporting) — Investment drill-down: vendor country × top category GMV

```sql
SELECT v.country AS vendor_country,
       parent.cat_name AS category,
       COUNT(DISTINCT o.order_id) AS order_count,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS gmv
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.prod_id
JOIN vendors v ON p.vendor_id = v.vendor_id
JOIN categories sub ON p.cat_id = sub.cat_id
JOIN categories parent ON sub.parent_cat_id = parent.cat_id
WHERE o.status IN ('Completed', 'Shipped')
GROUP BY v.country, parent.cat_name
ORDER BY gmv DESC
LIMIT 10;
```

| vendor_country | category | order_count | gmv |
| --- | --- | --- | --- |
| Germany | Electronics | 688 | 1135655.72 |
| Germany | Clothing | 501 | 658317.22 |
| Netherlands | Electronics | 483 | 545691.77 |
| Netherlands | Clothing | 372 | 485869.55 |
| Germany | Home & Kitchen | 327 | 377874.25 |
| Netherlands | Sports & Outdoors | 165 | 305936.13 |
| Netherlands | Home & Kitchen | 329 | 305395.03 |
| Germany | Sports & Outdoors | 191 | 292767.51 |
| UK | Home & Kitchen | 171 | 222789.83 |
| France | Electronics | 268 | 217297.60 |

(10 rows)
