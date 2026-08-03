# Summary: SQL Learning Session

**Date:** 01 July 2026
**Database:** sql-learn-db-week6.db
**Status:** Week 6 Day 4 COMPLETE - All Practice Exercises Done ✅

---

## Week 6 Day 4: CROSS JOIN & Self JOIN - Completed (Partial)

### Concepts Learned

**1. CROSS JOIN (Cartesian Product)**

- Returns ALL possible combinations of rows from both tables
- No ON clause needed (no relationship required)
- Formula: Table A rows × Table B rows = total rows

**2. CROSS JOIN Real-Life Examples**

| Use Case | Example |
|----------|---------|
| Scheduling matrix | All doctors × all time slots |
| Size × Color variants | Every size combined with every color |
| Shipping options | Every warehouse × every carrier |
| Test data generation | Generate sample datasets |
| Finding missing combinations | Who hasn't done which shift? |

**3. Self JOIN (Self-Referential Relationship)**

- Table joined to ITSELF using aliases
- Uses `manager_id` column that references `employees(id)`
- Useful for hierarchical data

**4. How Self JOIN Query Works (Employee-Manager)**

```sql
SELECT e.id, e.name AS employee, m.id AS manager_id, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id
```

**How it works step by step:**
- `e` = every employee row (the person we want info about)
- `m` = looking for their manager (same table, but as "another copy")
- `ON e.manager_id = m.id` = match where employee's manager_id = manager's id
- Example: Bob Smith (manager_id=1) matches Alice Johnson (id=1)
- Example: Alice (manager_id=NULL) has no manager → NULL result

**5. Understanding `e1.id < e2.id` (Avoiding Duplicate Pairs)**

For finding colleagues in the same department:

```sql
SELECT e1.name AS employee, e1.department_id, e2.name AS colleague
FROM employees e1
LEFT JOIN employees e2 ON e1.department_id = e2.department_id
WHERE e1.id < e2.id
ORDER BY e1.department_id, e1.name;
```

**What `e1.id < e2.id` does:**
- NOT about who is "above" or "below"
- Just a tie-breaking rule to avoid duplicate pairs
- `<` keeps only one direction (smaller ID claims the relationship)

**6. Real-World Insight: Data Engineering Truth**

- Knowing SQL syntax ≠ knowing what data is needed
- Most time spent on: gathering requirements, meetings, understanding business needs
- SQL syntax is easy; figuring out the RIGHT question to ask is hard
- Always clarify: "What does success look like?" before writing queries

---

## CASE WHEN & strftime Deep Dive

### strftime - String Format Time

`strftime` = SQLite function to extract parts from a date.

**Common format codes:**

| Code | Meaning | Example |
|------|---------|---------|
| `%Y` | 4-digit year | 2026 |
| `%m` | 2-digit month | 01-12 |
| `%d` | 2-digit day | 01-31 |
| `%H` | Hour (24h) | 00-23 |

```sql
strftime('%m', '2026-07-01')  -- Returns '07'
strftime('%Y-%m', '2026-07-01')  -- Returns '2026-07'
```

### CASE WHEN for Conditional Aggregation

```sql
SUM(CASE WHEN strftime('%m', o.order_date) = '01' THEN oi.quantity ELSE 0 END) AS Jan
```

**Logic:**
- `strftime('%m', o.order_date)` = extracts month from order_date as string ('01', '02', etc)
- `CASE WHEN month = '01' THEN quantity ELSE 0 END` = if January → use quantity, else → 0
- `SUM(...)` = adds up all the values

**Example:**
| order_date | quantity | CASE result |
|------------|----------|-------------|
| 2026-01-15 | 3 | 3 |
| 2026-01-22 | 2 | 2 |
| 2026-03-10 | 5 | 0 |

**SUM = 5** (January total)

---

## Practice Exercises Analysis

### Exercise #2: Find employees who are managers

**Question:** "Find employees who are managers (have at least one direct report)"

**What it means:** Employee yang TAMPIL SEBAGAI manager di employee lain (ada yang `manager_id`-nya pointing ke employee tersebut)

**Query:**
```sql
SELECT DISTINCT 
        m.id,
        m.name AS manager_name
    FROM
        employees e
    INNER JOIN
        employees m
    ON
        e.manager_id = m.id;
```

**Result:** Alice, David, Frank, Henry (4 managers)

---

### Exercise #4: Management chain for specific employee

