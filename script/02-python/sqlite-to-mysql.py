"""Convert a SQLite database into a MySQL-compatible SQL script.

Usage:
    python script/sqlite-to-mysql.py <input.db> [output.sql]

Reads the SQLite schema and data, translates types and defaults to MySQL,
and writes a self-contained .sql script (DDL + INSERTs).
Stdlib only - no external dependencies.
"""

import re
import sqlite3
import sys
from collections import OrderedDict
from pathlib import Path

DATE_COLUMNS = {
    "hire_date", "join_date", "order_date", "shipment_date",
    "delivery_date", "issue_date", "expiration_date",
    "start_date", "end_date",
}
TIMESTAMP_COLUMNS = {"created_at", "review_date"}
LONG_TEXT_COLUMNS = {"review_text"}

# FK-safe insert order (also guarded by FOREIGN_KEY_CHECKS=0)
TABLE_ORDER = [
    "departments", "categories", "customers", "employees", "suppliers",
    "promotions", "products", "orders", "order_items",
    "shipments", "product_reviews", "gift_cards",
]


def split_top_level(text):
    """Split a comma-separated definition on top-level commas."""
    parts = []
    depth = 0
    current = []
    for ch in text:
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        if ch == "," and depth == 0:
            parts.append("".join(current))
            current = []
        else:
            current.append(ch)
    parts.append("".join(current))
    return [p.strip() for p in parts if p.strip()]


def parse_column(chunk):
    """Parse one SQLite column definition into a dict."""
    m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*)\s+(.*)$", chunk, re.DOTALL)
    if not m:
        return None
    name, rest = m.group(1), m.group(2).strip()

    is_pk_auto = bool(re.search(r"\bPRIMARY\s+KEY\b", rest, re.I)) and \
                 bool(re.search(r"\bAUTOINCREMENT\b", rest, re.I))

    if re.search(r"\bREFERENCES\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)", rest, re.I):
        ref = re.search(r"\bREFERENCES\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)", rest, re.I)
        references = (ref.group(1), ref.group(2))
    else:
        references = None

    check = None
    cm = re.search(r"\bCHECK\s*\((.+?)\)\s*$", rest, re.I | re.DOTALL)
    if cm:
        check = cm.group(1).strip()

    has_default = bool(re.search(r"\bDEFAULT\b", rest, re.I))
    not_null = bool(re.search(r"\bNOT\s+NULL\b", rest, re.I))
    unique = bool(re.search(r"\bUNIQUE\b", rest, re.I))

    if "TEXT" in rest.upper():
        sqlite_type = "TEXT"
    elif "REAL" in rest.upper() or "DOUBLE" in rest.upper() or "FLOAT" in rest.upper():
        sqlite_type = "REAL"
    elif "INT" in rest.upper():
        sqlite_type = "INTEGER"
    else:
        sqlite_type = "TEXT"

    default = None
    dm = re.search(r"\bDEFAULT\s+(.+?)(?:\s+(?:NOT\s+NULL|UNIQUE|REFERENCES|CHECK)|$)", rest, re.I | re.DOTALL)
    if dm:
        default = dm.group(1).strip()

    return {
        "name": name,
        "rest": rest,
        "sqlite_type": sqlite_type,
        "is_pk_auto": is_pk_auto,
        "references": references,
        "check": check,
        "has_default": has_default,
        "default": default,
        "not_null": not_null,
        "unique": unique,
    }


def mysql_type(col, table_name):
    name = col["name"]
    sqlite_type = col["sqlite_type"]

    if col["is_pk_auto"]:
        return "INT AUTO_INCREMENT PRIMARY KEY"

    if name in TIMESTAMP_COLUMNS:
        return "DATETIME"
    if name in DATE_COLUMNS:
        return "DATE"
    if sqlite_type == "REAL":
        return "DECIMAL(10,2)"
    if sqlite_type == "INTEGER":
        if name.startswith("is_"):
            return "TINYINT(1)"
        return "INT"
    # TEXT
    if name in LONG_TEXT_COLUMNS:
        return "TEXT"
    if name in ("email", "code") or col["unique"] or col["has_default"]:
        return "VARCHAR(255)"
    return "VARCHAR(255)"


