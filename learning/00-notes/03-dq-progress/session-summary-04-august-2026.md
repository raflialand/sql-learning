# Summary: Data Quality Learning Session

**Date:** 04 August 2026
**Track:** Data Quality Engineer module (`learning/03-dq-learning/`)
**Status:** Unit 01 (DQ Foundations) IN PROGRESS

---

## Session 1: Unit 01 — Lesson 1.2 Six DQ Dimensions

### Covered
- Read `01-dq-foundations/02-six-dq-dimensions.md` (Lesson 1.2).
- Deep-dived the thesis: *"Six dimensions give every data quality problem a precise name. When you name a problem correctly, you know exactly what kind of SQL check to write."*
  - Naming replaces vague labels ("data is bad") with a fixed 6-word vocabulary.
  - Each dimension maps 1-to-1 to a distinct SQL check pattern.

### The Six Dimensions

| # | Dimension | Defect named | SQL check pattern |
|---|-----------|--------------|-------------------|
| 1 | **Completeness** | missing | `IS NULL`, `= ''` |
| 2 | **Uniqueness** | duplicated | `GROUP BY ... HAVING COUNT(*) > 1` |
| 3 | **Validity** | malformed / out of domain | `REGEXP`, `BETWEEN`, `IN` |
| 4 | **Accuracy** | contradicts reality | recompute / compare to master (`qty*unit_price <> total_price`) |
| 5 | **Consistency** | disagrees across rows/tables | `LEFT JOIN ... IS NULL`, cross-table diff |
| 6 | **Timeliness** | too late / too early / stale | date comparisons, `DATEDIFF` |

### Key Understandings
1. A value can pass completeness + uniqueness + validity and still be wrong (accuracy / consistency) — the dimensions are a pipeline of escalating certainty.
2. A single record can violate multiple dimensions at once (NULL email = completeness; invalid email = validity).
3. The dimension name *is* the hint for the query structure: missing-field problems are never solved with `GROUP BY`; duplication problems are never solved with `REGEXP`.

### Status Notes
- No exercises or quiz completed yet — Unit 01 conceptual foundation still in progress.

---

## Next Steps

1. **Lesson 1.3:** `01-dq-foundations/03-dq-roles-and-frameworks.md` — roles and frameworks in the DQ world.
2. **Lesson 1.4:** `01-dq-foundations/04-cost-of-poor-data-quality.md`.
3. **Unit 01 exercises:** `01-dq-foundations/exercises.md` + self-assessment checkpoint.
4. Then Unit 02 (Business Context).

---

*Ready to continue learning!*

---

## Session 2: Lesson 1.2 Deep-Dive — REGEXP & the Validity Dimension

### Covered
- Deep-dive on the Validity check (line 57 of `02-six-dq-dimensions.md`): the `REGEXP` operator.
- Q&A: what it is, its purpose, when it's used, and how to build the pattern.

### REGEXP Fundamentals
- **What it is:** a SQL operator that tests whether a string matches a pattern. Dialect differs: MySQL `REGEXP` (case-insensitive by default), PostgreSQL `~` (PCRE), SQL Server has no native regex (`LIKE` instead).
- **Purpose:** format/domain checks — exactly the Validity dimension. It judges *shape*, never truth (truth = Accuracy).
- **When used:** email/phone/ZIP/ID format validation, flagging typos (`'shippd'` vs `'shipped'`), data profiling.

### Decoding the email pattern
```
'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
```
- `^` / `$` — anchors: match the whole value, not a substring.
- `[...]` — character class: matches any ONE of the listed chars.
- `+` — quantifier: 1 or more. `{2,}` — at least 2.
- `\.` — escaped literal dot (`.` alone means "any character").
- Meaning: `local@domain.tld` shape. `NOT REGEXP` = flag rows that don't conform.

### Key Understandings
1. **LIKE vs REGEXP:** `LIKE '%@%.%'` accepts garbage (`@@.`, `@..`); `REGEXP` enforces the full format rule → this is what "Validity = format/domain" actually means in SQL.
2. **The pattern IS the business rule.** The analyst defines what "valid" means; SQL only applies it. Two analysts can encode different strictness for the same field.
3. **No memorization needed:** learn the 3 building blocks (`[...]`, quantifiers, anchors) and read patterns; exact strings come from regex libraries or docs.
4. **Real DQ workflow:** engineers never retype checks — they store them as versioned/parameterized SQL files, DQ frameworks (Great Expectations, Soda, dbt_expectations), schedulers, or enterprise DQ platforms. The regex pattern is the shared building block underneath.

