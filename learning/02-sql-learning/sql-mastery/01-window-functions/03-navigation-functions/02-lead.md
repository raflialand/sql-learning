# Lesson 3.2: LEAD() — Access Next Row Values

## What It Does

`LEAD()` retrieves a value from the **next row** in a result set (ordered within a partition).

**Think of it as:** "Look at the row that comes after this one."

**Use Cases:**
- Compare current value with next period (upcoming, forward-looking)
- Calculate future revenue or trends
- Identify when values change
- Find time until next event

---

## Basic Syntax

```sql
LEAD(column) OVER (PARTITION BY column ORDER BY column)
LEAD(column, offset) OVER (PARTITION BY column ORDER BY column)
LEAD(column, offset, default) OVER (PARTITION BY column ORDER BY column)
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| `column` | The column to retrieve from next row | — |
| `offset` | How many rows ahead (1 = immediately next) | 1 |
| `default` | Value to use if no next row exists | NULL |

---

## LAG vs LEAD

| Function | Direction | Looks At |
|----------|-----------|----------|
| `LAG()` | Backward | Previous row(s) |
| `LEAD()` | Forward | Next row(s) |

```
Row 1: LAG() → NULL    | Row 1: LEAD() → Row 2's value
Row 2: LAG() → Row 1   | Row 2: LEAD() → Row 3's value
Row 3: LAG() → Row 2   | Row 3: LEAD() → Row 4's value
Row 4: LAG() → Row 3   | Row 4: LEAD() → NULL (no next)
```

---

## Example 1: Next Order Date for Each Customer

**HR Request:**
> "Show me each customer's orders in chronological order. For each order, also show me what their next order date was."

```sql
SELECT 
    o.ord_id,
    o.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.ord_date,
    o.total_amount,
    LEAD(o.ord_date) OVER (PARTITION BY o.cust_id ORDER BY o.ord_date) AS next_order_date
FROM orders o
JOIN customers c ON o.cust_id = c.cust_id
ORDER BY o.cust_id, o.ord_date;
```

**English Translation:**
> "For each customer, list their orders from earliest to latest. Look at the order that comes after each one and show that order's date."

**Result Preview:**

| ord_id | customer_name | ord_date | total_amount | next_order_date |
|--------|---------------|----------|--------------|-----------------|
| ORD001 | John Smith | 2024-01-05 | 1299.00 | **2024-01-15** |
| ORD007 | John Smith | 2024-01-15 | 999.00 | **2024-03-01** |
| ORD025 | John Smith | 2024-03-01 | 999.00 | **2024-04-15** |
| ORD042 | John Smith | 2024-04-15 | 1799.00 | **2024-06-05** |
| ORD062 | John Smith | 2024-06-05 | 599.00 | NULL (last order) |
| ORD002 | Sarah Johnson | 2024-01-06 | 2348.00 | **2024-02-03** |
| ... | ... | ... | ... | ... |

---

## Example 2: Days Between Consecutive Orders

**HR Request:**
> "For each customer, calculate how many days passed between their consecutive orders."

```sql
SELECT 
    o.ord_id,
    o.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.ord_date,
    LEAD(o.ord_date) OVER (PARTITION BY o.cust_id ORDER BY o.ord_date) AS next_order_date,
    JULIANDAY(LEAD(o.ord_date) OVER (PARTITION BY o.cust_id ORDER BY o.ord_date)) - 
    JULIANDAY(o.ord_date) AS days_between_orders
FROM orders o
JOIN customers c ON o.cust_id = c.cust_id
ORDER BY o.cust_id, o.ord_date;
```

**English Translation:**
> "For each customer, list their orders. Calculate the difference in days between each order and the next order. If there's no next order, this will be empty."

---

## Example 3: Identify Price Changes Between Product Orders

**HR Request:**
> "For each product sale, show me the current order's unit price and the unit price of the next sale of that same product."

```sql
SELECT 
    oi.item_id,
    oi.ord_id,
    o.ord_date,
    p.prod_name,
    oi.unit_price AS current_price,
    LEAD(oi.unit_price) OVER (
        PARTITION BY oi.prod_id 
        ORDER BY o.ord_date
    ) AS next_sale_price
FROM order_items oi
JOIN orders o ON oi.ord_id = o.ord_id
JOIN products p ON oi.prod_id = p.prod_id
ORDER BY p.prod_name, o.ord_date;
```

**English Translation:**
> "Track each time a product was sold. Show the sale price this time and what price it was sold at the next time (for the same product)."

---

## Example 4: Upcoming Revenue (Forward-Looking)

**HR Request:**
> "Show me the current month's orders and the total revenue we expect to receive from the next month's orders (per customer)."

```sql
SELECT 
    o.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    DATE(o.ord_date, 'start of month') AS order_month,
    SUM(o.total_amount) AS month_revenue,
    LEAD(SUM(o.total_amount)) OVER (
        PARTITION BY o.cust_id 
        ORDER BY DATE(o.ord_date, 'start of month')
    ) AS next_month_revenue
FROM orders o
JOIN customers c ON o.cust_id = c.cust_id
GROUP BY o.cust_id, c.first_name, c.last_name, DATE(o.ord_date, 'start of month')
ORDER BY o.cust_id, order_month;
```

**English Translation:**
> "Group orders by customer and month. For each customer-month, show the total revenue and what the NEXT month's total revenue was for that customer."

---

## Example 5: Combined LAG and LEAD

**HR Request:**
> "Show me daily sales with the previous day, current day, and next day revenue — all side by side."

```sql
SELECT 
    sale_date,
    store_id,
    LAG(total_revenue) OVER (PARTITION BY store_id ORDER BY sale_date) AS prev_day,
    total_revenue AS today,
    LEAD(total_revenue) OVER (PARTITION BY store_id ORDER BY sale_date) AS next_day
FROM daily_sales
WHERE sale_date BETWEEN '2024-01-05' AND '2024-01-12'
ORDER BY store_id, sale_date;
```

**English Translation:**
> "For each store, show today's revenue along with what the previous day's revenue was and what the next day's revenue will be."

---

## Use Case: Identifying Customer Churn

**HR Request:**
> "Find customers who haven't placed an order in over 90 days, based on the gap between their orders."

```sql
SELECT 
    cust_id,
    customer_name,
    last_order_date,
    next_order_date,
    days_since_last_order
FROM (
    SELECT 
        o.cust_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        o.ord_date AS last_order_date,
        LEAD(o.ord_date) OVER (PARTITION BY o.cust_id ORDER BY o.ord_date) AS next_order_date,
        JULIANDAY(LEAD(o.ord_date) OVER (PARTITION BY o.cust_id ORDER BY o.ord_date)) - 
        JULIANDAY(o.ord_date) AS days_since_last_order
    FROM orders o
    JOIN customers c ON o.cust_id = c.cust_id
) sub
WHERE days_since_last_order > 90 OR next_order_date IS NULL;
```

**English Translation:**
> "Look at each customer's order history. Calculate the gap between each order and their next. Flag customers where the gap exceeds 90 days or where there is no next order (they may have churned)."

---

## Coming Up Next

`FIRST_VALUE()` and `LAST_VALUE()` — accessing the first and last values within a window frame.
