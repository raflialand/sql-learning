# AI-Observant Business Data Reporting Roadmap

**Duration:** 12 Weeks  
**SQL Depth Target:** 6-7/10  
**Primary AI Tool:** opencode (agentic data agent)  
**Goal:** Become a business data translator who uses AI agents to pull and analyze data — not someone who writes SQL from scratch.

---

## Philosophy

The old way of learning SQL:
> "Master SQL syntax → become a data expert → get a job"

The new way:
> "Understand what business questions need answering → use AI to get the data → validate and interpret results → drive decisions"

**You are the boss. AI is your staff. You observe, validate, and direct.**

---

## Your Data Environment

All exercises use: `sales-records.db` (path: `learning/03-tools/sql-mastery/datasets/sales-records.db`)

```
Available Tables:
├── daily_sales        → revenue & profit by date/store
├── orders             → transaction header (date, customer, store, status, total)
├── order_items        → line items (product, qty, price, discount)
├── products           → product catalog (name, category, price, cost)
├── customers          → customer base (region, membership, points)
├── stores             → store info (region, manager, open date)
├── regions            → region info
├── employees          → staff (job title, salary, department)
├── departments        → department info
└── user_events        → customer interaction events
```

---

## Phase 1: Business Metric Fluency

**Weeks 1-2 | Goal: Know what the numbers MEAN, not how to calculate them**

### Week 1: Core Financial Concepts

| Day | Topic | Business Question | AI Interaction |
|-----|-------|-------------------|----------------|
| 1 | **Revenue vs Sales** | "How much did we sell?" vs "How much money came in?" | Ask AI to show examples |
| 2 | **Profit vs Margin** | "Did we make money?" vs "How efficient are we?" | AI explains with examples from your data |
| 3 | **Gross Margin vs Net Margin** | "Profit before expenses" vs "Actual profit" | AI generates both calculations |
| 4 | **MoM Growth** | "Are we getting better or worse this month?" | AI calculates month-over-month change |
| 5 | **YoY Growth** | "Are we growing compared to last year?" | AI compares same month last year |
| 6 | **CAGR Basics** | "What is our average annual growth rate?" | AI explains and calculates |
| 7 | **Quiz Day** | Metric identification test | — |

### Week 2: Customer & Segment Metrics

| Day | Topic | Business Question | AI Interaction |
|-----|-------|-------------------|----------------|
| 1 | **Customer LTV (Lifetime Value)** | "Which customers are worth the most?" | AI segments customers by total spend |
| 2 | **Purchase Frequency** | "How often do customers buy?" | AI counts orders per customer |
| 3 | **Average Order Value** | "How much do customers spend per visit?" | AI calculates AOV |
| 4 | **Cohort Basics** | "Do customers from Month X behave differently?" | AI groups by signup month |
| 5 | **RFM Segmentation** | "Who are our best customers by recency/frequency/monetary?" | AI runs RFM analysis |
| 6 | **Segment Validation** | "Does this segment make sense for our business?" | You evaluate AI output |
| 7 | **Quiz Day** | Segment matching test | — |

---

## Phase 2: AI Prompting for Data

**Weeks 3-4 | Goal: Learn to DIRECT your AI agent effectively**

### Week 3: Prompt Fundamentals

| Day | Skill | Practice Prompt |
|-----|-------|-----------------|
| 1 | **Schema Context** | Provide AI the schema, ask "what tables contain order date and revenue?" |
| 2 | **Business Term Translation** | Ask: "Show me monthly revenue" → AI generates query |
| 3 | **Iterative Refinement** | Start with simple prompt, then add filters/refinements |
| 4 | **Error Detection** | Prompt with intentionally wrong assumption, see how AI corrects |
| 5 | **Cross-Table Analysis** | Ask for data that requires JOINs, validate AI's logic |
| 6 | **Prompt Templates** | Build reusable prompt patterns |
| 7 | **Review** | Document your best prompts |

### Week 4: Advanced Prompting

| Day | Skill | Practice |
|-----|-------|----------|
| 1 | **Multi-Step Chaining** | "First get monthly revenue, then calculate MoM change, then flag months below threshold" |
| 2 | **Comparative Analysis** | "Compare store performance side by side" |
| 3 | **Conditional Requests** | "If margin < 20%, flag those products" |
| 4 | **Limit + Sort Combinations** | "Top 5 products by revenue, excluding returns" |
| 5 | **Date Range Logic** | "Last 3 months, excluding January" |
| 6 | **Personal Prompt Library** | Compile your best performing prompts |
| 7 | **Quiz Day** | Prompt same report 3 ways, evaluate quality |

### Prompt Template Library

