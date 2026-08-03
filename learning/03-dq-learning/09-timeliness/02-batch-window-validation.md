# Lesson 9.2: Batch-Window Validation

Batch pipelines load data in scheduled windows. **Batch-window validation** checks that data arrived *for the right time period* — not too early, not too late, and not missing expected time buckets.

---

## The Concept

A nightly load should contain data for *exactly* yesterday (or today, depending on convention). Three things can go wrong:

1. **Missing buckets** — no rows for a day that should have data.
2. **Late data** — rows for an old day appear after the window closed.
3. **Early/future data** — rows dated after "now".

---

## Missing Time Buckets — the Calendar Anti-Join

The classic technique: generate a calendar, then find days with no data.

```sql
-- Days in the last 14 days with no daily_sales rows (per region)
WITH RECURSIVE date_spine AS (
    SELECT '2026-07-20' AS d
    UNION ALL
    SELECT DATE_ADD(d, INTERVAL 1 DAY) FROM date_spine WHERE d < '2026-08-02'
)
SELECT s.d AS missing_date
FROM date_spine s
LEFT JOIN daily_sales ds ON ds.sale_date = s.d
WHERE ds.sale_date IS NULL
ORDER BY s.d;
```

**Expected output:** no rows — every day has data. (If we widened the window to include today, it might reveal a missing bucket.)

> **Why it matters:** a missing day means the executive dashboard silently drops a day of revenue — users rarely notice, but the number is wrong.

---

## Per-Region Completeness of Time Buckets

More precise: check that *each region* has data for each expected day:

```sql
WITH RECURSIVE date_spine AS (
    SELECT '2026-07-20' AS d
    UNION ALL
    SELECT DATE_ADD(d, INTERVAL 1 DAY) FROM date_spine WHERE d < '2026-07-31'
)
SELECT s.d, r.region_id
FROM date_spine s
CROSS JOIN (SELECT 'RGN001' AS region_id UNION ALL SELECT 'RGN002') r
LEFT JOIN daily_sales ds
    ON ds.sale_date = s.d AND ds.region_id = r.region_id
WHERE ds.sale_date IS NULL;
```

**Expected output:** no rows for the window 2026-07-20..07-31 (both regions loaded every day). This is a *completeness-over-time* check — the time dimension adds the "expected" denominator.

---

## Late-Data Detection

Data arriving after its window is late. If we had a `loaded_at` timestamp, we'd check `loaded_at - event_date > window`. Without one, we can approximate with known expectations:

```sql
-- Orders that should have been loaded already but reference old dates
-- (assume a nightly load; anything > 7 days old with status 'pending'
--  is stale and may indicate a delayed feed)
SELECT order_id, order_date, status, DATEDIFF('2026-08-03', order_date) AS age_days
FROM orders
WHERE status = 'pending'
  AND order_date < DATE_SUB('2026-08-03', INTERVAL 7 DAY);
```

**Expected output (1 row):**

| order_id | order_date | status | age_days |
|----------|------------|--------|----------|
| 14 | 2026-06-30 | pending | 34 |

Order 14 has been pending for over a month — either the feed stopped updating it (staleness) or the business forgot it (actionable!).

---

## The Batch-Window Pattern

```
expected_time_window = <from date> .. <to date>
missing = expected_buckets LEFT JOIN actual WHERE actual IS NULL
late    = rows where event_date << expected
early   = rows where event_date > now
```

| Check | Pattern |
|-------|---------|
| Missing buckets | `date_spine LEFT JOIN table WHERE table IS NULL` |
| Late data | `WHERE event_date < DATE_SUB(now, INTERVAL window)` |
| Early data | `WHERE event_date > now` (Lesson 9.3) |

---

## Business Framing

| Consumer | Window | Failure cost |
|----------|--------|--------------|
| Executive dashboard | daily by 06:00 | Yesterday's revenue missing from morning brief |
| Finance month-end | month close | Incomplete month booked |
| Ops fulfillment | hourly | Orders not picked up on time |

The window definition **always comes from the business** (Unit 02). Your SQL enforces it.

---

## English Translation (of this lesson)

> "Batch pipelines load in time windows. I validate that every expected time bucket has data — building a date spine and left-joining the table to find missing days. I also catch late data (old events still pending) and early data. Missing buckets silently drop from reports, so this check runs on every load."

---

## Key Takeaways

1. **Batch-window validation** ensures the right data arrived for the right period.
2. Build a **date spine** and LEFT JOIN to find **missing buckets**.
3. Missing data is **silently invisible** in reports — that's why it's dangerous.
4. **Late data** = events far older than the expected window.
5. Windows come from the **business SLA** (Unit 02).

**Coming up next:** Future dates and expiry.
