# Solutions — Level 2: Intermediate

Verified solutions for `02-intermediate/challenges.md`. Each file was executed against `datasets/02-intermediate/ecommerce.db` and matches the expected result shown in the challenge.

| Challenge | File | Skill |
| --- | --- | --- |
| Q1 | solution_01.sql | INNER JOIN |
| Q2 | solution_02.sql | LEFT JOIN anti-join |
| Q3 | solution_03.sql | LEFT JOIN + GROUP BY |
| Q4 | solution_04.sql | Multi-JOIN + HAVING |
| Q5 | solution_05.sql | HAVING + scalar subquery |
| Q6 | solution_06.sql | WHERE + subquery + DISTINCT |
| Q7 | solution_07.sql | EXISTS subquery |
| Q8 | solution_08.sql | CTE + window running total |
| Q9 | solution_09.sql | ROW_NUMBER top-N per group |
| Q10 | solution_10.sql | AVG OVER (window) |
| Q11 | solution_11.sql | Conditional aggregation (CASE + SUM) |
| Q12 | solution_12.sql | CASE WHEN labels |
| Q13 | solution_13.sql | GROUP BY CASE expression |
| Q14 | solution_14.sql | Multi-JOIN + AVG + LIMIT |
| Q15 | solution_15.sql | CTE + HAVING |
| Q16 | solution_16.sql | Correlated subquery |
| Q17 | solution_17.sql | Date grouping |
| Q18 | solution_18.sql | CASE + date diff |
| Q19 | solution_19.sql | Two CTEs + join |
| Q20 | solution_20.sql | Conditional aggregation percentages |

There may be multiple valid queries — compare output, not just syntax. Run any solution with:

```bash
sqlite3 datasets/02-intermediate/ecommerce.db < 02-intermediate/solutions/solution_01.sql
```
