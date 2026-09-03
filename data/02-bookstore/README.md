# Bookstore Dataset

A comprehensive synthetic bookstore dataset with intentional mid-level data quality issues for SQL practice and data cleaning exercises.

## Dataset Overview

This dataset represents a **mid-size bookstore chain** ("PageTurner Books") with both physical stores and an online presence. It covers **2 years of order history** (September 2024 - August 2026) with realistic book catalog data, customer transactions, inventory management, and operational records.

## Tables

| Table | Rows | Description |
|-------|------|-------------|
| `publishers` | 25 | Book publisher information |
| `authors` | 120 | Author profiles |
| `categories` | 30 | Book categories/genres (hierarchical) |
| `books` | 500 | Book catalog with ISBNs, pricing, metadata |
| `book_authors` | 743 | Many-to-many book-author relationships |
| `customers` | 1200 | Customer profiles |
| `stores` | 8 | Physical store locations |
| `inventory` | 2293 | Stock levels per book per store |
| `orders` | 6500 | Order headers (2 years of history) |
| `order_items` | 14949 | Individual items per order |
| `payments` | 6175 | Payment transactions |
| `shipping` | 5200 | Shipping/delivery tracking |
| `reviews` | 2500 | Customer reviews and ratings |
| `promotions` | 40 | Discount codes and promotions |
| `employees` | 65 | Staff information |

## Schema Details

### `publishers`
- Columns: `id, name, country, founded_year, website, email, phone, created_at`

### `authors`
- Columns: `id, first_name, last_name, email, nationality, birth_date, biography, website, created_at`

### `categories`
- Columns: `id, name, description, parent_category_id, created_at`

### `books`
- Columns: `id, isbn13, isbn10, title, subtitle, publication_date, pages, language, price, list_price, edition, description, publisher_id, category_id, created_at`

### `book_authors`
- Columns: `book_id, author_id, author_order`

### `customers`
- Columns: `id, first_name, last_name, email, phone, address_line1, address_line2, city, state, postal_code, country, date_of_birth, registration_date, loyalty_card_number, customer_segment`

### `stores`
- Columns: `id, name, address_line1, address_line2, city, state, postal_code, country, phone, manager_id, opening_date, store_type, square_footage, created_at`

### `inventory`
- Columns: `id, book_id, store_id, quantity, reorder_point, reorder_quantity, last_restocked_at, created_at`

### `orders`
- Columns: `id, order_number, customer_id, store_id, order_date, order_status, subtotal, tax_amount, total_amount, shipping_address, notes, created_at`

### `order_items`
- Columns: `id, order_id, book_id, quantity, unit_price, discount, line_total`

### `payments`
- Columns: `id, order_id, payment_method, amount, currency, status, transaction_id, payment_date, created_at`

### `shipping`
- Columns: `id, order_id, carrier, tracking_number, shipping_date, estimated_delivery, actual_delivery, shipping_cost, status, shipping_address, created_at`

### `reviews`
- Columns: `id, book_id, customer_id, rating, title, review_text, review_date, is_verified, helpful_votes, moderation_status`

### `promotions`
- Columns: `id, code, name, description, discount_type, discount_value, min_order_amount, max_uses, times_used, start_date, end_date, status, created_at`

### `employees`
- Columns: `id, employee_id, first_name, last_name, email, phone, role, store_id, hire_date, salary, status, created_at`

## Dirty Data Categories (Mid-Level)

This dataset includes the following data quality issues:

| Category | Description |
|----------|-------------|
| **NULL values** | ~5-10% NULLs across applicable columns (optional fields, missing data) |
| **Case inconsistency** | Mixed capitalization in names, statuses, categories (e.g., "SHIPPED" vs "Shipped" vs "shipped") |
| **Whitespace issues** | Leading/trailing spaces, extra internal spaces in names (e.g., "John  Doe") |
| **Wrong data types** | "N/A", "--", "NULL" embedded in numeric/text columns |
| **Date format inconsistency** | Mixed date formats: YYYY-MM-DD, MM/DD/YYYY, DD-MM-YYYY, Month DD, YYYY |
| **String encoding variations** | Inconsistent phone number formats, ZIP codes, order numbers |

## Usage Hints

### SQLite
```bash
sqlite3 bookstore.db
```

### PostgreSQL
```bash
psql -U your_user -d your_database -f bookstore.sql
```

### Practice Queries

This dataset is ideal for practicing:

- **Data cleaning**: Handle NULLs, fix case inconsistencies, standardize dates
- **JOIN operations**: Multi-table joins across orders, books, customers, reviews
- **Aggregation**: Sales summaries, popular books, customer segmentation
- **Window functions**: Ranking, running totals, year-over-year comparisons
- **CTEs & subqueries**: Complex business analytics
- **Data quality auditing**: Identify and fix the embedded dirty data

## Files

| File | Description |
|------|-------------|
| `bookstore.db` | SQLite database with all tables |
| `bookstore.sql` | PostgreSQL-compatible SQL script (CREATE + INSERT) |
| `generate.py` | Python script that generated this dataset |
| `README.md` | This file |
