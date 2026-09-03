#!/usr/bin/env python3
"""
Bookstore Dataset Generator - Mid-Level Messiness
Generates a comprehensive bookstore dataset with intentional data quality issues.
"""

import sqlite3
import random
import string
import os
from datetime import datetime, timedelta, date
from faker import Faker
from pathlib import Path

fake = Faker()
random.seed(42)
Faker.seed(42)

# ============================================================
# CONFIGURATION
# ============================================================
OUTPUT_DIR = Path(__file__).parent
DB_FILE = OUTPUT_DIR / "bookstore.db"
SQL_FILE = OUTPUT_DIR / "bookstore.sql"

# Row counts
NUM_PUBLISHERS = 25
NUM_AUTHORS = 120
NUM_CATEGORIES = 30
NUM_BOOKS = 500
NUM_CUSTOMERS = 1200
NUM_STORES = 8
NUM_ORDERS = 6500  # ~2 years of orders
NUM_REVIEWS = 2500
NUM_PROMOTIONS = 40
NUM_EMPLOYEES = 65

# Date range: 2 years (2024-09 to 2026-08)
DATE_START = date(2024, 9, 1)
DATE_END = date(2026, 8, 31)

# ============================================================
# HELPER FUNCTIONS
# ============================================================

def random_date(start=DATE_START, end=DATE_END):
    """Generate a random date between start and end."""
    delta = (end - start).days
    return start + timedelta(days=random.randint(0, delta))

def random_datetime(start=DATE_START, end=DATE_END):
    """Generate a random datetime between start and end."""
    d = random_date(start, end)
    h = random.randint(8, 22)
    m = random.randint(0, 59)
    s = random.randint(0, 59)
    return datetime(d.year, d.month, d.day, h, m, s)

def random_past_datetime(years_back=3):
    """Generate a random datetime in the past."""
    start = date.today() - timedelta(days=years_back*365)
    return random_datetime(start, date.today())

def random_price(min_p=4.99, max_p=89.99):
    return round(random.uniform(min_p, max_p), 2)

def random_isbn13():
    prefix = random.choice(["978", "979"])
    group = str(random.randint(0, 9))
    publisher = str(random.randint(100, 999))
    title = str(random.randint(10000, 99999))
    check = str(random.randint(0, 9))
    return prefix + group + publisher + title + check

def random_isbn10():
    digits = [str(random.randint(0, 9)) for _ in range(9)]
    check = random.choice(string.digits)
    return "".join(digits) + check

def maybe_null(value, probability=0.07):
    """Return None with given probability (for NULL injection)."""
    if random.random() < probability:
        return None
    return value

def maybe_dirty_text(value, dirty_funcs):
    """Apply random dirty transformation to text."""
    if value is None:
        return None
    if random.random() < 0.15:  # 15% chance of dirty text
        func = random.choice(dirty_funcs)
        return func(value)
    return value

def dirty_whitespace(s):
    """Add leading/trailing whitespace."""
    if s is None:
        return None
    prefix = " " if random.random() < 0.5 else ""
    suffix = " " if random.random() < 0.5 else ""
    return prefix + s + suffix

def dirty_double_space(s):
    """Add extra internal spaces."""
    if s is None:
        return None
    words = s.split()
    if len(words) > 1:
        idx = random.randint(0, len(words)-2)
        words.insert(idx+1, "")
    return " ".join(words)

def dirty_case(s):
    """Randomly change case."""
    if s is None:
        return None
    if isinstance(s, bool):
        return s
    r = random.random()
    if r < 0.33:
        return s.upper()
    elif r < 0.66:
        return s.lower()
    return s

def dirty_wrong_type(s):
    """Embed wrong data type in text (e.g. 'N/A')."""
    if s is None:
        return None
    wrong_vals = ["N/A", "n/a", "NA", "-", "--", "NULL", "null", "undefined", "TBD", "0", "999", "missing", "MISSING"]
    return random.choice(wrong_vals)

def dirty_date_format(d):
    """Convert date to inconsistent string formats."""
    if d is None:
        return None
    formats = [
        "%Y-%m-%d",
        "%m/%d/%Y",
        "%d-%m-%Y",
        "%m-%d-%Y",
        "%Y/%m/%d",
        "%B %d, %Y",
        "%b %d, %Y",
    ]
    fmt = random.choice(formats)
    if isinstance(d, datetime):
        return d.strftime(fmt)
    elif isinstance(d, date):
        return datetime(d.year, d.month, d.day).strftime(fmt)
    return str(d)

def format_date_clean(d):
    """Clean date format for PostgreSQL (YYYY-MM-DD or timestamp)."""
    if d is None:
        return None
    if isinstance(d, datetime):
        return d.strftime("%Y-%m-%d %H:%M:%S")
    elif isinstance(d, date):
        return d.strftime("%Y-%m-%d")
    return str(d)

def format_date_dirty(d):
    """Apply inconsistent date formatting for mid-level messiness."""
    if d is None:
        return None
    if random.random() < 0.35:  # 35% of dates get dirty formatting
        return dirty_date_format(d)
    return format_date_clean(d)

def escape_sql(val):
    """Escape a value for SQL INSERT."""
    if val is None:
        return "NULL"
    if isinstance(val, bool):
        return "TRUE" if val else "FALSE"
    if isinstance(val, (int, float)):
        return str(val)
    s = str(val)
    s = s.replace("'", "''")
    return f"'{s}'"

def generate_phone():
    area = random.randint(200, 999)
    p1 = random.randint(200, 999)
    p2 = random.randint(1000, 9999)
    formats = [
        f"({area}) {p1}-{p2}",
        f"{area}-{p1}-{p2}",
        f"{area}.{p1}.{p2}",
        f"+1-{area}-{p1}-{p2}",
        f"{area}{p1}{p2}",
    ]
    return random.choice(formats)

def generate_loyalty_number():
    prefix = random.choice(["LOY", "Loy", "loy", "LOYALTY"])
    num = random.randint(100000, 999999)
    return f"{prefix}-{num}"

def generate_employee_id():
    prefix = random.choice(["EMP", "Emp", "emp", "STF", "Stf"])
    num = random.randint(1000, 9999)
    return f"{prefix}-{num}"

# ============================================================
# DATA GENERATION
# ============================================================