**Question:** "Show the management chain for a specific employee (e.g., Eve Davis)"

**What it means:** Tampilkan chain of command dari satu employee sampai ke top-level

**Eve Davis hierarchy:**
```
Eve Davis → Henry Wilson (manager_id=8) → Alice Johnson (manager_id=1) → NULL (CEO)
```

**Query:**
```sql
SELECT e.name AS employee,
       m.name AS manager,
       mm.name AS skip_level_manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id
LEFT JOIN employees mm ON m.manager_id = mm.id
WHERE e.name = 'Eve Davis';
```

---

### Exercise #5: Price comparison matrix

**Question:** "Create a price comparison matrix: products vs suppliers showing price differences"

**What it means:** CROSS JOIN products × suppliers untuk melihat semua kombinasi

**Issue discovered:** Database design flaw - suppliers table tidak punya `category_id`, jadi tidak ada hubungan logis antara supplier dengan product. CROSS JOIN menghasilkan kombinasi tidak masuk akal (e.g., Book Distributor supply Laptop).

**Query:**
```sql
SELECT p.id, p.name as product, p.price, s.name as supplier, s.rating
FROM products p
CROSS JOIN suppliers s
ORDER BY p.id, p.name, s.rating desc;
```

---

## Week 6 Day 4 Practice Exercises - COMPLETED ✅

### Exercise 1: Customers × Promotions
```sql
SELECT c.id, c.name as customer_name, pro.code as promotion_code
FROM customers c CROSS JOIN promotions pro;
```
**Result:** All combinations of customers and promotion codes.

---

### Exercise 2: Find Managers
```sql
SELECT DISTINCT m.id, m.name as manager_name
FROM employees m
INNER JOIN employees e ON e.manager_id = m.id;
```
**Result:** Alice, David, Frank, Henry (4 managers)

---

### Exercise 3: Products × Order Statuses
```sql
SELECT p.id, p.name as product, o.status
FROM products p
CROSS JOIN (SELECT DISTINCT status FROM orders) o
ORDER BY p.id, p.name, o.status;
```
**Result:** All products paired with all possible order statuses.

---

### Exercise 4: Management Chain Eve Davis
```sql
SELECT e.name as employee_name, m.name as manager_name, tm.name as top_manager_name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id
LEFT JOIN employees tm ON m.manager_id = tm.id
WHERE e.name = 'Eve Davis';
```
**Result:** Eve Davis → Henry Wilson → Alice Johnson

---

### Exercise 5: Price Comparison Matrix
```sql
SELECT p.id, p.name as product, p.price, s.name as supplier, s.rating
FROM products p
CROSS JOIN suppliers s
ORDER BY p.id, p.name, s.rating desc;
```
**Result:** All products paired with all suppliers with their ratings.

---

## Manager Hierarchy Summary

```
Alice (CEO)     → Bob, Henry
David (CTO)     → Frank  
Frank           → Carol, Grace
Henry           → Eve
```

| Manager | Direct Reports |
|---------|----------------|
| Alice Johnson | Bob, Henry |
| David Brown | Frank |
| Frank Miller | Carol, Grace |
| Henry Wilson | Eve |

---

## 3-Month Roadmap Progress

```
MONTH 1: FUNDAMENTALS ✅ COMPLETE
├── Week 1: Introduction & Basic Queries ✅
├── Week 2: Filtering with WHERE ✅ (Quiz: 9/10)
├── Week 3: Sorting & Limiting ✅ (Quiz: 9.5/10)
├── Week 4: Data Manipulation (CRUD) ✅ (Quiz: 10/10)

MONTH 2: INTERMEDIATE 🔄 IN PROGRESS
├── Week 5: Table Design & Relationships ✅ (Quiz: 10/10) 🎉
├── Week 6: JOIN Operations 🔄 Day 4/7 COMPLETE ✅ (Exercises done!)
├── Week 7: Aggregation & GROUP BY
└── Week 8: Subqueries

MONTH 3: ADVANCED
├── Week 9: CASE & Advanced Filtering
├── Week 10: Views & Indexes
├── Week 11: Advanced JOINs & Set Operations
└── Week 12: Performance & Best Practices
```

---

## Key Takeaways

