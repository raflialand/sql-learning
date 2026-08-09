#!/usr/bin/env python3
"""
sql-skill-push dataset generator.

Generates three deterministic (seeded) datasets used by the sql-skill-push
challenge module:

  01-beginner      retail.sql   / retail.db      coffee shop chain
  02-intermediate  ecommerce.sql / ecommerce.db  e-commerce marketplace
  03-advanced      telecom.sql  / telecom.db     mobile telecom carrier

Each dataset is emitted twice:
  * a MySQL 8.x DDL + INSERT .sql file (for loading into MySQL)
  * a SQLite .db file (used locally to verify expected challenge results)

Re-running this script reproduces the exact same data.
"""

import os
import random
import sqlite3

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATASETS = os.path.join(ROOT, "datasets")

FIRST = ["John", "Sarah", "Michael", "Emily", "David", "Jessica", "James", "Amanda",
         "Robert", "Jennifer", "William", "Elizabeth", "Daniel", "Michelle", "Chris",
         "Ashley", "Matthew", "Nicole", "Anthony", "Laura", "Kevin", "Megan", "Brian",
         "Samantha", "George", "Rachel", "Edward", "Linda", "Paul", "Karen", "Steven",
         "Diana", "Mark", "Angela", "Charles", "Helen", "Joshua", "Maria", "Ryan",
         "Kimberly", "Jason", "Cynthia", "Justin", "Deborah", "Adam", "Stephanie",
         "Eric", "Rebecca", "Frank", "Melissa"]
LAST = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
        "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson",
        "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson",
        "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker",
        "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores",
        "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell",
        "Carter", "Roberts"]
CITIES = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia",
          "San Antonio", "San Diego", "Dallas", "San Jose", "Boston", "Denver",
          "Seattle", "Miami", "Atlanta", "Austin", "Portland", "Nashville"]
COUNTRIES = ["USA", "UK", "Canada", "Germany", "Australia", "France", "Netherlands"]
REGIONS = ["Northeast", "Southeast", "Midwest", "Southwest", "West"]


def date_between(rng, d1, d2):
    """Random date between two 'YYYY-MM-DD' strings (inclusive)."""
    y1, m1, dd1 = map(int, d1.split("-"))
    y2, m2, dd2 = map(int, d2.split("-"))
    start = __import__("datetime").date(y1, m1, dd1)
    end = __import__("datetime").date(y2, m2, dd2)
    days = (end - start).days
    return (start + __import__("datetime").timedelta(days=rng.randint(0, days))).isoformat()


def add_months(iso, n):
    import datetime as dt
    y, m, d = map(int, iso.split("-"))
    m += n
    y += (m - 1) // 12
    m = (m - 1) % 12 + 1
    day = min(d, [31, 29 if y % 4 == 0 and (y % 100 != 0 or y % 400 == 0) else 28,
                  31, 30, 31, 30, 31, 31, 30, 31, 30, 31][m - 1])
    return dt.date(y, m, day).isoformat()


def sql_fmt(v):
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return "1" if v else "0"
    if isinstance(v, int):
        return str(v)
    if isinstance(v, float):
        return f"{v:.2f}"
    return "'" + str(v).replace("'", "''") + "'"


def mysql_ddl(tables):
    lines = []
    for tname, (cols, _rows) in tables.items():
        parts = []
        for c in cols:
            name, mtype, _stype, pk = c
            s = f"    `{name}` {mtype}"
            if pk:
                s += " PRIMARY KEY"
            parts.append(s)
        lines.append(f"CREATE TABLE `{tname}` (\n" + ",\n".join(parts) + "\n);")
    return "\n\n".join(lines) + "\n"


def mysql_inserts(tables, batch=400):
    out = []
    for tname, (cols, rows) in tables.items():
        names = [f"`{c[0]}`" for c in cols]
        out.append(f"INSERT INTO `{tname}` ({', '.join(names)}) VALUES")
        for i in range(0, len(rows), batch):
            chunk = rows[i:i + batch]
            vals = ",\n".join("(" + ", ".join(sql_fmt(v) for v in r) + ")" for r in chunk)
            out.append(vals + (";" if i + batch >= len(rows) else ";"))
            if i + batch < len(rows):
                out.append(f"INSERT INTO `{tname}` ({', '.join(names)}) VALUES")
    return "\n".join(out) + "\n"


