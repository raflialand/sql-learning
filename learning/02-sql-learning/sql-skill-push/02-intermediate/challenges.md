# SQL Skill Push — Level 2: Intermediate

**Dataset:** `datasets/02-intermediate/ecommerce.db` (MySQL: `ecommerce.sql`)
**Business:** an online marketplace. See `datasets/02-intermediate/README.md`.

Topics covered: JOINs (INNER/LEFT/multi), GROUP BY + HAVING, date functions, subqueries, CTEs, CASE WHEN, conditional aggregation, window functions (ROW_NUMBER, running totals). Solutions are in `solutions/`.

---

### Q1 — Orders with customer details

**Request:** For each order, show the customer's full name and country.

**Expected columns:** `order_id, order_date, first_name, last_name, country, total_amount`

**Expected result:**
| order_id | order_date | first_name | last_name | country | total_amount |
| --- | --- | --- | --- | --- | --- |
| 1 | 2025-11-03 | Justin | Gonzalez | UK | 2066.07 |
| 2 | 2026-01-05 | Kimberly | Johnson | USA | 1747.60 |
| 3 | 2025-06-25 | William | White | USA | 4603.47 |
| 4 | 2025-04-28 | Brian | Lee | Germany | 486.02 |
| 5 | 2025-07-06 | Joshua | Carter | UK | 1713.18 |
| 6 | 2025-03-09 | Ashley | Harris | Australia | 4732.62 |

*(2,800 rows total; 6 shown — every order)*

---

### Q2 — Unpaid orders

**Request:** Which orders have NOT been paid yet? Show orders with no matching payment row.

**Expected columns:** `order_id, order_date, customer_id, total_amount`

**Expected result:**
| order_id | order_date | customer_id | total_amount |
| --- | --- | --- | --- |
| 1 | 2025-11-03 | CST0280 | 2066.07 |
| 2 | 2026-01-05 | CST0256 | 1747.60 |
| 10 | 2025-11-02 | CST0028 | 2472.35 |
| 16 | 2025-01-10 | CST0298 | 3938.71 |
| 17 | 2025-12-15 | CST0083 | 4130.95 |
| 21 | 2026-01-22 | CST0107 | 2781.00 |

*(517 rows total; 6 shown)*

**Hint:** `LEFT JOIN payments` then filter `WHERE p.payment_id IS NULL`.

---

### Q3 — Products per category

**Request:** How many products does each category contain? Include both parent and subcategories.

**Expected columns:** `cat_name, product_count`

**Expected result:**
| cat_name | product_count |
| --- | --- |
| Men's Clothing | 22 |
| Smartphones | 20 |
| Furniture | 18 |
| Kitchen Appliances | 14 |
| Laptops | 12 |
| Women's Clothing | 12 |

*(16 rows total; 6 shown)*

**Hint:** use `LEFT JOIN` so categories with zero products still appear.

---

### Q4 — Big-revenue categories

**Request:** Total revenue per category (from order items), for categories with more than $500k revenue.

**Expected columns:** `cat_name, total_revenue`

**Expected result:**
| cat_name | total_revenue |
| --- | --- |
| Men's Clothing | 1537283.89 |
| Furniture | 1254653.46 |
| Smartphones | 1117124.00 |
| Laptops | 1110956.08 |
| Fitness | 1003865.03 |
| Women's Clothing | 840410.69 |

*(8 rows total; 6 shown)*

**Hint:** 3-way JOIN (order_items → products → categories) + `HAVING SUM(...) > 500000`.

---

### Q5 — Above-average countries

**Request:** Average order value per country, for countries whose average exceeds the overall average order value.

**Expected columns:** `country, avg_order_value`

**Expected result:**
| country | avg_order_value |
| --- | --- |
| Australia | 3117.84 |
| USA | 3062.38 |
| Canada | 3024.82 |

*(3 rows)*

**Hint:** subquery in `HAVING`: `AVG(o.total_amount) > (SELECT AVG(total_amount) FROM orders)`.