def build_column_ddl(col, table_name):
    name = col["name"]
    pieces = ["`%s`" % name, mysql_type(col, table_name)]

    if col["is_pk_auto"]:
        return "  " + " ".join(pieces)

    if col["references"]:
        ref_table, ref_col = col["references"]
        pieces.append("REFERENCES `%s`(`%s`)" % (ref_table, ref_col))

    if col["unique"]:
        pieces.append("UNIQUE")
    if col["not_null"]:
        pieces.append("NOT NULL")
    if col["has_default"]:
        dflt = col["default"]
        if col["name"] in TIMESTAMP_COLUMNS:
            pieces.append("DEFAULT CURRENT_TIMESTAMP")
        elif dflt is None:
            pieces.append("DEFAULT NULL")
        elif dflt.upper() == "NULL":
            pieces.append("DEFAULT NULL")
        elif re.match(r"^[\d.]+$", dflt):
            pieces.append("DEFAULT %s" % dflt)
        else:
            pieces.append("DEFAULT '%s'" % dflt.strip("'").replace("'", "''"))
    if col["check"]:
        pieces.append("CHECK (%s)" % col["check"])

    return "  " + " ".join(pieces)


def build_create_table(table_name, sql):
    inner = sql[sql.index("(") + 1: sql.rindex(")")]
    chunks = split_top_level(inner)
    columns = [parse_column(c) for c in chunks]
    columns = [c for c in columns if c]

    lines = ["CREATE TABLE `%s` (" % table_name]
    for i, col in enumerate(columns):
        comma = "," if i < len(columns) - 1 else ""
        lines.append(build_column_ddl(col, table_name) + comma)
    lines.append(");")
    return "\n".join(lines)


def mysql_quote(value):
    if value is None:
        return "NULL"
    s = str(value)
    s = s.replace("\\", "\\\\")
    s = s.replace("'", "''")
    return "'%s'" % s


def main():
    if len(sys.argv) < 2:
        print("usage: python sqlite-to-mysql.py <input.db> [output.sql]")
        return 1

    db_path = Path(sys.argv[1])
    out_path = Path(sys.argv[2]) if len(sys.argv) > 2 else db_path.with_suffix(".mysql.sql")

    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()

    tables = cur.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name"
    ).fetchall()
    table_names = [t[0] for t in tables]
    ordered = [t for t in TABLE_ORDER if t in table_names] + \
              [t for t in table_names if t not in TABLE_ORDER]

    out = []
    out.append("-- MySQL dump generated from SQLite database: %s" % db_path.name)
    out.append("-- Generated by script/sqlite-to-mysql.py")
    out.append("")
    out.append("CREATE DATABASE IF NOT EXISTS `sql_learn` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;")
    out.append("USE `sql_learn`;")
    out.append("SET NAMES utf8mb4;")
    out.append("SET FOREIGN_KEY_CHECKS=0;")
    out.append("")

    for table in ordered:
        sql = cur.execute(
            "SELECT sql FROM sqlite_master WHERE type='table' AND name=?", (table,)
        ).fetchone()[0]
        out.append("DROP TABLE IF EXISTS `%s`;" % table)
        out.append(build_create_table(table, sql))
        out.append("")

    out.append("-- Data")
    out.append("")

    row_counts = {}
    for table in ordered:
        cols = [r[1] for r in cur.execute("PRAGMA table_info(%s)" % table).fetchall()]
        rows = cur.execute("SELECT * FROM %s" % table).fetchall()
        row_counts[table] = len(rows)
        if not rows:
            out.append("-- %s: (empty)" % table)
            out.append("")
            continue
        col_sql = ", ".join("`%s`" % c for c in cols)
        out.append("INSERT INTO `%s` (%s) VALUES" % (table, col_sql))
        value_lines = []
        for row in rows:
            values = ", ".join(mysql_quote(v) for v in row)
            value_lines.append("(%s)" % values)
        out.append(",\n".join(value_lines) + ";")
        out.append("")

    out.append("SET FOREIGN_KEY_CHECKS=1;")
    out.append("")

    out_path.write_text("\n".join(out), encoding="utf-8")
    conn.close()

    print("Wrote %s" % out_path)
    print("Tables: %d | Rows: %d" % (len(ordered), sum(row_counts.values())))
    for t in ordered:
        print("  %-15s %d" % (t, row_counts[t]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