def write_mysql(dataset_dir, name, header, tables):
    path = os.path.join(dataset_dir, f"{name}.sql")
    content = (
        "-- =====================================================\n"
        f"-- sql-skill-push: {name} dataset (MySQL 8.x)\n"
        "-- Deterministic seed-generated data. Run as a single script.\n"
        "-- =====================================================\n\n"
        "SET FOREIGN_KEY_CHECKS = 0;\n"
        "DROP TABLE IF EXISTS "
        + ", ".join(f"`{t}`" for t in tables)
        + ";\n"
        "SET FOREIGN_KEY_CHECKS = 1;\n\n"
        "-- =====================================================\n"
        "-- BUSINESS CONTEXT (short)\n"
        f"-- {header}\n"
        "-- =====================================================\n\n"
        + mysql_ddl(tables)
        + "\n-- =====================================================\n-- DATA\n"
        "-- =====================================================\n\n"
        + mysql_inserts(tables)
    )
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"  wrote {os.path.relpath(path, ROOT)}")


def sqlite_ddl(cols):
    parts = []
    for c in cols:
        name, _mtype, stype, pk = c
        s = f"    {name} {stype}"
        if pk:
            s += " PRIMARY KEY"
        parts.append(s)
    return "(\n" + ",\n".join(parts) + "\n)"


def write_sqlite(dataset_dir, name, tables):
    path = os.path.join(dataset_dir, f"{name}.db")
    if os.path.exists(path):
        os.remove(path)
    con = sqlite3.connect(path)
    cur = con.cursor()
    for tname, (cols, rows) in tables.items():
        cur.execute(f"CREATE TABLE {tname} " + sqlite_ddl(cols))
        if rows:
            placeholders = ", ".join("?" for _ in cols)
            cur.executemany(
                f"INSERT INTO {tname} VALUES ({placeholders})",
                [tuple(r) for r in rows],
            )
    con.commit()
    con.close()
    print(f"  wrote {os.path.relpath(path, ROOT)}")


def emit(dataset_dir, name, header, tables):
    write_mysql(dataset_dir, name, header, tables)
    write_sqlite(dataset_dir, name, tables)