---

### Q6 — Customers with big orders

**Request:** Which customers placed orders worth more than the overall average order value?

**Expected columns:** `cust_id, first_name, last_name`

**Expected result:**
| cust_id | first_name | last_name |
| --- | --- | --- |
| CST0002 | Eric | Roberts |
| CST0003 | Charles | Davis |
| CST0005 | Ashley | Roberts |
| CST0006 | Jennifer | Ramirez |
| CST0007 | Brian | Young |
| CST0008 | Sarah | Flores |

*(453 rows total; 6 shown)*

**Hint:** `WHERE o.total_amount > (SELECT AVG(total_amount) FROM orders)` + `DISTINCT`.

---

### Q7 — Discontinued products still sold

**Request:** Which inactive (discontinued) products were still ordered by customers?

**Expected columns:** `prod_id, prod_name, cat_name, unit_price`

**Expected result:**
| prod_id | prod_name | cat_name | unit_price |
| --- | --- | --- | --- |
| PRD010 | Product 10 Mini | Laptops | 706.77 |
| PRD022 | Product 22 Max | Furniture | 474.86 |
| PRD025 | Product 25 Max | Women's Clothing | 592.52 |
| PRD035 | Product 35 Lite | Furniture | 846.71 |
| PRD042 | Product 42 Pro | Men's Clothing | 1121.68 |
| PRD059 | Product 59 Mini | Smartphones | 471.83 |

*(9 rows total; 6 shown)*

**Hint:** `is_active = 0` plus `EXISTS` against `order_items`.

---

### Q8 — Monthly revenue with running total

**Request:** Total revenue and order count per month, with a running total of revenue over time.

**Expected columns:** `month, order_count, revenue, running_revenue`

**Expected result:**
| month | order_count | revenue | running_revenue |
| --- | --- | --- | --- |
| 2025-01 | 218 | 649161.07 | 649161.07 |
| 2025-02 | 186 | 570571.09 | 1219732.16 |
| 2025-03 | 229 | 711926.52 | 1931658.68 |
| 2025-04 | 197 | 595938.88 | 2527597.56 |
| 2025-05 | 192 | 568038.59 | 3095636.15 |
| 2025-06 | 221 | 664088.88 | 3759725.03 |

*(13 rows total; 6 shown)*

**Hint:** CTE to compute monthly aggregates, then `SUM(revenue) OVER (ORDER BY month)`.

---

### Q9 — Top 2 orders per customer

**Request:** Rank each order within its customer by amount (1 = largest). Show the top 2 orders per customer.

**Expected columns:** `customer_id, order_id, total_amount, rn`

**Expected result:**
| customer_id | order_id | total_amount | rn |
| --- | --- | --- | --- |
| CST0001 | 1751 | 2532.38 | 1 |
| CST0001 | 734 | 2084.65 | 2 |
| CST0002 | 124 | 3312.21 | 1 |
| CST0002 | 2246 | 2675.93 | 2 |
| CST0003 | 608 | 6673.47 | 1 |
| CST0003 | 1308 | 6090.29 | 2 |

*(990 rows total; 6 shown)*

**Hint:** `ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY total_amount DESC)` in a CTE, filter `rn <= 2`.

---

### Q10 — Price vs category average

**Request:** For each active product, show its price compared to the average price of its category.

**Expected columns:** `prod_id, prod_name, unit_price, cat_avg_price, diff_from_avg`

**Expected result:**
| prod_id | prod_name | unit_price | cat_avg_price | diff_from_avg |
| --- | --- | --- | --- | --- |
| PRD081 | Product 81 Max | 1048.10 | 489.76 | 558.34 |
| PRD004 | Product 4 Max | 1043.69 | 489.76 | 553.93 |
| PRD104 | Product 104 Pro | 983.77 | 489.76 | 494.01 |
| PRD070 | Product 70 Pro | 837.11 | 489.76 | 347.35 |
| PRD016 | Product 16 Pro | 784.00 | 489.76 | 294.24 |
| PRD065 | Product 65 Plus | 731.96 | 489.76 | 242.20 |