1. CROSS JOIN = all combinations (Cartesian product), no ON clause needed
2. Self JOIN = table joined to itself using aliases for hierarchical data
3. `strftime('%m', date)` extracts month as 2-digit string ('01'-'12')
4. CASE WHEN inside SUM = conditional aggregation for pivot reports
5. `manager_id` = self-referential foreign key for employee-manager relationship
6. Direct report = employee yang `manager_id`-nya pointing ke manager tersebut
7. Database design should have proper relationships (e.g., suppliers should have category_id)
8. SQL syntax is easy; understanding what data is needed is the hard part

---

## Next Steps

1. ~~Week 6 Day 1: INNER JOIN~~ ✅ DONE
2. ~~Week 6 Day 2: LEFT JOIN~~ ✅ DONE
3. ~~Week 6 Day 3: RIGHT JOIN & Multiple JOINs~~ ✅ DONE
4. ~~Week 6 Day 4: CROSS JOIN & Self JOIN + All Exercises~~ ✅ DONE
5. **Week 6 Day 5: Multiple JOINs in One Query** - NEXT SESSION
6. **Week 6 Day 6: Complex JOIN Queries**
7. **Week 6 Day 7: Review + Mini Quiz**

---

## Database Design Critique

**Issue:** Week 6 database (sql-learn-db-week6.db) has flawed design for suppliers-products relationship.

**What should exist:**
- Option 1: `suppliers.category_id` → links supplier to specific product category
- Option 2: `supplier_categories` junction table
- Option 3: `product_suppliers` table with pricing per supplier

**Current problem:** CROSS JOIN products × suppliers produces nonsense combinations (Book Distributor supply Laptop).

---

---

## Week 6 Day 5: Multiple JOINs in One Query - COMPLETED ✅

### Practice Exercises Completed (5/5)

#### Exercise 1: Completed orders with customer name, product names, and total
```sql
SELECT
    o.id,
    c.name as customer_name,
    p.name as product,
    oi.quantity,
    p.price as product_price,
    oi.quantity * p.price as total_price,
    o.status as order_status
FROM customers c
INNER JOIN orders o ON o.customer_id = c.id
LEFT JOIN order_items oi ON oi.order_id = o.id
LEFT JOIN products p ON oi.product_id = p.id
WHERE o.status = 'completed'
ORDER BY o.id;
```
**Key:** LEFT JOIN for products (in case order_items is NULL)

---

#### Exercise 2: Orders with shipment status and supplier information
```sql
SELECT
    o.id,
    shi.status as shipments_status,
    sup.name as supplier_name,
    sup.city,
    sup.rating
FROM orders o
LEFT JOIN shipments shi ON shi.order_id = o.id
LEFT JOIN suppliers sup ON shi.supplier_id = sup.id;
```
**Key:** LEFT JOINs since not all orders may have shipments

---

#### Exercise 3: Top 3 customers by total spending with order count
```sql
SELECT
    c.id,
    c.name as customer_name,
    COUNT(o.id) as order_count,
    SUM(o.total) as total_spending
FROM customers c
INNER JOIN orders o ON o.customer_id = c.id
GROUP BY c.id, c.name
ORDER BY total_spending DESC
LIMIT 3;
```
**Key:** Aggregate per customer, ORDER BY spending DESC, LIMIT 3

---

#### Exercise 4: Product summary with category, times ordered, revenue
```sql
SELECT
    p.id,
    cat.name as category,
    p.name as product_name,
    COUNT(oi.id) as times_ordered,
    SUM(oi.quantity * oi.price) as revenue
FROM products p
INNER JOIN categories cat ON p.category_id = cat.id
INNER JOIN order_items oi ON oi.product_id = p.id
GROUP BY p.id, p.name
ORDER BY p.id, revenue DESC;
```
**Key:** Multiple JOINs (products → categories, products → order_items), aggregation

---

#### Exercise 5: Employees with department and manager names
```sql
SELECT
    e.id,
    e.name as employee_name,
    d.name as department,
    m.name as manager
FROM employees e
INNER JOIN departments d ON e.department_id = d.id
LEFT JOIN employees m ON e.manager_id = m.id;
```
**Key:** Self JOIN for manager lookup, LEFT JOIN for CEO (no manager)

---

## 3-Month Roadmap Progress

