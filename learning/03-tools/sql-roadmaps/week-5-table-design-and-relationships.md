# Week 5: Table Design & Relationships

**Database:** `sql-learn-db.sql` (E-Commerce Learning Database)
**Tables:** `departments`, `employees`, `customers`, `categories`, `products`, `orders`, `order_items`
**New Tables You'll Create:** `suppliers`, `shipments`, `product_reviews`
**Duration:** 7 days, 1-2 hours/day

---

## Database Schema Reference

### Current Tables in sql-learn-db

```sql
-- Departments
CREATE TABLE departments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    budget REAL
);

-- Employees
CREATE TABLE employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    department_id INTEGER REFERENCES departments(id),
    hire_date TEXT,
    salary REAL
);

-- Customers
CREATE TABLE customers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    city TEXT,
    join_date TEXT
);

-- Categories
CREATE TABLE categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
);

-- Products
CREATE TABLE products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(id),
    price REAL NOT NULL,
    stock INTEGER DEFAULT 0
);

-- Orders
CREATE TABLE orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER REFERENCES customers(id),
    order_date TEXT,
    status TEXT DEFAULT 'pending',
    total REAL
);

-- Order Items
CREATE TABLE order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER DEFAULT 1,
    price REAL NOT NULL
);
```

---

## Sample Data Summary

**Departments (4):** Sales, Marketing, IT, HR

**Employees (8):** Alice Johnson ($5500), Bob Smith ($4800), Carol White ($5200), David Brown ($7000), Eve Davis ($4500), Frank Miller ($6500), Grace Lee ($4900), Henry Wilson ($5100)

**Customers (8):** John Doe, Jane Smith, Mike Johnson, Sarah Brown, Tom Wilson, Lisa Garcia, Kevin Martinez, Amy Taylor

**Categories (5):** Electronics, Clothing, Books, Home & Garden, Sports

**Products (12):** Laptop ($999.99), Smartphone ($699.99), Headphones ($149.99), T-Shirt ($29.99), Jeans ($59.99), Jacket ($89.99), SQL Mastery ($49.99), Python Guide ($39.99), Garden Tools Set ($79.99), Running Shoes ($119.99), Basketball ($34.99), Yoga Mat ($24.99)

**Orders (12):** Mix of completed, pending, shipped, and cancelled statuses with totals ranging from $49.99 to $1049.98

---

## What is Table Design?

Table design is about **planning your database structure** before adding data. Think of it like:

| Activity | Real-World Analogy |
|----------|-------------------|
| **CREATE TABLE** | Building a new filing cabinet with specific drawers |
| **Choosing Data Types** | Deciding what kind of information each drawer holds |
| **Adding Constraints** | Setting rules for what can be stored in each drawer |
| **Defining Keys** | Assigning unique ID numbers to each file |

Good table design prevents problems before they happen!

---

## Day 1: CREATE TABLE - Building Your First Table

### What is CREATE TABLE?

CREATE TABLE creates a new table in your database. It's like setting up a new spreadsheet with column headers already defined.

### Syntax

```sql
CREATE TABLE table_name (
    column1 datatype constraints,
    column2 datatype constraints,
    ...
);
```

### Your First Tables

Let's create tables for a growing e-commerce business!

### Example 1: Creating a Suppliers Table

