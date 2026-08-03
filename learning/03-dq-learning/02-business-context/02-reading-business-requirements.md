# Lesson 2.2: Reading Business Requirements

Business requirements arrive messy. Your job is to translate them into **precise, testable data expectations**. This is a translation skill — and it's the skill that makes your SQL checks correct.

---

## From Requirement to Rule

Requirements come in words. Rules come in SQL. The bridge between them is a **structured translation** with three pieces:

```
Requirement (business words)
      │
      ▼
Expectation (what "good" means, in a testable sentence)
      │
      ▼
Rule (SQL check that fails when data is bad)
```

---

## The Translation Table

Common requirement phrasings and how to translate them:

| Business wording | Testable expectation | SQL pattern |
|------------------|----------------------|-------------|
| "Every customer must have a working email" | email NOT NULL and matches email format | `email IS NULL OR email NOT REGEXP '...'` |
| "We need unique customer records" | no duplicate email/phone | `GROUP BY ... HAVING COUNT(*) > 1` |
| "Prices are in whole dollars" | unit_price is a valid positive number | `unit_price <= 0` |
| "Order statuses are Shipped, Pending, or Cancelled" | status in the allowed set | `status NOT IN ('shipped','pending','cancelled')` |
| "Revenue must be complete" | total_amount never NULL | `total_amount IS NULL` |
| "Orders are current" | order_date not in the future | `order_date > CURRENT_DATE` |

**The trap:** business words hide assumptions. "Working email" implies *format* validation, not just "not empty". "Unique" implies *which key* is unique — email? phone? full name? You must clarify.

---

## Example: Ambiguity Hunting

**Requirement:** *"We should have one row per customer."*

Ambiguous! Which column makes a customer unique?

```sql
-- Interpretation A: unique by email
SELECT email, COUNT(*) AS cnt
FROM customers
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;
```

```sql
-- Interpretation B: unique by full name + phone
SELECT first_name, last_name, phone, COUNT(*) AS cnt
FROM customers
WHERE phone IS NOT NULL
GROUP BY first_name, last_name, phone
HAVING COUNT(*) > 1;
```

**Different interpretations → different results.** Customers 1 & 2 (exact dup) show up either way. Customers 3 & 4 (same phone, different email/state) only show up under B. You must agree on the business key *before* writing the check.

---

## The "So What?" Test

For every rule, apply the "so what?" test. A rule is worth having only if a violation has a consequence.

| Rule | So what? | Keep? |
|------|----------|-------|
| `email` matches regex | Bounced campaign emails → wasted spend + sender penalty | ✅ |
| `address_line` never contains a `#` character | No consequence | ❌ drop |
| `total_amount = sum(items)` | Finance books wrong revenue | ✅ |

> **DQ engineer's motto:** *If a violation wouldn't bother anyone, the rule shouldn't exist.*

---

## Writing a Rule Card

For every rule you create, write a **rule card** (this becomes your DQ rule catalog in Unit 11):

```
Rule ID      : DQ-ORD-001
Dataset      : orders
Field        : total_amount
Dimension    : Accuracy
Requirement  : "Revenue must equal what we actually charged"
Expectation  : total_amount = SUM(qty * unit_price) of its items
SQL check    : SELECT order_id FROM orders o
               LEFT JOIN (SELECT order_id, SUM(qty*unit_price) s
                          FROM order_items GROUP BY order_id) i
                 ON o.order_id = i.order_id
               WHERE COALESCE(i.s,0) <> o.total_amount;
Threshold    : 0 violations allowed
Severity     : High (finance)
Owner        : Finance Data Steward
```

---

## English Translation (of this lesson)

> "Business requirements come in words; I translate them into testable expectations and then into SQL. I hunt for ambiguity (which column is the unique key?), I drop rules that fail the 'so what?' test, and I document every rule on a rule card so it can be monitored later."

---

## Key Takeaways

1. Always translate **requirements → expectation → rule**, never straight to SQL.
2. **Hunt for ambiguity** — clarify the business key, the meaning of "valid", and the allowed set.
3. Apply the **"so what?" test** to kill meaningless rules.
4. Document rules on **rule cards** — they become your monitoring catalog.

**Coming up next:** Data consumers and use cases.