```
MONTH 1: FUNDAMENTALS ✅ COMPLETE
├── Week 1: Introduction & Basic Queries ✅
├── Week 2: Filtering with WHERE ✅ (Quiz: 9/10)
├── Week 3: Sorting & Limiting ✅ (Quiz: 9.5/10)
├── Week 4: Data Manipulation (CRUD) ✅ (Quiz: 10/10)

MONTH 2: INTERMEDIATE 🔄 IN PROGRESS
├── Week 5: Table Design & Relationships ✅ (Quiz: 10/10) 🎉
├── Week 6: JOIN Operations 🔄 Day 5/7 COMPLETE ✅ (Exercises done!)
├── Week 7: Aggregation & GROUP BY
└── Week 8: Subqueries

MONTH 3: ADVANCED
├── Week 9: CASE & Advanced Filtering
├── Week 10: Views & Indexes
├── Week 11: Advanced JOINs & Set Operations
└── Week 12: Performance & Best Practices
```

---

## Next Steps

1. ~~Week 6 Day 1: INNER JOIN~~ ✅ DONE
2. ~~Week 6 Day 2: LEFT JOIN~~ ✅ DONE
3. ~~Week 6 Day 3: RIGHT JOIN & Multiple JOINs~~ ✅ DONE
4. ~~Week 6 Day 4: CROSS JOIN & Self JOIN~~ ✅ DONE
5. ~~Week 6 Day 5: Multiple JOINs in One Query~~ ✅ DONE
6. **Week 6 Day 6: Complex JOIN Queries** - NEXT SESSION
7. **Week 6 Day 7: Review + Mini Quiz**

---

*Rest well! Week 6 Day 6 awaits! 🎉*

---

## Week 6 Day 6: Complex JOIN Queries - COMPLETED ✅

### Concepts Learned

**1. COALESCE Function**

```sql
COALESCE(value1, value2, value3, ...)
-- Returns the first non-NULL value
```

**When to use:**
- Replace NULL with default value: `COALESCE(SUM(quantity), 0)`
- Handle missing data: `COALESCE(phone, email, 'No contact')`
- Math with potential NULLs: `price * COALESCE(quantity, 0)`

**Why needed with LEFT JOIN + SUM:**
- LEFT JOIN can produce NULLs when no match
- SUM() on all NULL rows returns NULL, not 0
- COALESCE converts NULL to 0 for clean numbers

---

**2. ROW_NUMBER() Window Function**

```sql
ROW_NUMBER() OVER (
    PARTITION BY column_to_group_by
    ORDER BY column_to_sort_by ASC/DESC
)
```

**Key concepts:**
| Concept | Meaning |
|---------|---------|
| `OVER()` | Defines the window (sorting & grouping) |
| `PARTITION BY` | Groups rows (like GROUP BY, but keeps all rows) |
| `ORDER BY` | Defines the sequence for numbering |
| `ROW_NUMBER()` | Starts at 1 for each partition |

---

**3. Why Subquery/CTE is Required for Window Functions**

**SQL Logical Execution Order:**
| Order | Clause | What Happens |
|-------|--------|--------------|
| 1 | FROM/JOIN | Load tables |
| 2 | WHERE | Filter rows ← runs BEFORE SELECT |
| 3 | GROUP BY | Group data |
| 4 | SELECT | Compute expressions ← ROW_NUMBER() created HERE |

**Problem:** WHERE runs BEFORE SELECT, so window function aliases don't exist yet in WHERE.

**Solution:** Use subquery or CTE to compute window function first, then filter in outer query.

---

**4. CTE vs Subquery Comparison**

| Pattern | Structure |
|---------|-----------|
| **Subquery** | `SELECT * FROM ( SELECT ... ) WHERE ...` |
| **CTE** | `WITH name AS ( SELECT ... ) SELECT * FROM name WHERE ...` |

Both work identically. CTE is preferred for readability in complex queries.

---

### Practice Exercises Completed

#### Exercise 1: Top 3 products by revenue in each category

**Query (subquery approach):**
```sql
SELECT * FROM (
    SELECT
        cat.name as category,
        p.name as product,
        p.price,
        COALESCE(SUM(oi.quantity * oi.price), 0) as revenue,
        ROW_NUMBER() OVER(
            PARTITION BY cat.name
            ORDER BY COALESCE(SUM(oi.quantity * oi.price), 0) DESC
        ) AS rank_in_category
    FROM 
        categories cat
    INNER JOIN
        products p ON p.category_id = cat.id
    LEFT JOIN
        order_items oi ON oi.product_id = p.id
    GROUP BY cat.name, p.name, p.price
) WHERE rank_in_category <= 3;
```

