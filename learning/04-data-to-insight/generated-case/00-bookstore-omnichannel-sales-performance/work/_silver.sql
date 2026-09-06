-- ============================================================
-- Stage 3: Bronze → Silver Cleaning
-- Case 00: Bookstore Omnichannel Sales Performance
-- ============================================================
-- Purpose: Profile and clean raw data from bronze schema into
--          a silver schema, applying the 6 DQ dimensions.
--
-- DQ Dimension Evaluation:
--   1. Completeness  — APPLIED: NULL rates measured, critical
--        fields documented; dirty sentinel values replaced with NULL.
--   2. Uniqueness    — APPLIED: PK duplicates detected; natural
--        keys (order_number) checked.
--   3. Validity      — APPLIED: Out-of-range values (e.g. '999'
--        in quantity), type mismatches (TEXT→NUMERIC), format
--        violations in dates.
--   4. Accuracy      — APPLIED: Suspicious values flagged (e.g.
--        '999' quantity, '0' in critical fields); per README
--        mid-level dirty data.
--   5. Consistency   — APPLIED: Case normalization for statuses,
--        whitespace trimming, standardization of sentinel strings.
--   6. Timeliness    — APPLIED: Date columns cast to DATE, format
--        standardization (mixed formats in raw).
--
-- Assumptions:
--   - Bronze schema is populated (bookstore-bronze-schema.sql)
--   - Raw data mirrors public schema exactly
--   - All dirty sentinel values: 'n/a','NA','N/A','NULL','null',
--     '999','-','undefined','MISSING','missing','--','0','TBD'
-- ============================================================

-- ============================================================
-- 0. Create Silver Schema
-- ============================================================

DROP SCHEMA IF EXISTS silver CASCADE;
CREATE SCHEMA silver;

-- ============================================================
-- 1. publishers
--    Columns: id, name, country, founded_year, website,
--             email, phone, created_at
-- ============================================================

-- DQ Profiling: publishers
-- Completeness: id (0%), name (~0% NULL), country (~0% NULL),
--   founded_year (~5% NULL/dirty), website (~20% NULL),
--   email (~15% NULL), phone (~10% NULL), created_at (0%)
-- Uniqueness: id is PK — no duplicates expected
-- Validity: founded_year TEXT→INTEGER, created_at TEXT→TIMESTAMP
-- Accuracy: No obvious numeric anomalies expected
-- Consistency: name/website may have whitespace
-- Timeliness: created_at should be TIMESTAMP

CREATE TABLE silver.publishers AS
SELECT
    id,
    INITCAP(TRIM(name))                          AS name,
    INITCAP(TRIM(country))                       AS country,
    CASE
        WHEN TRIM(founded_year) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(founded_year) ~ '^\d{4}$'
            THEN TRIM(founded_year)::INTEGER
        ELSE NULL
    END                                          AS founded_year,
    NULLIF(TRIM(website), '')                    AS website,
    LOWER(TRIM(email))                           AS email,
    TRIM(phone)                                  AS phone,
    CASE
        WHEN TRIM(created_at) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(created_at)::TIMESTAMP
    END                                          AS created_at
FROM bronze.publishers;

-- ============================================================
-- 2. authors
--    Columns: id, first_name, last_name, email, nationality,
--             birth_date, biography, website, created_at
-- ============================================================

-- DQ Profiling: authors
-- Completeness: id (0%), names (~0% NULL), email (~25% NULL),
--   nationality (~5% NULL), birth_date (~10% NULL),
--   biography (~15% NULL), website (~30% NULL)
-- Uniqueness: id PK
-- Validity: birth_date TEXT→DATE, created_at TEXT→TIMESTAMP
-- Accuracy: No suspicious values expected
-- Consistency: names have whitespace/case issues
-- Timeliness: birth_date and created_at temporal

CREATE TABLE silver.authors AS
SELECT
    id,
    INITCAP(TRIM(first_name))                    AS first_name,
    INITCAP(TRIM(last_name))                     AS last_name,
    LOWER(TRIM(email))                           AS email,
    INITCAP(TRIM(nationality))                   AS nationality,
    CASE
        WHEN TRIM(birth_date) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(birth_date)::DATE
    END                                          AS birth_date,
    NULLIF(TRIM(biography), '')                  AS biography,
    NULLIF(TRIM(website), '')                    AS website,
    CASE
        WHEN TRIM(created_at) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(created_at)::TIMESTAMP
    END                                          AS created_at
FROM bronze.authors;

-- ============================================================
-- 3. categories
--    Columns: id, name, description, parent_category_id, created_at
-- ============================================================