# ---------------------------------------------------------------
# LEVEL 1: BEGINNER - "Brew & Co." coffee shop chain
# ---------------------------------------------------------------
def gen_retail():
    rng = random.Random(101)
    products = []
    bev = [("Espresso", 2.95), ("Latte", 4.25), ("Cappuccino", 4.25), ("Mocha", 4.75),
           ("Cold Brew", 4.50), ("Americano", 3.25), ("Matcha Latte", 5.25),
           ("Chai Latte", 4.95), ("Hot Chocolate", 3.95), ("Iced Tea", 3.45)]
    food = [("Croissant", 3.50), ("Blueberry Muffin", 3.25), ("Everything Bagel", 2.75),
            ("Turkey Sandwich", 8.50), ("Chocolate Chip Cookie", 2.50), ("Cheesecake Slice", 5.75),
            ("Avocado Toast", 9.50), ("Buttermilk Pancakes", 7.95), ("Caesar Salad", 8.95),
            ("Yogurt Parfait", 5.50)]
    merch = [("Coffee Beans 250g", 14.00), ("Ceramic Mug", 12.00), ("Tumbler", 22.00),
             ("Pour-Over Kit", 29.00), ("French Press", 35.00), ("Tote Bag", 15.00),
             ("Travel Cup", 18.50), ("Gift Card", 25.00), ("Cold Brew Bottle", 4.00)]
    catalog = []
    for cat, pool in (("Beverage", bev), ("Food", food), ("Merchandise", merch)):
        for nm, price in pool:
            catalog.append((nm, cat, price, 1))
    catalog.append(("Seasonal Pumpkin Latte", "Beverage", 5.50, 0))
    catalog.append(("Limited Holiday Blend", "Beverage", 16.00, 0))
    products = [(f"PRD{i:03d}", nm, cat, round(p, 2), act)
                for i, (nm, cat, p, act) in enumerate(catalog, 1)]
    products_rows = products

    customers = []
    used_email = set()
    for i in range(1, 351):
        fn = rng.choice(FIRST)
        ln = rng.choice(LAST)
        email = f"{fn.lower()}.{ln.lower()}{rng.randint(1, 999)}@mail.com"
        while email in used_email:
            email = f"{fn.lower()}.{ln.lower()}{rng.randint(1, 999)}@mail.com"
        used_email.add(email)
        customers.append((
            f"CST{i:03d}", fn, ln, email, rng.choice(CITIES),
            date_between(rng, "2022-01-01", "2025-12-31"),
            rng.randint(0, 12000),
        ))

    stores = ["BRW001", "BRW002", "BRW003"]
    pay_methods = ["Cash", "Card", "Mobile Pay", "Cash", "Card", "Card"]
    order_count = 1200
    orders = []
    order_items = []
    item_id = 0
    for oid in range(1, order_count + 1):
        cid = rng.choice(customers)[0]
        od = date_between(rng, "2025-01-01", "2026-01-31")
        sid = rng.choice(stores)
        pm = rng.choice(pay_methods)
        if rng.random() < 0.03:
            pm = None
        n_items = rng.randint(1, 5)
        total = 0.0
        for _ in range(n_items):
            item_id += 1
            prod = rng.choice(products)
            qty = rng.randint(1, 3)
            up = prod[3]
            total += qty * up
            order_items.append((item_id, oid, prod[0], qty, round(up, 2)))
        orders.append((oid, od, cid, sid, pm, round(total, 2)))

    tables = {
        "products": (
            [("prod_id", "VARCHAR(6)", "TEXT", True),
             ("prod_name", "VARCHAR(60)", "TEXT", False),
             ("category", "VARCHAR(20)", "TEXT", False),
             ("unit_price", "DECIMAL(8,2)", "REAL", False),
             ("is_active", "TINYINT(1)", "INTEGER", False)],
            products_rows,
        ),        "customers": (
            [("cust_id", "VARCHAR(6)", "TEXT", True),
             ("first_name", "VARCHAR(30)", "TEXT", False),
             ("last_name", "VARCHAR(30)", "TEXT", False),
             ("email", "VARCHAR(80)", "TEXT", False),
             ("city", "VARCHAR(40)", "TEXT", False),
             ("signup_date", "DATE", "TEXT", False),
             ("loyalty_points", "INT", "INTEGER", False)],
            customers,
        ),
        "orders": (
            [("order_id", "INT", "INTEGER", True),
             ("order_date", "DATE", "TEXT", False),
             ("customer_id", "VARCHAR(6)", "TEXT", False),
             ("store_id", "VARCHAR(6)", "TEXT", False),
             ("payment_method", "VARCHAR(12)", "TEXT", False),
             ("total_amount", "DECIMAL(8,2)", "REAL", False)],
            orders,
        ),
        "order_items": (
            [("item_id", "INT", "INTEGER", True),
             ("order_id", "INT", "INTEGER", False),
             ("product_id", "VARCHAR(6)", "TEXT", False),
             ("quantity", "INT", "INTEGER", False),
             ("unit_price", "DECIMAL(8,2)", "REAL", False)],
            order_items,
        ),
    }
    return tables


