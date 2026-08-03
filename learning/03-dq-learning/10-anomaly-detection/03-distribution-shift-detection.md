# Lesson 10.3: Distribution-Shift Detection

A **distribution shift** is when the *baseline* changes — not a one-day spike, but a sustained change. Shifts are the sneakiest data quality problems because nothing "looks broken" — the numbers are just different.

Our dataset has a real shift: from **2026-07-21**, the `daily_sales` baseline jumps from ~48-56 to ~75+ (the "promotion").

---

## Why Shifts Matter

| Type | Effect | Example |
|------|--------|---------|
| Sudden spike (Unit 10.1) | One anomalous day | 520 orders on one day |
| **Distribution shift** | New baseline | Orders permanently jump from 50 → 80 |
| Slow drift | Gradual change | Orders creep up 1%/week unnoticed |

Shifts break forecasts, dashboards, and models silently. **The data looks fine — it's just not the same data.**

---

## Detecting a Shift: Compare Two Windows

The simplest shift check: compare the current period to the previous period.

```sql
-- Current week vs previous week, per region
SELECT
    region_id,
    SUM(CASE WHEN sale_date BETWEEN '2026-07-21' AND '2026-07-27' THEN total_orders END) AS current_week,
    SUM(CASE WHEN sale_date BETWEEN '2026-07-14' AND '2026-07-20' THEN total_orders END) AS prev_week,
    ROUND(
        (SUM(CASE WHEN sale_date BETWEEN '2026-07-21' AND '2026-07-27' THEN total_orders END)
       - SUM(CASE WHEN sale_date BETWEEN '2026-07-14' AND '2026-07-20' THEN total_orders END))
      / NULLIF(SUM(CASE WHEN sale_date BETWEEN '2026-07-14' AND '2026-07-20' THEN total_orders END), 0)
      * 100, 1) AS change_pct
FROM daily_sales
GROUP BY region_id;
```

**Expected output:**

| region_id | current_week | prev_week | change_pct |
|-----------|--------------|-----------|------------|
| RGN001 | ~595 | ~439 | ~+35% |
| RGN002 | ~595 | ~439 | ~+35% |

A ~35% week-over-week jump with **no business justification** is a shift to investigate.

---

## The Moving-Average Baseline

A **rolling average** smooths noise and reveals the underlying trend:

```sql
SELECT
    sale_date,
    region_id,
    total_orders,
    ROUND(AVG(total_orders) OVER (
        PARTITION BY region_id
        ORDER BY sale_date
        ROWS BETWEEN 13 PRECEDING AND CURRENT ROW
    ), 1) AS 14day_moving_avg
FROM daily_sales
WHERE total_orders IS NOT NULL
ORDER BY region_id, sale_date;
```

**Expected output (rows around the shift):**

| sale_date | region_id | total_orders | 14day_moving_avg |
|-----------|-----------|--------------|------------------|
| 2026-07-20 | RGN001 | 51 | ~61 |
| 2026-07-21 | RGN001 | 82 | ~63 |
| 2026-07-25 | RGN001 | 86 | ~71 |
| 2026-07-31 | RGN001 | 77 | ~81 |

The moving average climbs from ~61 to ~81 after 2026-07-21 — the baseline moved.

---

## Detecting the Shift Programmatically

Compare today's value against the trailing window's moving average:

```sql
WITH baseline AS (
    SELECT
        sale_date, region_id, total_orders,
        AVG(total_orders) OVER (
            PARTITION BY region_id
            ORDER BY sale_date
            ROWS BETWEEN 13 PRECEDING AND 1 PRECEDING
        ) AS prev_14_avg
    FROM daily_sales
    WHERE total_orders IS NOT NULL
)
SELECT sale_date, region_id, total_orders,
       ROUND(prev_14_avg, 1) AS baseline_avg,
       ROUND((total_orders - prev_14_avg) / NULLIF(prev_14_avg, 0) * 100, 1) AS deviation_pct
FROM baseline
WHERE sale_date >= '2026-07-21'
  AND ABS((total_orders - prev_14_avg) / NULLIF(prev_14_avg, 0)) > 0.2;   -- > 20% deviation
```

**Expected output:** the rows from 2026-07-21 onward that deviate >20% from their trailing baseline — the new regime.

---

## Drift Detection (slow change)

For **slow drift**, compare the latest window average to a long historical average:

```sql
SELECT
    region_id,
    AVG(CASE WHEN sale_date >= '2026-07-21' THEN total_orders END) AS post_shift_avg,
    AVG(CASE WHEN sale_date <  '2026-07-21' THEN total_orders END) AS pre_shift_avg,
    ROUND(
        (AVG(CASE WHEN sale_date >= '2026-07-21' THEN total_orders END)
       - AVG(CASE WHEN sale_date <  '2026-07-21' THEN total_orders END))
      / NULLIF(AVG(CASE WHEN sale_date <  '2026-07-21' THEN total_orders END), 0) * 100, 1) AS shift_pct
FROM daily_sales
GROUP BY region_id;
```

**Expected output:**

| region_id | post_shift_avg | pre_shift_avg | shift_pct |
|-----------|----------------|---------------|-----------|
| RGN001 | ~83 | ~68 | ~+22% |
| RGN002 | ~83 | ~68 | ~+22% |

---

## The Shift-Investigation Protocol

1. **Flag** — moving-average deviation or window comparison exceeds threshold.
2. **Confirm** — is it sustained (not a one-day spike)?
3. **Explain** — real promotion? new store? data-load change? (business call)
4. **Re-baseline** — if legitimate, update expectations; if a bug, alert.

---

## English Translation (of this lesson)

> "Distribution shifts are sustained baseline changes, not one-day spikes. I detect them by comparing current vs previous windows, using moving averages to smooth noise, and measuring deviation from a trailing baseline. A persistent >20% change needs investigation: either re-baseline (real change) or alert (data bug)."

---

## Key Takeaways

1. **Shift = baseline change**; drift = slow baseline change.
2. Compare **current vs previous windows** or use a **14-day moving average**.
3. Flag when deviation from the trailing baseline exceeds **~20%**.
4. **Re-baseline** legit changes; **alert** on suspicious ones — a business call.
5. Moving averages are your smoothing tool for noisy daily data.

**Coming up next:** Time-series spike detection.