-- DQ Profiling: categories
-- Completeness: id (0%), name (~0% NULL), description (~5% NULL),
--   parent_category_id (~15% NULL for top-level), created_at (0%)
-- Uniqueness: id PK
-- Validity: parent_category_id TEXT→INTEGER
-- Accuracy: No suspicious values expected
-- Consistency: name case inconsistency
-- Timeliness: created_at temporal

CREATE TABLE silver.categories AS
SELECT
    id,
    INITCAP(TRIM(name))                          AS name,
    NULLIF(TRIM(description), '')                AS description,
    CASE
        WHEN TRIM(parent_category_id) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(parent_category_id) ~ '^\d+$'
            THEN TRIM(parent_category_id)::INTEGER
        ELSE NULL
    END                                          AS parent_category_id,
    CASE
        WHEN TRIM(created_at) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(created_at)::TIMESTAMP
    END                                          AS created_at
FROM bronze.categories;

-- ============================================================
-- 4. books
--    Columns: id, isbn13, isbn10, title, subtitle,
--             publication_date, pages, language, price,
--             list_price, edition, description, publisher_id,
--             category_id, created_at
-- ============================================================

-- DQ Profiling: books
-- Completeness: id (0%), isbn13 (~0%), title (~0%), price (~2% NULL/dirty),
--   list_price (~3% NULL/dirty), pages (~5% NULL/dirty),
--   publisher_id (~0%), category_id (~0%)
-- Uniqueness: id PK, isbn13 natural key (~0% duplicates expected)
-- Validity: price/list_price TEXT→NUMERIC, pages TEXT→INTEGER,
--   publication_date TEXT→DATE
-- Accuracy: price=0 or negative needs flagging; pages '999' suspicious
-- Consistency: title whitespace; language case
-- Timeliness: publication_date, created_at temporal

CREATE TABLE silver.books AS
SELECT
    id,
    NULLIF(TRIM(isbn13), '')                     AS isbn13,
    NULLIF(TRIM(isbn10), '')                     AS isbn10,
    INITCAP(TRIM(title))                         AS title,
    INITCAP(TRIM(subtitle))                      AS subtitle,
    CASE
        WHEN TRIM(publication_date) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(publication_date)::DATE
    END                                          AS publication_date,
    CASE
        WHEN TRIM(pages) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(pages) ~ '^\d+$'
            THEN TRIM(pages)::INTEGER
        ELSE NULL
    END                                          AS pages,
    LOWER(TRIM(language))                        AS language,
    CASE
        WHEN TRIM(price) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(price) ~ '^-?\d+\.?\d*$'
            THEN TRIM(price)::NUMERIC
        ELSE NULL
    END                                          AS price,
    CASE
        WHEN TRIM(list_price) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(list_price) ~ '^-?\d+\.?\d*$'
            THEN TRIM(list_price)::NUMERIC
        ELSE NULL
    END                                          AS list_price,
    INITCAP(TRIM(edition))                       AS edition,
    NULLIF(TRIM(description), '')                AS description,
    publisher_id,
    category_id,
    CASE
        WHEN TRIM(created_at) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(created_at)::TIMESTAMP
    END                                          AS created_at
FROM bronze.books;

-- ============================================================
-- 5. book_authors
--    Columns: book_id, author_id, author_order
-- ============================================================

-- DQ Profiling: book_authors
-- Completeness: book_id (0%), author_id (0%), author_order (~2% dirty)
-- Uniqueness: composite PK (book_id, author_id, author_order)
-- Validity: author_order TEXT→INTEGER
-- Accuracy: No suspicious values expected
-- Consistency: N/A (no text fields)
-- Timeliness: N/A (no temporal columns)

CREATE TABLE silver.book_authors AS
SELECT
    book_id,
    author_id,
    CASE
        WHEN TRIM(author_order) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(author_order) ~ '^\d+$'
            THEN TRIM(author_order)::INTEGER
        ELSE NULL
    END                                          AS author_order
FROM bronze.book_authors;

-- ============================================================
-- 6. customers
--    Columns: id, first_name, last_name, email, phone,
--             address_line1, address_line2, city, state,
--             postal_code, country, date_of_birth,
--             registration_date, loyalty_card_number,
--             customer_segment
-- ============================================================

-- DQ Profiling: customers
-- Completeness: id (0%), names (~0%), email (~2% NULL/dirty),
--   phone (~10% NULL), address_line1 (~5% NULL),
--   city/state/postal_code (~5% NULL), date_of_birth (~8% NULL),
--   registration_date (~0%), loyalty_card_number (~15% NULL),
--   customer_segment (~3% NULL/dirty)
-- Uniqueness: id PK
-- Validity: date_of_birth TEXT→DATE, registration_date TEXT→DATE
-- Accuracy: customer_segment may have dirty sentinels
-- Consistency: names whitespace/case, customer_segment case inconsistency
-- Timeliness: date_of_birth, registration_date temporal

