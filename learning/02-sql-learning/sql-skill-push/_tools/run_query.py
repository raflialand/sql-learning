#!/usr/bin/env python3
"""
sql-skill-push verification helper.

Runs a solution SQL file against one of the generated SQLite databases and
prints the result as a markdown preview (first N rows + total count), the same
format used in challenges.md "expected result" blocks.

Usage:
  python run_query.py <db-path> <solution-file> [max_rows]
"""

import sqlite3
import sys


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    db_path = sys.argv[1]
    sql_path = sys.argv[2]
    max_rows = int(sys.argv[3]) if len(sys.argv) > 3 else 10

    with open(sql_path, encoding="utf-8") as f:
        sql = f.read()

    con = sqlite3.connect(db_path)
    cur = con.cursor()
    try:
        cur.execute(sql)
    except sqlite3.Error as e:
        print("SQL ERROR:", e)
        sys.exit(2)

    cols = [d[0] for d in cur.description]
    rows = cur.fetchall()
    total = len(rows)
    preview = rows[:max_rows]

    print("| " + " | ".join(cols) + " |")
    print("| " + " | ".join("---" for _ in cols) + " |")
    for r in preview:
        print("| " + " | ".join(_fmt(v) for v in r) + " |")
    if total > max_rows:
        print(f"\n({total} rows total; {max_rows} shown)")
    else:
        print(f"\n({total} rows)")

    con.close()


def _fmt(v):
    if v is None:
        return "NULL"
    if isinstance(v, float):
        return f"{v:.2f}"
    return str(v)


if __name__ == "__main__":
    main()
