# SQL Skill Push — Level 3: Advanced

**Dataset:** `datasets/03-advanced/telecom.db` (MySQL: `telecom.sql`)
**Business:** a mobile telecom carrier. See `datasets/03-advanced/README.md`.

Topics covered: complex multi-joins, LAG/LEAD, NTILE/percentiles, correlated subqueries, recursive CTE, set operations, moving averages, gap detection, dedup, cross-tab/pivot, cohort-style analysis. Solutions are in `solutions/`.

---

### Q1 — Revenue by plan

**Request:** What is the total revenue per plan across the two billing months?

**Expected columns:** `plan_name, total_revenue`

**Expected result:**
| plan_name | total_revenue |
| --- | --- |
| Plus | 81750.00 |
| Standard | 79380.00 |
| Premium | 77280.00 |
| Family | 62100.00 |
| Starter | 39420.00 |
| Unlimited Max | 39360.00 |

*(6 rows)*

**Hint:** JOIN billing → subscribers → plans, then `GROUP BY plan`.

---

### Q2 — Month-over-month revenue change

**Request:** Show month-over-month revenue change using `LAG`.

**Expected columns:** `bill_date, revenue, prev_month_revenue, change`

**Expected result:**
| bill_date | revenue | prev_month_revenue | change |
| --- | --- | --- | --- |
| 2025-12-01 | 203420.00 | NULL | NULL |
| 2026-01-01 | 175870.00 | 203420.00 | -27550.00 |

*(2 rows)*

**Hint:** `LAG(revenue) OVER (ORDER BY bill_date)` in a CTE. NULL is expected for the first row.

---

### Q3 — Running total of revenue

**Request:** Show revenue per billing month with a running (cumulative) total.

**Expected columns:** `bill_date, revenue, running_revenue`

**Expected result:**
| bill_date | revenue | running_revenue |
| --- | --- | --- |
| 2025-12-01 | 203420.00 | 203420.00 |
| 2026-01-01 | 175870.00 | 379290.00 |

*(2 rows)*

---

### Q4 — Top data users

**Request:** Rank subscribers by total data usage (descending), show the top 10.

**Expected columns:** `sub_id, first_name, last_name, total_data_mb, usage_rank`

**Expected result:**
| sub_id | first_name | last_name | total_data_mb | usage_rank |
| --- | --- | --- | --- | --- |
| 1575 | Deborah | Rodriguez | 59711 | 1 |
| 2906 | David | Wilson | 59438 | 2 |
| 445 | Brian | Martin | 59341 | 3 |
| 46 | Steven | Roberts | 59124 | 4 |
| 800 | Stephanie | Wilson | 58976 | 5 |
| 1298 | John | Roberts | 58862 | 6 |

*(10 rows total; 6 shown)*

**Hint:** `RANK() OVER (ORDER BY SUM(data_mb) DESC)`.

---

### Q5 — Usage quartiles

**Request:** Divide subscribers into 4 usage quartiles based on total data usage.

**Expected columns:** `sub_id, total_data_mb, usage_quartile`

**Expected result:**
| sub_id | total_data_mb | usage_quartile |
| --- | --- | --- |
| 2606 | 1055 | 1 |
| 1196 | 1554 | 1 |
| 3312 | 1821 | 1 |
| 4381 | 1862 | 1 |
| 2177 | 1920 | 1 |
| 2326 | 1981 | 1 |

*(3,709 rows total; 6 shown)*

**Hint:** `NTILE(4) OVER (ORDER BY total_data_mb)`.

---

### Q6 — Median usage per region

**Request:** What is the median total data usage per region? (approx: the middle row when ordered)

**Expected columns:** `region, median_data_mb`

**Expected result:**
| region | median_data_mb |
| --- | --- |
| Southwest | 30548.00 |
| Midwest | 30406.00 |
| Northeast | 30236.00 |
| Southeast | 29664.00 |
| West | 29636.00 |

*(5 rows)*

**Hint:** `ROW_NUMBER() OVER (PARTITION BY region ORDER BY total)` and pick the middle row(s).

---

### Q7 — Above plan-average usage