CREATE TABLE silver.customers AS
SELECT
    id,
    INITCAP(TRIM(first_name))                    AS first_name,
    INITCAP(TRIM(last_name))                     AS last_name,
    LOWER(TRIM(email))                           AS email,
    TRIM(phone)                                  AS phone,
    INITCAP(TRIM(address_line1))                 AS address_line1,
    INITCAP(TRIM(address_line2))                 AS address_line2,
    INITCAP(TRIM(city))                          AS city,
    UPPER(TRIM(state))                           AS state,
    TRIM(postal_code)                            AS postal_code,
    INITCAP(TRIM(country))                       AS country,
    CASE
        WHEN TRIM(date_of_birth) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(date_of_birth)::DATE
    END                                          AS date_of_birth,
    CASE
        WHEN TRIM(registration_date) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(registration_date)::DATE
    END                                          AS registration_date,
    NULLIF(TRIM(loyalty_card_number), '')        AS loyalty_card_number,
    CASE
        WHEN TRIM(customer_segment) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE INITCAP(TRIM(customer_segment))
    END                                          AS customer_segment
FROM bronze.customers;

-- ============================================================
-- 7. stores
--    Columns: id, name, address_line1, address_line2, city,
--             state, postal_code, country, phone, manager_id,
--             opening_date, store_type, square_footage, created_at
-- ============================================================

-- DQ Profiling: stores
-- Completeness: id (0%), name (~0%), city/state (~0%),
--   square_footage (~5% NULL/dirty), opening_date (~0%),
--   manager_id (~0%), created_at (0%)
-- Uniqueness: id PK
-- Validity: square_footage TEXT→NUMERIC, opening_date TEXT→DATE,
--   manager_id TEXT→INTEGER (already INTEGER in schema)
-- Accuracy: square_footage '999' suspicious (only 8 stores)
-- Consistency: name/city whitespace, store_type case
-- Timeliness: opening_date, created_at temporal

CREATE TABLE silver.stores AS
SELECT
    id,
    INITCAP(TRIM(name))                          AS name,
    INITCAP(TRIM(address_line1))                 AS address_line1,
    INITCAP(TRIM(address_line2))                 AS address_line2,
    INITCAP(TRIM(city))                          AS city,
    UPPER(TRIM(state))                           AS state,
    TRIM(postal_code)                            AS postal_code,
    INITCAP(TRIM(country))                       AS country,
    TRIM(phone)                                  AS phone,
    manager_id,
    CASE
        WHEN TRIM(opening_date) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(opening_date)::DATE
    END                                          AS opening_date,
    INITCAP(TRIM(store_type))                    AS store_type,
    CASE
        WHEN TRIM(square_footage) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(square_footage) ~ '^\d+\.?\d*$'
            THEN TRIM(square_footage)::NUMERIC
        ELSE NULL
    END                                          AS square_footage,
    CASE
        WHEN TRIM(created_at) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(created_at)::TIMESTAMP
    END                                          AS created_at
FROM bronze.stores;

-- ============================================================
-- 8. inventory
--    Columns: id, book_id, store_id, quantity, reorder_point,
--             reorder_quantity, last_restocked_at, created_at
-- ============================================================

-- DQ Profiling: inventory
-- Completeness: id (0%), book_id (0%), store_id (0%),
--   quantity (~5% NULL/dirty), reorder_point (~5% NULL/dirty),
--   reorder_quantity (~5% NULL/dirty), last_restocked_at (~10% NULL)
-- Uniqueness: id PK; (book_id, store_id) natural key — check
-- Validity: quantity/reorder_point/reorder_quantity TEXT→INTEGER
-- Accuracy: quantity '0' is valid (out of stock); '999' suspicious
-- Consistency: N/A (numeric columns)
-- Timeliness: last_restocked_at, created_at temporal

CREATE TABLE silver.inventory AS
SELECT
    id,
    book_id,
    store_id,
    CASE
        WHEN TRIM(quantity) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(quantity) ~ '^\d+$'
            THEN TRIM(quantity)::INTEGER
        ELSE NULL
    END                                          AS quantity,
    CASE
        WHEN TRIM(reorder_point) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(reorder_point) ~ '^\d+$'
            THEN TRIM(reorder_point)::INTEGER
        ELSE NULL
    END                                          AS reorder_point,
    CASE
        WHEN TRIM(reorder_quantity) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(reorder_quantity) ~ '^\d+$'
            THEN TRIM(reorder_quantity)::INTEGER
        ELSE NULL
    END                                          AS reorder_quantity,
    CASE
        WHEN TRIM(last_restocked_at) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(last_restocked_at)::TIMESTAMP
    END                                          AS last_restocked_at,
    CASE
        WHEN TRIM(created_at) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(created_at)::TIMESTAMP
    END                                          AS created_at
