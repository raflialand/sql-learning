# dq_dataset — Schema & Seeded Defect Map

The purpose-built **dirty** dataset for this module. Everything is MySQL 8 compatible. Reference date for "now" is **2026-08-03** — any date after that is *in the future*.

---

## Business Purpose

This simulates a small e-commerce company:

| Table | Business purpose | Consumers |
|-------|------------------|-----------|
| `customers` | Customer master profile (CRM) | Marketing, Finance, Support |
| `products` | Product catalog (master data) | Commerce, Inventory |
| `addresses` | Customer shipping addresses | Operations, Logistics |
| `orders` | Order headers (sales transactions) | Finance, Ops, Analytics |
| `order_items` | Line items per order | Finance, Analytics |
| `daily_sales` | Pre-aggregated daily metrics by region | Executive dashboards |

---

## Table Map & Seeded Defects

Each row is intentionally planted so every DQ dimension has something to find.

### `customers` (15 rows)

| customer_id | Defect type | Dimension |
|-------------|-------------|-----------|
| 2 | Exact duplicate of #1 (same name, email, phone, state, date) | Uniqueness |
| 4 | Near duplicate of #3 — same phone, `state = 'California'` vs `'CA'` | Uniqueness / Consistency |
| 5 | `email` is NULL | Completeness |
| 6 | Invalid email (`david.wilson@@example.com`), state lowercase `'tx'` | Validity / Consistency |
| 7 | Invalid email (no TLD: `eve.brown@example`), `phone` NULL | Validity / Completeness |
| 8 | `signup_date` NULL | Completeness |
| 9 | Phone uses dots (`555.777.8888`) instead of dashes | Validity / Consistency |
| 10 | `phone` NULL | Completeness |
| 12 | Near duplicate of #11 — `state = 'Oregon'` vs `'OR'` | Uniqueness / Consistency |
| 14 | Fully empty row (all fields NULL) | Completeness |

### `products` (12 rows)

| product_id | Defect type | Dimension |
|------------|-------------|-----------|
| 2 | Duplicate SKU of #1 | Uniqueness |
| 3 | Negative price (`-5.00`) | Validity |
| 4 | Zero price (`0.00`) | Validity |
| 5 | Out-of-range weight (`150.00` kg for a chair; master says 12) | Validity / Accuracy |
| 6 | `discontinued_at` in the past (2025-01-01) but `is_active = 1` | Consistency |
| 8 | `category` NULL | Completeness |
| 11 | Duplicate SKU of #7 | Uniqueness |

### `addresses` (12 rows)

| address_id | Defect type | Dimension |
|------------|-------------|-----------|
| 2 | Duplicate address row for customer 1 | Uniqueness |
| 5 | Country `'US'` vs the `'USA'` convention | Consistency |
| 12 | Country `'United States'` vs `'USA'` convention | Consistency |

### `orders` (15 rows)

| order_id | Defect type | Dimension |
|----------|-------------|-----------|
| 3 | Orphan `customer_id = 99` (no customer 99) | Consistency |
| 4 | `ship_city` NULL AND `total_amount` NULL | Completeness |
| 5 | Future `order_date` (2026-08-15 > reference date) | Timeliness |
| 8 | Status `'Shipped'` (mixed case) | Consistency / Validity |
| 9 | Status `'SHIPPED'` (uppercase) | Consistency / Validity |
| 10 | Status `'shippd'` (typo) | Validity |
| 12, 13 | Order currency `EUR` (rest of dataset is USD) | Consistency |
| 15 | `ship_city` NULL, `total_amount` 0.00 with items beneath it | Completeness / Accuracy |

### `order_items` (20 rows)

| item_id | Defect type | Dimension |
|---------|-------------|-----------|
| 4 | Orphan `product_id = 99` (no product 99) | Consistency |
| 5 | `total_price` (4.00) != `qty * unit_price` (1 × 5.00) | Accuracy |
| 7 | Item from a zero-price product (0.00) | Accuracy / Validity |
| 11 | Zero `qty` (0) with a price | Validity |
| 14 | `currency = 'USD'` while parent order 12 is `EUR` | Consistency |
| 19 | Negative `qty` (-1) | Validity |
| 20 | Orphan `order_id = 999` (no order 999) | Consistency |

### `daily_sales` (2 regions × 92 days)

| Defect | Location | Dimension |
|--------|----------|-----------|
| Huge spike in orders/revenue | 2026-06-15, RGN001 (520 orders vs ~48-80 baseline) | Anomaly detection |
| Deep dip | 2026-06-25, RGN002 (3 orders) | Anomaly detection |
| `total_revenue` NULL | 2026-06-05, RGN002 | Completeness |
| `total_items` NULL | 2026-07-11, RGN001 | Completeness |
| Distribution shift | Baseline raised from 2026-07-21 (promotion) | Anomaly detection / Timeliness |

---

## Clean Reference Dataset (`dq_dataset_clean.sql`)

Separate, prefixed tables (`dq_clean_*`) that represent the **master data / source of truth**:

- `dq_clean_customers` — correct email, phone, state for customers 1-13.
- `dq_clean_products` — correct `unit_price` and `weight_kg` (note: USB-C Cable master price is **9.99**, dirty is **-5.00**; Desk Lamp master **24.99**, dirty **0.00**; Coffee Maker discontinued 2026-01-01 and inactive).
- `dq_clean_orders` / `dq_clean_order_items` — internally consistent totals.
- `dq_clean_daily_sales` — smooth baseline, no anomalies.

Use it in Unit 07 (Accuracy) by joining `customers` ↔ `dq_clean_customers` or `products` ↔ `dq_clean_products` on the natural key.
