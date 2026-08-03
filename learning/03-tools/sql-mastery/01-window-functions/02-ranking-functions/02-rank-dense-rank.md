# Lesson 2.2: RANK() and DENSE_RANK() — Handling Ties

## The Problem with ROW_NUMBER()

When values are **equal** (tied), ROW_NUMBER() still assigns unique numbers — but sometimes you want tied values to share the same rank.

---

## The Three Ranking Functions

| Function | Description | Example Output |
|----------|-------------|----------------|
| `ROW_NUMBER()` | Unique sequential numbers | 1, 2, 3, 4, 5 |
| `RANK()` | Tied values share rank, **gaps after** | 1, 1, 3, 4, 5 |
| `DENSE_RANK()` | Tied values share rank, **no gaps** | 1, 1, 2, 3, 4 |

---

## Visual Comparison

Given these scores:

| employee | score |
|----------|-------|
| Alice | 100 |
| Bob | 100 |
| Carol | 90 |
| Dave | 80 |
| Eve | 80 |

| employee | score | ROW_NUMBER() | RANK() | DENSE_RANK() |
|----------|-------|--------------|--------|--------------|
| Alice | 100 | 1 | 1 | 1 |
| Bob | 100 | 2 | 1 | 1 |
| Carol | 90 | 3 | 3 | 2 |
| Dave | 80 | 4 | 4 | 3 |
| Eve | 80 | 5 | 4 | 3 |

---

## RANK() — Ranking with Gaps

**HR Request:**
> "Rank our customers by their total spending. Customers who spent the same amount should share the same rank. Leave gaps after tied ranks."

```sql
SELECT 
    c.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    SUM(o.total_amount) AS total_spent,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS spend_rank
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.first_name, c.last_name
ORDER BY spend_rank;
```

**English Translation:**
> "For each customer, calculate their total spending. Rank them from highest spender (rank 1) to lowest. When two customers spent the same amount, they share the same rank, and the next rank jumps accordingly."

**Result Preview:**

| cust_id | customer_name | total_spent | spend_rank |
|---------|---------------|-------------|------------|
| CST006 | Jessica Garcia | 9293.00 | **1** |
| CST002 | Sarah Johnson | 3454.00 | **2** |
| CST001 | John Smith | 3227.00 | **3** |
| CST004 | Emily Brown | 1656.00 | **4** |
| CST013 | Daniel Harris | 1465.00 | **4** | ← Tied!
| CST015 | Matthew Thompson | 1427.00 | **6** | ← Gap (skipped 5)
| ... | ... | ... | ... |

**Notice:** CST004 and CST013 are both rank 4 (tied at $1656), but CST015 is rank 6 (gap!).

---

## DENSE_RANK() — Ranking Without Gaps

**HR Request:**
> "Rank our customers by their total spending. When customers spent the same amount, they share the same rank. Do NOT leave gaps between ranks."

```sql
SELECT 
    c.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    SUM(o.total_amount) AS total_spent,
    DENSE_RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS spend_rank
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.first_name, c.last_name
ORDER BY spend_rank;
```

**English Translation:**
> "Same as before, but this time when there's a tie, the next rank should be consecutive — no gaps."

**Result Preview:**

| cust_id | customer_name | total_spent | spend_rank |
|---------|---------------|-------------|------------|
| CST006 | Jessica Garcia | 9293.00 | **1** |
| CST002 | Sarah Johnson | 3454.00 | **2** |
| CST001 | John Smith | 3227.00 | **3** |
| CST004 | Emily Brown | 1656.00 | **4** |
| CST013 | Daniel Harris | 1465.00 | **4** | ← Tied!
| CST015 | Matthew Thompson | 1427.00 | **5** | ← No gap!
| ... | ... | ... | ... |

**Notice:** CST015 is rank 5 now (no gap after the tied rank 4).

---

## When to Use Which

| Function | Use When |
|----------|----------|
| `ROW_NUMBER()` | You need unique, sequential IDs. Use when no ties should exist or ties don't matter. |
| `RANK()` | You're creating a **leaderboard** where ties share a position, but the next position accounts for the gap (e.g., Olympic medals: gold, gold, bronze — no silver). |
| `DENSE_RANK()` | You're creating a **tier system** where gaps don't make sense (e.g., customer loyalty tiers). |

---

## Real-World Example: Leaderboard vs Tiers

### Leaderboard (Use RANK) — Olympic Style

**HR Request:**
> "Show me the top 3 spending customers. If there's a tie for 3rd place, both should be shown."

```sql
SELECT *
FROM (
    SELECT 
        c.cust_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        SUM(o.total_amount) AS total_spent,
        RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS spend_rank
    FROM customers c
    LEFT JOIN orders o ON c.cust_id = o.cust_id
    GROUP BY c.cust_id, c.first_name, c.last_name
) ranked
WHERE spend_rank <= 3;
```

---

### Tier System (Use DENSE_RANK) — Loyalty Levels

**HR Request:**
> "Assign each customer a spending tier: 'Platinum' for top 20%, 'Gold' for next 30%, 'Silver' for next 30%, 'Bronze' for the rest."

```sql
SELECT 
    c.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    SUM(o.total_amount) AS total_spent,
    CASE 
        WHEN DENSE_RANK() OVER (ORDER BY SUM(o.total_amount) DESC) <= 4 THEN 'Platinum'
        WHEN DENSE_RANK() OVER (ORDER BY SUM(o.total_amount) DESC) <= 10 THEN 'Gold'
        WHEN DENSE_RANK() OVER (ORDER BY SUM(o.total_amount) DESC) <= 15 THEN 'Silver'
        ELSE 'Bronze'
    END AS spending_tier
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.first_name, c.last_name;
```

---

## Combining RANK with Other Window Functions

```sql
SELECT 
    c.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    SUM(o.total_amount) AS total_spent,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS spend_rank,
    COUNT(*) OVER () AS total_customers,
    ROUND(RANK() OVER (ORDER BY SUM(o.total_amount) DESC) / COUNT(*) OVER () * 100, 1) AS pctile
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.first_name, c.last_name;
```

**English Translation:**
> "Show each customer's total spending, their rank, how many customers exist in total, and what percentile they fall into."

---

## Coming Up Next

`NTILE(n)` — dividing rows into equal groups (quartiles, terciles, percentiles).
