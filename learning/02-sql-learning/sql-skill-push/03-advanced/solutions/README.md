# Solutions — Level 3: Advanced

Verified solutions for `03-advanced/challenges.md`. Each file was executed against `datasets/03-advanced/telecom.db` and matches the expected result shown in the challenge.

| Challenge | File | Skill |
| --- | --- | --- |
| Q1 | solution_01.sql | Multi-JOIN + GROUP BY |
| Q2 | solution_02.sql | LAG (month-over-month) |
| Q3 | solution_03.sql | Running total (window SUM) |
| Q4 | solution_04.sql | RANK over aggregate |
| Q5 | solution_05.sql | NTILE quartiles |
| Q6 | solution_06.sql | Median via ROW_NUMBER |
| Q7 | solution_07.sql | Correlated subquery |
| Q8 | solution_08.sql | Set difference (NOT IN) |
| Q9 | solution_09.sql | LEAD (gap spotting) |
| Q10 | solution_10.sql | Moving average (frame) |
| Q11 | solution_11.sql | Recursive CTE + gap fill |
| Q12 | solution_12.sql | Churn rate (DISTINCT join) |
| Q13 | solution_13.sql | Pivot / cross-tab (CASE) |
| Q14 | solution_14.sql | INTERSECT |
| Q15 | solution_15.sql | MIN/MAX/COUNT per group |
| Q16 | solution_16.sql | NOT EXISTS anti-join |
| Q17 | solution_17.sql | Window ratio to group total |
| Q18 | solution_18.sql | HAVING over allowance |
| Q19 | solution_19.sql | Date diff (julianday / DATEDIFF) |
| Q20 | solution_20.sql | Cohort analysis |

**Note:** Q2, Q3, Q9, Q10, Q11 use window functions and recursive CTEs — these require MySQL 8.x (window functions) and SQLite 3.25+. Run any solution with:

```bash
sqlite3 datasets/03-advanced/telecom.db < 03-advanced/solutions/solution_01.sql
```
