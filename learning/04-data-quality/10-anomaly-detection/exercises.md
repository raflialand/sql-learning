# Exercises: Unit 10 — Anomaly Detection

*All exercises run against `dq_learning` — specifically the `daily_sales` table (2 regions × 92 days, seeded with a spike, a dip, a NULL, and a shift).*

---

## Part A: Write the Query

### Exercise 10.1 — Z-score of daily orders

Write a query computing the z-score of `total_orders` per region (using a `stats` CTE with `AVG` and `STDDEV_POP`).

**Expected:** the 2026-06-15 RGN001 spike (520) has a very high z-score (> 3).

### Exercise 10.2 — Flag outliers with |z| > 2

Extend 10.1 to flag only rows with `ABS(z_score) > 2`.

**Expected:** 2026-06-15 (520) and 2026-06-25 (3, RGN002) at least.

### Exercise 10.3 — IQR outlier flag

Write an IQR-based query flagging daily orders outside `Q1 − 1.5·IQR` .. `Q3 + 1.5·IQR` per region.

**Expected:** the spike (520) is flagged OUTLIER; the dip (3) lands exactly on the lower fence (~3) — note that it may or may not flag depending on the fence calculation. Confirm by also running the z-score and LAG checks.

### Exercise 10.4 — Week-over-week spike (LAG 7)

Write a query using `LAG(total_orders, 7)` per region that finds days more than **50%** above the same weekday last week.

**Expected:** 2026-06-15 RGN001 (520 vs 54, ~+863%).

### Exercise 10.5 — Both directions (ABS)

Modify 10.4 with `ABS(...)` to also catch the dip.

**Expected:** spike and dip both surface.

### Exercise 10.6 — Moving-average deviation

Write a query computing a 14-day trailing average (excluding today) and flag days from 2026-07-21 whose value deviates >20% from it.

**Expected:** the post-2026-07-21 baseline-change rows.

### Exercise 10.7 — Window comparison (shift)

Write a query comparing `daily_sales.total_orders` for `2026-07-21..07-27` vs `2026-07-14..07-20` per region, as a change percentage.

**Expected:** large positive change (~+35%) — the promotion shift.

---

## Part B: Translate the Query

### Exercise 10.8

Explain what `LAG(total_orders, 7) OVER (PARTITION BY region_id ORDER BY sale_date)` returns and why the `7` matters.

### Exercise 10.9

Explain the purpose of `NULLIF(sigma, 0)`:

```sql
ROUND((total_orders - mu) / NULLIF(sigma, 0), 2) AS z_score
```

### Exercise 10.10

Explain what the result of this query means for monitoring:

```sql
SELECT sale_date, region_id, total_orders,
       ROUND(AVG(total_orders) OVER (
           PARTITION BY region_id ORDER BY sale_date
           ROWS BETWEEN 13 PRECEDING AND 1 PRECEDING), 1) AS trailing_avg
FROM daily_sales
WHERE total_orders IS NOT NULL;
```

---

## Part C: Debug the Query

### Exercise 10.11 — Buggy z-score (no partition)

**Intended purpose:** z-score per region.

```sql
WITH stats AS (
    SELECT AVG(total_orders) AS mu, STDDEV_POP(total_orders) AS sigma FROM daily_sales
)
SELECT sale_date, total_orders, (total_orders - mu) / sigma AS z
FROM daily_sales, stats;
```

**Bug:** no `region_id` in the stats CTE → one global mean mixes both regions. Fix by adding `region_id` to the CTE and joining on it.

### Exercise 10.12 — Buggy LAG baseline

**Intended purpose:** compare to same weekday last week.

```sql
SELECT sale_date, total_orders,
       LAG(total_orders) OVER (ORDER BY sale_date) AS baseline
FROM daily_sales;
```

**Bug:** `LAG` without offset defaults to previous *day* (1), and there's no `PARTITION BY region_id`. Fix: `LAG(total_orders, 7) OVER (PARTITION BY region_id ORDER BY sale_date)`.

### Exercise 10.13 — Buggy deviation threshold

**Intended purpose:** flag rows where deviation from baseline > 20%.

```sql
WITH b AS (
    SELECT sale_date, total_orders,
           AVG(total_orders) OVER (ORDER BY sale_date ROWS BETWEEN 13 PRECEDING AND 1 PRECEDING) AS avg
    FROM daily_sales
)
SELECT sale_date, total_orders, avg
FROM b
WHERE total_orders > 1.2 * avg;
```

**Bug (conceptual):** only flags *above* the threshold — never catches dips. Also `avg` is NULL for the first rows. Fix with `ABS()` and handle NULLs (`WHERE avg IS NOT NULL`).

---

## Self-Assessment Checkpoint

- [ ] I can compute z-scores with a stats CTE and `STDDEV_POP`
- [ ] I can flag outliers with `ABS(z) > 2`
- [ ] I can build an IQR outlier check with `ROW_NUMBER`-based quartiles
- [ ] I can detect week-over-week spikes with `LAG(x, 7)`
- [ ] I can catch dips with `ABS()`
- [ ] I can detect distribution shifts with moving averages and window comparisons

**Ready to continue?** Move to **Unit 11 — DQ Monitoring & Reporting**.
