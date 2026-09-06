# Stage 0 — Context

**Case**: 00-bookstore-omnichannel-sales-performance
**Dataset**: `data/02-bookstore/` (SQLite: `bookstore.db`)
**Date**: 2026-09-03

---

## 1. Business Context

**PageTurner Books** is a mid-size bookstore chain operating **8 physical retail locations** plus an **online storefront**. Over **2 years** (September 2024 – August 2026), the company has accumulated transactional data across orders, inventory, customers, reviews, and promotional campaigns.

Senior leadership has called an urgent strategy review. The company is growing top-line revenue but margins are under pressure from rising shipping costs, inventory carrying costs, and a declining repeat-purchase rate among certain customer segments. The leadership team needs a **data-driven diagnostic**.

### Key Stakeholders

| Stakeholder | Interest |
|-------------|----------|
| VP of Retail Operations | Store-level performance, staffing efficiency, inventory turns |
| VP of E-Commerce | Online conversion, shipping cost management, digital marketing ROI |
| Head of Marketing | Promotion effectiveness, customer acquisition vs retention, segment health |
| CFO | Margin analysis, revenue decomposition, cost optimization |
| Inventory Manager | Stock-out frequency, reorder optimization, slow-mover identification |

---

## 2. Main Business Question

> **"How is PageTurner Books performing across its omnichannel operations, and which levers — store locations, customer segments, product categories, or promotional strategies — should leadership prioritize to improve profitability and customer loyalty over the next 12 months?"**

---

## 3. Dataset Summary

| Table | Rows | Key Columns |
|-------|------|-------------|
| `publishers` | 25 | id, name, country, founded_year |
| `authors` | 120 | id, first_name, last_name, nationality |
| `categories` | 30 | id, name, parent_category_id (hierarchical) |
| `books` | 500 | id, isbn13, title, price, list_price, publisher_id, category_id |
| `book_authors` | 743 | book_id, author_id, author_order |
| `customers` | 1200 | id, first_name, last_name, city, state, customer_segment, loyalty_card_number |
| `stores` | 8 | id, name, city, state, store_type, square_footage |
| `inventory` | 2293 | book_id, store_id, quantity, reorder_point |
| `orders` | 6500 | id, order_number, customer_id, store_id, order_date, order_status, total_amount |
| `order_items` | 14949 | order_id, book_id, quantity, unit_price, discount, line_total |
| `payments` | 6175 | order_id, payment_method, amount, status |
| `shipping` | 5200 | order_id, carrier, shipping_cost, status |
| `reviews` | 2500 | book_id, customer_id, rating, review_date |
| `promotions` | 40 | code, name, discount_type, discount_value, start_date, end_date |
| `employees` | 65 | id, employee_id, role, store_id |

**Total**: ~60,000+ rows across 15 tables.

---

## 4. Dataset Limitations (Hard Constraints)

| # | Limitation | Detail | Impact on Analysis |
|---|------------|--------|--------------------|
| L1 | **Date range** | Sep 2024 – Aug 2026 (24 months) | YoY comparisons are possible for the overlapping 12 months (Sep 2024–Aug 2025 vs Sep 2025–Aug 2026). Full 2-year trend analysis is supported. **NOT blocked.** |
| L2 | **Data quality issues** | ~5-10% NULLs, case inconsistency, whitespace, wrong data types, date format variation | Data cleaning (Stage 3: Bronze→Silver) must precede analysis. |
| L3 | **No cost/margin data** | `books` has `price` and `list_price` but no COGS | True margin analysis is impossible. Use `list_price - price` as a proxy for publisher discount only. **No true margin claims.** |
| L4 | **No online/offline channel flag** | `orders.store_id` is nullable but no explicit `channel` column | Online orders = `store_id IS NULL`. Channel inference required; must state assumption explicitly. |
| L5 | **Promotions not linked to orders** | `promotions` table has `code` but `orders` has no `promo_code` FK | Promotion effectiveness can only be inferred from `order_items.discount > 0` or timing overlaps — **not directly joined**. |
| L6 | **Shipping cost variability** | `shipping.shipping_cost` exists but no order-level fulfillment channel flag | Shipping cost analysis requires careful interpretation. |

---

## 5. Derived Constraints for Downstream Stages

Based on the limitations above, the following constraints are carried forward:

1. **No true margin metric** — Any "margin" discussion must be framed as "proxy margin" or "discount spread" (`list_price - price`), with explicit caveat.
2. **Channel is inferred** — All channel-based analysis (online vs in-store) must note the `store_id IS NULL` inference and treat it as directional.
3. **Promotions are indirect** — Any promotional ROI analysis is inferential, not causal. Frame as "discount-associated lift" rather than "promotional effectiveness."
4. **YoY is allowed** — The 24-month range supports Sep 2024–Aug 2025 vs Sep 2025–Aug 2026 comparisons.
5. **No fabricated data** — If a required metric cannot be computed from available columns, flag it as "data gap" rather than imputing.

---

## 6. ERD Summary (for join planning)

```
customers ──< orders >── stores
                │
                ├──< order_items >── books >── publishers
                │                       │
                │                       └── categories
                ├──< payments
                └──< shipping

books ──< reviews >── customers
books ──< inventory >── stores
books ──< book_authors >── authors

promotions (standalone — no FK to orders)
employees >── stores
```

### Critical Join Notes
- `orders.store_id` → `stores.id` (NULL = online)
- `orders.customer_id` → `customers.id`
- `order_items.order_id` → `orders.id`
- `order_items.book_id` → `books.id`
- `books.category_id` → `categories.id`
- `inventory(book_id, store_id)` — composite key to books and stores
- `promotions` has **no FK** to orders — must use discount patterns for inference

---

## 7. Database Setup (PostgreSQL)

**Status**: Fixed and verified (2026-09-06)

The original `bookstore.sql` had dirty data (`'n/a'`, `'NA'`, `'NULL'`, `'999'`, `'-'`, `'undefined'`, `'MISSING'`, `'missing'`, `'null'`, `'--'`, `'0'`, `'TBD'`) in columns typed as `INTEGER`/`NUMERIC`/`TIMESTAMP`/`DATE`/`BOOLEAN`, causing PostgreSQL to reject the INSERT statements.

**Fix applied**: Created `data/02-bookstore/bookstore-postgres.sql` with dirty-data columns changed to `TEXT`. Row counts verified against SQLite `bookstore.db` — all 15 tables match exactly (40,348 total rows).

**PostgreSQL connection**: `psql.exe` available at `C:\Program Files\PostgreSQL\18\bin\`. Load with:
```powershell
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d your_database -f "F:\#MY DATA\AI & DATA\.LESSONS\sql-learning\data\02-bookstore\bookstore-postgres.sql"
```

---

## 8. Pipeline Progress

| Stage | Status | Artifact |
|-------|--------|----------|
| 0 — Context | ✅ Complete | `00-context.md` |
| 1 — Scope | ✅ Complete | `01-scope.md` |
| 2 — Questions | ✅ Complete (PASS-WITH-NOTES) | `02-questions.md` |
| 3 — Silver | ✅ Complete (PASS-WITH-NOTES) | `_silver.sql` |
| 4 — Gold | ⏳ Ready | — |
| 5 — Queries | ⏸ Pending | — |
| 6 — Insight | ⏸ Pending | — |

### Database Setup for Silver
The `_silver.sql` reads from `bronze.*` schema. Before running:
1. Load `bookstore-postgres.sql` into `bronze` schema (or `public` and adjust)
2. Or load into `raw` schema (already done) and adjust silver SQL to read from `raw`
3. Then run `_silver.sql` to create `silver.*` tables