print("Generating publishers...")
publishers = []
publisher_names = [
    "Penguin Random House", "HarperCollins", "Simon & Schuster",
    "Hachette Book Group", "Macmillan Publishers", "Scholastic",
    "Wiley", "Oxford University Press", "Cambridge University Press",
    "Springer", "Elsevier", "Taylor & Francis", "Bloomsbury",
    "Abrams Books", "Chronicle Books", "Workman Publishing",
    "Candlewick Press", "Graywolf Press", "Counterpoint Press",
    "Europa Editions", "Grove Atlantic", "Melville House",
    "Coffee House Press", "Tin House Books", "McSweeney's"
]
publisher_countries = ["US", "UK", "Canada", "Australia", "Germany", "France", "India", None]
for i in range(NUM_PUBLISHERS):
    if i < len(publisher_names):
        name = publisher_names[i]
    else:
        name = fake.company() + " Publishing"
    publishers.append({
        "id": i + 1,
        "name": maybe_dirty_text(name, [dirty_whitespace, dirty_case]),
        "country": maybe_dirty_text(random.choice(publisher_countries), [dirty_case, dirty_whitespace]),
        "founded_year": maybe_null(random.randint(1800, 2020), 0.08),
        "website": maybe_dirty_text(fake.url(), [dirty_whitespace]),
        "email": maybe_dirty_text(fake.company_email(), [dirty_case, dirty_whitespace]),
        "phone": maybe_dirty_text(generate_phone(), [dirty_whitespace]),
        "created_at": format_date_clean(random_past_datetime(3)),
    })

print("Generating authors...")
authors = []
first_names = [
    "James", "Mary", "Robert", "Patricia", "John", "Jennifer", "Michael", "Linda",
    "David", "Elizabeth", "William", "Barbara", "Richard", "Susan", "Joseph", "Jessica",
    "Thomas", "Sarah", "Christopher", "Karen", "Charles", "Lisa", "Daniel", "Nancy",
    "Matthew", "Betty", "Anthony", "Margaret", "Mark", "Sandra", "Steven", "Ashley",
    "Paul", "Emily", "Andrew", "Donna", "Joshua", "Michelle", "Kenneth", "Carol",
    "Aisha", "Yuki", "Chen", "Raj", "Fatima", "Olga", "Miguel", "Sophia",
    "Liam", "Emma", "Noah", "Olivia", "Ethan", "Ava", "Mason", "Isabella",
    "Lucas", "Mia", "Alexander", "Charlotte", "Sebastian", "Amelia", "Benjamin", "Harper",
]
last_names = [
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
    "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson",
    "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson",
    "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker",
    "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores",
    "Chen", "Patel", "Kim", "Tanaka", "Müller", "Petrov", "Silva", "Singh",
    "Nakamura", "Dubois", "Sato", "Ivanov", "Johansson", "Ali", "Fernandez", "Wang",
]
nationalities = ["American", "British", "Canadian", "Australian", "Indian", "Japanese",
                 "French", "German", "Spanish", "Italian", "Brazilian", "Nigerian", "Korean",
                 "Chinese", "Russian", "Swedish", "Dutch", "Mexican", "Irish", None]

for i in range(NUM_AUTHORS):
    fn = random.choice(first_names)
    ln = random.choice(last_names)
    bio_words = random.randint(10, 40)
    authors.append({
        "id": i + 1,
        "first_name": maybe_dirty_text(fn, [dirty_case, dirty_whitespace]),
        "last_name": maybe_dirty_text(ln, [dirty_case, dirty_whitespace]),
        "email": maybe_dirty_text(f"{fn.lower()}.{ln.lower()}@{fake.free_email_domain()}", [dirty_case, dirty_whitespace]),
        "nationality": maybe_dirty_text(random.choice(nationalities), [dirty_case, dirty_whitespace]),
        "birth_date": maybe_null(format_date_clean(random_date(date(1930,1,1), date(2000,12,31))), 0.25),
        "biography": maybe_dirty_text(fake.text(max_nb_chars=300), [dirty_whitespace]),
        "website": maybe_dirty_text(fake.url(), [dirty_whitespace]),
        "created_at": format_date_clean(random_past_datetime(3)),
    })

print("Generating categories...")
categories = []
category_data = [
    ("Fiction", None), ("Non-Fiction", None), ("Mystery", "Fiction"),
    ("Science Fiction", "Fiction"), ("Fantasy", "Fiction"), ("Romance", "Fiction"),
    ("Thriller", "Fiction"), ("Horror", "Fiction"), ("Historical Fiction", "Fiction"),
    ("Literary Fiction", "Fiction"), ("Biography", "Non-Fiction"),
    ("Autobiography", "Non-Fiction"), ("History", "Non-Fiction"),
    ("Science", "Non-Fiction"), ("Technology", "Non-Fiction"),
    ("Self-Help", "Non-Fiction"), ("Business", "Non-Fiction"),
    ("Cooking", "Non-Fiction"), ("Travel", "Non-Fiction"),
    ("Poetry", "Fiction"), ("Children's Books", None),
    ("Young Adult", None), ("Graphic Novels", None),
    ("Comics", None), ("Academic", None),
    ("Reference", None), ("Art & Photography", None),
    ("Health & Fitness", "Non-Fiction"), ("Philosophy", "Non-Fiction"),
    ("Religion & Spirituality", "Non-Fiction"),
]
for i, (name, parent) in enumerate(category_data):
    categories.append({
        "id": i + 1,
        "name": maybe_dirty_text(name, [dirty_case, dirty_whitespace]),
        "description": maybe_dirty_text(fake.sentence(nb_words=8), [dirty_whitespace]),
        "parent_category_id": maybe_null(next((c["id"] for c in categories if c["name"] == parent), None), 0.05),
        "created_at": format_date_clean(random_past_datetime(3)),
    })

