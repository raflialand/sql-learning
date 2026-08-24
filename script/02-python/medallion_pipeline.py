#!/usr/bin/env python3
"""medallion-lab pipeline orchestrator.

Builds the three-layer Medallion architecture (bronze -> silver -> gold) on the
read-only MarketHub ecommerce dataset, using Python stdlib only (sqlite3 +
ATTACH DATABASE). Runs per-layer SQL scripts under script/01-sql/medallion/,
prints a stage summary per layer, runs the gold stage twice to prove idempotency,
and enforces row-count, grain, flag, and no-data-loss assertions.

Usage:
    python script/02-python/medallion_pipeline.py            # run all stages
    python script/02-python/medallion_pipeline.py --stage bronze   # one stage
    python script/02-python/medallion_pipeline.py --stage silver
    python script/02-python/medallion_pipeline.py --stage gold
"""

import os
import sqlite3
import sys
import urllib.parse

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SOURCE_DB = os.path.join(
    ROOT, "learning", "02-sql-learning", "sql-skill-push", "datasets", "02-intermediate", "ecommerce.db"
)
OUT_DIR = os.path.join(ROOT, "data", "medallion")
SQL_DIR = os.path.join(ROOT, "script", "01-sql", "medallion")
BRONZE_DB = os.path.join(OUT_DIR, "bronze.db")
SILVER_DB = os.path.join(OUT_DIR, "silver.db")
GOLD_DB = os.path.join(OUT_DIR, "gold.db")

BRONZE_TABLES = [
    "bronze_categories", "bronze_vendors", "bronze_products", "bronze_customers",
    "bronze_orders", "bronze_order_items", "bronze_payments", "bronze_shipments",
]
SOURCE_COUNTS = {
    "categories": 16, "vendors": 14, "products": 120, "customers": 500,
    "orders": 2800, "order_items": 7102, "payments": 2283, "shipments": 1864,
}
SILVER_TABLES = [
    "silver_categories", "silver_vendors", "silver_products", "silver_customers",
    "silver_orders", "silver_order_items", "silver_payments", "silver_shipments",
]
GOLD_TABLES = [
    "dim_customer", "dim_product", "dim_date", "fact_order_items",
    "fact_orders", "mart_vendor_performance", "mart_daily_revenue",
]

FAILURES = []


def log(msg):
    print(msg)


def fail(msg):
    FAILURES.append(msg)
    log("ASSERT FAIL: " + msg)


def file_uri(path):
    """Build a SQLite file URI with mode=ro for read-only attachment."""
    p = path.replace("\\", "/")
    encoded = urllib.parse.quote(p, safe="/:")
    return "file:" + encoded + "?mode=ro"


def ensure_inputs():
    if not os.path.exists(SOURCE_DB):
        raise SystemExit("FATAL: source dataset not found: %s" % SOURCE_DB)
    os.makedirs(OUT_DIR, exist_ok=True)


def list_tables(con, schema):
    rows = con.execute(
        "SELECT name FROM %s.sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%%' ORDER BY name" % schema
    ).fetchall()
    return [r[0] for r in rows]


def counts(con, schema, tables):
    return {t: con.execute("SELECT COUNT(*) FROM %s.%s" % (schema, t)).fetchone()[0] for t in tables}


def print_summary(title, rows):
    log("")
    log(title)
    width = max(len(r[0]) for r in rows) + 2
    log("-" * (width + 3 * 14))
    for name, a, b in rows:
        log("%-*s %14d %14d" % (width, name, a, b))
    log("")


def execute_sql(con, path, schema_aliases):
    if not os.path.exists(path):
        raise SystemExit("FATAL: script not found: %s" % path)
    with open(path, encoding="utf-8") as f:
        sql = f.read()
    for alias in schema_aliases:
        if alias not in sql:
            log("WARN: script %s never references attached schema '%s'" % (os.path.basename(path), alias))
    try:
        con.executescript(sql)
    except sqlite3.Error as e:
        raise SystemExit("SQL ERROR in %s: %s" % (path, e))


def new_connection():
    con = sqlite3.connect(":memory:", uri=True)
    con.execute("PRAGMA foreign_keys = OFF")
    return con


