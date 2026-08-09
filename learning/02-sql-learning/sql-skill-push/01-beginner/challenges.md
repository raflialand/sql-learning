# SQL Skill Push — Level 1: Beginner

**Dataset:** `datasets/01-beginner/retail.db` (MySQL: `retail.sql`)
**Business:** Brew & Co., a 3-branch coffee shop chain (stores BRW001/002/003). See `datasets/01-beginner/README.md`.

Each challenge asks a business question and shows the **expected result**. Write your own query, run it, and compare against the expected result (first rows + total row count). Solutions are in `solutions/`.

---

### Q1 — Active menu prices

**Request:** Which products are currently active? Show them from cheapest to most expensive.

**Expected columns:** `prod_id, prod_name, category, unit_price`

**Expected result:**
| prod_id | prod_name | category | unit_price |
| --- | --- | --- | --- |
| PRD015 | Chocolate Chip Cookie | Food | 2.50 |
| PRD013 | Everything Bagel | Food | 2.75 |
| PRD001 | Espresso | Beverage | 2.95 |
| PRD006 | Americano | Beverage | 3.25 |
| PRD012 | Blueberry Muffin | Food | 3.25 |
| PRD010 | Iced Tea | Beverage | 3.45 |
| PRD011 | Croissant | Food | 3.50 |
| PRD009 | Hot Chocolate | Beverage | 3.95 |
| PRD029 | Cold Brew Bottle | Merchandise | 4.00 |
| PRD002 | Latte | Beverage | 4.25 |

*(29 rows total; 10 shown)*

**Hint:** `is_active = 1`, sort by price ascending.

---

### Q2 — Distinct menu categories

**Request:** What are the distinct product categories in the menu?

**Expected columns:** `category`

**Expected result:**
| category |
| --- |
| Beverage |
| Food |
| Merchandise |

*(3 rows)*

---

### Q3 — New customers in 2025

**Request:** Which customers signed up in 2025? List their name, city and signup date.

**Expected columns:** `cust_id, first_name, last_name, city, signup_date`

**Expected result:**
| cust_id | first_name | last_name | city | signup_date |
| --- | --- | --- | --- | --- |
| CST128 | Mark | Johnson | Phoenix | 2025-01-02 |
| CST111 | Deborah | Martin | San Jose | 2025-01-08 |
| CST246 | Megan | Rivera | Portland | 2025-01-15 |
| CST163 | Jennifer | Gonzalez | Dallas | 2025-01-21 |
| CST170 | Kimberly | Scott | Nashville | 2025-01-22 |
| CST344 | Michael | Johnson | Philadelphia | 2025-01-22 |
| CST019 | Deborah | Lopez | San Antonio | 2025-01-25 |
| CST116 | Joshua | Miller | San Jose | 2025-01-25 |
| CST222 | Ashley | Rodriguez | Chicago | 2025-01-25 |
| CST021 | George | Jones | Nashville | 2025-02-01 |

*(83 rows total; 10 shown)*

**Hint:** use `BETWEEN '2025-01-01' AND '2025-12-31'` on `signup_date`.

---

### Q4 — Orders at the Manhattan store

**Request:** How many orders were placed at store BRW001 (Manhattan)?

**Expected columns:** `store_id, order_count`

**Expected result:**
| store_id | order_count |
| --- | --- |
| BRW001 | 407 |

*(1 row)*

---

### Q5 — Large card payments

**Request:** Which orders were paid by Card AND totaled more than $50?

**Expected columns:** `order_id, order_date, store_id, payment_method, total_amount`

**Expected result:**
| order_id | order_date | store_id | payment_method | total_amount |
| --- | --- | --- | --- | --- |
| 132 | 2025-09-18 | BRW002 | Card | 283.50 |
| 1011 | 2025-11-10 | BRW001 | Card | 215.75 |
| 229 | 2025-11-12 | BRW002 | Card | 213.00 |
| 276 | 2026-01-03 | BRW002 | Card | 212.90 |
| 1058 | 2025-11-01 | BRW003 | Card | 210.35 |

*(291 rows total; 5 shown)*

**Hint:** combine two conditions with `AND`.

---

### Q6 — Mid-price products

**Request:** Which products are priced between $3 and $6?

**Expected columns:** `prod_id, prod_name, category, unit_price`