print("Generating books...")
books = []
book_titles = [
    "The Great Gatsby", "To Kill a Mockingbird", "1984", "Pride and Prejudice",
    "The Catcher in the Rye", "The Hobbit", "Fahrenheit 451", "Jane Eyre",
    "Wuthering Heights", "The Lord of the Rings", "Animal Farm", "Brave New World",
    "The Alchemist", "One Hundred Years of Solitude", "The Kite Runner",
    "Life of Pi", "The Book Thief", "The Shadow of the Wind", "Cloud Atlas",
    "The Night Circus", "Where the Wild Things Are", "Goodnight Moon",
    "The Very Hungry Caterpillar", "Charlotte's Web", "Harry Potter and the Sorcerer's Stone",
    "A Game of Thrones", "The Hunger Games", "Divergent", "The Maze Runner",
    "Ender's Game", "Dune", "Neuromancer", "The Hitchhiker's Guide to the Galaxy",
    "Foundation", "Snow Crash", "The Name of the Wind", "American Gods",
    "The Handmaid's Tale", "The Color Purple", "Beloved", "Invisible Man",
    "The Sun Also Rises", "A Farewell to Arms", "Old Man and the Sea",
    "Crime and Punishment", "War and Peace", "Anna Karenina", "Don Quixote",
    "The Odyssey", "The Iliad", "Les Miserables", "The Count of Monte Cristo",
    "Frankenstein", "Dracula", "The Strange Case of Dr. Jekyll and Mr. Hyde",
    "Sherlock Holmes: A Study in Scarlet", "The Murders in the Rue Morgue",
    "And Then There Were None", "Murder on the Orient Express",
    "The Big Sleep", "The Maltese Falcon", "Rebecca", "Gone Girl",
    "The Girl with the Dragon Tattoo", "The Da Vinci Code", "Angels & Demons",
    "The Silence of the Lambs", "It", "The Shining", "Dr. Sleep",
    "The Stand", "Misery", "Carrie", "Cujo",
    "A Brief History of Time", "Sapiens", "Thinking, Fast and Slow",
    "The Power of Habit", "Atomic Habits", "Deep Work", "Range",
    "Outliers", "The Lean Startup", "Zero to One",
    "Rich Dad Poor Dad", "The Intelligent Investor", "Think and Grow Rich",
    "How to Win Friends and Influence People", "The 7 Habits of Highly Effective People",
    "Mindset", "Grit", "The Subtle Art of Not Giving a F*ck",
    "Educated", "Becoming", "A Promised Land", "Born a Crime",
    "The Diary of a Young Girl", "Long Walk to Freedom", "Steve Jobs",
    "Leonardo da Vinci", "Einstein", "Churchill",
    "Guns, Germs, and Steel", "The Silk Roads", "SPQR",
    "The Splendid and the Vile", "The Wright Brothers", "Team of Rivals",
    "The Color of Law", "Between the World and Me", "Caste",
    "The Sixth Extinction", "Silent Spring", "The Origin of Species",
    "Cosmos", "The Elegant Universe", "A Short History of Nearly Everything",
    "The Disappearing Spoon", "Stiff", "Salt", "Cooked",
    "Kitchen Confidential", "The Joy of Cooking", "Mastering the Art of French Cooking",
    "Plenty", "Salt Fat Acid Heat", "The Food Lab",
    "On the Road", "Eat Pray Love", "Wild", "Into the Wild",
    "A Walk in the Woods", "In a Sunburned Country", "The Art of Travel",
    "The Geography of Bliss", "Vagabonding", "Turn Right at Machu Picchu",
    "Meditations", "The Republic", "Beyond Good and Evil",
    "The Art of War", "The Tao of Pooh", "Siddhartha",
    "The Prophet", "Man's Search for Meaning", "The Nicomachean Ethics",
    "The Brothers Karamazov", "Les Fleurs du Mal", "Leaves of Grass",
    "The Waste Land", "Paradise Lost", "The Divine Comedy",
    "Sonnets from the Portuguese", "Ariel", "The Bell Jar",
    "Call Me by Your Name", "Normal People", "The Great Believers",
    "Red, White & Royal Blue", "Beach Read", "The Hating Game",
]
subtitles = [
    "A Novel", "A Memoir", "A Story of", "Tales from",
    "The Illustrated Edition", "Anniversary Edition", "Revised Edition",
    "Updated and Expanded", "A Graphic Adaptation", None, None, None,
]
languages = ["English", "English", "English", "English", "English", "Spanish",
             "French", "German", "Japanese", "Portuguese", "Italian", "Chinese"]
editions = ["1st Edition", "2nd Edition", "3rd Edition", "Reprint", "Paperback",
            "Hardcover", "Deluxe Edition", "Collector's Edition", None, None]

for i in range(NUM_BOOKS):
    if i < len(book_titles):
        title = book_titles[i]
    else:
        title = fake.catch_phrase().title()
    subtitle = random.choice(subtitles)
    if subtitle and random.random() < 0.3:
        subtitle = None
    pub_date = random_date(date(1920,1,1), DATE_END)
    pages = random.randint(80, 1200)
    price = random_price(5.99, 59.99)
    list_price = round(price * random.uniform(1.0, 1.3), 2)
    books.append({
        "id": i + 1,
        "isbn13": random_isbn13(),
        "isbn10": maybe_null(random_isbn10(), 0.15),
        "title": maybe_dirty_text(title, [dirty_case, dirty_whitespace, dirty_double_space]),
        "subtitle": maybe_dirty_text(subtitle, [dirty_whitespace]),
        "publication_date": format_date_dirty(pub_date),
        "pages": maybe_null(pages, 0.08),
        "language": maybe_dirty_text(random.choice(languages), [dirty_case]),
        "price": maybe_dirty_text(price, [dirty_wrong_type]),
        "list_price": maybe_dirty_text(list_price, [dirty_wrong_type]),
        "edition": maybe_dirty_text(random.choice(editions), [dirty_case, dirty_whitespace]),
        "description": maybe_dirty_text(fake.text(max_nb_chars=200), [dirty_whitespace]),
        "publisher_id": maybe_null(random.randint(1, NUM_PUBLISHERS), 0.10),
        "category_id": maybe_null(random.randint(1, NUM_CATEGORIES), 0.12),
        "created_at": format_date_clean(random_past_datetime(3)),
    })

print("Generating book_author relationships...")
book_authors = []
for book_id in range(1, NUM_BOOKS + 1):
    num_authors = random.choices([1, 2, 3], weights=[0.6, 0.3, 0.1])[0]
    author_ids = random.sample(range(1, NUM_AUTHORS + 1), num_authors)
    for order, author_id in enumerate(author_ids, 1):
        book_authors.append({
            "book_id": book_id,
            "author_id": author_id,
            "author_order": order,
        })

print("Generating customers...")
customers = []
customer_segments = ["Regular", "VIP", "Wholesale", "New", "Inactive", None]
for i in range(NUM_CUSTOMERS):
    fn = fake.first_name()
    ln = fake.last_name()
    customers.append({
        "id": i + 1,
        "first_name": maybe_dirty_text(fn, [dirty_case, dirty_whitespace]),
        "last_name": maybe_dirty_text(ln, [dirty_case, dirty_whitespace]),
        "email": maybe_dirty_text(fake.email(), [dirty_case, dirty_whitespace]),
        "phone": maybe_dirty_text(generate_phone(), [dirty_whitespace]),
        "address_line1": maybe_dirty_text(fake.street_address(), [dirty_whitespace]),
        "address_line2": maybe_null(fake.secondary_address(), 0.60),
        "city": maybe_dirty_text(fake.city(), [dirty_case, dirty_whitespace]),
        "state": maybe_dirty_text(fake.state_abbr(), [dirty_case]),
        "postal_code": maybe_dirty_text(fake.zipcode(), [dirty_whitespace]),
        "country": maybe_dirty_text(fake.country_code(), [dirty_case]),
        "date_of_birth": maybe_null(format_date_clean(random_date(date(1940,1,1), date(2005,12,31))), 0.30),
        "registration_date": format_date_dirty(random_date(DATE_START, DATE_END)),
        "loyalty_card_number": maybe_dirty_text(generate_loyalty_number(), [dirty_case, dirty_whitespace]),
        "customer_segment": maybe_dirty_text(random.choice(customer_segments), [dirty_case, dirty_whitespace]),
    })

