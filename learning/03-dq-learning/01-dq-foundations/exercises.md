# Exercises: Unit 01 — DQ Foundations

*No SQL needed here — these check your conceptual understanding.*

---

## Part A: Knowledge Check

### Exercise 1.1 — Define it

Write one-sentence definitions for:
1. Data quality
2. Fit for purpose
3. A "source of truth"

---

### Exercise 1.2 — Name the dimension

For each defect, write **which of the 6 dimensions** is primarily violated (completeness, uniqueness, validity, accuracy, consistency, timeliness):

| Defect | Dimension |
|--------|-----------|
| A customer has no email address | |
| The same SKU appears in `products` twice | |
| `status = 'shippd'` (typo) | |
| `qty * unit_price` is 30 but `total_price` says 40 | |
| Customer state is `'CA'` in `customers` but `'California'` in `addresses` | |
| An order is dated next month | |

---

### Exercise 1.3 — Multiple dimensions

A single record can violate more than one dimension. For this order row:

```
order_id=15, customer_id=14, ship_city=NULL, status='shipped', total_amount=0.00
```

- Which dimensions are violated, and how?
- *Hint:* look at what customer 14 looks like in the dataset.

---

### Exercise 1.4 — Roles

Match the person to the job:

| Person | Job |
|--------|-----|
| Data Quality Engineer | a) Decides what "good" means for Customer data |
| Data Steward | b) Builds and runs the automated checks |
| Data Owner | c) Investigates detected issues and quantifies impact |
| Data Quality Analyst | d) Senior person accountable, approves rules and fixes |

---

### Exercise 1.5 — The lifecycle

Put the 5 lifecycle steps in the correct order and, for each, name which unit of this module covers it:

1. Measure / Monitor / Define / Profile / Remediate

---

### Exercise 1.6 — Cost translation

A daily report consumed by the CFO uses `orders.total_amount`. About 5% of orders have a NULL total.

1. In plain English, why does this matter *to the CFO*?
2. Which of the five cost categories does it hit first?
3. Write the pitch you would give to get this fixed (2-3 sentences using the template from Lesson 1.4).

---

## Part B: Light SQL (optional, if you already have MySQL loaded)

### Exercise 1.7 — First touch

Run these and note what you see:

```sql
SELECT COUNT(*) AS total_customers FROM customers;

SELECT COUNT(*) AS customers_without_email
FROM customers
WHERE email IS NULL;

SELECT status, COUNT(*) AS cnt
FROM orders
GROUP BY status;
```

For each result, say which dimension (if any) it hints at.

---

### Exercise 1.8 — Translate

What does this query do, in plain English?

```sql
SELECT product_id, sku, COUNT(*) AS cnt
FROM products
GROUP BY sku
HAVING COUNT(*) > 1;
```

---

## Self-Assessment Checkpoint

- [ ] I can define data quality as "fit for purpose"
- [ ] I can name all 6 dimensions and give a defect example for each
- [ ] I know the 5-step DQ lifecycle in order
- [ ] I can map a defect to money using the five cost categories
- [ ] I can say what the DQ engineer's role is (builder of automated checks)

**Ready to continue?** Move to **Unit 02 — Business Context**.
