# Case 03 — NovaTel Telecom

**Module:** SQL Analyst Lab · **Dataset:** `sql-skill-push/datasets/03-advanced/telecom.db` (read-only, reused)
**Dataset README + ERD:** `sql-skill-push/datasets/03-advanced/README.md` — read this first: business context (mobile carrier with 6 plans, 4,500 subscribers), tables (`plans`/`subscribers`/`billing`/`payments`/`usage_logs`/`tickets`/`churn`), join hints, and data quirks (billing statuses Paid/Unpaid/Overdue, 216 billed-but-never-paid subscribers, churn reasons).

## Main question

> **Is the subscriber base healthy, and where is revenue leaking?**

This is a subscription-health question: it mixes growth/retention (subscriber base health) with collections (revenue leaking). Both matter — and the answer requires digging beyond headline counts.

## How to work this case

1. Draft your own `01-scope.md` and `02-questions.md` in `work/` first. This is the **minimal scaffolding** case: you derive the metrics (e.g. revenue, active subscribers, avg data usage) and dimensions (e.g. plan, state/region, month, usage tier) yourself — only suggested after your attempt in `expected/`.
2. Write your queries in `work/`, run them against `telecom.db`, and compare with `expected/03-results.md`.
3. Check the model answer in `expected/` only after your own attempt.

## Dataset limitation — READ BEFORE QUERYING

**Billing spans ONLY two months: `bill_date 2025-12-01` and `2026-01-01`. There is NO YoY comparison possible — only MoM (Dec-2025 → Jan-2026).** Do not write or claim any YoY comparison in this case; the honest limitation statement is part of the exercise. Usage logs span 2025-12 to 2026-01 (2 months), so the same MoM-only constraint applies.

## Scaffolding

Minimal: unlike Cases 01–02, metrics and dimensions are not handed to you. Derive them from the business question and the dataset README, then map them to the 4 buckets yourself.