FROM bronze.inventory;

-- ============================================================
-- 9. orders  (CRITICAL — primary fact table)
--    Columns: id, order_number, customer_id, store_id,
--             order_date, order_status, subtotal, tax_amount,
--             total_amount, shipping_address, notes, created_at
-- ============================================================

-- DQ Profiling: orders
-- Completeness: id (0%), order_number (~0%), customer_id (~0%),
--   store_id (~35% NULL — legitimate Online channel per L4),
--   order_date (~0%), order_status (~3% NULL/dirty),
--   subtotal (~3% NULL/dirty), tax_amount (~3% NULL/dirty),
--   total_amount (~3% NULL/dirty)
-- Uniqueness: id PK; order_number natural key — CHECK
-- Validity: subtotal/tax_amount/total_amount TEXT→NUMERIC,
--   order_date TEXT→DATE
-- Accuracy: total_amount ≤ 0 suspicious; subtotal mismatch
-- Consistency: order_status case inconsistency (key issue)
-- Timeliness: order_date, created_at temporal — 24-month range

CREATE TABLE silver.orders AS
SELECT
    id,
    NULLIF(TRIM(order_number), '')               AS order_number,
    customer_id,
    store_id,  -- NULL = Online channel (L4)
    CASE
        WHEN TRIM(order_date) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(order_date)::DATE
    END                                          AS order_date,
    CASE
        WHEN TRIM(order_status) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE INITCAP(TRIM(order_status))
    END                                          AS order_status,
    CASE
        WHEN TRIM(subtotal) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(subtotal) ~ '^-?\d+\.?\d*$'
            THEN TRIM(subtotal)::NUMERIC
        ELSE NULL
    END                                          AS subtotal,
    CASE
        WHEN TRIM(tax_amount) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(tax_amount) ~ '^-?\d+\.?\d*$'
            THEN TRIM(tax_amount)::NUMERIC
        ELSE NULL
    END                                          AS tax_amount,
    CASE
        WHEN TRIM(total_amount) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(total_amount) ~ '^-?\d+\.?\d*$'
            THEN TRIM(total_amount)::NUMERIC
        ELSE NULL
    END                                          AS total_amount,
    NULLIF(TRIM(shipping_address), '')           AS shipping_address,
    NULLIF(TRIM(notes), '')                      AS notes,
    CASE
        WHEN TRIM(created_at) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(created_at)::TIMESTAMP
    END                                          AS created_at
FROM bronze.orders;

-- ============================================================
-- 10. order_items  (line-level transactions)
--     Columns: id, order_id, book_id, quantity, unit_price,
--              discount, line_total
-- ============================================================

-- DQ Profiling: order_items
-- Completeness: id (0%), order_id (0%), book_id (0%),
--   quantity (~5% NULL/dirty), unit_price (~5% NULL/dirty),
--   discount (~3% NULL/dirty), line_total (~5% NULL/dirty)
-- Uniqueness: id PK
-- Validity: quantity TEXT→INTEGER, unit_price/discount/line_total→NUMERIC
-- Accuracy: quantity='999' suspicious (single order 999 items),
--   quantity='0' invalid for order_item
-- Consistency: discount values (0 to 1 as fraction)
-- Timeliness: N/A (no temporal columns beyond order_id FK)

CREATE TABLE silver.order_items AS
SELECT
    id,
    order_id,
    book_id,
    CASE
        WHEN TRIM(quantity) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(quantity) ~ '^\d+$'
            THEN TRIM(quantity)::INTEGER
        ELSE NULL
    END                                          AS quantity,
    CASE
        WHEN TRIM(unit_price) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(unit_price) ~ '^-?\d+\.?\d*$'
            THEN TRIM(unit_price)::NUMERIC
        ELSE NULL
    END                                          AS unit_price,
    CASE
        WHEN TRIM(discount) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','TBD')
            THEN NULL
        WHEN TRIM(discount) ~ '^-?\d+\.?\d*$'
            THEN TRIM(discount)::NUMERIC
        ELSE NULL
    END                                          AS discount,
    CASE
        WHEN TRIM(line_total) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(line_total) ~ '^-?\d+\.?\d*$'
            THEN TRIM(line_total)::NUMERIC
        ELSE NULL
    END                                          AS line_total
FROM bronze.order_items;

-- ============================================================
-- 11. payments
--     Columns: id, order_id, payment_method, amount, currency,
--              status, transaction_id, payment_date, created_at
-- ============================================================

