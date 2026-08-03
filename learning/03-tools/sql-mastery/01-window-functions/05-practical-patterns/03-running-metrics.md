# Lesson 5.3: Running Metrics Dashboard Patterns

## Overview

Real analytics dashboards combine multiple window functions to provide comprehensive metrics in a single query. This lesson shows patterns for building complete analytical views.

---

## Pattern: Complete Sales Dashboard Per Store Per Day

**HR Request:**
> "Build a comprehensive daily sales dashboard for each store showing: today's metrics, comparison to yesterday, running totals, and percentile rankings."

```sql
SELECT 
    ds.sale_date,
    ds.store_id,
    s.store_name,
    r.region_name,
    ds.total_revenue,
    ds.total_orders,
    ds.total_profit,
    
    -- Yesterday's metrics (for comparison)
    LAG(ds.total_revenue) OVER (
        PARTITION BY ds.store_id ORDER BY ds.sale_date
    ) AS yesterday_revenue,
    LAG(ds.total_orders) OVER (
        PARTITION BY ds.store_id ORDER BY ds.sale_date
    ) AS yesterday_orders,
    
    -- Day-over-day change
    ds.total_revenue - LAG(ds.total_revenue) OVER (
        PARTITION BY ds.store_id ORDER BY ds.sale_date
    ) AS dod_revenue_change,
    
    -- 7-day metrics
    AVG(ds.total_revenue) OVER (
        PARTITION BY ds.store_id ORDER BY ds.sale_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS revenue_ma_7_day,
    
    -- Running totals (month to date)
    SUM(ds.total_revenue) OVER (
        PARTITION BY ds.store_id, strftime('%Y-%m', ds.sale_date)
        ORDER BY ds.sale_date
    ) AS month_to_date_revenue,
    
    -- How today's revenue compares to this store's average
    ROUND(ds.total_revenue / AVG(ds.total_revenue) OVER (PARTITION BY ds.store_id) * 100, 2) 
        AS pct_of_store_avg,
    
    -- Revenue rank among all stores today
    RANK() OVER (ORDER BY ds.total_revenue DESC) AS revenue_rank_all_stores,
    
    -- Revenue rank within region today
    RANK() OVER (PARTITION BY r.region_name ORDER BY ds.total_revenue DESC) 
        AS revenue_rank_in_region

FROM daily_sales ds
JOIN stores s ON ds.store_id = s.store_id
JOIN regions r ON s.region_id = r.region_id
WHERE ds.sale_date BETWEEN '2024-01-05' AND '2024-01-15'
ORDER BY ds.store_id, ds.sale_date;
```

**English Translation:**
> "Build a full analytics dashboard showing each store's daily performance. Include today's numbers, yesterday's numbers for comparison, day-over-day changes, 7-day moving average, month-to-date running total, how today compares to the store's historical average, and how the store ranks among all stores and within its region."

---

## Pattern: Customer Lifetime Value Dashboard

**HR Request:**
> "Create a customer analysis view showing: order history, running totals, average order value trends, and customer tier classification."

```sql
SELECT 
    c.cust_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.membership_level,
    c.signup_date,
    o.ord_id,
    o.ord_date,
    o.total_amount,
    
    -- Order sequence
    ROW_NUMBER() OVER (
        PARTITION BY c.cust_id ORDER BY o.ord_date
    ) AS order_sequence,
    
    -- Running metrics
    SUM(o.total_amount) OVER (
        PARTITION BY c.cust_id ORDER BY o.ord_date
    ) AS lifetime_spending,
    
    AVG(o.total_amount) OVER (
        PARTITION BY c.cust_id ORDER BY o.ord_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS avg_order_value_to_date,
    
    -- Days between orders
    o.ord_date - LAG(o.ord_date) OVER (
        PARTITION BY c.cust_id ORDER BY o.ord_date
    ) AS days_since_last_order,
    
    -- Days since becoming a customer
    o.ord_date - FIRST_VALUE(o.ord_date) OVER (
        PARTITION BY c.cust_id ORDER BY o.ord_date
    ) AS days_since_first_purchase,
    
    -- What % of customer's total lifetime this order represents
    ROUND(o.total_amount / SUM(o.total_amount) OVER (
        PARTITION BY c.cust_id
    ) * 100, 2) AS pct_of_lifetime_value,
    
    -- Rank among all customers by lifetime value
    RANK() OVER (ORDER BY SUM(o.total_amount) OVER (PARTITION BY c.cust_id) DESC) 
        AS customer_value_rank

FROM customers c
INNER JOIN orders o ON c.cust_id = o.cust_id
ORDER BY c.cust_id, o.ord_date;
```