```sql
-- Create suppliers table
CREATE TABLE suppliers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT,
    city TEXT,
    country TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

**HR Translation:** "I need you to set up a new file for our suppliers. Each supplier needs:
- A unique ID number (auto-generated, no duplicates)
- Their company name (required - we need to know who we're working with)
- Email address (must be unique - no two suppliers can share the same email)
- Phone number (optional - some suppliers might not have a direct line)
- City and Country (to know where they're located)
- Created at timestamp (auto-record when we added them)

Every field has a purpose, and some fields are required while others are optional."

### Example 2: Creating a Product Reviews Table

```sql
-- Create product reviews table
CREATE TABLE product_reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER REFERENCES products(id),
    customer_id INTEGER REFERENCES customers(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date TEXT DEFAULT CURRENT_TIMESTAMP
);
```

**HR Translation:** "We want to collect customer reviews for our products. For each review:
- Give it a unique ID (auto-generated)
- Link it to a specific product (reference the products table)
- Link it to the customer who wrote it (reference the customers table)
- Rating from 1 to 5 stars (must be between 1 and 5, no invalid ratings)
- The actual review text (what did they say?)
- Date when they submitted the review (auto-recorded)

This way we can track which products have good reviews and which need improvement."

### Example 3: Creating a Shipments Table

```sql
-- Create shipments table
CREATE TABLE shipments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER REFERENCES orders(id),
    supplier_id INTEGER REFERENCES suppliers(id),
    shipment_date TEXT,
    delivery_date TEXT,
    tracking_number TEXT,
    status TEXT DEFAULT 'pending'
);
```

**HR Translation:** "We need to track how products get delivered to our warehouse. Each shipment record should have:
- A unique shipment ID
- Which order this shipment is for
- Which supplier sent it
- When it was shipped
- Expected/actual delivery date
- Tracking number (so we can follow its journey)
- Status (pending, shipped, delivered, or delayed)

This helps us know where our inventory is at all times."

### Viewing Your New Tables

After creating tables, you can see them with:

```sql
-- View all tables in the database
SELECT name FROM sqlite_master WHERE type='table';

-- View the structure of a specific table
PRAGMA table_info(suppliers);
```

### Practice Exercises

1. Create a `employees_backup` table with the same structure as `employees`
2. Create a `categories_archive` table for storing old categories
3. Create a `customer_addresses` table with fields: id, customer_id, address_type (shipping/billing), address, city, country, postal_code
4. Create a `product_images` table with fields: id, product_id, image_url, is_primary (0 or 1), created_at

---

## Day 2: Data Types - Choosing the Right Type

### Why Data Types Matter

Choosing the correct data type ensures:
- **Data integrity** - Invalid data gets rejected
- **Storage efficiency** - Smaller types use less space
- **Performance** - Proper types make queries faster
- **Validation** - Built-in type checking prevents errors

### SQLite Data Types Reference

| Type | Use For | Example Values |
|------|---------|----------------|
| **INTEGER** | Whole numbers | 1, 42, 1000, -5 |
| **REAL** | Decimal numbers | 3.14, 99.99, -0.5 |
| **TEXT** | Strings/text | "John Doe", "hello", dates stored as text |
| **BLOB** | Binary data | Images, files (rarely used in beginners) |
| **NULL** | Empty/missing | NULL |

### Choosing Types for Each Column

Look at the `employees` table structure:

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,  -- INTEGER: Employee ID
    name TEXT NOT NULL,                     -- TEXT: Names are text
    email TEXT UNIQUE,                      -- TEXT: Email is text
    department_id INTEGER,                  -- INTEGER: Foreign key
    hire_date TEXT,                         -- TEXT: Dates stored as "YYYY-MM-DD"
    salary REAL                             -- REAL: Money with decimals
);
```

### Example: Matching Types for a New Table

```sql
-- Create a promotions table
CREATE TABLE promotions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,           -- TEXT: Promo codes like "SUMMER20"
    discount_percent REAL NOT NULL,      -- REAL: 20.5% off
    min_purchase REAL DEFAULT 0,          -- REAL: Minimum spend required
    start_date TEXT NOT NULL,             -- TEXT: "2026-07-01"
    end_date TEXT NOT NULL,               -- TEXT: "2026-08-31"
    max_uses INTEGER DEFAULT 100,        -- INTEGER: Limit how many times it can be used
    is_active INTEGER DEFAULT 1           -- INTEGER: 1 = active, 0 = inactive
);
```

**HR Translation:** "I'm creating a promotions table to track our discount codes. Here's what I need:
- Unique ID for each promotion
- The actual promo code text (like 'SAVE20' - required, must be unique)
- Discount percentage as a decimal (like 20.5 for 20.5% off)
- Minimum purchase amount required (default is 0, so no minimum)
- Start and end dates for when the promotion is valid
- Maximum number of uses (to prevent abuse)
- Active flag (1 = currently running, 0 = turned off)

Each field has a purpose - the types make sure people enter the right kind of information."

### Common Data Type Mistakes