def run_bronze():
    log("== Stage: BRONZE ==")
    con = new_connection()
    con.execute("ATTACH DATABASE %s AS source" % sqlite3_quote(file_uri(SOURCE_DB)))
    con.execute("ATTACH DATABASE %s AS bronze" % sqlite3_quote(BRONZE_DB))
    execute_sql(con, os.path.join(SQL_DIR, "01-bronze.sql"), ("source", "bronze"))

    bronze_counts = counts(con, "bronze", BRONZE_TABLES)
    rows = []
    for b in BRONZE_TABLES:
        src = b[len("bronze_"):]
        expected = SOURCE_COUNTS[src]
        rows.append((b, expected, bronze_counts[b]))
        if bronze_counts[b] != expected:
            fail("bronze.%s = %d, expected %d" % (b, bronze_counts[b], expected))
    print_summary("Bronze: source vs bronze row counts", rows)

    audit_ok = all(
        _has_columns(con, "bronze", t, ("_ingest_ts", "_source_table")) for t in BRONZE_TABLES
    )
    if not audit_ok:
        fail("bronze tables missing audit columns (_ingest_ts / _source_table)")
    con.close()


def _has_columns(con, schema, table, cols):
    have = {r[1] for r in con.execute("PRAGMA %s.table_info(%s)" % (schema, table)).fetchall()}
    return all(c in have for c in cols)


def run_silver():
    log("== Stage: SILVER ==")
    con = new_connection()
    con.execute("ATTACH DATABASE %s AS bronze" % sqlite3_quote(BRONZE_DB))
    con.execute("ATTACH DATABASE %s AS silver" % sqlite3_quote(SILVER_DB))
    execute_sql(con, os.path.join(SQL_DIR, "02-silver.sql"), ("bronze", "silver"))

    bronze_counts = counts(con, "bronze", BRONZE_TABLES)
    silver_counts = counts(con, "silver", SILVER_TABLES)
    rows = []
    for s in SILVER_TABLES:
        b = "bronze" + s[len("silver"):]
        rows.append((s, bronze_counts[b], silver_counts[s]))
        if silver_counts[s] != bronze_counts[b]:
            fail("silver.%s = %d, bronze.%s = %d (grain mismatch)" % (s, silver_counts[s], b, bronze_counts[b]))
    print_summary("Silver: bronze vs silver row counts (grain preserved)", rows)

    q = con.execute("SELECT COUNT(*) FROM silver.silver_orders WHERE is_valid_order = 0").fetchone()[0]
    if q != 456:
        fail("silver_orders is_valid_order=0 = %d, expected 456 (Cancelled)" % q)
    q = con.execute("SELECT COUNT(*) FROM silver.silver_orders WHERE has_payment = 0").fetchone()[0]
    if q != 517:
        fail("silver_orders has_payment=0 = %d, expected 517 (no payment row)" % q)
    q = con.execute("SELECT COUNT(*) FROM silver.silver_shipments WHERE in_transit = 1").fetchone()[0]
    if q != 95:
        fail("silver_shipments in_transit=1 = %d, expected 95 (NULL delivery_date)" % q)
    q = con.execute("SELECT COUNT(*) FROM silver.silver_products WHERE is_discontinued_but_sold = 1").fetchone()[0]
    if q != 9:
        fail("silver_products is_discontinued_but_sold=1 = %d, expected 9 (inactive-but-sold)" % q)

    bad_issues = con.execute(
        "SELECT COUNT(*) FROM silver.silver_orders WHERE _quality_issues IS NOT NULL AND _quality_issues = ''"
    ).fetchone()[0]
    if bad_issues:
        fail("silver_orders has %d empty-string _quality_issues (must be NULL or comma-delimited)" % bad_issues)
    con.close()


