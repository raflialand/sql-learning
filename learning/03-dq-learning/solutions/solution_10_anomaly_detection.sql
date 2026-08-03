-- Solutions: Unit 10 — Anomaly Detection
-- Run against dq_learning (daily_sales table)

-- =====================================================================
-- Exercise 10.1 — Z-score of daily orders per region
-- =====================================================================
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
WHERE ds.total_orders IS NOT NULL
ORDER BY z_score DESC;
-- Expected: 2026-06-15 RGN001 (520) has the top z-score

-- =====================================================================
-- Exercise 10.2 — Flag outliers with |z| > 2
-- =====================================================================
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
WHERE ds.total_orders IS NOT NULL
  AND ABS((ds.total_orders - s.mu) / NULLIF(s.sigma, 0)) > 2
ORDER BY z_score DESC;
-- Expected: 2026-06-15 (520) and 2026-06-25 (3) surface

-- =====================================================================
-- Exercise 10.3 — IQR outlier flag
-- =====================================================================
WITH ordered AS (
    SELECT region_id, total_orders,
        ROW_NUMBER() OVER (PARTITION BY region_id ORDER BY total_orders) AS rn,
        COUNT(*) OVER (PARTITION BY region_id) AS n
    FROM daily_sales
    WHERE total_orders IS NOT NULL
),
quartiles AS (
    SELECT region_id,
        MAX(CASE WHEN rn <= CEIL(0.25 * n) THEN total_orders END) AS q1,
        MAX(CASE WHEN rn <= CEIL(0.75 * n) THEN total_orders END) AS q3
    FROM ordered
    GROUP BY region_id
)
SELECT ds.sale_date, ds.region_id, ds.total_orders,
       q.q1 - 1.5 * (q.q3 - q.q1) AS lower_fence,
       q.q3 + 1.5 * (q.q3 - q.q1) AS upper_fence,
       CASE WHEN ds.total_orders < q.q1 - 1.5 * (q.q3 - q.q1)
              OR ds.total_orders > q.q3 + 1.5 * (q.q3 - q.q1)
            THEN 'OUTLIER' ELSE 'ok' END AS flag
FROM daily_sales ds
JOIN quartiles q ON ds.region_id = q.region_id
WHERE ds.total_orders IS NOT NULL
  AND (ds.total_orders < q.q1 - 1.5 * (q.q3 - q.q1)
    OR ds.total_orders > q.q3 + 1.5 * (q.q3 - q.q1))
ORDER BY ds.total_orders DESC;
-- Expected: the spike (520) flagged OUTLIER. The dip (3) sits exactly on
-- the lower fence (~3) so a strict < may not flag it -> combine with the
-- z-score and LAG checks (exercises 10.2/10.4) for a confident verdict.

-- =====================================================================
-- Exercise 10.4 — Week-over-week spike (LAG 7, >50%)
-- =====================================================================
WITH lagged AS (
    SELECT sale_date, region_id, total_orders,
        LAG(total_orders, 7) OVER (PARTITION BY region_id ORDER BY sale_date) AS prev_week
    FROM daily_sales
    WHERE total_orders IS NOT NULL
)
SELECT sale_date, region_id, total_orders, prev_week
FROM lagged
WHERE prev_week IS NOT NULL
  AND (total_orders - prev_week) / NULLIF(prev_week, 0) > 0.5
ORDER BY (total_orders - prev_week) DESC;
-- Expected: 2026-06-15 RGN001 (520)

-- =====================================================================
-- Exercise 10.5 — Both directions (ABS)
-- =====================================================================
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
ORDER BY (total_orders - prev_week) DESC;
-- Expected: spike and dip both surface

-- =====================================================================
-- Exercise 10.6 — Moving-average deviation (>20%) from 2026-07-21
-- =====================================================================
WITH baseline AS (
    SELECT sale_date, region_id, total_orders,
        AVG(total_orders) OVER (
            PARTITION BY region_id ORDER BY sale_date
            ROWS BETWEEN 13 PRECEDING AND 1 PRECEDING
        ) AS trailing_avg
    FROM daily_sales
    WHERE total_orders IS NOT NULL
)
SELECT sale_date, region_id, total_orders,
       ROUND(trailing_avg, 1) AS baseline,
       ROUND((total_orders - trailing_avg) / NULLIF(trailing_avg, 0) * 100, 1) AS deviation_pct
FROM baseline
WHERE sale_date >= '2026-07-21'
  AND trailing_avg IS NOT NULL
  AND ABS((total_orders - trailing_avg) / NULLIF(trailing_avg, 0)) > 0.2
ORDER BY deviation_pct DESC;
-- Expected: the post-2026-07-21 rows (new baseline regime)

-- =====================================================================
-- Exercise 10.7 — Window comparison (shift detection)
-- =====================================================================
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
-- Expected: large positive change (~+40%) for both regions

-- =====================================================================
-- Exercise 10.8 (TRANSLATE — for reference)
-- Returns the total_orders from 7 rows earlier, per region, ordered by
-- date. The 7 = one week, so you compare each day to the SAME weekday
-- last week, removing weekly seasonality.

-- =====================================================================
-- Exercise 10.9 (TRANSLATE — for reference)
-- NULLIF(sigma, 0) returns NULL when sigma is 0 (a constant column),
-- making the division NULL instead of an error / infinite value.

-- =====================================================================
-- Exercise 10.10 (TRANSLATE — for reference)
-- Produces a 14-day trailing average per region (excluding the current
-- row via ROWS ... 1 PRECEDING). Monitoring compares each day to it to
-- flag shifts and spikes; the first 13 rows have NULL avg.

-- =====================================================================
-- Exercise 10.11 — Fixed: partition stats by region
-- =====================================================================
WITH stats AS (
    SELECT region_id,
        AVG(total_orders)        AS mu,
        STDDEV_POP(total_orders) AS sigma
    FROM daily_sales
    WHERE total_orders IS NOT NULL
    GROUP BY region_id
)
SELECT ds.sale_date, ds.region_id, ds.total_orders,
       ROUND((ds.total_orders - s.mu) / NULLIF(s.sigma, 0), 2) AS z
FROM daily_sales ds
JOIN stats s ON ds.region_id = s.region_id
WHERE ds.total_orders IS NOT NULL
ORDER BY z DESC;

-- =====================================================================
-- Exercise 10.12 — Fixed: offset 7 + partition by region
-- =====================================================================
SELECT sale_date, region_id, total_orders,
       LAG(total_orders, 7) OVER (PARTITION BY region_id ORDER BY sale_date) AS baseline
FROM daily_sales;

-- =====================================================================
-- Exercise 10.13 — Fixed: ABS + NULL-safe baseline
-- =====================================================================
WITH b AS (
    SELECT sale_date, total_orders,
           AVG(total_orders) OVER (ORDER BY sale_date ROWS BETWEEN 13 PRECEDING AND 1 PRECEDING) AS avg
    FROM daily_sales
)
SELECT sale_date, total_orders, ROUND(avg, 1) AS baseline
FROM b
WHERE avg IS NOT NULL
  AND ABS(total_orders - avg) / NULLIF(avg, 0) > 0.2;