| Mistake | Problem | Correct Choice |
|---------|---------|----------------|
| Using TEXT for numbers | Can't do math operations | Use INTEGER or REAL |
| Using REAL for IDs | Unnecessary precision | Use INTEGER |
| Using TEXT for dates | Must parse text | Use TEXT with consistent format "YYYY-MM-DD" |
| No size limit | May accept huge text | SQLite doesn't enforce size, but keep reasonable |

### Practice Exercises

1. What data type should each field have for a `gift_cards` table?
   - gift_card_code, initial_amount, current_balance, issue_date, expiration_date, recipient_email, is_redeemed

2. What data type for a `stock_movements` table?
   - movement_id, product_id, quantity_change, movement_type (in/out), movement_date, notes

3. Create the `gift_cards` table with appropriate types
4. Create the `stock_movements` table with appropriate types

---

## Day 3: Constraints - Adding Rules to Your Tables

### What are Constraints?

Constraints are **rules** that prevent invalid data from entering your database. They act like guards at a door.

### Constraint Types Reference

| Constraint | Purpose | Example |
|------------|---------|---------|
| **NOT NULL** | Field cannot be empty | `name TEXT NOT NULL` |
| **UNIQUE** | No duplicate values | `email TEXT UNIQUE` |
| **CHECK** | Validate a condition | `rating INTEGER CHECK (rating >= 1 AND rating <= 5)` |
| **DEFAULT** | Auto-fill if not provided | `status TEXT DEFAULT 'active'` |
| **PRIMARY KEY** | Unique row identifier | `id INTEGER PRIMARY KEY` |
| **FOREIGN KEY** | Link to another table | `category_id INTEGER REFERENCES categories(id)` |

### Example: Adding Constraints to the Suppliers Table

```sql
-- Create suppliers table WITH proper constraints
CREATE TABLE suppliers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,                      -- Supplier name is required
    email TEXT UNIQUE,                        -- No duplicate emails allowed
    phone TEXT,                               -- Optional - no constraint needed
    city TEXT NOT NULL DEFAULT 'Unknown',     -- Required but has fallback
    country TEXT NOT NULL DEFAULT 'Unknown',  -- Required but has fallback
    rating REAL CHECK (rating >= 0 AND rating <= 5),  -- Rating must be 0-5
    is_active INTEGER DEFAULT 1,              -- Default to active
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
```