def run_gold():
    log("== Stage: GOLD ==")
    script = os.path.join(SQL_DIR, "03-gold.sql")

    con = new_connection()
    con.execute("ATTACH DATABASE %s AS silver" % sqlite3_quote(SILVER_DB))
    con.execute("ATTACH DATABASE %s AS gold" % sqlite3_quote(GOLD_DB))

    execute_sql(con, script, ("silver", "gold"))
    first_counts = counts(con, "gold", GOLD_TABLES)

    execute_sql(con, script, ("silver", "gold"))
    second_counts = counts(con, "gold", GOLD_TABLES)

    rows = []
    for g in GOLD_TABLES:
        rows.append((g, first_counts[g], second_counts[g]))
        if first_counts[g] != second_counts[g]:
            fail("gold.%s idempotency mismatch: run1=%d run2=%d" % (g, first_counts[g], second_counts[g]))
    print_summary("Gold: idempotency (run 1 vs run 2 row counts)", rows)

    if first_counts["fact_order_items"] != 7102:
        fail("fact_order_items = %d, expected 7102" % first_counts["fact_order_items"])
    if first_counts["fact_orders"] != 2800:
        fail("fact_orders = %d, expected 2800" % first_counts["fact_orders"])
    if first_counts["dim_product"] != 120:
        fail("dim_product = %d, expected 120" % first_counts["dim_product"])
    if first_counts["dim_customer"] != 500:
        fail("dim_customer = %d, expected 500 distinct customers" % first_counts["dim_customer"])
    if first_counts["mart_vendor_performance"] != 14:
        fail("mart_vendor_performance = %d, expected 14" % first_counts["mart_vendor_performance"])

    min_o = con.execute("SELECT MIN(order_date) FROM silver.silver_orders").fetchone()[0]
    max_o = con.execute("SELECT MAX(order_date) FROM silver.silver_orders").fetchone()[0]
    min_d = con.execute("SELECT MIN(date) FROM gold.dim_date").fetchone()[0]
    max_d = con.execute("SELECT MAX(date) FROM gold.dim_date").fetchone()[0]
    if (min_d, max_d) != (min_o, max_o):
        fail("dim_date covers %s..%s, expected %s..%s" % (min_d, max_d, min_o, max_o))

    _no_data_loss(con)
    con.close()


def _no_data_loss(con):
    gold_sum = con.execute(
        "SELECT COALESCE(SUM(total_amount), 0) FROM gold.fact_orders WHERE order_status IN ('completed', 'shipped')"
    ).fetchone()[0]
    src_sum = con.execute(
        "SELECT COALESCE(SUM(total_amount), 0) FROM silver.silver_orders WHERE status IN ('completed', 'shipped')"
    ).fetchone()[0]
    if abs(gold_sum - src_sum) > 0.01:
        fail("no-data-loss: gold Completed+Shipped total_amount sum = %s, source = %s" % (gold_sum, src_sum))

    gold_cnt = con.execute("SELECT COUNT(*) FROM gold.fact_orders").fetchone()[0]
    src_cnt = con.execute("SELECT COUNT(*) FROM silver.silver_orders").fetchone()[0]
    if gold_cnt != src_cnt:
        fail("no-data-loss: fact_orders = %d rows, source orders = %d rows" % (gold_cnt, src_cnt))


def sqlite3_quote(s):
    return "'" + s.replace("'", "''") + "'"


def main():
    ensure_inputs()
    args = sys.argv[1:]
    stage = None
    if args:
        if args[0] == "--stage" and len(args) > 1:
            stage = args[1]
        else:
            print(__doc__)
            return 2

    targets = []
    if stage is None or stage == "bronze":
        targets.append(BRONZE_DB)
    if stage is None or stage == "silver":
        targets.append(SILVER_DB)
    if stage is None or stage == "gold":
        targets.append(GOLD_DB)
    for path in targets:
        if os.path.exists(path):
            os.remove(path)

    if stage is None:
        run_bronze()
        run_silver()
        run_gold()
    elif stage == "bronze":
        run_bronze()
    elif stage == "silver":
        run_bronze()
        run_silver()
    elif stage == "gold":
        run_bronze()
        run_silver()
        run_gold()
    else:
        print("unknown stage: %s" % stage)
        return 2

    if FAILURES:
        log("")
        log("FAILED: %d assertion(s)" % len(FAILURES))
        return 1
    log("")
    log("PASS: all assertions passed; end-to-end run complete (exit 0)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