**Common errors fixed:**
1. Missing GROUP BY (required when using aggregate + non-aggregate columns)
2. Using alias in PARTITION BY/ORDER BY instead of actual expression
3. Trying to use WHERE on window function alias directly

---

## 3-Month Roadmap Progress

```
MONTH 1: FUNDAMENTALS ✅ COMPLETE
├── Week 1: Introduction & Basic Queries ✅
├── Week 2: Filtering with WHERE ✅ (Quiz: 9/10)
├── Week 3: Sorting & Limiting ✅ (Quiz: 9.5/10)
├── Week 4: Data Manipulation (CRUD) ✅ (Quiz: 10/10)

MONTH 2: INTERMEDIATE 🔄 IN PROGRESS
├── Week 5: Table Design & Relationships ✅ (Quiz: 10/10) 🎉
├── Week 6: JOIN Operations 🔄 Day 6/7 COMPLETE ✅ (Exercise 1 done!)
├── Week 7: Aggregation & GROUP BY
└── Week 8: Subqueries

MONTH 3: ADVANCED
├── Week 9: CASE & Advanced Filtering
├── Week 10: Views & Indexes
├── Week 11: Advanced JOINs & Set Operations
└── Week 12: Performance & Best Practices
```

---

## Key Takeaways

1. COALESCE returns first non-NULL value, essential for handling NULL sums
2. ROW_NUMBER() assigns sequential numbers within partitions
3. WHERE runs BEFORE SELECT - cannot filter on window functions directly
4. Subquery/CTE required: compute window function first, then filter
5. PARTITION BY and ORDER BY in window functions need actual expressions, not aliases
6. GROUP BY required when mixing aggregate and non-aggregate columns

---

## Next Steps

1. ~~Week 6 Day 1: INNER JOIN~~ ✅ DONE
2. ~~Week 6 Day 2: LEFT JOIN~~ ✅ DONE
3. ~~Week 6 Day 3: RIGHT JOIN & Multiple JOINs~~ ✅ DONE
4. ~~Week 6 Day 4: CROSS JOIN & Self JOIN~~ ✅ DONE
5. ~~Week 6 Day 5: Multiple JOINs in One Query~~ ✅ DONE
6. ~~Week 6 Day 6: Exercise 1 (Top 3 per category)~~ ✅ DONE
7. **Week 6 Day 6: Exercises 2-5** - NEXT SESSION
8. **Week 6 Day 7: Review + Mini Quiz**

---

*Rest well! Week 6 Day 6 Exercises 2-5 await! 🎉*

---

## Week 6 Day 6 Exercises 2-5 - COMPLETED ✅

### Exercise 2: NY/LA Customers Spent > $500

**Note:** SQLite allows alias in HAVING, but standard SQL requires repeating aggregate.

```sql
SELECT
    c.id,
    c.name as customer_name,
    c.city,
    SUM(o.total) as total_spending
FROM customers c 
LEFT JOIN orders o ON o.customer_id = c.id
WHERE c.city IN ('New York', 'Los Angeles')
GROUP BY c.id, c.name, c.city
HAVING SUM(o.total) > 500           -- Best practice: repeat aggregate
ORDER BY total_spending DESC;
```

---

### Exercise 3: Orders with City and Shipment Status

```sql
SELECT
    o.id as order_id,
    c.city,
    s.status as shipment_status,
    o.total
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.id
LEFT JOIN shipments s ON s.order_id = o.id
ORDER BY o.total DESC;
```

---

### Exercise 4: Products Never Ordered (Revised)

**Key Fix:** GROUP BY must include unique identifier (p.id), add HAVING to filter.

```sql
SELECT
    p.id as product_id,
    p.name as product,
    COUNT(o.id) as ordered_history
FROM products p 
LEFT JOIN order_items oi ON oi.product_id = p.id
LEFT JOIN orders o ON oi.order_id = o.id
GROUP BY p.id, p.name
HAVING COUNT(o.id) = 0              -- Filter to never-ordered only
ORDER BY product_id;
```

---

### Exercise 5: Department Report with Salary Budget

**Clarified:** "total salary budget" = SUM of actual salaries (not departments.budget).

```sql
SELECT
    d.id as department_id,
    d.name as department_name,
    d.budget as department_budget,
    AVG(e.salary) as avg_salary,
    SUM(e.salary) as actual_salary_spent
FROM departments d 
LEFT JOIN employees e ON e.department_id = d.id
GROUP BY d.id, d.name;
```