**Request:** Compare each subscriber's total data usage against the average usage of their own plan (correlated subquery).

**Expected columns:** `sub_id, first_name, last_name, plan_name, total_data_mb, plan_avg_usage, diff_from_plan_avg`

**Expected result:**
| sub_id | first_name | last_name | plan_name | total_data_mb | plan_avg_usage | diff_from_plan_avg |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | Joshua | King | Starter | 38620.00 | 29684.00 | 8936.00 |
| 3 | Jessica | Taylor | Plus | 40784.00 | 30208.00 | 10576.00 |
| 4 | Amanda | Hall | Starter | 34854.00 | 29684.00 | 5170.00 |
| 6 | Megan | Martinez | Starter | 33468.00 | 29684.00 | 3784.00 |
| 8 | Eric | Johnson | Family | 30302.00 | 30795.00 | -493.00 |
| 12 | Stephanie | Green | Plus | 42288.00 | 30208.00 | 12080.00 |

*(3,709 rows total; 6 shown)*

**Hint:** correlated subquery that re-computes the plan average per subscriber row.

---

### Q8 — Tickets but no churn (set difference)

**Request:** Which subscribers have support tickets but never churned?

**Expected columns:** `sub_id, first_name, last_name, phone`

**Expected result:**
| sub_id | first_name | last_name | phone |
| --- | --- | --- | --- |
| 2 | Joshua | King | 555-517626 |
| 4 | Amanda | Hall | 555-510113 |
| 9 | Eric | Thompson | 555-175437 |
| 12 | Stephanie | Green | 555-175802 |
| 13 | William | Taylor | 555-301105 |
| 14 | John | Taylor | 555-661254 |

*(2,304 rows total; 6 shown)*

**Hint:** `sub_id IN (tickets) AND sub_id NOT IN (churn)`. Equivalent to a set `MINUS`/`EXCEPT`.

---

### Q9 — Next payment (gap spotting)

**Request:** For each subscriber, show their next payment date (LEAD) to spot missed payments.

**Expected columns:** `sub_id, pay_date, amount, next_pay_date, next_pay_amount`

**Expected result:**
| sub_id | pay_date | amount | next_pay_date | next_pay_amount |
| --- | --- | --- | --- | --- |
| 2 | 2025-12-23 | 20.00 | 2026-01-16 | 20.00 |
| 2 | 2026-01-16 | 20.00 | NULL | NULL |
| 3 | 2025-12-10 | 50.00 | 2026-01-31 | 50.00 |
| 3 | 2026-01-31 | 50.00 | NULL | NULL |
| 4 | 2025-12-04 | 20.00 | NULL | NULL |
| 5 | 2025-12-22 | 35.00 | NULL | NULL |

*(6,588 rows total; 6 shown)*

**Hint:** `LEAD(pay_date) OVER (PARTITION BY sub_id ORDER BY pay_date)`.

---

### Q10 — Moving average of ticket volume

**Request:** Show monthly ticket volume with a 3-month moving average.

**Expected columns:** `month, ticket_count, moving_avg_3m`

**Expected result:**
| month | ticket_count | moving_avg_3m |
| --- | --- | --- |
| 2025-06 | 458 | 458.00 |
| 2025-07 | 451 | 454.50 |
| 2025-08 | 459 | 456.00 |
| 2025-09 | 483 | 464.33 |
| 2025-10 | 505 | 482.33 |
| 2025-11 | 454 | 480.67 |

*(8 rows total; 6 shown)*

**Hint:** `AVG(...) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)`.

---

### Q11 — Continuous month series (recursive CTE)

**Request:** Generate a continuous series of months and show ticket counts, including months with zero tickets.

**Expected columns:** `month, ticket_count`

**Expected result:**
| month | ticket_count |
| --- | --- |
| 2025-06 | 458 |
| 2025-07 | 451 |
| 2025-08 | 459 |
| 2025-09 | 483 |
| 2025-10 | 505 |
| 2025-11 | 454 |

*(8 rows total; 6 shown)*