### Status Notes
- Still no exercises/quiz — Unit 01 conceptual foundation in progress.

---

## Next Steps

1. **Lesson 1.3:** `01-dq-foundations/03-dq-roles-and-frameworks.md` — roles and frameworks in the DQ world.
2. **Lesson 1.4:** `01-dq-foundations/04-cost-of-poor-data-quality.md`.
3. **Unit 01 exercises:** `01-dq-foundations/exercises.md` + self-assessment checkpoint.
4. Then Unit 02 (Business Context). REGEXP returns in **Unit 06 (Validity) — format validation**.

---

*Ready to continue learning!*

---

## Session 3: Lesson 1.3 — Data Quality Roles & Frameworks

### Covered
- Read `01-dq-foundations/03-dq-roles-and-frameworks.md` (Lesson 1.3).
- Q&A: what "ad-hoc querying" means.
- Mapped where the DQ engineer fits among the other roles.

### The People (roles)

| Role | Responsibility |
|------|----------------|
| **DQ Engineer** *(me)* | Builds/runs the automated checks; owns the DQ code, rules, monitoring, alerting — the hands-on builder |
| **DQ Analyst** | Investigates issues, quantifies impact, prioritizes fixes with owners |
| **Data Steward** | Owns a domain (e.g. Customer); defines what "good" means; documents rules |
| **Data Owner** | Senior person accountable for a dataset's quality + budget; approves rules/fixes |
| **Data Architect / Engineer** | Builds the pipelines; fixes root causes at the source |

**Rule of thumb:** engineer *automates* the checks; analysts + stewards *decide what to check*; owners *approve and fund*; pipeline engineers *fix the root cause*.

### The Process Frameworks

| Framework | What it gives you |
|-----------|-------------------|
| **DAMA-DMBOK** | The industry-standard body of knowledge; DQ is one knowledge area (governance, dimensions/metrics, repeated measurement, root cause analysis) |
| **ISO/IEC 25012** | International standard with **15 DQ characteristics** in 3 groups — Inherent (accuracy, completeness, consistency…), System-dependent (accessibility, compliance…), Usage-dependent (timeliness, traceability…). Superset of our 6-dimension model |
| **DQAF** (World Bank/IMF) | Practical method: define indicators → measure → set thresholds → report |

### The DQ Lifecycle (the method to follow everywhere)
1. **DEFINE** rules with business → 2. **PROFILE** the data → 3. **MEASURE** run checks at scale → 4. **REMEDIATE** fix root causes → 5. **MONITOR** watch over time.

> **Critical sequencing insight:** can't define good rules until you understand the business (Unit 02); can't define sensible checks until you profile the data (Unit 03). Jumping to "check for NULLs" produces checks nobody needs.

### Tool Frameworks (Unit 12 preview)
- **Great Expectations** — Python library, declare "expectations" (rules), validate datasets.
- **dbt tests** — SQL assertions (`not_null`, `unique`, `accepted_values`, custom) inside the pipeline.
- **Soda** — data observability tool with SQL-like check syntax.
- The SQL patterns in Units 03–11 are the *same logic* these tools implement under the hood.

### Key Q&A — What does "ad-hoc querying" mean?
- Writing **one-off SQL queries on the spot** — improvised, unrepeatable, no baseline for comparison (e.g. hand-running a different query each time you ask "why are there duplicates?").
- Frameworks replace this with a **repeatable method**: defined rules, consistent checks, measurements comparable over time.

