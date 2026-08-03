# Lesson 9.1: Data Freshness and Lag

**Timeliness** answers: *is the data available when needed and up to date?* The core metric is **freshness** — how recent the data is — and **lag** — how far behind "now" it has fallen.

Reference date for this module: **2026-08-03**.

---

## Freshness — How Old Is the Data?

The freshest record tells you how current the table is:

```sql
SELECT
    MAX(order_date) AS latest_order,
    DATEDIFF('2026-08-03', MAX(order_date)) AS days_since_latest
FROM orders;
```

**Expected output:**

| latest_order | days_since_latest |
|--------------|-------------------|
| 2026-08-15 | -12 |

`days_since_latest = -12` (negative) means the newest order is **12 days in the future** — a future-date defect (covered in Lesson 9.3). In a healthy table, this value is small and non-negative.

---

## The Freshness Report (per table)

```sql
SELECT
    'orders'      AS dataset,
    MAX(order_date) AS max_date,
    DATEDIFF('2026-08-03', MAX(order_date)) AS days_behind
FROM orders
UNION ALL
SELECT
    'daily_sales',
    MAX(sale_date),
    DATEDIFF('2026-08-03', MAX(sale_date))
FROM daily_sales;
```

**Expected output:**

| dataset | max_date | days_behind |
|---------|----------|-------------|
| orders | 2026-08-15 | -12 |
| daily_sales | 2026-07-31 | 3 |

- `orders` is "ahead of now" (future rows exist) — investigate.
- `daily_sales` ends 3 days before the reference date — if the dashboard expects daily data through today, that's **stale**.

---

## Lag — Measuring Pipeline Delay

**Lag** = how long between an event and its appearance in the data. In batch pipelines, you expect data to arrive within a window (next lesson). A simple lag check: compare `MAX(order_date)` to the batch timestamp.

```sql
-- If orders are loaded nightly, the table should contain up to yesterday.
-- Rows older than the expected retention window are stale.
SELECT COUNT(*) AS stale_orders
FROM orders
WHERE order_date < '2025-01-01';
```

**Expected output:** `0` (no orders that old) — but the check matters when history is truncated incorrectly.

---

## Freshness Thresholds (from business context)

| Dataset | Consumer | Expected freshness | Check |
|---------|----------|--------------------|-------|
| `daily_sales` | Exec dashboard | ≤ 2 days behind | `DATEDIFF(CURDATE(), MAX(sale_date)) <= 2` |
| `orders` | Finance | no future dates, daily complete | `MAX(order_date) <= CURDATE()` |
| `customers` | CRM | within 1 day of last update | compare to a `last_updated` column |

```sql
-- PASS/FAIL: daily_sales freshness
SELECT
    CASE
        WHEN DATEDIFF('2026-08-03', MAX(sale_date)) <= 2 THEN 'PASS'
        ELSE 'FAIL'
    END AS freshness_check
FROM daily_sales;
```

**Expected output: `FAIL`** (3 days behind > 2-day threshold).

---

## The Freshness Pattern (memorize)

```
freshness = DATEDIFF(now, MAX(partition_date))
lag       = now - expected_arrival_time of latest data
```

1. Identify the **time column** (order_date, sale_date, event_time).
2. Compute `MAX(time)` per partition/table.
3. Compare against **now** and the **expected window**.
4. Threshold comes from the consumer's needs (Unit 02).

---

## English Translation (of this lesson)

> "Timeliness means the data is fresh and on time. Freshness is how recent the latest record is — MAX(date) minus now. Lag is how far behind schedule the data has fallen. I compute freshness per table, set thresholds from consumer needs, and PASS/FAIL against them. A future date or a stale max date both fail the check."

---

## Key Takeaways

1. **Freshness = `DATEDIFF(now, MAX(time))`** — the age of the newest data.
2. Negative freshness means **future dates** (defect).
3. **Lag** measures pipeline delay vs expected arrival.
4. Thresholds come from the **consumer's** needs.
5. The freshness pattern is a **PASS/FAIL** rule you can monitor.

**Coming up next:** Batch-window validation.
