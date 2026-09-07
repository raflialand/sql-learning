-- ============================================================
-- Bookstore Raw Schema Copy
-- Copies all tables from public schema to raw schema
-- preserving exact data from the loaded dataset
-- ============================================================

-- Create raw schema
DROP SCHEMA IF EXISTS bronze CASCADE;
CREATE SCHEMA bronze;

-- Copy tables in dependency order (parent tables first)

-- 1. publishers (no dependencies)
CREATE TABLE bronze.publishers AS SELECT * FROM public.publishers;

-- 2. authors (no dependencies)
CREATE TABLE bronze.authors AS SELECT * FROM public.authors;

-- 3. categories (no dependencies)
CREATE TABLE bronze.categories AS SELECT * FROM public.categories;

-- 4. books (depends on publishers, categories)
CREATE TABLE bronze.books AS SELECT * FROM public.books;

-- 5. book_authors (depends on books, authors)
CREATE TABLE bronze.book_authors AS SELECT * FROM public.book_authors;

-- 6. customers (no dependencies)
CREATE TABLE bronze.customers AS SELECT * FROM public.customers;

-- 7. stores (no dependencies)
CREATE TABLE bronze.stores AS SELECT * FROM public.stores;

-- 8. inventory (depends on books, stores)
CREATE TABLE bronze.inventory AS SELECT * FROM public.inventory;

-- 9. orders (depends on customers, stores)
CREATE TABLE bronze.orders AS SELECT * FROM public.orders;

-- 10. order_items (depends on orders, books)
CREATE TABLE bronze.order_items AS SELECT * FROM public.order_items;

-- 11. payments (depends on orders)
CREATE TABLE bronze.payments AS SELECT * FROM public.payments;

-- 12. shipping (depends on orders)
CREATE TABLE bronze.shipping AS SELECT * FROM public.shipping;

-- 13. reviews (depends on books, customers)
CREATE TABLE bronze.reviews AS SELECT * FROM public.reviews;

-- 14. promotions (no dependencies)
CREATE TABLE bronze.promotions AS SELECT * FROM public.promotions;

-- 15. employees (depends on stores)
CREATE TABLE bronze.employees AS SELECT * FROM public.employees;

-- Verify row counts
SELECT 'bronze.publishers' AS table_name, COUNT(*) AS rows FROM bronze.publishers UNION ALL
SELECT 'bronze.authors', COUNT(*) FROM bronze.authors UNION ALL
SELECT 'bronze.categories', COUNT(*) FROM bronze.categories UNION ALL
SELECT 'bronze.books', COUNT(*) FROM bronze.books UNION ALL
SELECT 'bronze.book_authors', COUNT(*) FROM bronze.book_authors UNION ALL
SELECT 'bronze.customers', COUNT(*) FROM bronze.customers UNION ALL
SELECT 'bronze.stores', COUNT(*) FROM bronze.stores UNION ALL
SELECT 'bronze.inventory', COUNT(*) FROM bronze.inventory UNION ALL
SELECT 'bronze.orders', COUNT(*) FROM bronze.orders UNION ALL
SELECT 'bronze.order_items', COUNT(*) FROM bronze.order_items UNION ALL
SELECT 'bronze.payments', COUNT(*) FROM bronze.payments UNION ALL
SELECT 'bronze.shipping', COUNT(*) FROM bronze.shipping UNION ALL
SELECT 'bronze.reviews', COUNT(*) FROM bronze.reviews UNION ALL
SELECT 'bronze.promotions', COUNT(*) FROM bronze.promotions UNION ALL
SELECT 'bronze.employees', COUNT(*) FROM bronze.employees
ORDER BY table_name;