---

## Pattern: Product Performance Analysis

**HR Request:**
> "Analyze each product's performance showing: revenue ranking, volume ranking, trend direction, and category contribution."

```sql
SELECT 
    p.prod_id,
    p.prod_name,
    c.cat_name,
    p.brand,
    p.unit_price,
    COALESCE(SUM(oi.qty), 0) AS total_quantity_sold,
    COALESCE(SUM(oi.qty * oi.unit_price), 0) AS total_revenue,
    COUNT(DISTINCT o.ord_id) AS order_count,
    
    -- Revenue rank within category
    RANK() OVER (
        PARTITION BY c.cat_id 
        ORDER BY COALESCE(SUM(oi.qty * oi.unit_price), 0) DESC
    ) AS revenue_rank_in_cat,
    
    -- Volume rank within category
    RANK() OVER (
        PARTITION BY c.cat_id 
        ORDER BY COALESCE(SUM(oi.qty), 0) DESC
    ) AS volume_rank_in_cat,
    
    -- Revenue rank overall
    RANK() OVER (ORDER BY COALESCE(SUM(oi.qty * oi.unit_price), 0) DESC) 
        AS revenue_rank_overall,
    
    -- % of category revenue
    ROUND(
        COALESCE(SUM(oi.qty * oi.unit_price), 0) / 
        SUM(SUM(oi.qty * oi.unit_price)) OVER (PARTITION BY c.cat_id) * 100, 2
    ) AS pct_of_category_revenue,
    
    -- % of total company revenue
    ROUND(
        COALESCE(SUM(oi.qty * oi.unit_price), 0) / 
        (SELECT SUM(qty * unit_price) FROM order_items) * 100, 2
    ) AS pct_of_company_revenue

FROM products p
LEFT JOIN order_items oi ON p.prod_id = oi.prod_id
LEFT JOIN orders o ON oi.ord_id = o.ord_id
LEFT JOIN categories c ON p.cat_id = c.cat_id
WHERE p.is_active = TRUE
GROUP BY p.prod_id, p.prod_name, c.cat_name, p.brand, p.unit_price
ORDER BY total_revenue DESC;
```

---

## Pattern: Employee Performance Metrics

**HR Request:**
> "Create an employee performance view showing: hire seniority, salary positioning, and department contribution."

```sql
SELECT 
    e.emp_id,
    e.emp_name,
    d.dept_name,
    j.job_title,
    e.hire_date,
    e.salary,
    
    -- Seniority (days since hired)
    DATE('now') - DATE(e.hire_date) AS days_employed,
    
    -- Salary metrics
    ROUND(e.salary / AVG(e.salary) OVER (PARTITION BY d.dept_id) * 100, 2) 
        AS salary_vs_dept_avg_pct,
    
    RANK() OVER (PARTITION BY d.dept_id ORDER BY e.salary DESC) 
        AS salary_rank_in_dept,
    
    -- Company-wide salary percentile
    ROUND(
        (RANK() OVER (ORDER BY e.salary DESC) - 1) * 100.0 / 
        COUNT(*) OVER (), 2
    ) AS salary_percentile_company,
    
    -- Salary vs job title range
    ROUND(e.salary / j.max_salary * 100, 2) AS pct_of_job_max_salary,
    ROUND(e.salary / j.min_salary * 100, 2) AS pct_of_job_min_salary

FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN job_titles j ON e.job_id = j.job_id
ORDER BY d.dept_name, e.salary DESC;
```

---

## Key Takeaways: Dashboard Patterns

| Component | Window Functions Used |
|-----------|----------------------|
| **Comparisons** | LAG, LEAD |
| **Trends** | AVG OVER with ROWS |
| **Running totals** | SUM OVER with ORDER BY |
| **Rankings** | RANK, ROW_NUMBER |
| **Percentages** | Division by aggregated window |
| **Context** | FIRST_VALUE for baselines |

---

## Coming Up Next

Statistical window functions — calculating percentiles, cumulative distributions, and other statistical measures.