**Hint:** `WITH RECURSIVE months(month) AS (...)` seeded from `2025-06-01`, stepping `+1 month` to `2026-01-01`, then `LEFT JOIN` the aggregated counts.

---

### Q12 — Churn rate by region

**Request:** What is the churn rate (churned / total) per region?

**Expected columns:** `region, total_subs, churned, churn_rate_pct`

**Expected result:**
| region | total_subs | churned | churn_rate_pct |
| --- | --- | --- | --- |
| West | 874 | 94 | 10.76 |
| Northeast | 890 | 91 | 10.22 |
| Midwest | 887 | 86 | 9.70 |
| Southwest | 909 | 81 | 8.91 |
| Southeast | 940 | 75 | 7.98 |

*(5 rows)*

**Hint:** `LEFT JOIN churn`, then `COUNT(DISTINCT ...)` to avoid double counting.

---

### Q13 — Ticket status pivot

**Request:** Cross-tabulate ticket category by status (one row per category).

**Expected columns:** `category, open_count, resolved_count, closed_count, total`

**Expected result:**
| category | open_count | resolved_count | closed_count | total |
| --- | --- | --- | --- | --- |
| Billing | 268 | 241 | 279 | 788 |
| Technical | 246 | 271 | 264 | 781 |
| Network | 243 | 261 | 260 | 764 |
| Account | 248 | 268 | 243 | 759 |
| Device | 227 | 258 | 223 | 708 |

*(5 rows)*

**Hint:** conditional aggregation with `SUM(CASE WHEN status = '...' THEN 1 ELSE 0 END)`.

---

### Q14 — Churned with unpaid bills (intersection)

**Request:** Which subscribers churned AND still have unpaid or overdue bills?

**Expected columns:** `sub_id, phone, first_name, last_name`

**Expected result:**
| sub_id | phone | first_name | last_name |
| --- | --- | --- | --- |
| 395 | 555-915401 | Cynthia | Robinson |
| 843 | 555-383028 | Kimberly | Martin |
| 927 | 555-590534 | Sarah | Miller |
| 949 | 555-215810 | Amanda | King |
| 1205 | 555-831773 | Frank | White |
| 1218 | 555-989516 | Frank | Clark |

*(38 rows total; 6 shown)*

**Hint:** `INTERSECT` of the churn set and the unpaid-bills set.

---

### Q15 — Payment history per subscriber

**Request:** For each subscriber, find their first and last payment date and how many payments they made.

**Expected columns:** `sub_id, first_pay_date, last_pay_date, payment_count`

**Expected result:**
| sub_id | first_pay_date | last_pay_date | payment_count |
| --- | --- | --- | --- |
| 2 | 2025-12-23 | 2026-01-16 | 2 |
| 3 | 2025-12-10 | 2026-01-31 | 2 |
| 8 | 2025-12-23 | 2026-01-20 | 2 |
| 13 | 2025-12-16 | 2026-01-18 | 2 |
| 16 | 2025-12-27 | 2026-01-12 | 2 |
| 17 | 2025-12-20 | 2026-01-02 | 2 |

*(4,071 rows total; 6 shown)*

**Hint:** `GROUP BY sub_id` with `MIN(pay_date)`, `MAX(pay_date)`, `COUNT(*)`.

---

### Q16 — Billed but never paid

**Request:** Which subscribers received a bill but never made any payment?

**Expected columns:** `sub_id, first_name, last_name, phone, region, bills_issued`

**Expected result:**
| sub_id | first_name | last_name | phone | region | bills_issued |
| --- | --- | --- | --- | --- | --- |
| 79 | David | Flores | 555-403224 | Southeast | 2 |
| 99 | Adam | Hernandez | 555-500095 | Southwest | 2 |
| 107 | Matthew | Nguyen | 555-650773 | West | 2 |
| 198 | Rachel | Campbell | 555-467124 | Northeast | 2 |
| 239 | Cynthia | Green | 555-762046 | Southeast | 2 |
| 251 | John | Robinson | 555-587790 | Midwest | 2 |

*(216 rows total; 6 shown)*

**Hint:** anti-join — `NOT EXISTS (SELECT 1 FROM payments WHERE ...)`.

---

