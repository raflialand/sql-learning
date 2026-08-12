# Summary: SQL Skill Push Session

**Date:** 12 Aug 2026
**Track:** SQL Skill Push (sql-push)
**Status:** Intermediate Q12–Q13 done and verified against expected results.

---

## Completed

- Q12 — Order size labels via `CASE WHEN` (Large ≥ 4000, Medium ≥ 1500, else Small) on `orders`, 2,800 rows. PASS.
- Q13 — Order-size buckets: count + total revenue per bucket. PASS.

### Examples practiced

```sql
-- Q13 via CTE reuse of Q12's CASE (DRY)
WITH order_bucket AS (
    SELECT order_id, order_date, total_amount,
        CASE
            WHEN total_amount >= 4000 THEN 'Large'
            WHEN total_amount >= 1500 THEN 'Medium'
            ELSE 'Small'
        END AS order_size
    FROM orders
)
SELECT order_size,
    COUNT(*) AS order_count,
    ROUND(SUM(total_amount), 2) AS total_revenue
FROM order_bucket
GROUP BY order_size
ORDER BY order_count DESC;
```

---

## Key Takeaways

1. **Window vs aggregate with GROUP BY:** `COUNT(*) OVER(PARTITION BY order_size)` evaluated together with `GROUP BY order_size` returns 1 per bucket — window functions run *after* grouping, so each partition has a single row. Use a plain `COUNT(*)` aggregate instead.
2. **CTE reuse (DRY):** reusing Q12's `CASE` as a CTE avoids re-typing thresholds; a CTE is reusable only within the same query (temp tables/views needed across queries). No `ORDER BY` needed inside a CTE.
3. **Rounding:** `ROUND(SUM(total_amount), 2)` to match expected revenue (`3651768.83 / 4139038.41 / 598891.25`).

## Mistakes / Notes

- Q13: first draft mixed `COUNT(*) OVER(PARTITION BY order_size)` with `GROUP BY order_size` → order_count = 1 for every bucket.
- Reference solution repeats the full `CASE` in `GROUP BY` for portability; `GROUP BY order_size` (alias) also works in MySQL/SQLite.

## Next Steps

1. Fix the 6 pending Beginner fixes (Q1, Q3, Q14, Q15, Q18, Q19) → 20/20.
2. Continue Intermediate Q14 (vendors with priciest products).

---

*Happy Learning!*