print("Generating store locations...")
stores = []
store_types = ["Main Store", "Branch", "Kiosk", "Online Warehouse", "Pop-up", "Outlet"]
cities_data = [
    ("New York", "NY"), ("Los Angeles", "CA"), ("Chicago", "IL"),
    ("Houston", "TX"), ("Phoenix", "AZ"), ("Philadelphia", "PA"),
    ("San Antonio", "TX"), ("San Diego", "CA"),
]
for i in range(NUM_STORES):
    if i < len(cities_data):
        city, state = cities_data[i]
    else:
        city = fake.city()
        state = fake.state_abbr()
    stores.append({
        "id": i + 1,
        "name": maybe_dirty_text(f"PageTurner {city}", [dirty_case, dirty_whitespace]),
        "address_line1": maybe_dirty_text(fake.street_address(), [dirty_whitespace]),
        "address_line2": maybe_null(fake.secondary_address(), 0.50),
        "city": maybe_dirty_text(city, [dirty_case, dirty_whitespace]),
        "state": maybe_dirty_text(state, [dirty_case]),
        "postal_code": maybe_dirty_text(fake.zipcode(), [dirty_whitespace]),
        "country": "US",
        "phone": maybe_dirty_text(generate_phone(), [dirty_whitespace]),
        "manager_id": maybe_null(random.randint(1, NUM_EMPLOYEES), 0.15),
        "opening_date": format_date_clean(random_date(date(2015,1,1), date(2024,8,31))),
        "store_type": maybe_dirty_text(random.choice(store_types), [dirty_case, dirty_whitespace]),
        "square_footage": maybe_dirty_text(random.randint(800, 15000), [dirty_wrong_type]),
        "created_at": format_date_clean(random_past_datetime(3)),
    })

print("Generating inventory...")
inventory = []
for book_id in range(1, NUM_BOOKS + 1):
    num_stores = random.randint(1, NUM_STORES)
    for store_id in random.sample(range(1, NUM_STORES + 1), num_stores):
        inventory.append({
            "id": len(inventory) + 1,
            "book_id": book_id,
            "store_id": store_id,
            "quantity": maybe_dirty_text(random.randint(0, 200), [dirty_wrong_type]),
            "reorder_point": maybe_dirty_text(random.randint(5, 30), [dirty_wrong_type]),
            "reorder_quantity": maybe_dirty_text(random.randint(20, 100), [dirty_wrong_type]),
            "last_restocked_at": maybe_null(format_date_dirty(random_datetime(DATE_START, DATE_END)), 0.10),
            "created_at": format_date_clean(random_past_datetime(3)),
        })

print("Generating orders...")
orders = []
statuses = ["pending", "processing", "shipped", "delivered", "cancelled", "returned",
            "completed", "on_hold", None]
payment_statuses = ["pending", "paid", "failed", "refunded", "partial", None]
shipping_methods = ["Standard", "Express", "Overnight", "In-Store Pickup", "Free Shipping",
                    "Economy", "Two-Day", None]
customers_sample = random.sample(range(1, NUM_CUSTOMERS + 1), min(800, NUM_CUSTOMERS))

for i in range(NUM_ORDERS):
    order_date = random_datetime(DATE_START, DATE_END)
    status = random.choice(statuses)
    subtotal = random_price(5.99, 299.99)
    tax_rate = random.choice([0.0, 0.05, 0.06, 0.07, 0.08, 0.09, 0.10])
    tax_amount = round(subtotal * tax_rate, 2)
    total_amount = round(subtotal + tax_amount, 2)
    cust_id = random.choice(customers_sample)

    # Determine store: mostly online (store_id = 1 or NULL), some in-store
    if random.random() < 0.3:
        store_id = random.randint(2, NUM_STORES)
    else:
        store_id = maybe_null(1, 0.4)

    orders.append({
        "id": i + 1,
        "order_number": maybe_dirty_text(f"ORD-{random.randint(100000, 999999)}", [dirty_case]),
        "customer_id": cust_id,
        "store_id": store_id,
        "order_date": format_date_dirty(order_date),
        "order_status": maybe_dirty_text(status, [dirty_case, dirty_whitespace]),
        "subtotal": maybe_dirty_text(subtotal, [dirty_wrong_type]),
        "tax_amount": maybe_dirty_text(tax_amount, [dirty_wrong_type]),
        "total_amount": maybe_dirty_text(total_amount, [dirty_wrong_type]),
        "shipping_address": maybe_dirty_text(fake.address(), [dirty_whitespace]),
        "notes": maybe_dirty_text(fake.sentence(nb_words=6), [dirty_whitespace]),
        "created_at": format_date_dirty(order_date),
    })

print("Generating order items...")
order_items = []
items_per_order_avg = 2.3
total_items_target = int(NUM_ORDERS * items_per_order_avg)

for i in range(total_items_target):
    order_id = random.randint(1, NUM_ORDERS)
    book_id = random.randint(1, NUM_BOOKS)
    quantity = random.choices([1, 2, 3, 4, 5], weights=[0.45, 0.30, 0.15, 0.07, 0.03])[0]
    unit_price = random_price(4.99, 59.99)
    discount = random.choice([0, 0, 0, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30])
    line_total = round(unit_price * quantity * (1 - discount), 2)

    order_items.append({
        "id": len(order_items) + 1,
        "order_id": order_id,
        "book_id": book_id,
        "quantity": maybe_dirty_text(quantity, [dirty_wrong_type]),
        "unit_price": maybe_dirty_text(unit_price, [dirty_wrong_type]),
        "discount": maybe_dirty_text(discount, [dirty_wrong_type]),
        "line_total": maybe_dirty_text(line_total, [dirty_wrong_type]),
    })

print("Generating payments...")
payments = []
payment_methods = ["Credit Card", "Debit Card", "PayPal", "Apple Pay", "Google Pay",
                   "Cash", "Gift Card", "Bank Transfer", None]
pay_statuses = ["completed", "pending", "failed", "refunded", "processing", None]

for i in range(int(NUM_ORDERS * 0.95)):  # ~95% of orders have payment records
    pay_date = random_datetime(DATE_START, DATE_END)
    payments.append({
        "id": len(payments) + 1,
        "order_id": random.randint(1, NUM_ORDERS),
        "payment_method": maybe_dirty_text(random.choice(payment_methods), [dirty_case, dirty_whitespace]),
        "amount": maybe_dirty_text(random_price(5.99, 299.99), [dirty_wrong_type]),
        "currency": maybe_dirty_text(random.choice(["USD", "USD", "USD", "EUR", "GBP", "CAD"]), [dirty_case]),
        "status": maybe_dirty_text(random.choice(pay_statuses), [dirty_case, dirty_whitespace]),
        "transaction_id": maybe_dirty_text(f"TXN-{random.randint(10000000, 99999999)}", [dirty_case]),
        "payment_date": format_date_dirty(pay_date),
        "created_at": format_date_dirty(pay_date),
    })

print("Generating shipping records...")
shipping = []
carriers = ["USPS", "FedEx", "UPS", "DHL", "Amazon Logistics", "OnTrac", None]
ship_statuses = ["pending", "in_transit", "out_for_delivery", "delivered", "exception",
                 "returned", "failed_delivery", None]