### Q17 — Share of region data usage

**Request:** What is each subscriber's data usage as a share of their region's total?

**Expected columns:** `sub_id, region, sub_data, region_data, pct_of_region`

**Expected result:**
| sub_id | region | sub_data | region_data | pct_of_region |
| --- | --- | --- | --- | --- |
| 1298 | West | 58862 | 21002724 | 0.28 |
| 357 | West | 56781 | 21002724 | 0.27 |
| 976 | West | 55778 | 21002724 | 0.27 |
| 1086 | Northeast | 58593 | 22087650 | 0.27 |
| 2397 | West | 56428 | 21002724 | 0.27 |
| 300 | Midwest | 57385 | 22010406 | 0.26 |

*(3,709 rows total; 6 shown)*

**Hint:** CTE with per-region totals, then join and compute `SUM(u.data_mb) * 100.0 / region_data`.

---

### Q18 — Over plan allowance

**Request:** Which subscribers exceeded their plan's data allowance?

**Expected columns:** `sub_id, first_name, last_name, plan_name, plan_data_gb, total_data_mb, total_data_gb`

**Expected result:**
| sub_id | first_name | last_name | plan_name | plan_data_gb | total_data_mb | total_data_gb |
| --- | --- | --- | --- | --- | --- | --- |
| 1575 | Deborah | Rodriguez | Standard | 15 | 59711 | 58.31 |
| 2906 | David | Wilson | Standard | 15 | 59438 | 58.04 |
| 445 | Brian | Martin | Standard | 15 | 59341 | 57.95 |
| 3314 | Mark | Flores | Plus | 30 | 58750 | 57.37 |
| 1086 | David | Hernandez | Plus | 30 | 58593 | 57.22 |
| 3554 | Kimberly | Robinson | Standard | 15 | 58538 | 57.17 |

*(2,177 rows total; 6 shown)*

**Hint:** `HAVING SUM(data_mb) > p.data_gb * 1024`.

---

### Q19 — Ticket handling time

**Request:** How many days does each resolved ticket take to handle?

**Expected columns:** `ticket_id, sub_id, category, created_date, resolved_date, handling_days`

**Expected result:**
| ticket_id | sub_id | category | created_date | resolved_date | handling_days |
| --- | --- | --- | --- | --- | --- |
| 215 | 3413 | Account | 2025-12-07 | 2026-02-07 | 62.00 |
| 854 | 2961 | Account | 2025-07-02 | 2025-09-02 | 62.00 |
| 1198 | 2866 | Billing | 2025-12-28 | 2026-02-28 | 62.00 |
| 2647 | 1951 | Billing | 2025-12-07 | 2026-02-07 | 62.00 |
| 2724 | 3457 | Account | 2025-12-11 | 2026-02-11 | 62.00 |
| 3215 | 1498 | Technical | 2025-07-26 | 2025-09-26 | 62.00 |

*(2,651 rows total; 6 shown)*

**Hint:** `julianday(resolved_date) - julianday(created_date)` (SQLite) / `DATEDIFF()` (MySQL).

---

### Q20 — Signup cohort retention

**Request:** For each signup quarter, how many subscribers are still active, and what % of the cohort is that?

**Expected columns:** `cohort, total_subs, still_active, active_pct`

**Expected result:**
| cohort | total_subs | still_active | active_pct |
| --- | --- | --- | --- |
| 2021-Q1 | 247 | 197 | 79.76 |
| 2021-Q2 | 241 | 200 | 82.99 |
| 2021-Q3 | 255 | 209 | 81.96 |
| 2021-Q4 | 252 | 212 | 84.13 |
| 2022-Q1 | 221 | 179 | 81.00 |
| 2022-Q2 | 230 | 196 | 85.22 |

*(19 rows total; 6 shown)*

**Hint:** build a cohort label from `signup_date`, then count active vs total per cohort.

---

## How to verify

```bash
sqlite3 datasets/03-advanced/telecom.db < solutions/solution_XX.sql
# or use the helper:
python ../../_tools/run_query.py datasets/03-advanced/telecom.db solutions/solution_XX.sql
```