*(111 rows total; 6 shown)*

**Hint:** `AVG(...) OVER (PARTITION BY cat_id)`.

---

### Q11 — Revenue by order status

**Request:** Revenue breakdown by order status using conditional aggregation.

**Expected columns:** `completed_rev, shipped_rev, pending_rev, cancelled_rev`

**Expected result:**
| completed_rev | shipped_rev | pending_rev | cancelled_rev |
| --- | --- | --- | --- |
| 4084189.50 | 1463951.12 | 1476408.88 | 1365148.99 |

*(1 row)*

**Hint:** `SUM(CASE WHEN status = '...' THEN total_amount ELSE 0 END)` per status.

---

### Q12 — Order size labels

**Request:** Flag orders as "Large", "Medium", or "Small" based on their total amount.

**Expected columns:** `order_id, order_date, total_amount, order_size`

**Expected result:**
| order_id | order_date | total_amount | order_size |
| --- | --- | --- | --- |
| 1 | 2025-11-03 | 2066.07 | Medium |
| 2 | 2026-01-05 | 1747.60 | Medium |
| 3 | 2025-06-25 | 4603.47 | Large |
| 4 | 2025-04-28 | 486.02 | Small |
| 5 | 2025-07-06 | 1713.18 | Medium |
| 6 | 2025-03-09 | 4732.62 | Large |

*(2,800 rows total; 6 shown)*

**Hint:** `CASE WHEN total_amount >= 4000 THEN 'Large' WHEN >= 1500 THEN 'Medium' ELSE 'Small'`.

---

### Q13 — Order-size buckets

**Request:** How many orders fall into each order-size bucket?

**Expected columns:** `order_size, order_count, total_revenue`

**Expected result:**
| order_size | order_count | total_revenue |
| --- | --- | --- |
| Medium | 1337 | 3651768.83 |
| Large | 756 | 4139038.41 |
| Small | 707 | 598891.25 |

*(3 rows)*

**Hint:** `GROUP BY` the same `CASE` expression (or by its alias in MySQL).

---

### Q14 — Vendors with priciest products

**Request:** Which vendors have the highest average product price? Show the top 5.

**Expected columns:** `vendor_name, avg_price, product_count`

**Expected result:**
| vendor_name | avg_price | product_count |
| --- | --- | --- |
| Sunrise Trading | 820.42 | 3 |
| Cedar & Co | 754.54 | 7 |
| Harbor Trade | 727.26 | 9 |
| Global Goods | 710.81 | 6 |
| Vista Market | 655.63 | 5 |

*(5 rows)*

---

### Q15 — Power customers (CTE + HAVING)

**Request:** Which customers have made more than 3 orders? Show their total spend too.

**Expected columns:** `customer_id, first_name, last_name, order_count, total_spent`

**Expected result:**
| customer_id | first_name | last_name | order_count | total_spent |
| --- | --- | --- | --- | --- |
| CST0147 | Sarah | Mitchell | 14 | 34708.49 |
| CST0122 | Rachel | Perez | 13 | 40091.04 |
| CST0385 | Brian | Sanchez | 13 | 59557.23 |
| CST0098 | Robert | Gonzalez | 12 | 34771.25 |
| CST0257 | Edward | Brown | 12 | 28941.60 |
| CST0296 | Joshua | Davis | 12 | 45291.04 |

*(400 rows total; 6 shown)*

---

### Q16 — Above their own average

**Request:** Find orders whose total is greater than the average total of their own customer's orders.

**Expected columns:** `order_id, customer_id, total_amount, customer_avg`

**Expected result:**
| order_id | customer_id | total_amount | customer_avg |
| --- | --- | --- | --- |
| 734 | CST0001 | 2084.65 | 1737.50 |
| 1751 | CST0001 | 2532.38 | 1737.50 |
| 124 | CST0002 | 3312.21 | 2994.07 |
| 345 | CST0003 | 4990.93 | 3236.89 |
| 608 | CST0003 | 6673.47 | 3236.89 |
| 1024 | CST0003 | 4253.93 | 3236.89 |

