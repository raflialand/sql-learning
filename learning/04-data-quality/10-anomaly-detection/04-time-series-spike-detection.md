# Lesson 10.4: Time-Series Spike Detection

**Spike detection** finds single points that deviate wildly from their neighbors — the 520-order day in `daily_sales`. The workhorse is the **`LAG()`** window function: compare each value to the previous period (or the same period last week).

---

## The LAG Function

`LAG(value, offset)` returns the value *offset rows back* in the ordered partition:

```sql
SELECT
    sale_date,
    total_orders,
    LAG(total_orders) OVER (ORDER BY sale_date) AS prev_day,
    LAG(total_orders, 7) OVER (ORDER BY sale_date) AS prev_week
FROM daily_sales
WHERE region_id = 'RGN001' AND total_orders IS NOT NULL
ORDER BY sale_date;
```

**Expected output (around the spike):**

| sale_date | total_orders | prev_day | prev_week |
|-----------|--------------|----------|-----------|
| 2026-06-14 | ~50 | ~51 | ~49 |
| 2026-06-15 | **520** | ~50 | 54 |
| 2026-06-16 | ~53 | 520 | ~51 |

`prev_week` (same weekday last week) is the smarter baseline — it accounts for weekly seasonality (weekends busier than weekdays).

---

## Day-over-Day Spike Detection

```sql
WITH lagged AS (
    SELECT
        sale_date, region_id, total_orders,
        LAG(total_orders, 7) OVER (PARTITION BY region_id ORDER BY sale_date) AS prev_week_orders
    FROM daily_sales
    WHERE total_orders IS NOT NULL
)
SELECT
    sale_date, region_id, total_orders, prev_week_orders,
    ROUND((total_orders - prev_week_orders) / NULLIF(prev_week_orders, 0) * 100, 1) AS vs_last_week_pct
FROM lagged
WHERE prev_week_orders IS NOT NULL
ORDER BY (total_orders - prev_week_orders) DESC;
```

**Expected output (top row):**

| sale_date | region_id | total_orders | prev_week_orders | vs_last_week_pct |
|-----------|-----------|--------------|------------------|------------------|
| 2026-06-15 | RGN001 | 520 | 54 | ~+863% |

A **+863%** jump versus the same weekday last week — that's a spike, not a normal fluctuation.

---

## The Week-Over-Week Spike Rule

```sql
WITH lagged AS (
    SELECT
        sale_date, region_id, total_orders,
        LAG(total_orders, 7) OVER (PARTITION BY region_id ORDER BY sale_date) AS prev_week
    FROM daily_sales
    WHERE total_orders IS NOT NULL
)
SELECT sale_date, region_id, total_orders, prev_week
FROM lagged
WHERE prev_week IS NOT NULL
  AND (total_orders - prev_week) / NULLIF(prev_week, 0) > 0.5   -- >50% above last week
ORDER BY (total_orders - prev_week) DESC;
```

**Expected output:**

| sale_date | region_id | total_orders | prev_week |
|-----------|-----------|--------------|-----------|
| 2026-06-15 | RGN001 | 520 | 54 |

The >50% threshold catches the spike. (The 2026-07-21 shift would also appear here — as we learned in 10.3, distinguish a *sustained* shift from a *one-day* spike.)

---

## Spikes on Both Ends — The Dip

Spike detection works both directions:

```sql
WITH lagged AS (
    SELECT sale_date, region_id, total_orders,
        LAG(total_orders, 7) OVER (PARTITION BY region_id ORDER BY sale_date) AS prev_week
    FROM daily_sales
    WHERE total_orders IS NOT NULL
)
SELECT sale_date, region_id, total_orders, prev_week
FROM lagged
WHERE prev_week IS NOT NULL
  AND ABS(total_orders - prev_week) / NULLIF(prev_week, 0) > 0.5
ORDER BY (total_orders - prev_week) ASC;
```

**Expected output:** both the spike (2026-06-15) and the dip (2026-06-25, 3 orders) surface with `ABS()`.

---

## Spike Detection Patterns (recap)

| Pattern | Baseline | Use |
|---------|----------|-----|
| Day-over-day | `LAG(x, 1)` | sudden day changes |
| **Week-over-week** | `LAG(x, 7)` | removes weekly seasonality (recommended) |
| Moving average | 14-day `AVG` over window | smooths noise, finds shifts |
| Z-score / IQR | mean±std / quartiles | distribution-based outliers |

**Rule of thumb:** always compare against the **same weekday last week** for daily metrics — it removes the biggest confounder (weekend vs weekday).

---

## English Translation (of this lesson)

> "Spike detection finds single points that deviate from their neighbors using LAG(). I compare each day against the same weekday last week — LAG(total_orders, 7) — to remove weekly seasonality. A >50% deviation is a spike worth investigating. The same logic catches dips too, by taking the absolute value."

---

## Key Takeaways

1. **`LAG(value, offset)`** is the spike-detection tool.
2. Use **`LAG(x, 7)`** for daily metrics — same weekday last week beats previous day.
3. **>`50%` deviation** is a practical spike threshold (calibrate per metric).
4. `ABS()` catches **dips** as well as spikes.
5. Distinguish **one-day spikes** from **sustained shifts** (Lesson 10.3).

---

## Unit 10 Exercises → practice anomaly detection.

Move on to `exercises.md`.