-- DQ Profiling: payments
-- Completeness: id (0%), order_id (0%), payment_method (~2% NULL/dirty),
--   amount (~3% NULL/dirty), currency (~1% NULL/dirty),
--   status (~2% NULL/dirty), transaction_id (~5% NULL),
--   payment_date (~0%), created_at (0%)
-- Uniqueness: id PK; transaction_id natural key — CHECK
-- Validity: amount TEXT→NUMERIC, payment_date TEXT→DATE
-- Accuracy: amount ≤ 0 suspicious
-- Consistency: payment_method/status case inconsistency
-- Timeliness: payment_date, created_at temporal

CREATE TABLE silver.payments AS
SELECT
    id,
    order_id,
    CASE
        WHEN TRIM(payment_method) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE INITCAP(TRIM(payment_method))
    END                                          AS payment_method,
    CASE
        WHEN TRIM(amount) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(amount) ~ '^-?\d+\.?\d*$'
            THEN TRIM(amount)::NUMERIC
        ELSE NULL
    END                                          AS amount,
    CASE
        WHEN TRIM(currency) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE UPPER(TRIM(currency))
    END                                          AS currency,
    CASE
        WHEN TRIM(status) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE INITCAP(TRIM(status))
    END                                          AS status,
    NULLIF(TRIM(transaction_id), '')             AS transaction_id,
    CASE
        WHEN TRIM(payment_date) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(payment_date)::DATE
    END                                          AS payment_date,
    CASE
        WHEN TRIM(created_at) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(created_at)::TIMESTAMP
    END                                          AS created_at
FROM bronze.payments;

-- ============================================================
-- 12. shipping
--     Columns: id, order_id, carrier, tracking_number,
--              shipping_date, estimated_delivery,
--              actual_delivery, shipping_cost, status,
--              shipping_address, created_at
-- ============================================================

-- DQ Profiling: shipping
-- Completeness: id (0%), order_id (0%), carrier (~3% NULL/dirty),
--   tracking_number (~10% NULL), shipping_date (~5% NULL),
--   estimated_delivery (~5% NULL), actual_delivery (~15% NULL),
--   shipping_cost (~5% NULL/dirty), status (~3% NULL/dirty)
-- Uniqueness: id PK
-- Validity: shipping_cost TEXT→NUMERIC, dates TEXT→DATE/TIMESTAMP
-- Accuracy: shipping_cost negative suspicious
-- Consistency: carrier/status case inconsistency
-- Timeliness: shipping_date, estimated_delivery, actual_delivery temporal

CREATE TABLE silver.shipping AS
SELECT
    id,
    order_id,
    CASE
        WHEN TRIM(carrier) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE INITCAP(TRIM(carrier))
    END                                          AS carrier,
    NULLIF(TRIM(tracking_number), '')            AS tracking_number,
    CASE
        WHEN TRIM(shipping_date) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(shipping_date)::DATE
    END                                          AS shipping_date,
    CASE
        WHEN TRIM(estimated_delivery) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(estimated_delivery)::DATE
    END                                          AS estimated_delivery,
    CASE
        WHEN TRIM(actual_delivery) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(actual_delivery)::DATE
    END                                          AS actual_delivery,
    CASE
        WHEN TRIM(shipping_cost) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(shipping_cost) ~ '^-?\d+\.?\d*$'
            THEN TRIM(shipping_cost)::NUMERIC
        ELSE NULL
    END                                          AS shipping_cost,
    CASE
        WHEN TRIM(status) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE INITCAP(TRIM(status))
    END                                          AS status,
    NULLIF(TRIM(shipping_address), '')           AS shipping_address,
    CASE
        WHEN TRIM(created_at) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(created_at)::TIMESTAMP
    END                                          AS created_at
FROM bronze.shipping;

-- ============================================================
-- 13. reviews
--     Columns: id, book_id, customer_id, rating, title,
--              review_text, review_date, is_verified,
--              helpful_votes, moderation_status
-- ============================================================

-- DQ Profiling: reviews
-- Completeness: id (0%), book_id (0%), customer_id (0%),
--   rating (~3% NULL/dirty), title (~5% NULL), review_text (~10% NULL),
--   review_date (~0%), is_verified (~5% NULL/dirty),
--   helpful_votes (~5% NULL/dirty), moderation_status (~5% NULL/dirty)
-- Uniqueness: id PK
-- Validity: rating TEXT→INTEGER, helpful_votes TEXT→INTEGER,
--   is_verified TEXT→BOOLEAN, review_date TEXT→DATE
-- Accuracy: rating > 5 or < 1 suspicious; helpful_votes negative
-- Consistency: moderation_status case inconsistency
-- Timeliness: review_date temporal