for i in range(int(NUM_ORDERS * 0.80)):  # ~80% of orders shipped
    ship_date = random_datetime(DATE_START, DATE_END)
    delivery_date = ship_date + timedelta(days=random.randint(1, 14)) if random.random() < 0.7 else None
    shipping.append({
        "id": len(shipping) + 1,
        "order_id": random.randint(1, NUM_ORDERS),
        "carrier": maybe_dirty_text(random.choice(carriers), [dirty_case, dirty_whitespace]),
        "tracking_number": maybe_dirty_text(
            fake.bothify("???-??????????-???").upper(), [dirty_case]
        ),
        "shipping_date": format_date_dirty(ship_date),
        "estimated_delivery": format_date_dirty(ship_date + timedelta(days=random.randint(3, 10))),
        "actual_delivery": maybe_null(format_date_dirty(delivery_date), 0.25),
        "shipping_cost": maybe_dirty_text(random_price(0, 25.99), [dirty_wrong_type]),
        "status": maybe_dirty_text(random.choice(ship_statuses), [dirty_case, dirty_whitespace]),
        "shipping_address": maybe_dirty_text(fake.address(), [dirty_whitespace]),
        "created_at": format_date_dirty(ship_date),
    })

print("Generating reviews...")
reviews = []
review_titles = [
    "Loved it!", "Great read", "Couldn't put it down", "A masterpiece",
    "Disappointed", "Not what I expected", "Decent book", "Highly recommended",
    "Boring", "Amazing", "Just okay", "A must-read", "Overrated",
    "Hidden gem", "Waste of time", "Changed my life", "Beautiful writing",
    "Poorly written", "Would recommend", "Fantastic", "Mediocre",
    "Brilliant", "Tedious", "Captivating", "Meh", "Excellent",
    None, None, None,
]
stars = [1, 2, 3, 3, 4, 4, 4, 5, 5, 5]

for i in range(NUM_REVIEWS):
    review_date = random_date(DATE_START, DATE_END)
    reviews.append({
        "id": len(reviews) + 1,
        "book_id": random.randint(1, NUM_BOOKS),
        "customer_id": random.choice(customers_sample),
        "rating": maybe_dirty_text(random.choice(stars), [dirty_wrong_type]),
        "title": maybe_dirty_text(random.choice(review_titles), [dirty_case, dirty_whitespace]),
        "review_text": maybe_dirty_text(fake.text(max_nb_chars=500), [dirty_whitespace, dirty_double_space]),
        "review_date": format_date_dirty(review_date),
        "is_verified": maybe_dirty_text(random.choice([True, True, True, False]), [dirty_case]),
        "helpful_votes": maybe_dirty_text(random.randint(0, 150), [dirty_wrong_type]),
        "moderation_status": maybe_dirty_text(random.choice(["approved", "pending", "rejected", None]), [dirty_case, dirty_whitespace]),
    })

print("Generating promotions...")
promotions = []
promo_types = ["percentage", "fixed_amount", "buy_one_get_one", "free_shipping", "bundle", None]
promo_statuses = ["active", "inactive", "expired", "scheduled", None]

for i in range(NUM_PROMOTIONS):
    start_date = random_date(DATE_START, DATE_END)
    end_date = start_date + timedelta(days=random.randint(7, 90))
    promotions.append({
        "id": i + 1,
        "code": maybe_dirty_text(
            fake.bothify("???-#####").upper(), [dirty_case, dirty_whitespace]
        ),
        "name": maybe_dirty_text(fake.catch_phrase(), [dirty_whitespace, dirty_double_space]),
        "description": maybe_dirty_text(fake.sentence(nb_words=8), [dirty_whitespace]),
        "discount_type": maybe_dirty_text(random.choice(promo_types), [dirty_case, dirty_whitespace]),
        "discount_value": maybe_dirty_text(random_price(1.00, 50.00), [dirty_wrong_type]),
        "min_order_amount": maybe_null(random_price(10.00, 100.00), 0.30),
        "max_uses": maybe_null(random.randint(10, 1000), 0.25),
        "times_used": random.randint(0, 500),
        "start_date": format_date_dirty(start_date),
        "end_date": format_date_dirty(end_date),
        "status": maybe_dirty_text(random.choice(promo_statuses), [dirty_case, dirty_whitespace]),
        "created_at": format_date_clean(random_past_datetime(3)),
    })

print("Generating employees...")
employees = []
roles = ["Manager", "Assistant Manager", "Senior Clerk", "Clerk", "Cashier",
         "Inventory Specialist", "Online Order Fulfillment", "Customer Service",
         "Visual Merchandiser", "Events Coordinator", "Buyer", "Admin Assistant", None]
statuses = ["active", "on_leave", "terminated", "suspended", None]

for i in range(NUM_EMPLOYEES):
    fn = fake.first_name()
    ln = fake.last_name()
    hire_date = random_date(date(2015,1,1), DATE_END)
    salary = random.randint(28000, 95000)
    employees.append({
        "id": i + 1,
        "employee_id": maybe_dirty_text(generate_employee_id(), [dirty_case, dirty_whitespace]),
        "first_name": maybe_dirty_text(fn, [dirty_case, dirty_whitespace]),
        "last_name": maybe_dirty_text(ln, [dirty_case, dirty_whitespace]),
        "email": maybe_dirty_text(f"{fn.lower()}.{ln.lower()}@pageturner.com", [dirty_case, dirty_whitespace]),
        "phone": maybe_dirty_text(generate_phone(), [dirty_whitespace]),
        "role": maybe_dirty_text(random.choice(roles), [dirty_case, dirty_whitespace]),
        "store_id": maybe_null(random.randint(1, NUM_STORES), 0.10),
        "hire_date": format_date_dirty(hire_date),
        "salary": maybe_dirty_text(salary, [dirty_wrong_type]),
        "status": maybe_dirty_text(random.choice(statuses), [dirty_case, dirty_whitespace]),
        "created_at": format_date_clean(random_past_datetime(3)),
    })

# ============================================================
# SQLITE OUTPUT
# ============================================================

print(f"\nWriting SQLite database to {DB_FILE}...")
if DB_FILE.exists():
    DB_FILE.unlink()

conn = sqlite3.connect(str(DB_FILE))
cur = conn.cursor()