# ---------------------------------------------------------------
# LEVEL 2: INTERMEDIATE - online marketplace
# ---------------------------------------------------------------
def gen_ecommerce():
    rng = random.Random(202)
    cats = [
        ("CAT001", "Electronics", None), ("CAT002", "Clothing", None),
        ("CAT003", "Home & Kitchen", None), ("CAT004", "Sports & Outdoors", None),
        ("CAT005", "Books & Media", None), ("CAT006", "Beauty & Health", None),
        ("CAT007", "Toys & Games", None), ("CAT008", "Automotive", None),
        ("CAT009", "Smartphones", "CAT001"), ("CAT010", "Laptops", "CAT001"),
        ("CAT011", "Headphones", "CAT001"), ("CAT012", "Men's Clothing", "CAT002"),
        ("CAT013", "Women's Clothing", "CAT002"), ("CAT014", "Kitchen Appliances", "CAT003"),
        ("CAT015", "Furniture", "CAT003"), ("CAT016", "Fitness", "CAT004"),
    ]
    vendors = []
    vn = ["TechSource", "Global Goods", "Prime Supply", "Evergreen", "Nordic Craft",
          "Pacific Imports", "Sunrise Trading", "Atlas Wholesale", "Metro Distributors",
          "Cedar & Co", "Vista Market", "Summit Brands", "Harbor Trade", "Ivy Commerce"]
    for i, name in enumerate(vn, 1):
        vendors.append((f"VEN{i:03d}", name, rng.choice(COUNTRIES)))

    products = []
    active_cats = [c[0] for c in cats if c[2] is not None]
    for i in range(1, 121):
        cat = rng.choice(active_cats)
        ven = rng.choice(vendors)[0]
        price = round(rng.uniform(5, 1200), 2)
        cost = round(price * rng.uniform(0.45, 0.75), 2)
        active = 1 if rng.random() < 0.92 else 0
        products.append((
            f"PRD{i:03d}", f"Product {i} {rng.choice(['Pro', 'Lite', 'Max', 'Plus', 'Mini'])}",
            cat, ven, price, cost, active,
        ))

    customers = []
    used_email = set()
    for i in range(1, 501):
        fn = rng.choice(FIRST)
        ln = rng.choice(LAST)
        email = f"{fn.lower()}{ln.lower()}{rng.randint(1, 9999)}@mail.com"
        while email in used_email:
            email = f"{fn.lower()}{ln.lower()}{rng.randint(1, 9999)}@mail.com"
        used_email.add(email)
        customers.append((
            f"CST{i:04d}", fn, ln, email, rng.choice(CITIES), rng.choice(COUNTRIES),
            date_between(rng, "2022-01-01", "2025-12-31"),
        ))

    statuses = ["Completed", "Completed", "Completed", "Shipped", "Pending", "Cancelled"]
    carriers = ["UPS", "FedEx", "DHL", "USPS"]
    pay_methods = ["Card", "Card", "PayPal", "Bank Transfer", "COD"]
    pay_statuses = ["Paid", "Paid", "Paid", "Refunded", "Failed"]

    orders = []
    order_items = []
    payments = []
    shipments = []
    item_id = 0
    pay_id = 0
    ship_id = 0
    for oid in range(1, 2801):
        od = date_between(rng, "2025-01-01", "2026-01-31")
        cid = rng.choice(customers)[0]
        status = rng.choice(statuses)
        n_items = rng.randint(1, 4)
        total = 0.0
        for _ in range(n_items):
            item_id += 1
            prod = rng.choice(products)
            qty = rng.randint(1, 3)
            up = prod[4]
            total += qty * up
            order_items.append((item_id, oid, prod[0], qty, round(up, 2)))
        total = round(total, 2)
        orders.append((oid, od, cid, status, total))
        if status != "Cancelled" and rng.random() < 0.97:
            pay_id += 1
            method = rng.choice(pay_methods)
            pstatus = rng.choice(pay_statuses)
            paid_date = add_months(od, 0)
            paid_date = od if pstatus != "Paid" else date_between(rng, od, add_months(od, 1))
            payments.append((pay_id, oid, method, total, pstatus, paid_date))
        if status in ("Completed", "Shipped"):
            ship_id += 1
            ship_date = date_between(rng, od, add_months(od, 1))
            delivery = None
            if rng.random() < 0.95:
                delivery = date_between(rng, ship_date, add_months(ship_date, 1))
            shipments.append((
                ship_id, oid, rng.choice(carriers), ship_date, delivery,
                f"{rng.randint(100, 9999)} {rng.choice(['Main St', 'Oak Ave', 'Maple Dr', 'Lake Rd', 'Hill St'])}",
            ))

    tables = {
        "categories": (
            [("cat_id", "VARCHAR(6)", "TEXT", True),
             ("cat_name", "VARCHAR(40)", "TEXT", False),
             ("parent_cat_id", "VARCHAR(6)", "TEXT", False)],
            cats,
        ),
        "vendors": (
            [("vendor_id", "VARCHAR(6)", "TEXT", True),
             ("vendor_name", "VARCHAR(40)", "TEXT", False),
             ("country", "VARCHAR(30)", "TEXT", False)],
            vendors,
        ),
        "products": (
            [("prod_id", "VARCHAR(6)", "TEXT", True),
             ("prod_name", "VARCHAR(60)", "TEXT", False),
             ("cat_id", "VARCHAR(6)", "TEXT", False),
             ("vendor_id", "VARCHAR(6)", "TEXT", False),
             ("unit_price", "DECIMAL(10,2)", "REAL", False),
             ("cost", "DECIMAL(10,2)", "REAL", False),
             ("is_active", "TINYINT(1)", "INTEGER", False)],
            products,
        ),
        "customers": (
            [("cust_id", "VARCHAR(7)", "TEXT", True),
             ("first_name", "VARCHAR(30)", "TEXT", False),
             ("last_name", "VARCHAR(30)", "TEXT", False),
             ("email", "VARCHAR(80)", "TEXT", False),
             ("city", "VARCHAR(40)", "TEXT", False),
             ("country", "VARCHAR(30)", "TEXT", False),
             ("signup_date", "DATE", "TEXT", False)],
            customers,
        ),
        "orders": (
            [("order_id", "INT", "INTEGER", True),
             ("order_date", "DATE", "TEXT", False),
             ("customer_id", "VARCHAR(7)", "TEXT", False),
             ("status", "VARCHAR(15)", "TEXT", False),
             ("total_amount", "DECIMAL(10,2)", "REAL", False)],
            orders,
        ),
        "order_items": (
            [("item_id", "INT", "INTEGER", True),
             ("order_id", "INT", "INTEGER", False),
             ("product_id", "VARCHAR(6)", "TEXT", False),
             ("quantity", "INT", "INTEGER", False),
             ("unit_price", "DECIMAL(10,2)", "REAL", False)],
            order_items,
        ),
        "payments": (
            [("payment_id", "INT", "INTEGER", True),
             ("order_id", "INT", "INTEGER", False),
             ("method", "VARCHAR(20)", "TEXT", False),
             ("amount", "DECIMAL(10,2)", "REAL", False),
             ("status", "VARCHAR(10)", "TEXT", False),
             ("paid_date", "DATE", "TEXT", False)],
            payments,
        ),
        "shipments": (
            [("shipment_id", "INT", "INTEGER", True),
             ("order_id", "INT", "INTEGER", False),
             ("carrier", "VARCHAR(10)", "TEXT", False),
             ("ship_date", "DATE", "TEXT", False),
             ("delivery_date", "DATE", "TEXT", False),
             ("address", "VARCHAR(80)", "TEXT", False)],
            shipments,
        ),
    }
    return tables


