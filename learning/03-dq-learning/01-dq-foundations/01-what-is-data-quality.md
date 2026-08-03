# Lesson 1.1: What Is Data Quality?

## The Core Idea

**Data quality = how well a dataset serves the purpose it was created for.**

Notice the key word: *purpose*. A phone number like `555-1234` is perfectly fine for a contact directory on your own phone. It is **bad quality** for a marketing automation platform that requires 10-digit US numbers with area codes.

> **Data is not good or bad in a vacuum. It is good or bad *relative to a use case*.**

This is the single most important idea in this entire module — and it is why Unit 02 (Business Context) comes *before* any SQL.

---

## An Everyday Analogy

Think of a restaurant menu.

- **Completeness** — does the menu list a price for every dish?
- **Uniqueness** — is "Fish & Chips" listed twice?
- **Validity** — is every price in dollars, or are a few in euros?
- **Accuracy** — does the "Catch of the Day" price match what you actually get charged?
- **Consistency** — does the kitchen call it "Chips" while the menu says "Fries"?
- **Timeliness** — is the seasonal menu still showing dishes discontinued last month?

A menu missing a price is a *data quality* problem, not a cooking problem. Your database can serve the wrong dish for the exact same reason — bad data.

---

## Why It Matters in the Real World

Poor data quality is not an abstract concern. It produces concrete failures:

| Failure | Example |
|---------|---------|
| Wrong business decisions | Executives approve a budget based on revenue totals that miss 8% of orders |
| Regulatory fines | GDPR/mandatory reporting submitted with incomplete or inaccurate records |
| Wasted spend | A marketing campaign sent to 40,000 duplicated customer profiles |
| Customer harm | A patient's allergy field NULL → wrong medication prescribed |
| Operational breakage | An order shipped to an address stored with a typo |

The industry-common estimate (IBM, Gartner, etc.) is that bad data costs organizations **tens of millions of dollars per year** — mostly in wasted effort, rework, and lost trust.

---

## Good Data vs. Trustworthy Data

| Good data (looks fine) | Trustworthy data (proven fine) |
|------------------------|--------------------------------|
| The column has values | Every value has been *checked* against a rule |
| No obvious NULLs | Completeness rules are documented and measured |
| Looks clean at a glance | Checks run automatically, every pipeline run |
| No one complains | Defects are found and fixed *before* consumers see them |

Your job as a **Data Quality Engineer** is to move the organization from the left column to the right column — using SQL as your primary tool for *finding* and *measuring* problems.

---

## English Translation (of this lesson)

> "Data quality means the data is fit for its intended purpose. A value is only 'good' or 'bad' relative to how it will be used. Bad data causes wrong decisions, wasted money, and lost trust. My job is to systematically find, measure, and prevent bad data using SQL."

---

## Key Takeaways

1. Data quality is **fit for purpose** — context decides what "good" means.
2. The 6 dimensions give us a vocabulary to name problems precisely.
3. Bad data costs real money and causes real harm — this is a serious engineering discipline.
4. A DQ engineer *proves* data is good with checks, rather than assuming it.

**Coming up next:** The six dimensions of data quality.