# Create tables
cur.executescript("""
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS shipping;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS promotions;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS stores;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS publishers;

CREATE TABLE publishers (
    id INTEGER PRIMARY KEY,
    name TEXT,
    country TEXT,
    founded_year INTEGER,
    website TEXT,
    email TEXT,
    phone TEXT,
    created_at TEXT
);

CREATE TABLE authors (
    id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    nationality TEXT,
    birth_date TEXT,
    biography TEXT,
    website TEXT,
    created_at TEXT
);

CREATE TABLE categories (
    id INTEGER PRIMARY KEY,
    name TEXT,
    description TEXT,
    parent_category_id INTEGER,
    created_at TEXT
);

CREATE TABLE books (
    id INTEGER PRIMARY KEY,
    isbn13 TEXT,
    isbn10 TEXT,
    title TEXT,
    subtitle TEXT,
    publication_date TEXT,
    pages INTEGER,
    language TEXT,
    price REAL,
    list_price REAL,
    edition TEXT,
    description TEXT,
    publisher_id INTEGER,
    category_id INTEGER,
    created_at TEXT
);

CREATE TABLE book_authors (
    book_id INTEGER,
    author_id INTEGER,
    author_order INTEGER
);

CREATE TABLE customers (
    id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    phone TEXT,
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    country TEXT,
    date_of_birth TEXT,
    registration_date TEXT,
    loyalty_card_number TEXT,
    customer_segment TEXT
);

CREATE TABLE stores (
    id INTEGER PRIMARY KEY,
    name TEXT,
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    country TEXT,
    phone TEXT,
    manager_id INTEGER,
    opening_date TEXT,
    store_type TEXT,
    square_footage INTEGER,
    created_at TEXT
);

CREATE TABLE inventory (
    id INTEGER PRIMARY KEY,
    book_id INTEGER,
    store_id INTEGER,
    quantity INTEGER,
    reorder_point INTEGER,
    reorder_quantity INTEGER,
    last_restocked_at TEXT,
    created_at TEXT
);

CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    order_number TEXT,
    customer_id INTEGER,
    store_id INTEGER,
    order_date TEXT,
    order_status TEXT,
    subtotal REAL,
    tax_amount REAL,
    total_amount REAL,
    shipping_address TEXT,
    notes TEXT,
    created_at TEXT
);

CREATE TABLE order_items (
    id INTEGER PRIMARY KEY,
    order_id INTEGER,
    book_id INTEGER,
    quantity INTEGER,
    unit_price REAL,
    discount REAL,
    line_total REAL
);

CREATE TABLE payments (
    id INTEGER PRIMARY KEY,
    order_id INTEGER,
    payment_method TEXT,
    amount REAL,
    currency TEXT,
    status TEXT,
    transaction_id TEXT,
    payment_date TEXT,
    created_at TEXT
);

CREATE TABLE shipping (
    id INTEGER PRIMARY KEY,
    order_id INTEGER,
    carrier TEXT,
    tracking_number TEXT,
    shipping_date TEXT,
    estimated_delivery TEXT,
    actual_delivery TEXT,
    shipping_cost REAL,
    status TEXT,
    shipping_address TEXT,
    created_at TEXT
);

CREATE TABLE reviews (
    id INTEGER PRIMARY KEY,
    book_id INTEGER,
    customer_id INTEGER,
    rating INTEGER,
    title TEXT,
    review_text TEXT,
    review_date TEXT,
    is_verified TEXT,
    helpful_votes INTEGER,
    moderation_status TEXT
);

CREATE TABLE promotions (
    id INTEGER PRIMARY KEY,
    code TEXT,
    name TEXT,
    description TEXT,
    discount_type TEXT,
    discount_value REAL,
    min_order_amount REAL,
    max_uses INTEGER,
    times_used INTEGER,
    start_date TEXT,
    end_date TEXT,
    status TEXT,
    created_at TEXT
);

CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    employee_id TEXT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    phone TEXT,
    role TEXT,
    store_id INTEGER,
    hire_date TEXT,
    salary INTEGER,
    status TEXT,
    created_at TEXT
);
""")

# Insert data
def insert_many(table_name, columns, data):
    placeholders = ",".join(["?"] * len(columns))
    col_str = ",".join(columns)
    rows = []
    for row in data:
        vals = []
        for c in columns:
            v = row.get(c)
            if isinstance(v, bool):
                v = 1 if v else 0
            vals.append(v)
        rows.append(tuple(vals))
    cur.executemany(f"INSERT INTO {table_name} ({col_str}) VALUES ({placeholders})", rows)

print("Inserting publishers...")
insert_many("publishers", list(publishers[0].keys()), publishers)

print("Inserting authors...")
insert_many("authors", list(authors[0].keys()), authors)

print("Inserting categories...")
insert_many("categories", list(categories[0].keys()), categories)

print("Inserting books...")
insert_many("books", list(books[0].keys()), books)

print("Inserting book_authors...")
insert_many("book_authors", list(book_authors[0].keys()), book_authors)

print("Inserting customers...")
insert_many("customers", list(customers[0].keys()), customers)

print("Inserting stores...")
insert_many("stores", list(stores[0].keys()), stores)

print("Inserting inventory...")
insert_many("inventory", list(inventory[0].keys()), inventory)

print("Inserting orders...")
insert_many("orders", list(orders[0].keys()), orders)

print("Inserting order_items...")
insert_many("order_items", list(order_items[0].keys()), order_items)

print("Inserting payments...")
insert_many("payments", list(payments[0].keys()), payments)

print("Inserting shipping...")
insert_many("shipping", list(shipping[0].keys()), shipping)

print("Inserting reviews...")
insert_many("reviews", list(reviews[0].keys()), reviews)

print("Inserting promotions...")
insert_many("promotions", list(promotions[0].keys()), promotions)

print("Inserting employees...")
insert_many("employees", list(employees[0].keys()), employees)

conn.commit()
conn.close()

# Verify
conn = sqlite3.connect(str(DB_FILE))
cur = conn.cursor()
print("\n=== SQLite Verification ===")
tables = cur.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name").fetchall()
for (tname,) in tables:
    count = cur.execute(f"SELECT COUNT(*) FROM [{tname}]").fetchone()[0]
    print(f"  {tname}: {count} rows")
conn.close()

print(f"\nSQLite database written: {DB_FILE}")
print(f"  Size: {DB_FILE.stat().st_size / 1024:.1f} KB")

# ============================================================
# POSTGRESQL SQL OUTPUT
# ============================================================

print(f"\nWriting PostgreSQL SQL to {SQL_FILE}...")

def pg_value(val):
    """Format a value for PostgreSQL INSERT."""
    if val is None:
        return "NULL"
    if isinstance(val, bool):
        return "TRUE" if val else "FALSE"
    if isinstance(val, int):
        return str(val)
    if isinstance(val, float):
        return f"{val:.2f}"
    s = str(val)
    s = s.replace("'", "''")
    return f"'{s}'"

