# Lesson 1.1: Why Window Functions Exist

## The Problem: GROUP BY Can't Do This

Before window functions, if you wanted to see **total sales per region AND each product's contribution**, you had two painful options:

### Option A: Two Separate Queries (Inefficient)

```sql
-- Query 1: Get total sales by region
SELECT region_id, SUM(total_amount) AS region_total
FROM orders
GROUP BY region_id;

-- Query 2: Get each product's sales
SELECT prod_id, SUM(qty * unit_price) AS product_total
FROM order_items
GROUP BY prod_id;
```

**English Translation:**
> "First, show me the total sales amount grouped by each region. Then separately, show me the total quantity times unit price for each product."

**Problem:** These are two separate results. You can't easily see both side by side.

---

### Option B: Subquery (Hard to Read)

```sql
SELECT 
    p.prod_name,
    oi.qty * oi.unit_price AS product_total,
    (SELECT SUM(o2.total_amount) 
     FROM orders o2 
     WHERE o2.store_id IN (SELECT store_id FROM stores WHERE region_id = s.region_id)
    ) AS region_total
FROM order_items oi
JOIN products p ON oi.prod_id = p.prod_id
JOIN orders o ON oi.ord_id = o.ord_id
JOIN stores s ON o.store_id = s.store_id;
```

**English Translation:**
> "Show me each product name, its total sales amount, and the total sales for the entire region that store belongs to — calculated using a subquery that sums all orders from stores in that region."

**Problem:** Complex, nested, and slow on large datasets.

---

## The Solution: Window Functions

```sql
SELECT 
    p.prod_name,
    oi.qty * oi.unit_price AS product_total,
    SUM(oi.qty * oi.unit_price) OVER (PARTITION BY s.region_id) AS region_total,
    ROUND((oi.qty * oi.unit_price) / 
          SUM(oi.qty * oi.unit_price) OVER (PARTITION BY s.region_id) * 100, 2) AS pct_of_region
FROM order_items oi
JOIN products p ON oi.prod_id = p.prod_id
JOIN orders o ON oi.ord_id = o.ord_id
JOIN stores s ON o.store_id = s.store_id;
```

**English Translation:**
> "Show me each product name, its total sales amount, and the total sales for its region, plus what percentage that product contributes to the region total — all in one clean result."

---

## Visual Comparison

### GROUP BY: Condenses Rows

| operation | result |
|-----------|--------|
| `GROUP BY region_id` | 5 rows (one per region) |
| Input: 90 order rows | Output: 5 summary rows |

### Window Functions: Keep Rows, Add Calculations

| operation | result |
|-----------|--------|
| `SUM() OVER (PARTITION BY region_id)` | 90 rows (all orders preserved) |
| Input: 90 order rows | Output: 90 rows + new calculated column |

---

## The Key Insight

| GROUP BY | Window Functions |
|----------|-----------------|
| Collapses rows into fewer summary rows | Keeps all original rows |
| One aggregation per query | Can add multiple window calculations |
| Can't mix detail + summary in same row | Detail and summary coexist |

---

## When to Use Window Functions

| Scenario | Use Window Functions? |
|----------|----------------------|
| Show each employee's salary AND the department average | Yes |
| Show total revenue per region (no per-row detail needed) | No (GROUP BY is fine) |
| Rank customers by purchase amount | Yes |
| Find the difference between each row and the average | Yes |
| Simply count rows per group | No (GROUP BY is simpler) |

---

## Summary

**Window functions** let you perform calculations across rows **without collapsing them** — unlike `GROUP BY` which reduces rows to one per group.

They add new columns to your existing result set while keeping all your original rows intact.

**Coming up next:** The anatomy of window function syntax.
