# Lesson 1.3: Data Quality Roles and Frameworks

Data quality work happens in an organization, not in isolation. Understanding the *roles* and *frameworks* tells you where you fit and what standards the industry follows.

---

## The People

| Role | Responsibility | Typical background |
|------|----------------|--------------------|
| **Data Quality Engineer** *(you, this module)* | Builds and runs the automated checks; owns the DQ code, rules, monitoring, and alerting. The *hands-on* builder. | Engineering, SQL-heavy |
| **Data Quality Analyst** | Investigates detected issues, quantifies business impact, works with owners to prioritize fixes. | Analytics / business |
| **Data Steward** | Owns a specific domain's data (e.g., Customer), defines what "good" means, documents rules. | Business + data |
| **Data Owner** | Senior person accountable for a dataset's quality and budget. Approves rules and fixes. | Management |
| **Data Architect / Engineer** | Builds the pipelines that the DQ engineer monitors. Fixes root causes at the source. | Engineering |

**Practical rule of thumb:** as a DQ engineer you *automate the checks*; analysts and stewards *decide what to check*; owners *approve and fund*; pipeline engineers *fix the root cause*.

---

## The Process Frameworks

Frameworks give you a repeatable method instead of ad-hoc querying.

### DAMA-DMBOK (Data Management Body of Knowledge)

The most widely referenced data-management framework. Data quality is one of its knowledge areas. It emphasizes:

- **Data Governance** — who decides rules and who is accountable.
- **Data Quality dimensions & metrics** — the 6 dimensions formalized.
- **DQ measurement** — repeated measurement over time, not one-off.
- **Root cause analysis** — fixing processes, not just records.

### ISO/IEC 25012

The international standard defining **15 data quality characteristics** (a superset of our 6 dimensions). It splits them into three groups:

| Group | Examples |
|-------|----------|
| Inherent (about the data itself) | accuracy, completeness, consistency, credibility |
| System-dependent | accessibility, compliance, recoverability |
| Usage-dependent | timeliness, traceability, understandability |

We use a **6-dimension model** in this module because it maps cleanly to SQL checks. Know that real-world standards are broader.

### DQAF (Data Quality Assessment Framework) — World Bank / IMF

A practical assessment method: define indicators → measure → set thresholds → report. Very close to what you'll build in Unit 11.

---

## The DQ Lifecycle (the method you will follow)

```
┌────────────┐   ┌────────────┐   ┌────────────┐   ┌────────────┐   ┌────────────┐
│  1. DEFINE  │ → │  2. PROFILE │ → │ 3. MEASURE │ → │4. REMEDIATE │ → │ 5. MONITOR │
│  rules with │   │ understand  │   │  run checks│   │  fix root   │   │  watch over│
│  business   │   │  the data   │   │  at scale  │   │  causes     │   │  time      │
└────────────┘   └────────────┘   └────────────┘   └────────────┘   └────────────┘
```

| Step | What you do | Where in this module |
|------|-------------|----------------------|
| **Define** | Turn business requirements into concrete rules ("email must match regex", "total = qty×price") | Unit 02 |
| **Profile** | Explore the data first — counts, distributions, NULL rates | Unit 03 |
| **Measure** | Run the checks, count violations, compute pass rates | Units 04–10 |
| **Remediate** | Clean the data and fix the upstream process that creates defects | Unit 13 (capstone) |
| **Monitor** | Re-run checks on a schedule and alert when thresholds break | Unit 11 |

> **Critical sequencing insight (this is the heart of the module):** you cannot *define* good rules until you *understand the business* (Unit 02), and you cannot *define* sensible checks until you *profile* the data (Unit 03). Jumping straight to "check for NULLs" produces checks nobody needs.

---

## Frameworks for Tools (brief)

Two tool-oriented frameworks you will meet later:

- **Great Expectations** — a Python library where you declare "expectations" (rules) and validate datasets against them.
- **dbt tests** — SQL assertions (`not_null`, `unique`, `accepted_values`, custom) that run inside your data pipeline.
- **Soda** — a data observability tool with SQL-like check syntax.

You will study these conceptually in **Unit 12**. The SQL patterns you learn in Units 03–11 are the *same logic* those tools implement under the hood — so mastering SQL DQ checks transfers directly.

---

## English Translation (of this lesson)

> "Data quality is a team sport. A DQ engineer builds the automated checks; stewards and owners define and fund the rules; analysts quantify impact. Industry frameworks like DAMA-DMBOK and ISO 25012 give us vocabulary and process. The method I follow everywhere is: define rules, profile the data, measure violations, fix root causes, then monitor over time."

---

## Key Takeaways

1. Know your **role** (engineer = builder of checks) and who owns the *decisions* (stewards/owners).
2. **DAMA-DMBOK** is the industry-standard framework; **ISO 25012** formalizes 15 characteristics.
3. The **5-step lifecycle** (Define → Profile → Measure → Remediate → Monitor) is your method for every dataset.
4. Tool frameworks (Great Expectations, dbt, Soda) implement the same logic as your SQL checks.

**Coming up next:** The cost of poor data quality.