**Expected result:**
| prod_id | prod_name | category | unit_price |
| --- | --- | --- | --- |
| PRD006 | Americano | Beverage | 3.25 |
| PRD012 | Blueberry Muffin | Food | 3.25 |
| PRD010 | Iced Tea | Beverage | 3.45 |
| PRD011 | Croissant | Food | 3.50 |
| PRD009 | Hot Chocolate | Beverage | 3.95 |
| PRD029 | Cold Brew Bottle | Merchandise | 4.00 |
| PRD002 | Latte | Beverage | 4.25 |
| PRD003 | Cappuccino | Beverage | 4.25 |
| PRD005 | Cold Brew | Beverage | 4.50 |
| PRD004 | Mocha | Beverage | 4.75 |

*(15 rows total; 10 shown)*

**Hint:** `BETWEEN 3 AND 6` is inclusive on both ends.

---

### Q7 — Coffee products

**Request:** Which products have "Coffee" anywhere in their name?

**Expected columns:** `prod_id, prod_name, category, unit_price`

**Expected result:**
| prod_id | prod_name | category | unit_price |
| --- | --- | --- | --- |
| PRD021 | Coffee Beans 250g | Merchandise | 14.00 |

*(1 row)*

**Hint:** `LIKE '%Coffee%'`.

---

### Q8 — Orders with no payment method

**Request:** Which orders do NOT have a recorded payment method?

**Expected columns:** `order_id, order_date, store_id, total_amount`

**Expected result:**
| order_id | order_date | store_id | total_amount |
| --- | --- | --- | --- |
| 20 | 2025-08-12 | BRW002 | 36.95 |
| 29 | 2025-07-18 | BRW001 | 56.75 |
| 60 | 2025-08-17 | BRW003 | 16.50 |
| 63 | 2025-12-02 | BRW002 | 98.00 |
| 136 | 2025-06-28 | BRW001 | 109.40 |
| 158 | 2025-12-25 | BRW001 | 25.00 |
| 159 | 2025-08-21 | BRW001 | 14.65 |
| 160 | 2025-09-12 | BRW001 | 6.90 |
| 207 | 2025-06-07 | BRW002 | 28.65 |
| 224 | 2025-08-11 | BRW001 | 3.50 |

*(37 rows total; 10 shown)*

**Hint:** NULL is compared with `IS NULL`, never `= NULL`.

---

### Q9 — Top 5 most expensive products

**Request:** What are the 5 most expensive products on the menu?

**Expected columns:** `prod_id, prod_name, category, unit_price`

**Expected result:**
| prod_id | prod_name | category | unit_price |
| --- | --- | --- | --- |
| PRD025 | French Press | Merchandise | 35.00 |
| PRD024 | Pour-Over Kit | Merchandise | 29.00 |
| PRD028 | Gift Card | Merchandise | 25.00 |
| PRD023 | Tumbler | Merchandise | 22.00 |
| PRD027 | Travel Cup | Merchandise | 18.50 |

*(5 rows)*

**Hint:** `ORDER BY ... DESC LIMIT 5`.

---

### Q10 — Top 5 largest orders

**Request:** What are the 5 largest orders, and what store did each come from?

**Expected columns:** `order_id, order_date, store_id, total_amount`

**Expected result:**
| order_id | order_date | store_id | total_amount |
| --- | --- | --- | --- |
| 132 | 2025-09-18 | BRW002 | 283.50 |
| 172 | 2026-01-27 | BRW002 | 253.50 |
| 1011 | 2025-11-10 | BRW001 | 215.75 |
| 229 | 2025-11-12 | BRW002 | 213.00 |
| 276 | 2026-01-03 | BRW002 | 212.90 |

*(5 rows)*

---

### Q11 — Order count per store

**Request:** How many orders were placed at each store?

**Expected columns:** `store_id, order_count`

**Expected result:**
| store_id | order_count |
| --- | --- |
| BRW003 | 409 |
| BRW001 | 407 |
| BRW002 | 384 |

*(3 rows)*

---

### Q12 — Revenue per store

**Request:** What is the total revenue per store?

**Expected columns:** `store_id, total_revenue`

**Expected result:**
| store_id | total_revenue |
| --- | --- |
| BRW001 | 24189.20 |
| BRW003 | 24081.65 |
| BRW002 | 21963.25 |

*(3 rows)*

**Hint:** `SUM(total_amount)`, round to 2 decimals.

---

### Q13 — Average order value per store

**Request:** What is the average order value at each store?

**Expected columns:** `store_id, avg_order_value`