**HR Translation:** "I'm setting up rules for our supplier records:
- Every supplier MUST have a name (we can't work with anonymous suppliers)
- Each email must be unique (two suppliers can't share the same contact email)
- City and country are required, but if somehow we don't know, default to 'Unknown'
- Rating can only be 0 to 5 stars (a rating of 10 makes no sense!)
- New suppliers are active by default (we assume they're good until proven otherwise)
- The creation date auto-fills if not provided

These rules prevent garbage data from entering our system."

### Example: Constraints with CHECK

```sql
-- Create orders table with validation
CREATE TABLE orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    order_date TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
    total REAL NOT NULL CHECK (total >= 0),   -- Total cannot be negative
    shipping_cost REAL DEFAULT 0 CHECK (shipping_cost >= 0)
);
```

**HR Translation:** "I'm setting up our orders table with strict rules:
- Every order must belong to a customer (no orphan orders)
- Every order needs a date (when was it placed?)
- Status can only be one of these values: pending, processing, shipped, delivered, or cancelled (no custom statuses)
- Total must be zero or positive (a negative total would be nonsense)
- Shipping cost defaults to 0 and can never be negative

These constraints keep our order data clean and predictable."

### Example: DEFAULT Values

```sql
-- Create a product_returns table
CREATE TABLE product_returns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL REFERENCES orders(id),
    product_id INTEGER NOT NULL REFERENCES products(id),
    return_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL,
    refund_amount REAL,
    status TEXT DEFAULT 'pending'
        CHECK (status IN ('pending', 'approved', 'rejected', 'completed')),
    processed_date TEXT
);
```

**HR Translation:** "For handling product returns, I need:
- Link to the original order
- Which product is being returned
- Return date (auto-fills to today if not specified)
- Reason for return (required - we need to know why)
- Refund amount (we'll fill this in when approved)
- Status starts as 'pending' automatically
- Processed date (null until we actually handle it)

Defaults save time and ensure nothing gets missed."

### Practice Exercises

1. Add appropriate constraints to your `product_reviews` table from Day 1
2. Create a `employees_audit` table to track salary changes with constraints
3. Create a `coupon_usage` table to track when customers use coupons
4. Add CHECK constraint to `products` table ensuring price is always positive

---

## Day 4: Primary Key - Uniquely Identifying Rows

### What is a Primary Key?

A Primary Key (PK) is a **unique identifier** for each row in a table. Think of it like:

| Real-World Analogy | Database |
|-------------------|----------|
| Employee ID | `id INTEGER PRIMARY KEY` |
| Social Security Number | `ssn TEXT UNIQUE PRIMARY KEY` |
| ISBN for books | `isbn TEXT UNIQUE PRIMARY KEY` |

### Primary Key Rules

1. **Unique** - No two rows can have the same PK value
2. **Not NULL** - PK cannot be empty
3. **Immutable** - PK value should never change
4. **Simple** - Use simple numbers when possible

### Examining Existing Primary Keys

Let's look at the `products` table:

```sql
SELECT * FROM products;
```

**Output:**
| id | name | category_id | price | stock |
|----|------|-------------|-------|-------|
| 1 | Laptop | 1 | 999.99 | 50 |
| 2 | Smartphone | 1 | 699.99 | 100 |
| 3 | Headphones | 1 | 149.99 | 200 |

The `id` column is the Primary Key - it uniquely identifies each product.

### Auto-incrementing Primary Keys

In SQLite, use `AUTOINCREMENT` to let the database generate sequential IDs:

```sql
CREATE TABLE suppliers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,  -- 1, 2, 3, 4... automatically
    name TEXT NOT NULL,
    ...
);
```

**Why AUTOINCREMENT?**
- Guarantees unique IDs
- No need to track what the next ID should be
- Prevents duplicate IDs

### Creating Tables with Primary Keys

```sql
-- Create shipments table with primary key
CREATE TABLE shipments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,     -- Unique ID for each shipment
    order_id INTEGER NOT NULL,               -- Which order this ships
    supplier_id INTEGER,                     -- Which supplier sent it
    shipment_date TEXT,
    delivery_date TEXT,
    tracking_number TEXT,
    status TEXT DEFAULT 'pending'
);
```

**HR Translation:** "Each shipment needs its own unique ID. When we ship 100 orders, each gets a different number: Shipment 1, Shipment 2, Shipment 3, and so on. This way we can track each shipment individually and never get them confused."

### When to Add Your Own Primary Key

Not every table has a natural PK. Example - a `product_reviews` table:

```sql
-- Natural key attempt (BAD):
-- What if two customers review the same product on the same day?
-- product_id + review_date would conflict!

-- Better approach: Add an artificial PK
CREATE TABLE product_reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,    -- Artificial PK solves everything
    product_id INTEGER REFERENCES products(id),
    customer_id INTEGER REFERENCES customers(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date TEXT DEFAULT CURRENT_TIMESTAMP
);
```

### Composite Primary Keys

Sometimes you need TWO columns to uniquely identify a row:

```sql
-- Example: Order items already have order_id and product_id
-- Together they form a unique identifier (can't order same product twice in same order)

-- SQLite doesn't enforce composite keys easily, so use artificial PK instead:
CREATE TABLE order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,     -- Simple solution
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER DEFAULT 1,
    price REAL NOT NULL
);
```

### Practice Exercises

1. Look at the structure of all tables in sql-learn-db and identify their Primary Keys
2. Create a `suppliers` table with proper PRIMARY KEY
3. Create an `product_images` table where the same product can have multiple images (each image needs unique ID)
4. What would happen if we didn't have a PRIMARY KEY?

---

## Day 5: Foreign Key - Linking Tables Together

### What is a Foreign Key?

A Foreign Key (FK) creates a **relationship** between two tables. It's like a reference that says "this belongs to that."

| Analogy | Explanation |
|---------|------------|
| Employee's Department | Employee row "points to" Department row |
| Order's Customer | Order row "points to" Customer who placed it |
| Product's Category | Product row "points to" Category it belongs to |

### Foreign Key Syntax

```sql
column_name INTEGER REFERENCES other_table(column_name)
```

### Examining Existing Relationships

Look at the `products` table - it links to `categories`:

```sql
-- In products table:
category_id INTEGER REFERENCES categories(id)

-- This means:
-- Every product's category_id must match an existing category's id
-- You cannot create a product with category_id = 999 (if categories only go up to 5)
```

### Creating Tables with Foreign Keys

```sql
-- Create shipments table WITH foreign keys
CREATE TABLE shipments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL REFERENCES orders(id),      -- Must reference existing order
    supplier_id INTEGER REFERENCES suppliers(id),          -- Must reference existing supplier
    shipment_date TEXT,
    delivery_date TEXT,
    tracking_number TEXT,
    status TEXT DEFAULT 'pending'
        CHECK (status IN ('pending', 'shipped', 'delivered', 'returned'))
);
```

**HR Translation:** "I'm creating a shipments table that connects to our existing data:
- Every shipment MUST be linked to an order (no orphan shipments!)
- The supplier_id should reference an existing supplier (if we have one)
- Status can only be: pending, shipped, delivered, or returned
- If someone tries to enter a shipment for Order #999 that doesn't exist, the database will reject it

Foreign keys keep our data connected and accurate."

### Foreign Key Benefits

| Benefit | Example |
|---------|---------|
| **Data Integrity** | Can't have order for non-existent customer |
| **Prevents Orphaned Data** | Deleting a customer with orders is prevented |
| **Automatic Linking** | Database maintains relationships |
| **Cascade Deletion** | Can auto-delete related records (careful!) |

### Enabling Foreign Key Support

SQLite requires foreign keys to be explicitly enabled:

```sql
PRAGMA foreign_keys = ON;
```

### Example: Complete E-Commerce Table Design

```sql
-- First, enable foreign keys
PRAGMA foreign_keys = ON;

-- Suppliers table
CREATE TABLE suppliers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT,
    city TEXT,
    country TEXT,
    is_active INTEGER DEFAULT 1
);

-- Product reviews table
CREATE TABLE product_reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL REFERENCES products(id),
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Shipments table
CREATE TABLE shipments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL REFERENCES orders(id),
    supplier_id INTEGER REFERENCES suppliers(id),
    shipment_date TEXT,
    delivery_date TEXT,
    tracking_number TEXT,
    status TEXT DEFAULT 'pending'
);
```

**HR Translation:** "I've built three new tables that work together:
- **Suppliers**: Our product vendors with their contact info and active status
- **Product Reviews**: Customers reviewing products they purchased (linked to both product and customer)
- **Shipments**: Tracking how orders get delivered (linked to orders, optionally to suppliers)

The foreign keys ensure all connections make sense - every review is for a real product by a real customer, every shipment is for a real order."

### Practice Exercises

1. Create a `order_returns` table linking orders, products, and customers
2. Create a `supplier_products` table to track which suppliers provide which products (many-to-many)
3. Add a foreign key to `product_reviews` referencing `customers`
4. Try inserting invalid data (wrong foreign key) and see the error

---

## Day 6: ALTER TABLE - Modifying Table Structure

### What is ALTER TABLE?

ALTER TABLE lets you **modify an existing table** without recreating it. You can:
- Add new columns
- Remove columns
- Rename columns
- Change column types

### Syntax

```sql
-- Add a column
ALTER TABLE table_name ADD COLUMN column_name datatype constraints;

-- Drop a column (SQLite has limitations - research before using)
ALTER TABLE table_name DROP COLUMN column_name;

-- Rename a column
ALTER TABLE table_name RENAME COLUMN old_name TO new_name;
```

### Adding Columns

```sql
-- Add a phone number to suppliers
ALTER TABLE suppliers ADD COLUMN phone TEXT;
```

```sql
-- Add a description to categories
ALTER TABLE categories ADD COLUMN description TEXT;
```

```sql
-- Add a validated rating column to product_reviews
ALTER TABLE product_reviews ADD COLUMN verified_purchase INTEGER DEFAULT 0;
```

**HR Translation:** "We forgot to ask for phone numbers when we created the suppliers table. I need you to add a phone column to capture that information. Also, can you add a verified_purchase flag to reviews so we know if the reviewer actually bought the product?"

### Renaming Columns

```sql
-- Rename 'name' to 'supplier_name' in suppliers table
ALTER TABLE suppliers RENAME COLUMN name TO supplier_name;
```

```sql
-- Rename 'total' to 'order_total' in orders table
ALTER TABLE orders RENAME COLUMN total TO order_total;
```

### Modifying Column Definitions

In SQLite, you cannot directly change a column type. Instead, you must:
1. Create a new table with the correct structure
2. Copy data from the old table
3. Drop the old table
4. Rename the new table

```sql
-- Example: Change email to be NOT NULL (workaround)
-- Step 1: Create new table
CREATE TABLE suppliers_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL,  -- Changed: now required
    phone TEXT
);

-- Step 2: Copy data
INSERT INTO suppliers_new (id, name, email, phone)
SELECT id, name, email, phone FROM suppliers;

-- Step 3: Drop old table
DROP TABLE suppliers;

-- Step 4: Rename new table
ALTER TABLE suppliers_new RENAME TO suppliers;
```

### Adding Constraints with ALTER

```sql
-- Add a CHECK constraint to ensure positive prices
-- SQLite allows adding CHECK via ALTER in some versions
ALTER TABLE products ADD CONSTRAINT positive_price CHECK (price > 0);
```

Note: Constraint support varies by SQLite version. Test before using in production.

### Dropping Tables

**WARNING: DROP TABLE permanently deletes the table and ALL its data!**

```sql
-- Delete a table (use with extreme caution!)
DROP TABLE table_name;
```

```sql
-- Delete only if table exists (safer)
DROP TABLE IF EXISTS table_name;
```

**HR Translation:** "We're shutting down our old product_reviews_archive table - please delete it. Make sure to verify there's no important data in there first!"

### ALTER TABLE in Practice

```sql
-- Enable foreign keys first
PRAGMA foreign_keys = ON;

-- Add new columns to customers table
ALTER TABLE customers ADD COLUMN phone TEXT;
ALTER TABLE customers ADD COLUMN address TEXT;
ALTER TABLE customers ADD COLUMN loyalty_points INTEGER DEFAULT 0;

-- Rename for clarity
ALTER TABLE customers RENAME COLUMN name TO customer_name;
```

### Practice Exercises

1. Add a `last_updated` column to the `products` table
2. Add a `notes` column to `orders` table for special instructions
3. Rename the `stock` column in `products` to `stock_quantity`
4. Create a backup of `customers` table, then drop it, then restore it

---

## Day 7: Review & Mini Quiz

### Summary: What You Learned This Week

| Day | Topic | Key Concept |
|-----|-------|-------------|
| 1 | CREATE TABLE | Build new tables with columns and types |
| 2 | Data Types | INTEGER, REAL, TEXT - choose the right one |
| 3 | Constraints | NOT NULL, UNIQUE, CHECK, DEFAULT - add rules |
| 4 | Primary Key | Unique identifier for each row |
| 5 | Foreign Key | Link tables together with REFERENCES |
| 6 | ALTER TABLE | Modify existing table structure |

---

## Mini Quiz (10 Questions)

### Q1: Create a suppliers table

Create a `suppliers` table with: id (auto-increment PK), name (required), email (unique), phone, city, country

```sql
CREATE TABLE suppliers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    phone TEXT,
    city TEXT,
    country TEXT
);
```

**HR Translation:** "I need a new suppliers file. Each supplier gets a unique ID automatically. Their name is required (can't be blank), email must be unique across all suppliers, and phone/city/country are optional details we can fill in as we learn them."

---

### Q2: What data type should you use for a product price?

```sql
-- Answer: REAL (for decimal numbers like 99.99)
price REAL NOT NULL
```

---

### Q3: Add a constraint to ensure rating is between 1 and 5

```sql
rating INTEGER CHECK (rating >= 1 AND rating <= 5)
```

---

### Q4: Create a foreign key linking orders to customers

```sql
customer_id INTEGER REFERENCES customers(id)
```

---

### Q5: What is the PRIMARY KEY rule?

The PRIMARY KEY must be UNIQUE and NOT NULL - each row needs a unique identifier that cannot be empty.

---

### Q6: Add a phone column to suppliers table

```sql
ALTER TABLE suppliers ADD COLUMN phone TEXT;
```

---

### Q7: Create a product_reviews table with proper constraints

```sql
CREATE TABLE product_reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL REFERENCES products(id),
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    review_date TEXT DEFAULT CURRENT_TIMESTAMP
);
```

**HR Translation:** "We want to collect product reviews. Each review needs a unique ID, must be tied to a real product and real customer, the rating must be 1-5 stars, the review text is optional, and the date auto-fills if not provided."

---

### Q8: What does DEFAULT CURRENT_TIMESTAMP do?

It automatically fills in the current date and time when a new row is created.

---

### Q9: Create a shipments table linking to orders and suppliers

```sql
CREATE TABLE shipments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL REFERENCES orders(id),
    supplier_id INTEGER REFERENCES suppliers(id),
    shipment_date TEXT,
    delivery_date TEXT,
    tracking_number TEXT,
    status TEXT DEFAULT 'pending'
);
```

**HR Translation:** "I need to track shipments. Each shipment has a unique ID, must be tied to an order, can optionally reference a supplier, and includes dates and tracking info. New shipments start with 'pending' status."

---

### Q10: Why use foreign keys? Give two reasons.

1. **Data Integrity** - Prevents inserting invalid references (can't reference a non-existent record)
2. **Relationships** - Connects tables together so we can query across related data

---

## Quick Reference Card

### CREATE TABLE Syntax

```sql
CREATE TABLE table_name (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    column1 datatype constraints,
    column2 datatype constraints
);
```

### Constraint Types

| Constraint | Purpose | Syntax |
|------------|---------|--------|
| NOT NULL | Cannot be empty | `name TEXT NOT NULL` |
| UNIQUE | No duplicates | `email TEXT UNIQUE` |
| CHECK | Validate condition | `price REAL CHECK (price > 0)` |
| DEFAULT | Auto-fill value | `status TEXT DEFAULT 'active'` |
| PRIMARY KEY | Unique row ID | `id INTEGER PRIMARY KEY` |
| FOREIGN KEY | Link tables | `category_id INTEGER REFERENCES categories(id)` |

### ALTER TABLE Commands

```sql
-- Add column
ALTER TABLE table_name ADD COLUMN column_name datatype;

-- Rename column
ALTER TABLE table_name RENAME COLUMN old TO new;

-- Drop table (CAREFUL!)
DROP TABLE table_name;
DROP TABLE IF EXISTS table_name;
```

### Safety Rules

1. **Always have a PRIMARY KEY** on every table
2. **Use NOT NULL** for required fields
3. **Use UNIQUE** for fields that must not duplicate
4. **Use FOREIGN KEY** to link related tables
5. **Use CHECK** to validate data ranges
6. **DEFAULT** provides fallback values
7. **DROP TABLE is permanent** - always check dependencies first

---

## Milestone Checklist (End of Week 5)

- [ ] Can create new tables with CREATE TABLE
- [ ] Understands and can choose appropriate data types
- [ ] Can add constraints (NOT NULL, UNIQUE, CHECK, DEFAULT)
- [ ] Can define PRIMARY KEY on tables
- [ ] Can create FOREIGN KEY relationships
- [ ] Can modify tables with ALTER TABLE
- [ ] Understands DROP TABLE consequences
- [ ] Can design normalized tables

---

## Week 5 Summary

**Topics Covered:**
- CREATE TABLE - Building new tables
- Data Types - INTEGER, REAL, TEXT, choosing correctly
- Constraints - NOT NULL, UNIQUE, CHECK, DEFAULT
- Primary Key - Unique row identifiers
- Foreign Key - Linking tables together
- ALTER TABLE - Modifying table structure
- DROP TABLE - Deleting tables (with caution)

**Goal:** Pass Week 5 quiz with score > 80%

---

## Next Week Preview

**Week 6: JOIN Operations**
- INNER JOIN - Matched rows from both tables
- LEFT JOIN - All rows from left + matched from right
- RIGHT JOIN - All rows from right + matched from left
- Multiple JOINs - Connect many tables in one query
- Self JOIN - Table referencing itself

---

*Week 5 of 12 — Part of the 3-Month SQL Learning Roadmap*
