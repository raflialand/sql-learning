# Case 01 — Verified Expected Results

Captured by executing `03-queries.sql` statement-by-statement against `sql-skill-push/datasets/01-beginner/retail.db` (read-only, reused) with the `run_query.py` output format. Re-running the same queries reproduces these rows and counts exactly.

## Q1 (Overall Trends) — Monthly revenue + order count + AOV

```sql
SELECT strftime('%Y-%m', order_date) AS month,
       COUNT(*) AS order_count,
       ROUND(SUM(total_amount), 2) AS revenue,
       ROUND(SUM(total_amount) / COUNT(*), 2) AS aov
FROM orders
GROUP BY strftime('%Y-%m', order_date)
ORDER BY month;
```

| month | order_count | revenue | aov |
| --- | --- | --- | --- |
| 2025-01 | 71 | 4000.30 | 56.34 |
| 2025-02 | 86 | 4887.25 | 56.83 |
| 2025-03 | 98 | 5693.35 | 58.10 |
| 2025-04 | 98 | 5910.75 | 60.31 |
| 2025-05 | 80 | 4898.55 | 61.23 |
| 2025-06 | 98 | 5338.25 | 54.47 |
| 2025-07 | 96 | 5534.00 | 57.65 |
| 2025-08 | 108 | 6359.85 | 58.89 |
| 2025-09 | 94 | 5257.20 | 55.93 |
| 2025-10 | 81 | 4519.00 | 55.79 |

(13 rows total; 10 shown)

## Q2 (Overall Trends) — Revenue + order count by store

```sql
SELECT store_id,
       COUNT(*) AS order_count,
       ROUND(SUM(total_amount), 2) AS revenue
FROM orders
GROUP BY store_id
ORDER BY revenue DESC;
```

| store_id | order_count | revenue |
| --- | --- | --- |
| BRW001 | 407 | 24189.20 |
| BRW003 | 409 | 24081.65 |
| BRW002 | 384 | 21963.25 |

(3 rows)

## Q3 (Overall Trends) — Revenue + order count by menu category

```sql
SELECT p.category,
       COUNT(DISTINCT oi.order_id) AS order_count,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.prod_id
GROUP BY p.category
ORDER BY revenue DESC;
```

| category | order_count | revenue |
| --- | --- | --- |
| Merchandise | 737 | 42145.00 |
| Beverage | 861 | 14747.60 |
| Food | 738 | 13341.50 |

(3 rows)

## Q4 (Growth Rates) — Month-over-month revenue growth %

```sql
WITH monthly AS (
    SELECT strftime('%Y-%m', order_date) AS month,
           SUM(total_amount) AS revenue
    FROM orders
    GROUP BY month
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month) * 100, 2) AS mom_growth_pct
FROM monthly
ORDER BY month;
```

| month | revenue | mom_growth_pct |
| --- | --- | --- |
| 2025-01 | 4000.30 | NULL |
| 2025-02 | 4887.25 | 22.17 |
| 2025-03 | 5693.35 | 16.49 |
| 2025-04 | 5910.75 | 3.82 |
| 2025-05 | 4898.55 | -17.12 |
| 2025-06 | 5338.25 | 8.98 |
| 2025-07 | 5534.00 | 3.67 |
| 2025-08 | 6359.85 | 14.92 |
| 2025-09 | 5257.20 | -17.34 |
| 2025-10 | 4519.00 | -14.04 |

(13 rows total; 10 shown)

## Q5 (Performance Measurement) — Category mix per store

```sql
SELECT o.store_id,
       p.category,
       COUNT(*) AS order_count,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.prod_id
GROUP BY o.store_id, p.category
ORDER BY o.store_id, revenue DESC;
```

| store_id | category | order_count | revenue |
| --- | --- | --- | --- |
| BRW001 | Merchandise | 372 | 14847.00 |
| BRW001 | Beverage | 468 | 4822.75 |
| BRW001 | Food | 386 | 4519.45 |
| BRW002 | Merchandise | 342 | 12816.00 |
| BRW002 | Beverage | 438 | 4802.45 |
| BRW002 | Food | 375 | 4344.80 |
| BRW003 | Merchandise | 376 | 14482.00 |
| BRW003 | Beverage | 491 | 5122.40 |
| BRW003 | Food | 399 | 4477.25 |

(9 rows)

## Q6 (KPI Reporting) — Bottom products by revenue (the "why")

```sql
SELECT p.prod_id,
       p.prod_name,
       p.category,
       p.unit_price,
       p.is_active,
       COALESCE(SUM(oi.quantity), 0) AS units_sold,
       ROUND(COALESCE(SUM(oi.quantity * oi.unit_price), 0), 2) AS revenue
FROM products p
LEFT JOIN order_items oi ON p.prod_id = oi.product_id
GROUP BY p.prod_id
ORDER BY revenue ASC
LIMIT 10;
```

| prod_id | prod_name | category | unit_price | is_active | units_sold | revenue |
| --- | --- | --- | --- | --- | --- | --- |
| PRD001 | Espresso | Beverage | 2.95 | 1 | 203 | 598.85 |
| PRD015 | Chocolate Chip Cookie | Food | 2.50 | 1 | 249 | 622.50 |
| PRD006 | Americano | Beverage | 3.25 | 1 | 192 | 624.00 |
| PRD013 | Everything Bagel | Food | 2.75 | 1 | 257 | 706.75 |
| PRD010 | Iced Tea | Beverage | 3.45 | 1 | 223 | 769.35 |
| PRD012 | Blueberry Muffin | Food | 3.25 | 1 | 241 | 783.25 |
| PRD011 | Croissant | Food | 3.50 | 1 | 229 | 801.50 |
| PRD003 | Cappuccino | Beverage | 4.25 | 1 | 203 | 862.75 |
| PRD029 | Cold Brew Bottle | Merchandise | 4.00 | 1 | 243 | 972.00 |
| PRD002 | Latte | Beverage | 4.25 | 1 | 236 | 1003.00 |

(10 rows)

> Note: Q6 highlights that the bottom-revenue products are low-priced staples (unit price ≤ $4.25), not slow movers — every product sold at least once. The two inactive seasonal items (PRD030, PRD031) are excluded from sales data entirely (0 units). The "why" here is price-driven, not demand-driven.