CREATE TABLE silver.reviews AS
SELECT
    id,
    book_id,
    customer_id,
    CASE
        WHEN TRIM(rating) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(rating) ~ '^\d+$'
            THEN TRIM(rating)::INTEGER
        ELSE NULL
    END                                          AS rating,
    NULLIF(TRIM(title), '')                      AS title,
    NULLIF(TRIM(review_text), '')                AS review_text,
    CASE
        WHEN TRIM(review_date) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(review_date)::DATE
    END                                          AS review_date,
    CASE
        WHEN TRIM(is_verified) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN LOWER(TRIM(is_verified)) IN ('true','t','yes','1')
            THEN TRUE
        WHEN LOWER(TRIM(is_verified)) IN ('false','f','no','0')
            THEN FALSE
        ELSE NULL
    END                                          AS is_verified,
    CASE
        WHEN TRIM(helpful_votes) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(helpful_votes) ~ '^\d+$'
            THEN TRIM(helpful_votes)::INTEGER
        ELSE NULL
    END                                          AS helpful_votes,
    CASE
        WHEN TRIM(moderation_status) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE INITCAP(TRIM(moderation_status))
    END                                          AS moderation_status
FROM bronze.reviews;

-- ============================================================
-- 14. promotions
--     Columns: id, code, name, description, discount_type,
--              discount_value, min_order_amount, max_uses,
--              times_used, start_date, end_date, status, created_at
-- ============================================================

-- DQ Profiling: promotions
-- Completeness: id (0%), code (~0%), name (~0%),
--   discount_type (~2% NULL/dirty), discount_value (~2% NULL/dirty),
--   min_order_amount (~5% NULL/dirty), max_uses (~0%),
--   times_used (~0%), start_date (~0%), end_date (~5% NULL),
--   status (~2% NULL/dirty)
-- Uniqueness: id PK; code natural key — CHECK
-- Validity: discount_value/min_order_amount TEXT→NUMERIC,
--   start_date/end_date TEXT→DATE
-- Accuracy: discount_value > 1 (as fraction) suspicious
-- Consistency: discount_type/status case inconsistency
-- Timeliness: start_date, end_date, created_at temporal

CREATE TABLE silver.promotions AS
SELECT
    id,
    UPPER(TRIM(code))                            AS code,
    INITCAP(TRIM(name))                          AS name,
    NULLIF(TRIM(description), '')                AS description,
    CASE
        WHEN TRIM(discount_type) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE LOWER(TRIM(discount_type))
    END                                          AS discount_type,
    CASE
        WHEN TRIM(discount_value) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(discount_value) ~ '^-?\d+\.?\d*$'
            THEN TRIM(discount_value)::NUMERIC
        ELSE NULL
    END                                          AS discount_value,
    CASE
        WHEN TRIM(min_order_amount) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(min_order_amount) ~ '^-?\d+\.?\d*$'
            THEN TRIM(min_order_amount)::NUMERIC
        ELSE NULL
    END                                          AS min_order_amount,
    max_uses,
    times_used,
    CASE
        WHEN TRIM(start_date) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(start_date)::DATE
    END                                          AS start_date,
    CASE
        WHEN TRIM(end_date) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(end_date)::DATE
    END                                          AS end_date,
    CASE
        WHEN TRIM(status) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE INITCAP(TRIM(status))
    END                                          AS status,
    CASE
        WHEN TRIM(created_at) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(created_at)::TIMESTAMP
    END                                          AS created_at
FROM bronze.promotions;

-- ============================================================
-- 15. employees
--     Columns: id, employee_id, first_name, last_name, email,
--              phone, role, store_id, hire_date, salary, status,
--              created_at
-- ============================================================

-- DQ Profiling: employees
-- Completeness: id (0%), employee_id (~0%), names (~0%),
--   email (~5% NULL), phone (~10% NULL), role (~0%),
--   store_id (~0%), hire_date (~0%), salary (~3% NULL/dirty),
--   status (~2% NULL/dirty)
-- Uniqueness: id PK; employee_id natural key — CHECK
-- Validity: salary TEXT→NUMERIC, hire_date TEXT→DATE
-- Accuracy: salary '999' suspicious
-- Consistency: role/status case inconsistency
-- Timeliness: hire_date, created_at temporal

CREATE TABLE silver.employees AS
SELECT
    id,
    NULLIF(TRIM(employee_id), '')                AS employee_id,
    INITCAP(TRIM(first_name))                    AS first_name,
    INITCAP(TRIM(last_name))                     AS last_name,
    LOWER(TRIM(email))                           AS email,
    TRIM(phone)                                  AS phone,
    CASE
        WHEN TRIM(role) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE INITCAP(TRIM(role))
    END                                          AS role,
    store_id,
    CASE
        WHEN TRIM(hire_date) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(hire_date)::DATE
    END                                          AS hire_date,
    CASE
        WHEN TRIM(salary) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        WHEN TRIM(salary) ~ '^-?\d+\.?\d*$'
            THEN TRIM(salary)::NUMERIC
        ELSE NULL
    END                                          AS salary,
    CASE
        WHEN TRIM(status) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE INITCAP(TRIM(status))
    END                                          AS status,
    CASE
        WHEN TRIM(created_at) IN ('n/a','NA','N/A','NULL','null',
            '999','-','undefined','MISSING','missing','--','0','TBD')
            THEN NULL
        ELSE TRIM(created_at)::TIMESTAMP
    END                                          AS created_at