```markdown
## Basic Revenue Request
"Using sales-records.db, show me monthly total revenue for 2026"

## Filtered Revenue
"Using sales-records.db, show me monthly revenue for 2026, but only for Store ID 'S001'"

## Revenue with Growth
"Using sales-records.db, show me monthly revenue for 2026 with MoM % change"

## Top N Analysis
"Using sales-records.db, show me top 10 customers by total order value in 2026"

## Profit Analysis
"Using sales-records.db, show me product name, total revenue, total cost, and gross margin % 
for all active products, sorted by margin descending"

## Segment Breakdown
"Using sales-records.db, show me total revenue by region for 2026"
```

---

## Phase 3: SQL Reading & Validation

**Weeks 5-6 | Goal: 6-7/10 SQL — enough to READ and VALIDATE AI output**

### Week 5: Query Reading Skills

| Day | Skill | Validation Exercise |
|-----|-------|---------------------|
| 1 | **SELECT Clause Reading** | AI generates a query — identify which columns are selected and why |
| 2 | **FROM & JOIN Reading** | Trace which tables the data comes from |
| 3 | **WHERE Clause Logic** | Is the filtering correct? Any rows excluded incorrectly? |
| 4 | **GROUP BY Aggregation** | Is the grouping at the right level? (daily vs monthly vs annual) |
| 5 | **Alias Recognition** | Follow aliased columns through complex queries |
| 6 | **Schema Mapping** | Given AI's query, map it back to the actual schema |
| 7 | **Review** | Common AI query errors to watch for |

### Week 6: Validation & Error Detection

| Day | Skill | Validation Exercise |
|-----|-------|---------------------|
| 1 | **Duplicate Row Detection** | AI query returns suspiciously high numbers — find the bug |
| 2 | **Missing JOIN Condition** | Cross-joined mess — identify what WHERE clause is missing |
| 3 | **Aggregation Level Error** | AI shows daily data as monthly — catch the granularity mistake |
| 4 | **Calculation Accuracy** | AI used `price` instead of `price * qty` — spot the math error |
| 5 | **NULL Handling** | AI missed NULL discounts — review COALESCE usage |
| 6 | **Edge Case Review** | What happens with returns (status = 'cancelled')? AI handled? |
| 7 | **Quiz Day** | 5 AI queries — find all the errors |

### SQL Validation Checklist

```
When reviewing AI-generated SQL, check:
□ Are the RIGHT tables being used?
□ Are the JOIN conditions correct? (one-to-many won't create duplicates)
□ Is the GROUP BY at the correct granularity?
□ Are calculations using the RIGHT fields? (price vs revenue, qty included?)
□ Are filters applied at the correct stage? (WHERE vs HAVING)
□ Are NULLs handled appropriately?
□ Is the date range correct and complete?
□ Are returns/cancellations excluded if needed?
```

---

## Phase 4: Report Types Catalog

**Weeks 7-8 | Goal: "What data answers what business question?"**

### Week 7: Standard Business Reports

| Day | Report Type | Business Question | AI Generates |
|-----|-------------|-------------------|--------------|
| 1 | **Revenue Dashboard** | "How much did we make and when?" | Monthly revenue trend with sparklines |
| 2 | **Revenue by Category** | "Which category drives the most sales?" | Revenue grouped by product category |
| 3 | **Margin Analysis** | "Which products/stores are most profitable?" | Gross margin by product and store |
| 4 | **Customer LTV Report** | "Which customers are worth the most?" | Top 20 customers by total spend |
| 5 | **Store Performance** | "Which store is underperforming?" | Revenue per store vs average |
| 6 | **Regional Breakdown** | "Which region is our strongest market?" | Revenue and margin by region |
| 7 | **Review** | Build your report template library | — |

### Week 8: Advanced Reports

| Day | Report Type | Business Question | AI Generates |
|-----|-------------|-------------------|--------------|
| 1 | **Department Budget vs Actual** | "Are we over/under budget?" | Actual vs budget by department |
| 2 | **Employee Cost Analysis** | "How much are we paying staff?" | Salary cost as % of revenue |
| 3 | **Churn Risk Report** | "Who might stop buying?" | Customers with no orders in 60+ days |
| 4 | **Product Return Rate** | "Which products have highest returns?" | Return rate by product |
| 5 | **Customer Cohort Analysis** | "Do customers from Month X retain better?" | Cohort retention by signup month |
| 6 | **Exception Report** | "Anything unusual this month?" | AI flags statistical anomalies |
| 7 | **Capstone Setup** | Pick ONE business problem to investigate in Phase 5 | — |

### Report Type Reference

| Report | Answers | Primary Tables | Key Metric |
|--------|---------|----------------|------------|
| Revenue Dashboard | "How much did we make?" | orders, daily_sales | total_amount, total_revenue |
| Margin Analysis | "Are we making money on each sale?" | order_items, products | (price - cost) / price |
| Customer LTV | "Which customers matter most?" | orders, customers | SUM(total_amount) |
| Store Performance | "Which store is best/worst?" | stores, orders | revenue per store |
| Budget vs Actual | "Are we on track?" | departments, employees | SUM(salary) vs budget |
| Churn Risk | "Who might leave?" | orders, customers | days since last order |
| Cohort Analysis | "Do acquisitions retain?" | customers, orders | retention rate by cohort |