with open(SQL_FILE, "w", encoding="utf-8") as f:
    f.write("-- ============================================================\n")
    f.write("-- Bookstore Dataset - PostgreSQL SQL Script\n")
    f.write("-- Generated by dataset-generator agent\n")
    f.write("-- Dirty level: MID\n")
    f.write("-- ============================================================\n\n")
    f.write("BEGIN;\n\n")

    # Drop tables (reverse dependency order)
    f.write("-- Drop existing tables (if any)\n")
    drop_order = [
        "order_items", "book_authors", "inventory", "shipping", "payments",
        "reviews", "orders", "promotions", "books", "employees", "customers",
        "stores", "categories", "authors", "publishers"
    ]
    for t in drop_order:
        f.write(f"DROP TABLE IF EXISTS {t} CASCADE;\n")
    f.write("\n")

    # Create tables
    f.write("-- ============================================================\n")
    f.write("-- CREATE TABLES\n")
    f.write("-- ============================================================\n\n")

    f.write("""CREATE TABLE publishers (
    id INTEGER PRIMARY KEY,
    name TEXT,
    country TEXT,
    founded_year INTEGER,
    website TEXT,
    email TEXT,
    phone TEXT,
    created_at TIMESTAMP
);

CREATE TABLE authors (
    id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    nationality TEXT,
    birth_date DATE,
    biography TEXT,
    website TEXT,
    created_at TIMESTAMP
);

CREATE TABLE categories (
    id INTEGER PRIMARY KEY,
    name TEXT,
    description TEXT,
    parent_category_id INTEGER,
    created_at TIMESTAMP
);

CREATE TABLE books (
    id INTEGER PRIMARY KEY,
    isbn13 TEXT,
    isbn10 TEXT,
    title TEXT,
    subtitle TEXT,
    publication_date DATE,
    pages INTEGER,
    language TEXT,
    price NUMERIC(10,2),
    list_price NUMERIC(10,2),
    edition TEXT,
    description TEXT,
    publisher_id INTEGER,
    category_id INTEGER,
    created_at TIMESTAMP
);

CREATE TABLE book_authors (
    book_id INTEGER,
    author_id INTEGER,
    author_order INTEGER
);

CREATE TABLE customers (
    id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    phone TEXT,
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    country TEXT,
    date_of_birth DATE,
    registration_date DATE,
    loyalty_card_number TEXT,
    customer_segment TEXT
);

CREATE TABLE stores (
    id INTEGER PRIMARY KEY,
    name TEXT,
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    country TEXT,
    phone TEXT,
    manager_id INTEGER,
    opening_date DATE,
    store_type TEXT,
    square_footage INTEGER,
    created_at TIMESTAMP
);

CREATE TABLE inventory (
    id INTEGER PRIMARY KEY,
    book_id INTEGER,
    store_id INTEGER,
    quantity INTEGER,
    reorder_point INTEGER,
    reorder_quantity INTEGER,
    last_restocked_at TIMESTAMP,
    created_at TIMESTAMP
);

CREATE TABLE orders (
    id INTEGER PRIMARY KEY,
    order_number TEXT,
    customer_id INTEGER,
    store_id INTEGER,
    order_date TIMESTAMP,
    order_status TEXT,
    subtotal NUMERIC(10,2),
    tax_amount NUMERIC(10,2),
    total_amount NUMERIC(10,2),
    shipping_address TEXT,
    notes TEXT,
    created_at TIMESTAMP
);

CREATE TABLE order_items (
    id INTEGER PRIMARY KEY,
    order_id INTEGER,
    book_id INTEGER,
    quantity INTEGER,
    unit_price NUMERIC(10,2),
    discount NUMERIC(5,2),
    line_total NUMERIC(10,2)
);

CREATE TABLE payments (
    id INTEGER PRIMARY KEY,
    order_id INTEGER,
    payment_method TEXT,
    amount NUMERIC(10,2),
    currency TEXT,
    status TEXT,
    transaction_id TEXT,
    payment_date TIMESTAMP,
    created_at TIMESTAMP
);

CREATE TABLE shipping (
    id INTEGER PRIMARY KEY,
    order_id INTEGER,
    carrier TEXT,
    tracking_number TEXT,
    shipping_date TIMESTAMP,
    estimated_delivery TIMESTAMP,
    actual_delivery TIMESTAMP,
    shipping_cost NUMERIC(10,2),
    status TEXT,
    shipping_address TEXT,
    created_at TIMESTAMP
);

CREATE TABLE reviews (
    id INTEGER PRIMARY KEY,
    book_id INTEGER,
    customer_id INTEGER,
    rating INTEGER,
    title TEXT,
    review_text TEXT,
    review_date DATE,
    is_verified BOOLEAN,
    helpful_votes INTEGER,
    moderation_status TEXT
);

CREATE TABLE promotions (
    id INTEGER PRIMARY KEY,
    code TEXT,
    name TEXT,
    description TEXT,
    discount_type TEXT,
    discount_value NUMERIC(10,2),
    min_order_amount NUMERIC(10,2),
    max_uses INTEGER,
    times_used INTEGER,
    start_date DATE,
    end_date DATE,
    status TEXT,
    created_at TIMESTAMP
);

CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    employee_id TEXT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    phone TEXT,
    role TEXT,
    store_id INTEGER,
    hire_date DATE,
    salary INTEGER,
    status TEXT,
    created_at TIMESTAMP
);
""")

    # Insert data
    f.write("\n-- ============================================================\n")
    f.write("-- INSERT DATA\n")
    f.write("-- ============================================================\n\n")

    all_data = {
        "publishers": (["id","name","country","founded_year","website","email","phone","created_at"], publishers),
        "authors": (["id","first_name","last_name","email","nationality","birth_date","biography","website","created_at"], authors),
        "categories": (["id","name","description","parent_category_id","created_at"], categories),
        "books": (["id","isbn13","isbn10","title","subtitle","publication_date","pages","language","price","list_price","edition","description","publisher_id","category_id","created_at"], books),
        "book_authors": (["book_id","author_id","author_order"], book_authors),
        "customers": (["id","first_name","last_name","email","phone","address_line1","address_line2","city","state","postal_code","country","date_of_birth","registration_date","loyalty_card_number","customer_segment"], customers),
        "stores": (["id","name","address_line1","address_line2","city","state","postal_code","country","phone","manager_id","opening_date","store_type","square_footage","created_at"], stores),
        "inventory": (["id","book_id","store_id","quantity","reorder_point","reorder_quantity","last_restocked_at","created_at"], inventory),
        "orders": (["id","order_number","customer_id","store_id","order_date","order_status","subtotal","tax_amount","total_amount","shipping_address","notes","created_at"], orders),
        "order_items": (["id","order_id","book_id","quantity","unit_price","discount","line_total"], order_items),
        "payments": (["id","order_id","payment_method","amount","currency","status","transaction_id","payment_date","created_at"], payments),
        "shipping": (["id","order_id","carrier","tracking_number","shipping_date","estimated_delivery","actual_delivery","shipping_cost","status","shipping_address","created_at"], shipping),
        "reviews": (["id","book_id","customer_id","rating","title","review_text","review_date","is_verified","helpful_votes","moderation_status"], reviews),
        "promotions": (["id","code","name","description","discount_type","discount_value","min_order_amount","max_uses","times_used","start_date","end_date","status","created_at"], promotions),
        "employees": (["id","employee_id","first_name","last_name","email","phone","role","store_id","hire_date","salary","status","created_at"], employees),
    }

    for table_name in drop_order:
        if table_name not in all_data:
            continue
        cols, data_rows = all_data[table_name]
        f.write(f"-- {table_name}\n")
        f.write(f"INSERT INTO {table_name} ({', '.join(cols)}) VALUES\n")
        value_lines = []
        for row in data_rows:
            vals = ", ".join(pg_value(row.get(c)) for c in cols)
            value_lines.append(f"  ({vals})")
        f.write(",\n".join(value_lines))
        f.write(";\n\n")

    f.write("COMMIT;\n")
    f.write(f"-- Total rows: {sum(len(d[1]) for d in all_data.values())}\n")

