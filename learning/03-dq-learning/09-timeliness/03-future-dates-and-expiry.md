# Lesson 9.3: Future Dates and Expiry

Two timeliness defects are extremely common: **future dates** (data dated beyond now) and **expired records** (data that should no longer be active). Both are easy to detect with date comparisons.

---

## Future Dates — the Data Is "From the Future"

A future date usually means a bad system clock, a wrong feed, or a data-entry error.

```sql
-- Orders dated after the reference date
SELECT order_id, order_date, status, total_amount
FROM orders
WHERE order_date > '2026-08-03';
```

**Expected output (1 row):**

| order_id | order_date | status | total_amount |
|----------|------------|--------|--------------|
| 5 | 2026-08-15 | shipped | 199.99 |

Order 5 is dated 12 days in the future. It will land in the wrong reporting period, and any "today" filter will drop it until then.

---

## Future Dates — Count and Percentage

```sql
SELECT
    COUNT(*) AS total_orders,
    SUM(order_date > '2026-08-03') AS future_orders,
    ROUND(SUM(order_date > '2026-08-03') * 100.0 / COUNT(*), 1) AS future_pct
FROM orders;
```

**Expected output:**

| total_orders | future_orders | future_pct |
|--------------|---------------|------------|
| 15 | 1 | 6.7 |

---

## The Future-Date PASS/FAIL Rule

```sql
SELECT
    CASE
        WHEN SUM(order_date > '2026-08-03') = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS future_date_check
FROM orders;
```

**Expected output: `FAIL`**

> **Note:** use `CURRENT_DATE` (or `CURDATE()`) in production so the check adapts to today automatically:
> ```sql
> WHERE order_date > CURDATE()
> ```

---

## Expired Records — Should Have Ended

Expiry logic: a record is **expired** if its end date is in the past, or if a product was discontinued before now.

```sql
-- Products marked discontinued in the past (expired lifecycle)
SELECT product_id, sku, product_name, discontinued_at, is_active
FROM products
WHERE discontinued_at IS NOT NULL
  AND discontinued_at < '2026-08-03';
```

**Expected output:**

| product_id | sku | product_name | discontinued_at | is_active |
|------------|-----|--------------|-----------------|-----------|
| 6 | SKU-1005 | Coffee Maker | 2025-01-01 | 1 |

Product 6 was discontinued in 2025 but is *still active* — an expired record that should have been deactivated. (We caught the same row from the lifecycle-rule angle in Unit 07; here it's the timeliness framing: the record outlived its expiry.)

---

## Expiry vs Current-Status Consistency

Combine future-date and expiry logic into a single timeliness report:

```sql
SELECT 'future-dated orders' AS check_name,
       COUNT(*) AS violations
FROM orders
WHERE order_date > '2026-08-03'
UNION ALL
SELECT 'expired-but-active products',
       COUNT(*)
FROM products
WHERE discontinued_at IS NOT NULL
  AND discontinued_at < '2026-08-03'
  AND is_active = 1;
```

**Expected output:**

| check_name | violations |
|------------|------------|
| future-dated orders | 1 |
| expired-but-active products | 1 |

---

## Handling Date Types and Formats

- **`DATE` / `DATETIME` columns** — compare directly: `order_date > CURDATE()`.
- **String dates** — validate format first (Unit 06), then `CAST`/`STR_TO_DATE` before comparing.
- **Timezone** — a naive `MAX(date)` ignores timezones. In production, store and compare in **UTC**, convert for display.

```sql
-- If order_date were a string column 'YYYY-MM-DD'
SELECT order_id
FROM orders
WHERE STR_TO_DATE(order_date, '%Y-%m-%d') > CURDATE();
```

---

## English Translation (of this lesson)

> "Future dates and expired records are two common timeliness defects. I check future dates with order_date > CURDATE(), and I check expiry with end/discontinuation dates in the past. Both can be rolled into one timeliness report. In production I use CURDATE() and UTC so the check adapts to today."

---

## Key Takeaways

1. **Future dates** = `date > CURDATE()` — wrong period, dropped by "today" filters.
2. **Expired records** = end date in the past but still marked active.
3. Use **`CURDATE()`/`CURRENT_DATE`** in production so checks adapt.
4. Combine multiple timeliness checks into **one report**.
5. Watch **types and timezones** — normalize dates before comparing.

---

## Unit 09 Exercises → practice timeliness checks.

Move on to `exercises.md`.
