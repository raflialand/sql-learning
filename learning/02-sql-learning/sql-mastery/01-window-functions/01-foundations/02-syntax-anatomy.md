# Lesson 1.2: Syntax Anatomy of Window Functions

## The Basic Structure

Every window function follows this pattern:

```sql
WINDOW_FUNCTION(column) OVER (PARTITION BY column ORDER BY column)
```

**Breaking it down:**

```
WINDOW_FUNCTION(column)  +  OVER (PARTITION BY ... ORDER BY ...)
        ↓                        ↓
    What to calculate      How to frame the calculation
```

---

## Components Explained

### 1. WINDOW_FUNCTION

The operation you want to perform. Categories include:

| Category | Functions |
|----------|-----------|
| **Ranking** | `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `NTILE(n)` |
| **Navigation** | `LAG()`, `LEAD()`, `FIRST_VALUE()`, `LAST_VALUE()` |
| **Aggregate** | `SUM()`, `AVG()`, `COUNT()`, `MIN()`, `MAX()` |
| **Statistical** | `CUME_DIST()`, `PERCENT_RANK()`, `PERCENTILE_CONT()` |

---

### 2. OVER()

The `OVER()` clause defines the **window frame** — the set of rows the function operates on.

Think of it as saying: *"For each row, look at this group of rows to calculate the value."*

```sql
-- Without OVER(): Aggregate - collapses rows
SELECT SUM(total_amount) FROM orders;

-- With OVER(): Window function - keeps rows
SELECT total_amount, SUM(total_amount) OVER () FROM orders;
```

**English Translation:**
> "Without OVER: Show me the total sum of all orders. With OVER: Show me each order's amount AND the total sum of all orders."

---

### 3. PARTITION BY (Optional but Common)

Divides rows into groups for the window function to operate on.

```sql
SUM(total_amount) OVER (PARTITION BY region_id)
```

**English Translation:**
> "Calculate the sum of total_amount separately for each region."

**Visual Example:**

| region_id | total_amount | SUM(...) OVER (PARTITION BY region_id) |
|-----------|--------------|----------------------------------------|
| RGN001 | 1500 | 1500 + 2000 + 1800 = **5300** |
| RGN001 | 2000 | 1500 + 2000 + 1800 = **5300** |
| RGN001 | 1800 | 1500 + 2000 + 1800 = **5300** |
| RGN002 | 900 | 900 + 1100 = **2000** |
| RGN002 | 1100 | 900 + 1100 = **2000** |

Each row shows its region's total, but the row count is preserved.

---

### 4. ORDER BY (Optional)

Orders rows within each partition before applying the window function.

```sql
SUM(total_amount) OVER (PARTITION BY region_id ORDER BY ord_date)
```

**English Translation:**
> "Within each region, calculate a running sum of total_amount ordered by order date."

**Visual Example (Running Total):**

| region_id | ord_date | total_amount | Running Sum |
|-----------|----------|--------------|-------------|
| RGN001 | 2024-01-05 | 1500 | **1500** |
| RGN001 | 2024-01-10 | 2000 | **3500** |
| RGN001 | 2024-01-15 | 1800 | **5300** |
| RGN002 | 2024-01-07 | 900 | **900** |
| RGN002 | 2024-01-12 | 1100 | **2000** |

---

### 5. The Full Picture

```sql
SELECT 
    ord_id,
    ord_date,
    cust_id,
    total_amount,
    region_id,
    
    -- No partition, no order: entire dataset as one window
    COUNT(*) OVER () AS total_orders,
    
    -- Partition by region: sum within each region
    SUM(total_amount) OVER (PARTITION BY region_id) AS region_total,
    
    -- Partition by region, ordered by date: running total per region
    SUM(total_amount) OVER (PARTITION BY region_id ORDER BY ord_date) AS running_total_per_region,
    
    -- Partition by region, ordered by date: rank within region
    ROW_NUMBER() OVER (PARTITION BY region_id ORDER BY ord_date) AS order_sequence
FROM orders;
```

**English Translation:**
> "Show me each order's details. Also show me:
> - How many total orders exist in the dataset
> - The total sales amount for the order's region
> - A running total of sales within that region from earliest to latest date
> - What number order this is within that region"

---

## Common Patterns

| Pattern | Syntax | Use Case |
|---------|--------|----------|
| **Full aggregate** | `SUM(x) OVER ()` | Calculate a constant value across all rows |
| **Partitioned aggregate** | `SUM(x) OVER (PARTITION BY y)` | Sum per group, repeat for each row |
| **Running total** | `SUM(x) OVER (ORDER BY date)` | Cumulative sum over time |
| **Running total per group** | `SUM(x) OVER (PARTITION BY y ORDER BY date)` | Cumulative sum per group |
| **Rank within group** | `ROW_NUMBER() OVER (PARTITION BY y ORDER BY x DESC)` | Number rows within each group |

---

## Key Rules

1. **Window functions are computed after WHERE, GROUP BY, and HAVING**
   - They can use columns from the result set but can't be used in WHERE directly

2. **Window functions appear in SELECT (or ORDER BY)**
   - They cannot replace a column in FROM/JOIN

3. **PARTITION BY and ORDER BY are independent**
   - `PARTITION BY` groups rows
   - `ORDER BY` orders rows within each group
   - Both are optional (but usually at least one is used)

4. **NULL values behave specially in ORDER BY**
   - Use `NULLS FIRST` or `NULLS LAST` if needed

---

## Coming Up Next

Your first hands-on window function query, with detailed explanations.