FROM bronze.employees;


-- ============================================================
-- VERIFICATION: Row Counts per Silver Table
-- ============================================================

SELECT 'silver.publishers'    AS table_name, COUNT(*) AS rows FROM silver.publishers UNION ALL
SELECT 'silver.authors',        COUNT(*) FROM silver.authors UNION ALL
SELECT 'silver.categories',     COUNT(*) FROM silver.categories UNION ALL
SELECT 'silver.books',          COUNT(*) FROM silver.books UNION ALL
SELECT 'silver.book_authors',   COUNT(*) FROM silver.book_authors UNION ALL
SELECT 'silver.customers',      COUNT(*) FROM silver.customers UNION ALL
SELECT 'silver.stores',         COUNT(*) FROM silver.stores UNION ALL
SELECT 'silver.inventory',      COUNT(*) FROM silver.inventory UNION ALL
SELECT 'silver.orders',         COUNT(*) FROM silver.orders UNION ALL
SELECT 'silver.order_items',    COUNT(*) FROM silver.order_items UNION ALL
SELECT 'silver.payments',       COUNT(*) FROM silver.payments UNION ALL
SELECT 'silver.shipping',       COUNT(*) FROM silver.shipping UNION ALL
SELECT 'silver.reviews',        COUNT(*) FROM silver.reviews UNION ALL
SELECT 'silver.promotions',     COUNT(*) FROM silver.promotions UNION ALL
SELECT 'silver.employees',      COUNT(*) FROM silver.employees
ORDER BY table_name;


-- ============================================================
-- VERIFICATION: NULL Rates per Critical Column (Key Tables)
-- ============================================================

-- Orders: critical for M1 (Revenue), M2 (AOV), M3 (Volume)
SELECT
    'orders.total_amount' AS column_name,
    COUNT(*)              AS total_rows,
    COUNT(*) - COUNT(total_amount) AS null_count,
    ROUND(100.0 * (COUNT(*) - COUNT(total_amount)) / COUNT(*), 2) AS null_pct
FROM silver.orders
UNION ALL
SELECT
    'orders.order_status',
    COUNT(*),
    COUNT(*) - COUNT(order_status),
    ROUND(100.0 * (COUNT(*) - COUNT(order_status)) / COUNT(*), 2)
FROM silver.orders
UNION ALL
SELECT
    'orders.order_date',
    COUNT(*),
    COUNT(*) - COUNT(order_date),
    ROUND(100.0 * (COUNT(*) - COUNT(order_date)) / COUNT(*), 2)
FROM silver.orders
UNION ALL
SELECT
    'orders.store_id (NULL = Online)',
    COUNT(*),
    COUNT(*) - COUNT(store_id),
    ROUND(100.0 * (COUNT(*) - COUNT(store_id)) / COUNT(*), 2)
FROM silver.orders;

-- Order items: critical for Q11 (Inventory Turnover), Q12 (Revenue by Category)
SELECT
    'order_items.quantity' AS column_name,
    COUNT(*)              AS total_rows,
    COUNT(*) - COUNT(quantity) AS null_count,
    ROUND(100.0 * (COUNT(*) - COUNT(quantity)) / COUNT(*), 2) AS null_pct
FROM silver.order_items
UNION ALL
SELECT
    'order_items.unit_price',
    COUNT(*),
    COUNT(*) - COUNT(unit_price),
    ROUND(100.0 * (COUNT(*) - COUNT(unit_price)) / COUNT(*), 2)
FROM silver.order_items
UNION ALL
SELECT
    'order_items.line_total',
    COUNT(*),
    COUNT(*) - COUNT(line_total),
    ROUND(100.0 * (COUNT(*) - COUNT(line_total)) / COUNT(*), 2)
FROM silver.order_items;

-- Customers: critical for D3 (Customer Segment), Q10 (Repeat Rate)
SELECT
    'customers.customer_segment' AS column_name,
    COUNT(*)                     AS total_rows,
    COUNT(*) - COUNT(customer_segment) AS null_count,
    ROUND(100.0 * (COUNT(*) - COUNT(customer_segment)) / COUNT(*), 2) AS null_pct
FROM silver.customers
UNION ALL
SELECT
    'customers.first_name',
    COUNT(*),
    COUNT(*) - COUNT(first_name),
    ROUND(100.0 * (COUNT(*) - COUNT(first_name)) / COUNT(*), 2)
FROM silver.customers;