### Key Understandings
1. DQ is a team sport — you're the builder; stewards/owners decide and fund; pipeline engineers fix root causes.
2. Real-world standards (ISO 25012's 15 characteristics) are broader than our 6-dimension model; the 6 map cleanly to SQL checks.
3. The 5-step lifecycle (Define → Profile → Measure → Remediate → Monitor) is your universal method for every dataset.

### Status Notes
- Unit 01 conceptual foundation still in progress; no exercises/quiz yet.

---

## Next Steps

1. **Lesson 1.4:** `01-dq-foundations/04-cost-of-poor-data-quality.md` — the cost of poor data quality.
2. **Unit 01 exercises:** `01-dq-foundations/exercises.md` + self-assessment checkpoint.
3. Then Unit 02 (Business Context) — understanding the business before defining rules.

---

*Ready to continue learning!*

---

## Session 4: Lesson 1.4 — The Cost of Poor Data Quality

### Covered
- Read `01-dq-foundations/04-cost-of-poor-data-quality.md` (Lesson 1.4).
- Core thesis: **"a DQ engineer who cannot argue for resources gets no resources"** — DQ work must be justified in money, not as a nice-to-have.
- Q&A deep-dives: who fixes a NULL at the source, when NULLs are acceptable, and the DQ engineer's pitch.

### The Five Cost Categories

| # | Cost | Mechanism |
|---|------|-----------|
| 1 | **Rework** | Time spent finding/fixing bad data (analysts spend ~40% of the week cleaning) |
| 2 | **Wrong decisions** | Decisions made on bad numbers (revenue missing 8% of orders) |
| 3 | **Wasted spend** | Money spent on the wrong target (campaign to 40,000 duplicates) |
| 4 | **Compliance & legal** | Fines for bad filings (GDPR) |
| 5 | **Lost trust** | Consumers stop believing data (shadow spreadsheets) |

### Defect → Dollars translation
- Example: NULL `orders.total_amount` → `SELECT COUNT(*) * 59.00 FROM orders WHERE total_amount IS NULL` = revenue finance cannot measure/audit.
- The skill: **translate any defect into money by asking how the data is used downstream** (this forces business context).

### The 10× Rule (prevention beats correction)
- Cost multiplies ~10× per downstream stage: source 1× → ETL 10× → warehouse 100× → report/model 1,000× → real-world action 10,000×.
- Catching a defect in SQL before the dashboard is 1,000× cheaper than after a wrong business action.

### The DQ Engineer's Pitch (4 steps)
1. **Quantify a concrete defect** — "we can't measure $X of monthly revenue" (hook = money).
2. **Name the downstream risk** — wrong forecasts, compliance, wasted spend (turns technical issue into risk).
3. **Point to prevention economics** — catch it in the pipeline, not at the report (10× rule = it's cheap insurance).
4. **Propose measurement first** — profile + scorecard, then remediate (low-commitment entry, evidence-driven).

### Who you pitch to (depends on what you need)
- **Budget holder** (data lead/head of data/eng manager) → budget for DQ checks.
- **Source app team** → they own the root-cause fix (e.g., make `total_amount` NOT NULL at write time).
- **Business owner** (finance/product) → defines what "correct" means + funds priority.

### NULL handling — when NULLs are acceptable
- **NULL is allowed when it's meaningful/documented/monitored**, forbidden when it breaks a downstream calculation.
- Acceptable: semantically NULL (`deleted_at` for active rows, `middle_name` with none), agreed by business owner, has a documented handling policy, monitored rate (anomaly alerts, not "0 or fail").
- Unacceptable: NULL like `total_amount` that silently breaks revenue math.
- DQ stance: *"Every NULL must have a documented meaning and a monitored rate."*

### Key Understandings
1. Money is the only language leadership shares — a defect with a price tag gets attention.
2. Frame carefully: NULL total means revenue is **unmeasurable/untracked**, not "lost" — say "we can't account for X%" (more defensible).
3. The DQ engineer argues + monitors; the producing team fixes the source; the business owns priority and definition.
4. The 4-step pitch flows: Hook (money) → Threat (risk) → Reframe (cheap insurance) → Plan (measure first).

### Status Notes
- Lesson 1.4 complete — Unit 01 reading done.
- **Unit 01 exercises NOT started yet** — will do later (next session).

---

## Next Steps

1. **Unit 01 exercises:** `01-dq-foundations/exercises.md` + self-assessment checkpoint (started later, separate session).
2. Then Unit 02 (Business Context) — understanding the business before defining rules.

---

*Ready to continue learning!*