*(1,289 rows total; 6 shown)*

**Hint:** **correlated subquery** — the inner query references the outer order's `customer_id`.

---

### Q17 — 2025 monthly orders

**Request:** Count orders and sum revenue per month for 2025.

**Expected columns:** `month, order_count, revenue`

**Expected result:**
| month | order_count | revenue |
| --- | --- | --- |
| 2025-01 | 218 | 649161.07 |
| 2025-02 | 186 | 570571.09 |
| 2025-03 | 229 | 711926.52 |
| 2025-04 | 197 | 595938.88 |
| 2025-05 | 192 | 568038.59 |
| 2025-06 | 221 | 664088.88 |

*(12 rows total; 6 shown)*

---

### Q18 — Late or missing deliveries

**Request:** Which shipments were delivered late (delivery more than 7 days after order) or not yet delivered?

**Expected columns:** `shipment_id, order_id, carrier, ship_date, delivery_date, order_date, delivery_status`

**Expected result:**
| shipment_id | order_id | carrier | ship_date | delivery_date | order_date | delivery_status |
| --- | --- | --- | --- | --- | --- | --- |
| 7 | 10 | DHL | 2025-11-26 | NULL | 2025-11-02 | In transit |
| 12 | 18 | UPS | 2025-12-01 | NULL | 2025-11-24 | In transit |
| 17 | 25 | FedEx | 2025-01-14 | NULL | 2025-01-04 | In transit |
| 43 | 62 | FedEx | 2025-03-01 | NULL | 2025-02-27 | In transit |
| 55 | 79 | DHL | 2025-07-08 | NULL | 2025-06-27 | In transit |
| 58 | 82 | FedEx | 2025-01-05 | NULL | 2025-01-01 | In transit |

*(1,787 rows total; 6 shown)*

**Hint:** `CASE` with `delivery_date IS NULL` → 'In transit'; else compare day difference with `julianday()` (SQLite) / `DATEDIFF()` (MySQL).

---

### Q19 — Above category average sale price

**Request:** Which active products sell above their category's average sale price?

**Expected columns:** `prod_id, prod_name, avg_sale_price, category_avg_sale`

**Expected result:**
| prod_id | prod_name | avg_sale_price | category_avg_sale |
| --- | --- | --- | --- |
| PRD081 | Product 81 Max | 1048.10 | 489.76 |
| PRD004 | Product 4 Max | 1043.69 | 489.76 |
| PRD104 | Product 104 Pro | 983.77 | 489.76 |
| PRD070 | Product 70 Pro | 837.11 | 489.76 |
| PRD016 | Product 16 Pro | 784.00 | 489.76 |
| PRD065 | Product 65 Plus | 731.96 | 489.76 |

*(55 rows total; 6 shown)*

**Hint:** two CTEs — per-product average sale price, then per-category average of those; join and filter.

---

### Q20 — Payment method success rates

**Request:** Compare payment methods by success rate (paid vs failed vs refunded).

**Expected columns:** `method, total_payments, paid_pct, failed_pct, refunded_pct`

**Expected result:**
| method | total_payments | paid_pct | failed_pct | refunded_pct |
| --- | --- | --- | --- | --- |
| PayPal | 478 | 60.04 | 18.41 | 21.55 |
| COD | 486 | 58.85 | 20.99 | 20.16 |
| Bank Transfer | 408 | 58.82 | 20.59 | 20.59 |
| Card | 911 | 58.73 | 22.83 | 18.44 |

*(4 rows)*

**Hint:** conditional `SUM(CASE WHEN status='Paid' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)`.

---

## How to verify

```bash
sqlite3 datasets/02-intermediate/ecommerce.db < solutions/solution_XX.sql
# or use the helper:
python ../../_tools/run_query.py datasets/02-intermediate/ecommerce.db solutions/solution_XX.sql
```