---

## Phase 5: Business Translation & Decision Support

**Weeks 9-10 | Goal: From DATA to INSIGHT to ACTION**

### Week 9: Insight Generation

| Day | Skill | Practice |
|-----|-------|----------|
| 1 | **"So What?" Analysis** | AI gives you numbers — what do they MEAN for the business? |
| 2 | **Trend Interpretation** | "Revenue is up 5%" — is that good? Depends on context |
| 3 | **Correlation vs Causation** | "Customers who buy X also buy Y" — so what do we do? |
| 4 | **Stakeholder Translation** | Same data, different audience — CFO vs Marketing vs Ops |
| 5 | **Recommendation Framing** | Data → Insight → Action recommendation |
| 6 | **Presenting to Non-Technical** | "The SQL says..." → "What this means is..." |
| 7 | **Review** | Refine your analysis framework |

### Week 10: Capstone Project

| Day | Deliverable |
|-----|-------------|
| 1-3 | **Investigate your chosen business problem** using AI as your data agent |
| 4-5 | **Build the analysis** — data pulls, validation, interpretation |
| 6-7 | **Present findings** — what did you find? what should the business do? |

**Capstone Template:**

```markdown
# Business Problem: [Your Question]

## What I Wanted to Know
[Business context and why this matters]

## Data Retrieved
[AI queries run, what data was pulled]

## What the Data Shows
[Key numbers and trends]

## So What?
[What this means for the business]

## Recommendation
[Specific action the business should take]

## Risks & Caveats
[What might be wrong with this analysis]
```

---

## Phase 6: Agentic Workflow Conceptual

**Weeks 11-12 | Goal: Understand AI agent architecture — NO hands-on automation**

### Week 11: AI Agent Principles

| Day | Topic | Concept |
|-----|-------|--------|
| 1 | **Monitoring vs Acting Agents** | Agents that watch data vs agents that take action |
| 2 | **Threshold-Based Alerting** | Define "normal" — AI flags when broken |
| 3 | **Exception Reporting** | AI actively looks for unusual patterns |
| 4 | **Human-in-the-Loop Design** | When should AI stop and ask? |
| 5 | **Agent Orchestration** | Multiple agents working together |
| 6 | **Error Handling** | What happens when AI gives wrong data? |
| 7 | **Review** | How would you design YOUR data agent team? |

### Week 12: Personal AI Data Workflow

| Day | Topic |
|-----|-------|
| 1-2 | **Design your ideal AI data environment** |
| 3-4 | **Map reports to agents** — which AI handles which recurring request? |
| 5-6 | **Build your observation checklist** — how do YOU validate AI work? |
| 7 | **Final Review: Where you started vs where you are** |

### Your Target Profile at Week 12

```
BEFORE (Old Way):
- Can write complex JOINs
- Knows every SQL function
- Tests: 10/10 on quizzes
- Job story: "I am an SQL expert"

AFTER (New Way):
- Knows which business question needs which data
- Can direct AI agents to pull data
- Validates AI output for correctness and business logic
- Tests: Can identify errors in AI-generated SQL
- Job story: "I translate business questions into data answers using AI agents"
```

---

## Progress Tracking

```
PHASE 1: Business Metric Fluency
├── Week 1: Core Financial Concepts  □
└── Week 2: Customer & Segment Metrics  □

PHASE 2: AI Prompting for Data
├── Week 3: Prompt Fundamentals  □
└── Week 4: Advanced Prompting  □

PHASE 3: SQL Reading & Validation
├── Week 5: Query Reading Skills  □
└── Week 6: Validation & Error Detection  □

PHASE 4: Report Types Catalog
├── Week 7: Standard Business Reports  □
└── Week 8: Advanced Reports  □

PHASE 5: Business Translation & Decision Support
├── Week 9: Insight Generation  □
└── Week 10: Capstone Project  □

PHASE 6: Agentic Workflow Conceptual
├── Week 11: AI Agent Principles  □
└── Week 12: Personal AI Data Workflow  □
```

---

## Key Differences from Traditional SQL Learning

| Aspect | Traditional SQL Learning | This Roadmap |
|--------|---------------------------|--------------|
| Success metric | "Can you write this query?" | "Can you get the right data?" |
| SQL depth needed | 9-10/10 | 6-7/10 |
| AI role | Learning aid | Working agent |
| Primary skill | Query writing | Question asking + validation |
| Job readiness | 6+ months | 3-4 months |
| AI exposure | Optional | Core to everything |
| Business focus | Technical | Decision-oriented |

---

*Curriculum created: July 2026*  
*Designed for: AI-first, business-data-driven learning*  
*Tools: opencode as primary AI agent, sales-records.db for practice*