**Expected result:**
| store_id | avg_order_value |
| --- | --- |
| BRW001 | 59.43 |
| BRW003 | 58.88 |
| BRW002 | 57.20 |

*(3 rows)*

---

### Q14 — Revenue by category

**Request:** Which product categories bring in the most revenue? (revenue = qty × unit_price)

**Expected columns:** `category, total_revenue`

**Expected result:**
| category | total_revenue |
| --- | --- |
| Merchandise | 42145.00 |
| Beverage | 14747.60 |
| Food | 13341.50 |

*(3 rows)*

**Hint:** join `order_items` to `products`, aggregate `SUM(quantity * unit_price)`.

---

### Q15 — Payment method usage

**Request:** How many times was each payment method used?

**Expected columns:** `payment_method, usage_count`

**Expected result:**
| payment_method | usage_count |
| --- | --- |
| Card | 562 |
| Cash | 398 |
| Mobile Pay | 203 |
| NULL | 37 |

*(4 rows)*

**Note:** NULL appears because some orders have no payment method. `COUNT(*)` counts all rows including NULLs.

---

### Q16 — Most loyal customers

**Request:** Which customer has placed the most orders? Show the top 5 customers by order count.

**Expected columns:** `cust_id, first_name, last_name, order_count`

**Expected result:**
| cust_id | first_name | last_name | order_count |
| --- | --- | --- | --- |
| CST108 | Megan | Mitchell | 9 |
| CST125 | Michelle | Rodriguez | 9 |
| CST152 | Elizabeth | Lee | 9 |
| CST252 | Ashley | Torres | 9 |
| CST054 | George | Martinez | 8 |

*(5 rows)*

---

### Q17 — High-spending customers

**Request:** Which customers have spent more than $100 in total, and how much? Show the top 10.

**Expected columns:** `cust_id, first_name, last_name, total_spent`

**Expected result:**
| cust_id | first_name | last_name | total_spent |
| --- | --- | --- | --- |
| CST252 | Ashley | Torres | 860.15 |
| CST255 | David | Ramirez | 677.25 |
| CST008 | Cynthia | Flores | 618.35 |
| CST125 | Michelle | Rodriguez | 575.15 |
| CST100 | Kevin | Jones | 560.70 |

*(10 rows total; 5 shown)*

**Hint:** filter aggregated values with `HAVING SUM(total_amount) > 100`.

---

### Q18 — Monthly order volume (2025)

**Request:** How many orders were placed in each month of 2025?

**Expected columns:** `month, order_count`

**Expected result:**
| month | order_count |
| --- | --- |
| 2025-01 | 71 |
| 2025-02 | 86 |
| 2025-03 | 98 |
| 2025-04 | 98 |
| 2025-05 | 80 |
| 2025-06 | 98 |
| 2025-07 | 96 |
| 2025-08 | 108 |
| 2025-09 | 94 |
| 2025-10 | 81 |

*(12 rows total; 10 shown)*

**Hint:** extract `YYYY-MM` with `strftime('%Y-%m', order_date)` (SQLite) / `DATE_FORMAT(order_date, '%Y-%m')` (MySQL).

---

### Q19 — Best months by average order value

**Request:** What is the average order value per month, and which month had the highest?

**Expected columns:** `month, avg_order_value`

**Expected result:**
| month | avg_order_value |
| --- | --- |
| 2025-11 | 65.22 |
| 2026-01 | 65.10 |
| 2025-05 | 61.23 |
| 2025-04 | 60.31 |
| 2025-08 | 58.89 |

*(13 rows total; 5 shown)*

---

### Q20 — Customers who never ordered

**Request:** Which customers have NEVER placed an order?

**Expected columns:** `cust_id, first_name, last_name, email`

**Expected result:**
| cust_id | first_name | last_name | email |
| --- | --- | --- | --- |
| CST027 | Michael | Perez | michael.perez245@mail.com |
| CST090 | James | King | james.king447@mail.com |
| CST103 | Jessica | Robinson | jessica.robinson387@mail.com |
| CST105 | Angela | Allen | angela.allen293@mail.com |
| CST112 | Jennifer | Thompson | jennifer.thompson19@mail.com |

*(18 rows total; 5 shown)*

**Hint:** `LEFT JOIN orders` then keep rows where `o.order_id IS NULL`.

---

## How to verify

```bash
sqlite3 datasets/01-beginner/retail.db < solutions/solution_XX.sql
# or use the helper:
python ../../_tools/run_query.py datasets/01-beginner/retail.db solutions/solution_XX.sql
```