# ---------------------------------------------------------------
# LEVEL 3: ADVANCED - mobile telecom carrier
# ---------------------------------------------------------------
def gen_telecom():
    rng = random.Random(303)
    plans = [
        ("PL001", "Starter", 20.00, 5, 100),
        ("PL002", "Standard", 35.00, 15, 300),
        ("PL003", "Plus", 50.00, 30, 600),
        ("PL004", "Premium", 70.00, 60, 1200),
        ("PL005", "Family", 90.00, 120, 2000),
        ("PL006", "Unlimited Max", 120.00, 1000, 3000),
    ]
    plan_ids = [p[0] for p in plans]
    plan_weights = [0.25, 0.28, 0.20, 0.14, 0.09, 0.04]

    subscribers = []
    used_phone = set()
    for i in range(1, 4501):
        fn = rng.choice(FIRST)
        ln = rng.choice(LAST)
        phone = f"555-{rng.randint(100000, 999999)}"
        while phone in used_phone:
            phone = f"555-{rng.randint(100000, 999999)}"
        used_phone.add(phone)
        plan = rng.choices(plan_ids, weights=plan_weights)[0]
        status = rng.choices(["Active", "Active", "Active", "Suspended", "Cancelled"],
                             weights=[0.55, 0.25, 0.02, 0.08, 0.10])[0]
        subscribers.append((
            i, fn, ln, phone, plan, rng.choice(REGIONS),
            date_between(rng, "2021-01-01", "2025-09-30"), status,
        ))
    fee = {p[0]: p[2] for p in plans}

    billing = []
    payments = []
    usage_logs = []
    bill_id = 0
    pay_id = 0
    log_id = 0
    periods = [("2025-12-01", "2025-12-31", "2025-12-01"),
               ("2026-01-01", "2026-01-31", "2026-01-01")]
    for sub in subscribers:
        sub_id, fn, ln, phone, plan, region, signup, status = sub
        if status == "Cancelled":
            n_periods = 1 if rng.random() < 0.5 else 0
        else:
            n_periods = 2 if status == "Active" else 1
        for pi in range(n_periods):
            pstart, pend, bdate = periods[pi]
            if signup > pstart:
                continue
            bill_id += 1
            amount = fee[plan]
            bstatus = rng.choices(["Paid", "Unpaid", "Overdue"], weights=[0.82, 0.10, 0.08])[0]
            billing.append((bill_id, sub_id, bdate, pstart, pend, amount, bstatus))
            if bstatus == "Paid":
                pay_id += 1
                pdate = date_between(rng, bdate, add_months(bdate, 1))
                method = rng.choice(["Auto-Pay", "Card", "Card", "Bank Transfer", "Wallet"])
                payments.append((pay_id, sub_id, bill_id, pdate, amount, method))
            if status == "Active":
                log_id += 1
                usage_logs.append((
                    log_id, sub_id, date_between(rng, pstart, pend),
                    rng.randint(0, 30000), rng.randint(0, 1500), rng.randint(0, 300),
                ))

    tickets = []
    tcats = ["Billing", "Technical", "Network", "Account", "Device"]
    tstatus = ["Open", "Open", "Resolved", "Resolved", "Closed", "Closed"]
    for i in range(1, 3801):
        sub = rng.choice(subscribers)
        created = date_between(rng, "2025-06-01", "2026-01-31")
        resolved = None
        if rng.random() < 0.7:
            resolved = date_between(rng, created, add_months(created, 2))
        tickets.append((
            i, sub[0], created, resolved, rng.choice(tcats), rng.choice(tstatus),
        ))

    churn = []
    reasons = ["Price", "Coverage", "Service Quality", "Moving", "Competitor Offer", "Other"]
    churn_candidates = [s for s in subscribers if s[7] == "Cancelled"]
    for i, sub in enumerate(churn_candidates[:450], 1):
        churn.append((
            i, sub[0], date_between(rng, "2025-06-01", "2025-12-31"), rng.choice(reasons),
        ))

    tables = {
        "plans": (
            [("plan_id", "VARCHAR(6)", "TEXT", True),
             ("plan_name", "VARCHAR(20)", "TEXT", False),
             ("monthly_fee", "DECIMAL(8,2)", "REAL", False),
             ("data_gb", "INT", "INTEGER", False),
             ("voice_min", "INT", "INTEGER", False)],
            plans,
        ),
        "subscribers": (
            [("sub_id", "INT", "INTEGER", True),
             ("first_name", "VARCHAR(30)", "TEXT", False),
             ("last_name", "VARCHAR(30)", "TEXT", False),
             ("phone", "VARCHAR(15)", "TEXT", False),
             ("plan_id", "VARCHAR(6)", "TEXT", False),
             ("region", "VARCHAR(15)", "TEXT", False),
             ("signup_date", "DATE", "TEXT", False),
             ("status", "VARCHAR(12)", "TEXT", False)],
            subscribers,
        ),
        "billing": (
            [("bill_id", "INT", "INTEGER", True),
             ("sub_id", "INT", "INTEGER", False),
             ("bill_date", "DATE", "TEXT", False),
             ("period_start", "DATE", "TEXT", False),
             ("period_end", "DATE", "TEXT", False),
             ("amount", "DECIMAL(8,2)", "REAL", False),
             ("status", "VARCHAR(10)", "TEXT", False)],
            billing,
        ),
        "payments": (
            [("pay_id", "INT", "INTEGER", True),
             ("sub_id", "INT", "INTEGER", False),
             ("bill_id", "INT", "INTEGER", False),
             ("pay_date", "DATE", "TEXT", False),
             ("amount", "DECIMAL(8,2)", "REAL", False),
             ("method", "VARCHAR(15)", "TEXT", False)],
            payments,
        ),
        "usage_logs": (
            [("log_id", "INT", "INTEGER", True),
             ("sub_id", "INT", "INTEGER", False),
             ("log_date", "DATE", "TEXT", False),
             ("data_mb", "INT", "INTEGER", False),
             ("voice_min", "INT", "INTEGER", False),
             ("sms", "INT", "INTEGER", False)],
            usage_logs,
        ),
        "tickets": (
            [("ticket_id", "INT", "INTEGER", True),
             ("sub_id", "INT", "INTEGER", False),
             ("created_date", "DATE", "TEXT", False),
             ("resolved_date", "DATE", "TEXT", False),
             ("category", "VARCHAR(15)", "TEXT", False),
             ("status", "VARCHAR(10)", "TEXT", False)],
            tickets,
        ),
        "churn": (
            [("churn_id", "INT", "INTEGER", True),
             ("sub_id", "INT", "INTEGER", False),
             ("churn_date", "DATE", "TEXT", False),
             ("reason", "VARCHAR(25)", "TEXT", False)],
            churn,
        ),
    }
    return tables


def main():
    datasets = [
        ("01-beginner", "retail",
         "Brew & Co., a 3-branch coffee shop chain. Tables: products, customers, orders, order_items.",
         gen_retail),
        ("02-intermediate", "ecommerce",
         "An online marketplace. Tables: categories, vendors, products, customers, orders, order_items, payments, shipments.",
         gen_ecommerce),
        ("03-advanced", "telecom",
         "A mobile telecom carrier. Tables: plans, subscribers, billing, payments, usage_logs, tickets, churn.",
         gen_telecom),
    ]
    for sub, name, header, gen in datasets:
        d = os.path.join(DATASETS, sub)
        print(f"== generating {name} ==")
        emit(d, name, header, gen())
    print("done.")


if __name__ == "__main__":
    main()
