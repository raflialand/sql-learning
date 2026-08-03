# Lesson 2.3: NTILE(n) — Dividing into Equal Groups

## What It Does

Divides rows within a partition into **n approximately equal groups** and assigns a group number (1, 2, 3, etc.) to each row.

**Use Cases:**
- Quartile analysis (divide into 4 groups)
- Tercile analysis (divide into 3 groups)
- Percentile analysis (divide into 100 groups)
- Segmenting customers into spending tiers
- Binning continuous variables

---

## Basic Syntax

```sql
NTILE(n) OVER (PARTITION BY column ORDER BY column)
```

Where `n` is the number of groups you want.

---

## Example 1: Divide Customers into Spending Quartiles

**HR Request:**
> "Divide our customers into 4 equal groups based on their total spending. Call the groups Q1 (highest spenders), Q2, Q3, and Q4 (lowest spenders)."

```sql
SELECT 
    c.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    NTILE(4) OVER (ORDER BY COALESCE(SUM(o.total_amount), 0) DESC) AS spending_quartile
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.first_name, c.last_name
ORDER BY spending_quartile, total_spent DESC;
```

**English Translation:**
> "Rank all customers by their total spending and divide them into 4 groups of equal size. The top 25% of spenders get quartile 1, the next 25% get quartile 2, and so on."

**Result Preview:**

| cust_id | customer_name | total_spent | spending_quartile |
|---------|---------------|-------------|-------------------|
| CST006 | Jessica Garcia | 9293.00 | **1** |
| CST002 | Sarah Johnson | 3454.00 | **1** |
| CST001 | John Smith | 3227.00 | **1** |
| CST004 | Emily Brown | 1656.00 | **1** |
| CST013 | Daniel Harris | 1465.00 | **1** | ← 5 customers in Q1
| CST015 | Matthew Thompson | 1427.00 | **2** |
| CST008 | Ashley Lewis | 1078.00 | **2** |
| ... | ... | ... | ... |

---

## How NTILE() Handles Uneven Counts

If the total number of rows doesn't divide evenly by `n`, NTILE() distributes extra rows to the earlier groups.

**Example:** 20 customers divided into 4 quartiles = 5 per quartile exactly.

**Example:** 21 customers divided into 4 quartiles:
- First 1 extra row goes to group 1 (6 in Q1, 5 in Q2, 5 in Q3, 5 in Q4)
- Or distribution varies by database

---

## Example 2: Quarterly Sales Performance (Terciles)

**HR Request:**
> "Classify each store's monthly performance into 3 tiers: 'Top', 'Middle', and 'Bottom'. Each tier should have approximately the same number of store-months."

```sql
SELECT 
    ds.sale_date,
    ds.store_id,
    s.store_name,
    ds.total_revenue,
    CASE NTILE(3) OVER (PARTITION BY ds.sale_date ORDER BY ds.total_revenue DESC)
        WHEN 1 THEN 'Top'
        WHEN 2 THEN 'Middle'
        WHEN 3 THEN 'Bottom'
    END AS performance_tier
FROM daily_sales ds
JOIN stores s ON ds.store_id = s.store_id
WHERE ds.sale_date BETWEEN '2024-01-01' AND '2024-01-31'
ORDER BY ds.sale_date, ds.total_revenue DESC;
```

**English Translation:**
> "For each day, rank stores by their revenue that day. Put the highest-performing third into 'Top', the middle third into 'Middle', and the lowest third into 'Bottom'."

---

## Example 3: Customer Segmentation for Marketing

**HR Request:**
> "Segment our customers into 5 groups for targeted marketing: 'VIP' (top 20%), 'Premium' (next 20%), 'Regular' (next 20%), 'Basic' (next 20%), and 'New' (bottom 20%)."

```sql
SELECT 
    c.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.membership_level,
    COALESCE(SUM(o.total_amount), 0) AS total_spent,
    CASE NTILE(5) OVER (ORDER BY COALESCE(SUM(o.total_amount), 0) DESC)
        WHEN 1 THEN 'VIP'
        WHEN 2 THEN 'Premium'
        WHEN 3 THEN 'Regular'
        WHEN 4 THEN 'Basic'
        WHEN 5 THEN 'New'
    END AS marketing_segment
FROM customers c
LEFT JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id, c.first_name, c.last_name, c.membership_level
ORDER BY marketing_segment, total_spent DESC;
```

**English Translation:**
> "Based on total spending, divide all customers into 5 equal groups. Assign them marketing segment labels from VIP (highest spenders) to New (lowest or no spending)."

---

## Example 4: Percentile Rank (100 Groups)

**HR Request:**
> "Show me each product's price and what percentile that price falls into compared to all other active products."

```sql
SELECT 
    prod_name,
    cat_id,
    unit_price,
    NTILE(100) OVER (ORDER BY unit_price DESC) AS price_percentile
FROM products
WHERE is_active = TRUE
ORDER BY price_percentile;
```

**English Translation:**
> "Sort all active products by price from highest to lowest. Divide them into 100 equal groups. A product in the 100th percentile is the most expensive; a product in the 1st percentile is the cheapest."

---

## NTILE vs RANK vs DENSE_RANK

| Function | What It Does | Example Output |
|----------|--------------|----------------|
| `RANK()` | Assigns rank with gaps | 1, 1, 3, 4, 4, 6 |
| `DENSE_RANK()` | Assigns rank without gaps | 1, 1, 2, 3, 3, 4 |
| `NTILE(n)` | Divides into n equal groups | 1, 1, 2, 2, 3, 3 |

**Key Difference:**
- RANK/DENSE_RANK assign ranks based on ORDER BY values
- NTILE assigns groups based on the **distribution** of values

---

## Common Use Cases Table

| n Value | Name | Common Use Case |
|---------|------|-----------------|
| 2 | Median split | High vs Low |
| 3 | Terciles | Top/Middle/Bottom tiers |
| 4 | Quartiles | Q1, Q2, Q3, Q4 (earnings reports) |
| 5 | Quintiles | 5-tier segmentation |
| 10 | Deciles | Percentile groupings |
| 100 | Percentiles | Detailed ranking |

---

## Advanced: NTILE with Variable-Sized Groups

If you need exact group sizes (not approximately equal), use NTILE with a subquery or calculate the group boundaries manually:

```sql
SELECT 
    cust_id,
    total_spent,
    CASE 
        WHEN total_spent >= (SELECT PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY total_spent) FROM customers) THEN 'Top 20%'
        WHEN total_spent >= (SELECT PERCENTILE_CONT(0.6) WITHIN GROUP (ORDER BY total_spent) FROM customers) THEN 'Next 20%'
        WHEN total_spent >= (SELECT PERCENTILE_CONT(0.4) WITHIN GROUP (ORDER BY total_spent) FROM customers) THEN 'Middle 20%'
        WHEN total_spent >= (SELECT PERCENTILE_CONT(0.2) WITHIN GROUP (ORDER BY total_spent) FROM customers) THEN 'Next 20%'
        ELSE 'Bottom 20%'
    END AS spending_group
FROM (
    SELECT cust_id, COALESCE(SUM(total_amount), 0) AS total_spent
    FROM orders
    GROUP BY cust_id
) cust_totals;
```

---

## Coming Up Next

Exercises for Module 2: Ranking Functions. You'll practice:
- Using ROW_NUMBER for deduplication
- Using RANK/DENSE_RANK for leaderboards
- Using NTILE for segmentation
- Debugging ranking-related issues