---

## SQL Clause Order - Critical Concept

**Correct Order:**
```sql
WHERE ...        -- 1. Filter rows (before grouping)
GROUP BY ...     -- 2. Group rows
HAVING ...       -- 2.5. Filter groups (after grouping)
ORDER BY ...     -- 3. Sort final result
```

**Why:**
- WHERE runs BEFORE GROUP BY → can't use aggregates
- HAVING runs AFTER GROUP BY → can use aggregates
- SELECT runs AFTER HAVING → aliases created here

---

## Aggregate vs Window Function - When to Use Which

### Use AGGREGATE (GROUP BY) when requirement says:
- "**per** customer/category/month" → GROUP BY
- "total/count/average" → aggregate functions
- "**who have** / **that have**" → GROUP BY + HAVING

### Use WINDOW FUNCTION when requirement says:
- "**top N** per group" → ROW_NUMBER() + outer WHERE
- "**rank** within" → ROW_NUMBER() OVER()
- "**each row with** comparison" → LAG/LEAD() OVER()
- "**all rows with** running total" → SUM() OVER()

### Decision Flowchart:
```
Need to REDUCE rows?
├── YES → GROUP BY + aggregate → HAVING can filter
└── NO (keep rows, just annotate) → Window function → CTE/subquery to filter
```

---

## Understanding "Total Salary Budget" Ambiguity

**Two interpretations:**

| Interpretation | Meaning | Column |
|----------------|---------|--------|
| Actual spending | SUM of all employee salaries | `SUM(e.salary)` |
| Allocated budget | departments.budget column | `d.budget` |

**Best practice:** Ask stakeholder for clarification.

**Good question to ask:** "Do you mean the sum of actual salaries paid, or the allocated department budget?"

---

## Key Takeaways

1. **SQL Clause Order:** WHERE → GROUP BY → HAVING → ORDER BY
2. **HAVING vs WHERE:** HAVING filters groups (after GROUP BY), WHERE filters rows (before)
3. **Standard SQL:** Repeat aggregate in HAVING, don't use alias
4. **GROUP BY rule:** All non-aggregated columns in SELECT must be in GROUP BY
5. **Aggregate vs Window:** Aggregate REDUCES rows; Window ADDS to rows without reducing
6. **CTE/Subquery needed:** When filtering on window function results (WHERE can't see SELECT aliases)
7. **Ambiguous requirements:** Always clarify with stakeholder (e.g., "salary budget" vs "actual spending")

---

## 3-Month Roadmap Progress

```
MONTH 1: FUNDAMENTALS ✅ COMPLETE
├── Week 1: Introduction & Basic Queries ✅
├── Week 2: Filtering with WHERE ✅ (Quiz: 9/10)
├── Week 3: Sorting & Limiting ✅ (Quiz: 9.5/10)
├── Week 4: Data Manipulation (CRUD) ✅ (Quiz: 10/10)

MONTH 2: INTERMEDIATE 🔄 IN PROGRESS
├── Week 5: Table Design & Relationships ✅ (Quiz: 10/10) 🎉
├── Week 6: JOIN Operations ✅ Day 6/7 COMPLETE (All Exercises Done!)
├── Week 7: Aggregation & GROUP BY
└── Week 8: Subqueries

MONTH 3: ADVANCED
├── Week 9: CASE & Advanced Filtering
├── Week 10: Views & Indexes
├── Week 11: Advanced JOINs & Set Operations
└── Week 12: Performance & Best Practices
```

---

## Next Steps

1. ~~Week 6 Day 1: INNER JOIN~~ ✅ DONE
2. ~~Week 6 Day 2: LEFT JOIN~~ ✅ DONE
3. ~~Week 6 Day 3: RIGHT JOIN & Multiple JOINs~~ ✅ DONE
4. ~~Week 6 Day 4: CROSS JOIN & Self JOIN~~ ✅ DONE
5. ~~Week 6 Day 5: Multiple JOINs in One Query~~ ✅ DONE
6. ~~Week 6 Day 6: Complex JOIN Queries (All 5 Exercises)~~ ✅ DONE
7. **Week 6 Day 7: Review + Mini Quiz** - NEXT SESSION

---

*Great progress! Week 6 Day 7 Quiz awaits! 🎉*
