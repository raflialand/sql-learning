# Lesson 11.3: Scheduling and Alerting Basics

Checks only protect data if they **run on schedule** and **alert when they fail**. This lesson covers the MySQL-side building blocks; the orchestration (cron, Airflow, etc.) wraps around them.

---

## Step 1: The Alert Query

An alert is just a query that returns a row *only when something is wrong*:

```sql
-- Alert: email completeness below 99%
SELECT 'email_completeness' AS alert,
       ROUND(COUNT(email) * 100.0 / COUNT(*), 1) AS actual
FROM customers
HAVING actual < 99;
```

**Expected output (1 row):**

| alert | actual |
|-------|--------|
| email_completeness | 86.7 |

The trick: `HAVING actual < 99` with no `GROUP BY` produces one row (the aggregate), and it *disappears* when the condition passes. **Zero rows = all good; one row = fire the alert.**

---

## Step 2: Store Alert History

```sql
CREATE TABLE dq_alerts (
    alert_id    INT AUTO_INCREMENT PRIMARY KEY,
    alert_date  DATETIME NOT NULL,
    alert_name  VARCHAR(100) NOT NULL,
    detail      VARCHAR(255),
    status      VARCHAR(20) DEFAULT 'OPEN'   -- OPEN / ACK / RESOLVED
);

-- Fire the alert (only inserts when the condition is true)
INSERT INTO dq_alerts (alert_date, alert_name, detail)
SELECT NOW(), 'email_completeness', CONCAT('Email completeness is ', ROUND(COUNT(email)*100.0/COUNT(*),1), '% (threshold 99%)')
FROM customers
HAVING ROUND(COUNT(email) * 100.0 / COUNT(*), 1) < 99;
```

---

## Step 3: The "Alert If Exists" Pattern

To avoid duplicate alerts, check whether an OPEN alert already exists:

```sql
INSERT INTO dq_alerts (alert_date, alert_name, detail)
SELECT NOW(), 'email_completeness', 'Email completeness below 99%'
FROM customers
HAVING ROUND(COUNT(email) * 100.0 / COUNT(*), 1) < 99
  AND NOT EXISTS (
      SELECT 1 FROM dq_alerts
      WHERE alert_name = 'email_completeness' AND status = 'OPEN'
  );
```

---

## Step 4: Scheduling

MySQL has no built-in scheduler for arbitrary SQL, so the schedule lives in an orchestrator. Standard options:

| Scheduler | How it runs your checks | Best for |
|-----------|-------------------------|----------|
| **cron / Task Scheduler** | runs a `.sql` file via `mysql < file.sql` | simple, single machine |
| **Airflow DAG** | DQ task after pipeline task | full pipeline orchestration |
| **dbt test / Soda scan** | runs the DQ suite natively | dbt/Soda-based stacks |

**Example: run a checks file every morning at 6am (Windows Task Scheduler / cron equivalent):**

```bash
mysql -u root -p dq_learning < dq_daily_checks.sql >> dq_run_$(date +%F).log
```

On Windows, the same idea uses `schtasks` or Task Scheduler to invoke `mysql.exe` with the script.

---

## Step 5: Alert Delivery

Delivery is done by whatever runs the schedule. Patterns:

| Channel | Trigger |
|---------|---------|
| Email | script checks `SELECT COUNT(*) FROM dq_alerts WHERE status='OPEN'` and emails if > 0 |
| Slack/webhook | orchestrator task calls a webhook when the DQ task fails |
| Dashboard | scorecard view (Lesson 11.1) shows current status |

The **Open alerts view** is the single source a delivery script reads:

```sql
-- What's broken right now?
SELECT alert_date, alert_name, detail
FROM dq_alerts
WHERE status = 'OPEN'
ORDER BY alert_date;
```

---

## The Complete Monitoring Loop (recap)

```
schedule (cron/Airflow)
    │
    ▼
run dq_daily_checks.sql   (catalog rules → violations)
    │
    ├──► dq_check_results   (history)
    ├──► dq_alerts          (new OPEN alerts)
    │
    ▼
delivery script reads OPEN alerts → email/Slack/dashboard
    │
    ▼
steward acknowledges & resolves  →  history for trends
```

---

## English Translation (of this lesson)

> "Scheduling makes DQ checks automatic. An alert query returns a row only when something is wrong, using HAVING on an aggregate with no GROUP BY. I store alerts in a table to avoid duplicates and track status, run the checks on a schedule (cron or Airflow), and have a delivery script read OPEN alerts to email or post to Slack. The scorecard and history complete the loop."

---

## Key Takeaways

1. **Alert query = aggregate + `HAVING` on the threshold** — returns a row only when broken.
2. Store alerts in a **`dq_alerts` table** with `OPEN/ACK/RESOLVED` status.
3. **Deduplicate** alerts with `NOT EXISTS` on OPEN alerts.
4. **Scheduling** lives in cron/Airflow — MySQL doesn't schedule SQL.
5. **Delivery** reads OPEN alerts and pushes to email/Slack/dashboard.

---

## Unit 11 Exercises → practice building a monitoring suite.

Move on to `exercises.md`.