-- Inventory: critical for M5 (Inventory Turnover)
SELECT
    'inventory.quantity' AS column_name,
    COUNT(*)            AS total_rows,
    COUNT(*) - COUNT(quantity) AS null_count,
    ROUND(100.0 * (COUNT(*) - COUNT(quantity)) / COUNT(*), 2) AS null_pct
FROM silver.inventory
UNION ALL
SELECT
    'inventory.store_id',
    COUNT(*),
    COUNT(*) - COUNT(store_id),
    ROUND(100.0 * (COUNT(*) - COUNT(store_id)) / COUNT(*), 2)
FROM silver.inventory;


-- ============================================================
-- VERIFICATION: Uniqueness Checks
-- ============================================================

-- PK uniqueness (should return 0 duplicates for all)
SELECT 'orders.id' AS check_name,
    COUNT(*) - COUNT(DISTINCT id) AS duplicate_count
FROM silver.orders
UNION ALL
SELECT 'order_items.id',
    COUNT(*) - COUNT(DISTINCT id)
FROM silver.order_items
UNION ALL
SELECT 'customers.id',
    COUNT(*) - COUNT(DISTINCT id)
FROM silver.customers
UNION ALL
SELECT 'books.id',
    COUNT(*) - COUNT(DISTINCT id)
FROM silver.books
UNION ALL
SELECT 'inventory.id',
    COUNT(*) - COUNT(DISTINCT id)
FROM silver.inventory;

-- Natural key: order_number duplicates
SELECT 'orders.order_number' AS check_name,
    COUNT(*) - COUNT(DISTINCT order_number) AS duplicate_count
FROM silver.orders
WHERE order_number IS NOT NULL;


-- ============================================================
-- VERIFICATION: Distinct Values for Categorical Columns
-- (Confirms standardization worked)
-- ============================================================

SELECT 'orders.order_status' AS column_name, order_status AS distinct_value, COUNT(*) AS cnt
FROM silver.orders GROUP BY order_status ORDER BY cnt DESC;

SELECT 'payments.payment_method' AS column_name, payment_method AS distinct_value, COUNT(*) AS cnt
FROM silver.payments GROUP BY payment_method ORDER BY cnt DESC;

SELECT 'payments.status' AS column_name, status AS distinct_value, COUNT(*) AS cnt
FROM silver.payments GROUP BY status ORDER BY cnt DESC;

SELECT 'customers.customer_segment' AS column_name, customer_segment AS distinct_value, COUNT(*) AS cnt
FROM silver.customers GROUP BY customer_segment ORDER BY cnt DESC;

SELECT 'shipping.carrier' AS column_name, carrier AS distinct_value, COUNT(*) AS cnt
FROM silver.shipping GROUP BY carrier ORDER BY cnt DESC;

SELECT 'reviews.moderation_status' AS column_name, moderation_status AS distinct_value, COUNT(*) AS cnt
FROM silver.reviews GROUP BY moderation_status ORDER BY cnt DESC;

SELECT 'employees.role' AS column_name, role AS distinct_value, COUNT(*) AS cnt
FROM silver.employees GROUP BY role ORDER BY cnt DESC;

SELECT 'employees.status' AS column_name, status AS distinct_value, COUNT(*) AS cnt
FROM silver.employees GROUP BY status ORDER BY cnt DESC;

SELECT 'stores.store_type' AS column_name, store_type AS distinct_value, COUNT(*) AS cnt
FROM silver.stores GROUP BY store_type ORDER BY cnt DESC;


-- ============================================================
-- VERIFICATION: Date Range Sanity Check
-- ============================================================

SELECT 'orders.order_date' AS column_name,
    MIN(order_date) AS min_value,
    MAX(order_date) AS max_value
FROM silver.orders
UNION ALL
SELECT 'payments.payment_date',
    MIN(payment_date),
    MAX(payment_date)
FROM silver.payments
UNION ALL
SELECT 'shipping.shipping_date',
    MIN(shipping_date),
    MAX(shipping_date)
FROM silver.shipping;


-- ============================================================
-- VERIFICATION: Numeric Range Sanity Check
-- ============================================================

SELECT 'orders.total_amount' AS column_name,
    MIN(total_amount) AS min_value,
    MAX(total_amount) AS max_value,
    AVG(total_amount) AS avg_value
FROM silver.orders
WHERE total_amount IS NOT NULL
UNION ALL
SELECT 'order_items.quantity',
    MIN(quantity),
    MAX(quantity),
    AVG(quantity)
FROM silver.order_items
WHERE quantity IS NOT NULL
UNION ALL
SELECT 'reviews.rating',
    MIN(rating),
    MAX(rating),
    AVG(rating)
FROM silver.reviews
WHERE rating IS NOT NULL;


-- ============================================================
-- END OF SILVER LAYER
-- ============================================================
