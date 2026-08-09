# Solutions — Level 1: Beginner

Verified solutions for `01-beginner/challenges.md`. Each file was executed against `datasets/01-beginner/retail.db` and matches the expected result shown in the challenge.

| Challenge | File | Skill |
| --- | --- | --- |
| Q1 | solution_01.sql | WHERE + ORDER BY |
| Q2 | solution_02.sql | DISTINCT |
| Q3 | solution_03.sql | Date range filter (BETWEEN) |
| Q4 | solution_04.sql | WHERE + COUNT |
| Q5 | solution_05.sql | AND with two conditions |
| Q6 | solution_06.sql | BETWEEN |
| Q7 | solution_07.sql | LIKE wildcard |
| Q8 | solution_08.sql | IS NULL |
| Q9 | solution_09.sql | ORDER BY DESC + LIMIT |
| Q10 | solution_10.sql | ORDER BY + LIMIT |
| Q11 | solution_11.sql | GROUP BY + COUNT |
| Q12 | solution_12.sql | GROUP BY + SUM |
| Q13 | solution_13.sql | GROUP BY + AVG |
| Q14 | solution_14.sql | JOIN + GROUP BY + SUM |
| Q15 | solution_15.sql | GROUP BY + COUNT (incl. NULL) |
| Q16 | solution_16.sql | JOIN + GROUP BY + ORDER BY + LIMIT |
| Q17 | solution_17.sql | HAVING + JOIN |
| Q18 | solution_18.sql | Date extraction (strftime / DATE_FORMAT) |
| Q19 | solution_19.sql | GROUP BY month + AVG |
| Q20 | solution_20.sql | LEFT JOIN anti-join |

There may be multiple valid queries — compare output, not just syntax. Run any solution with:

```bash
sqlite3 datasets/01-beginner/retail.db < 01-beginner/solutions/solution_01.sql
```
