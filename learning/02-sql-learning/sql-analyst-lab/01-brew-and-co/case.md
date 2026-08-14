# Case 01 — Brew & Co. Coffee Shop

**Module:** SQL Analyst Lab · **Dataset:** `sql-skill-push/datasets/01-beginner/retail.db` (read-only, reused)
**Dataset README + ERD:** `sql-skill-push/datasets/01-beginner/README.md` — read this first: business context (3-store coffee chain, loyalty program), tables (`products`, `customers`, `orders`, `order_items`), join hints, and data quirks (37 orders with NULL payment method, 18 customers with no orders, `total_amount` always equals line-item sum).

## Main question

> **How is sales performance, and where should we focus next month?**

This is the kind of open-ended question a store owner asks. "Sales performance" is not a single number — before writing any SQL, narrow the scope.

## How to work this case

1. Draft your own `01-scope.md` (metrics + dimensions) and `02-questions.md` (bucket mapping) in `work/` **before** looking at the model answer.
2. Write your queries in `work/`, run them against `retail.db`, and compare with `expected/03-results.md`.
3. Check the model scope/questions/queries/insight in `expected/` only after your own attempt.

## Scaffolding

This case has the **highest scaffolding** in the lab: the metrics, dimensions, and bucket mapping are suggested for you (see `expected/01-scope.md` and `expected/02-questions.md`). Later cases leave progressively more to you.
