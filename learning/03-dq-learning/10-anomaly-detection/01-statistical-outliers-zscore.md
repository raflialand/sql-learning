# Lesson 10.1: Statistical Outliers — The Z-Score

Anomaly detection finds values that are statistically unusual — the spikes and dips that a fixed rule (like "price > 0") would miss. The **z-score** measures how many standard deviations a value sits from the mean.

---

## The Z-Score Formula

```
z = (value - mean) / standard deviation
```

- `z ≈ 0` → value is typical
- `|z| > 2` → somewhat unusual
- `|z| > 3` → very unusual (outlier)

---

## Computing the Z-Score in SQL

```sql
-- Z-score of daily sales orders (per region)
WITH stats AS (
    SELECT
        region_id,
        AVG(total_orders)        AS mu,
        STDDEV_POP(total_orders) AS sigma
    FROM daily_sales
    WHERE total_orders IS NOT NULL
    GROUP BY region_id
)
SELECT
    ds.sale_date,
    ds.region_id,
    ds.total_orders,
    ROUND(s.mu, 2)      AS avg_orders,
    ROUND(s.sigma, 2)   AS std_orders,
    ROUND((ds.total_orders - s.mu) / NULLIF(s.sigma, 0), 2) AS z_score
FROM daily_sales ds
JOIN stats s ON ds.region_id = s.region_id
WHERE ds.total_orders IS NOT NULL
ORDER BY z_score DESC;
```

**Expected output (top rows, per-region stats):**

| sale_date | region_id | total_orders | avg_orders | std_orders | z_score |
|-----------|-----------|--------------|------------|------------|---------|
| 2026-06-15 | RGN001 | 520 | ~70 | ~50 | ~9.0 |
| 2026-06-25 | RGN002 | 3 | ~64 | ~17 | ~-3.5 |

> **Why the numbers differ per region:** RGN001 contains the spike (520), which inflates its own mean (~70) and stddev (~50) — that's why its z-score (~9) is lower than the raw ratio suggests. RGN002 contains the dip (3), so its stats stay clean (mean ~64, std ~17) and the dip scores z ≈ −3.5.

The **spike on 2026-06-15 (z ≈ 9)** is a screaming anomaly — a normal day is ~64-70 orders, this day is 520.

---

## Flagging Outliers with a Threshold

```sql
WITH stats AS (
    SELECT region_id,
        AVG(total_orders)        AS mu,
        STDDEV_POP(total_orders) AS sigma
    FROM daily_sales
    WHERE total_orders IS NOT NULL
    GROUP BY region_id
)
SELECT ds.sale_date, ds.region_id, ds.total_orders,
       ROUND((ds.total_orders - s.mu) / NULLIF(s.sigma, 0), 2) AS z_score
FROM daily_sales ds
JOIN stats s ON ds.region_id = s.region_id
WHERE ABS((ds.total_orders - s.mu) / NULLIF(s.sigma, 0)) > 3;
```

**Expected output:**

| sale_date | region_id | total_orders | z_score |
|-----------|-----------|--------------|---------|
| 2026-06-15 | RGN001 | 520 | ~9.0 |
| 2026-06-25 | RGN002 | 3 | ~-3.5 |

> **Check the numbers:** RGN001's spike (520) has z ≈ 9; RGN002's dip (3) has z ≈ −3.5. Both exceed the |z| > 3 threshold, so both are flagged. The 2026-07-21 promotion raises the baseline, but the spike still dwarfs everything.

**Both the spike and the dip are caught — even at the strict |z| > 3 threshold.**

---

## Why Z-Score (vs Fixed Bounds)

| Method | Catches | Misses |
|--------|---------|--------|
| Fixed bounds (`> 100`) | known limits | adaptive changes (promotion raises baseline) |
| Z-score | *relative* unusualness | needs stable distribution |

Z-score is **adaptive** — it flags values unusual *relative to their own distribution* — which is exactly what you want for monitoring (Unit 11).

---

## Cautions

1. **Sensitive to the mean/stddev being polluted** by the anomalies themselves (a huge spike inflates sigma). For monitoring, compute statistics on a *reference window* (e.g., trailing 30 days excluding today).
2. **Non-normal data** (counts, sales) may need transforms. For DQ *monitoring* purposes, z-score is still a practical early-warning heuristic.
3. Always **investigate flagged values** — an anomaly is a *symptom*, not a diagnosis. (The 06-15 spike might be a real promotion, a data-load bug, or a double-count.)

---

## English Translation (of this lesson)

> "The z-score tells me how many standard deviations a value is from its mean. I compute mean and stddev per region with a CTE, then flag any day whose |z| > 2 or 3. It's adaptive — it catches values unusual relative to their own distribution. Anomalies are symptoms; I still have to investigate what caused them."

---

## Key Takeaways

1. **z = (value − mean) / stddev** — measures relative unusualness.
2. Compute stats per **partition** (region) in a CTE.
3. **|z| > 2** flags anomalies; **|z| > 3** flags extreme ones.
4. **`NULLIF(sigma, 0)`** avoids divide-by-zero for constant columns.
5. Use a **reference window** to keep stats clean of anomalies themselves.

**Coming up next:** IQR and percentile bounds.
