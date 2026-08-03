# Lesson 10.2: IQR and Percentile Bounds

The **Interquartile Range (IQR)** method flags outliers using quartiles instead of mean/stddev — it is **robust to outliers** because quartiles aren't dragged by extreme values.

---

## The IQR Method

```
Q1 = 25th percentile
Q3 = 75th percentile
IQR = Q3 − Q1
Lower fence = Q1 − 1.5 × IQR
Upper fence = Q3 + 1.5 × IQR
Anything outside the fences is an outlier
```

---

## Percentiles in MySQL

MySQL 8 has **window functions** — perfect for percentile work:

```sql
-- Percentile ranks of daily orders
SELECT
    sale_date,
    region_id,
    total_orders,
    ROUND(PERCENT_RANK() OVER (PARTITION BY region_id ORDER BY total_orders), 3) AS pct_rank
FROM daily_sales
WHERE total_orders IS NOT NULL
ORDER BY pct_rank DESC;
```

`PERCENT_RANK()` gives each value its relative rank 0..1. The 520-order day will have pct_rank = 1.0 (the max).

---

## The IQR Outlier Query

```sql
WITH ordered AS (
    SELECT
        region_id,
        total_orders,
        ROW_NUMBER() OVER (PARTITION BY region_id ORDER BY total_orders) AS rn,
        COUNT(*) OVER (PARTITION BY region_id) AS n
    FROM daily_sales
    WHERE total_orders IS NOT NULL
),
quartiles AS (
    SELECT
        region_id,
        MAX(CASE WHEN rn <= CEIL(0.25 * n) THEN total_orders END) AS q1,
        MAX(CASE WHEN rn <= CEIL(0.75 * n) THEN total_orders END) AS q3
    FROM ordered
    GROUP BY region_id
)
SELECT
    ds.sale_date, ds.region_id, ds.total_orders,
    q.q1, q.q3,
    q.q3 - q.q1 AS iqr,
    q.q1 - 1.5 * (q.q3 - q.q1) AS lower_fence,
    q.q3 + 1.5 * (q.q3 - q.q1) AS upper_fence,
    CASE
        WHEN ds.total_orders < q.q1 - 1.5 * (q.q3 - q.q1)
          OR ds.total_orders > q.q3 + 1.5 * (q.q3 - q.q1)
        THEN 'OUTLIER' ELSE 'ok'
    END AS flag
FROM daily_sales ds
JOIN quartiles q ON ds.region_id = q.region_id
WHERE ds.total_orders IS NOT NULL
ORDER BY ds.total_orders DESC;
```

**Expected output (top rows):**

| sale_date | region_id | total_orders | q1 | q3 | iqr | lower_fence | upper_fence | flag |
|-----------|-----------|--------------|----|----|-----|-------------|-------------|------|
| 2026-06-15 | RGN001 | 520 | 51 | 83 | 32 | 3 | 131 | OUTLIER |
| 2026-06-25 | RGN002 | 3 | 51 | 83 | 32 | 3 | 131 | ok (boundary) |

**Decode the results:**
- **The spike (520) is clearly OUTLIER** — 520 > upper fence 131. The IQR method flags it robustly.
- **The dip (3) lands exactly ON the lower fence (3)** — with a strict `<` comparison it is *not* flagged. It *is* a genuine anomaly (verified by z-score and LAG in the other lessons), but the 1.5×IQR fence sits right at the value.

> **Honest takeaway:** the 1.5×IQR fence is a heuristic, not a law. Values near the fence are *boundary cases* — you investigate them, then decide with domain knowledge. This is why a real DQ engineer combines methods (z-score, IQR, LAG) instead of trusting one fence. (Quartile *definition* also changes the exact fence — e.g., `PERCENTILE_CONT` vs the `ROW_NUMBER` approximation below.)

> **Simplification:** the quartile approximation above (using `ROW_NUMBER` + `CEIL`) is a practical SQL technique. Exact percentile functions differ per database (e.g., `PERCENTILE_CONT` exists in SQL Server/PostgreSQL, not in MySQL 8).

---

## The Simpler Percentile-Based Threshold

For monitoring, an approximation is often enough — flag anything above the 99th percentile or below the 1st:

```sql
WITH pcts AS (
    SELECT
        region_id,
        MAX(CASE WHEN rn <= CEIL(0.99 * n) THEN total_orders END) AS p99,
        MAX(CASE WHEN rn <= CEIL(0.01 * n) THEN total_orders END) AS p01
    FROM (
        SELECT region_id, total_orders,
               ROW_NUMBER() OVER (PARTITION BY region_id ORDER BY total_orders) AS rn,
               COUNT(*) OVER (PARTITION BY region_id) AS n
        FROM daily_sales WHERE total_orders IS NOT NULL
    ) t
    GROUP BY region_id
)
SELECT ds.sale_date, ds.region_id, ds.total_orders, p.p01, p.p99
FROM daily_sales ds
JOIN pcts p ON ds.region_id = p.region_id
WHERE ds.total_orders > p.p99 OR ds.total_orders < p.p01;
```

**Expected output:** the spike (520) and the dip (3).

---

## IQR vs Z-Score

| | Z-score | IQR |
|---|---------|-----|
| Center | mean | median (via quartiles) |
| Spread | stddev | IQR |
| Outlier-robust | ❌ (mean/stddev affected) | ✅ (quartiles resist extremes) |
| Best for | roughly normal data | skewed data, heavy tails |
| MySQL 8 support | easy (`STDDEV_POP`) | manual quartile math |

For DQ monitoring, **either works** — the point is adaptive, data-driven thresholds rather than hard-coded numbers.

---

## English Translation (of this lesson)

> "The IQR method computes quartiles and flags anything outside Q1−1.5×IQR or Q3+1.5×IQR. It's robust to outliers because quartiles resist extremes. In MySQL I approximate quartiles with ROW_NUMBER and CEIL over window counts. IQR and z-score are two adaptive ways to set thresholds instead of guessing fixed bounds."

---

## Key Takeaways

1. **IQR = Q3 − Q1**; fences at `Q1 − 1.5·IQR` and `Q3 + 1.5·IQR`.
2. **Robust to outliers** — quartiles resist extreme values.
3. MySQL 8: approximate quartiles with **`ROW_NUMBER()` + `CEIL(n·p)`**.
4. IQR catches **both spikes and dips** (robust center).
5. Use **adaptive thresholds** (z-score or IQR) for monitoring, not fixed bounds.

**Coming up next:** Distribution-shift detection.