print(f"PostgreSQL SQL written: {SQL_FILE}")
print(f"  Size: {SQL_FILE.stat().st_size / 1024:.1f} KB")

# ============================================================
# README
# ============================================================

print(f"\nWriting README...")
readme_path = OUTPUT_DIR / "README.md"

with open(readme_path, "w", encoding="utf-8") as f:
    f.write("# Bookstore Dataset\n\n")
    f.write("A comprehensive synthetic bookstore dataset with intentional mid-level data quality issues for SQL practice and data cleaning exercises.\n\n")
    f.write("## Dataset Overview\n\n")
    f.write("This dataset represents a **mid-size bookstore chain** (\"PageTurner Books\") with both physical stores and an online presence. It covers **2 years of order history** (September 2024 - August 2026) with realistic book catalog data, customer transactions, inventory management, and operational records.\n\n")
    f.write("## Tables\n\n")
    f.write("| Table | Rows | Description |\n")
    f.write("|-------|------|-------------|\n")
    f.write(f"| `publishers` | {NUM_PUBLISHERS} | Book publisher information |\n")
    f.write(f"| `authors` | {NUM_AUTHORS} | Author profiles |\n")
    f.write(f"| `categories` | {NUM_CATEGORIES} | Book categories/genres (hierarchical) |\n")
    f.write(f"| `books` | {NUM_BOOKS} | Book catalog with ISBNs, pricing, metadata |\n")
    f.write(f"| `book_authors` | {len(book_authors)} | Many-to-many book-author relationships |\n")
    f.write(f"| `customers` | {NUM_CUSTOMERS} | Customer profiles |\n")
    f.write(f"| `stores` | {NUM_STORES} | Physical store locations |\n")
    f.write(f"| `inventory` | {len(inventory)} | Stock levels per book per store |\n")
    f.write(f"| `orders` | {NUM_ORDERS} | Order headers (2 years of history) |\n")
    f.write(f"| `order_items` | {len(order_items)} | Individual items per order |\n")
    f.write(f"| `payments` | {len(payments)} | Payment transactions |\n")
    f.write(f"| `shipping` | {len(shipping)} | Shipping/delivery tracking |\n")
    f.write(f"| `reviews` | {NUM_REVIEWS} | Customer reviews and ratings |\n")
    f.write(f"| `promotions` | {NUM_PROMOTIONS} | Discount codes and promotions |\n")
    f.write(f"| `employees` | {NUM_EMPLOYEES} | Staff information |\n")
    f.write("\n## Schema Details\n\n")

    schema_details = {
        "publishers": "id, name, country, founded_year, website, email, phone, created_at",
        "authors": "id, first_name, last_name, email, nationality, birth_date, biography, website, created_at",
        "categories": "id, name, description, parent_category_id, created_at",
        "books": "id, isbn13, isbn10, title, subtitle, publication_date, pages, language, price, list_price, edition, description, publisher_id, category_id, created_at",
        "book_authors": "book_id, author_id, author_order",
        "customers": "id, first_name, last_name, email, phone, address_line1, address_line2, city, state, postal_code, country, date_of_birth, registration_date, loyalty_card_number, customer_segment",
        "stores": "id, name, address_line1, address_line2, city, state, postal_code, country, phone, manager_id, opening_date, store_type, square_footage, created_at",
        "inventory": "id, book_id, store_id, quantity, reorder_point, reorder_quantity, last_restocked_at, created_at",
        "orders": "id, order_number, customer_id, store_id, order_date, order_status, subtotal, tax_amount, total_amount, shipping_address, notes, created_at",
        "order_items": "id, order_id, book_id, quantity, unit_price, discount, line_total",
        "payments": "id, order_id, payment_method, amount, currency, status, transaction_id, payment_date, created_at",
        "shipping": "id, order_id, carrier, tracking_number, shipping_date, estimated_delivery, actual_delivery, shipping_cost, status, shipping_address, created_at",
        "reviews": "id, book_id, customer_id, rating, title, review_text, review_date, is_verified, helpful_votes, moderation_status",
        "promotions": "id, code, name, description, discount_type, discount_value, min_order_amount, max_uses, times_used, start_date, end_date, status, created_at",
        "employees": "id, employee_id, first_name, last_name, email, phone, role, store_id, hire_date, salary, status, created_at",
    }

    for table_name, cols in schema_details.items():
        f.write(f"### `{table_name}`\n")
        f.write(f"- Columns: `{cols}`\n\n")

    f.write("## Dirty Data Categories (Mid-Level)\n\n")
    f.write("This dataset includes the following data quality issues:\n\n")
    f.write("| Category | Description |\n")
    f.write("|----------|-------------|\n")
    f.write("| **NULL values** | ~5-10% NULLs across applicable columns (optional fields, missing data) |\n")
    f.write("| **Case inconsistency** | Mixed capitalization in names, statuses, categories (e.g., \"SHIPPED\" vs \"Shipped\" vs \"shipped\") |\n")
    f.write("| **Whitespace issues** | Leading/trailing spaces, extra internal spaces in names (e.g., \"John  Doe\") |\n")
    f.write("| **Wrong data types** | \"N/A\", \"--\", \"NULL\" embedded in numeric/text columns |\n")
    f.write("| **Date format inconsistency** | Mixed date formats: YYYY-MM-DD, MM/DD/YYYY, DD-MM-YYYY, Month DD, YYYY |\n")
    f.write("| **String encoding variations** | Inconsistent phone number formats, ZIP codes, order numbers |\n")
    f.write("\n## Usage Hints\n\n")
    f.write("### SQLite\n")
    f.write("```bash\n")
    f.write("sqlite3 bookstore.db\n")
    f.write("```\n\n")
    f.write("### PostgreSQL\n")
    f.write("```bash\n")
    f.write("psql -U your_user -d your_database -f bookstore.sql\n")
    f.write("```\n\n")
    f.write("### Practice Queries\n\n")
    f.write("This dataset is ideal for practicing:\n\n")
    f.write("- **Data cleaning**: Handle NULLs, fix case inconsistencies, standardize dates\n")
    f.write("- **JOIN operations**: Multi-table joins across orders, books, customers, reviews\n")
    f.write("- **Aggregation**: Sales summaries, popular books, customer segmentation\n")
    f.write("- **Window functions**: Ranking, running totals, year-over-year comparisons\n")
    f.write("- **CTEs & subqueries**: Complex business analytics\n")
    f.write("- **Data quality auditing**: Identify and fix the embedded dirty data\n\n")
    f.write("## Files\n\n")
    f.write("| File | Description |\n")
    f.write("|------|-------------|\n")
    f.write("| `bookstore.db` | SQLite database with all tables |\n")
    f.write("| `bookstore.sql` | PostgreSQL-compatible SQL script (CREATE + INSERT) |\n")
    f.write("| `generate.py` | Python script that generated this dataset |\n")
    f.write("| `README.md` | This file |\n")

print(f"README written: {readme_path}")
print("\n=== DONE ===")
print(f"Output directory: {OUTPUT_DIR}")
