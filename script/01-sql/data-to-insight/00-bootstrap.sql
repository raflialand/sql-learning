-- =====================================================
-- data-to-insight: PostgreSQL medallion bootstrap
-- =====================================================
--
-- Creates the three medallion schemas and documents how to
-- load the raw datasets into the bronze schema. Uses SEPARATE
-- databases per case (one dataset per database).
--
-- ── Case 02 — MarketHub ───────────────────────────────
--   psql -U postgres -c "CREATE DATABASE datainsight_markethub;"
--   psql -U postgres -d datainsight_markethub -f script/01-sql/data-to-insight/00-bootstrap.sql
--   psql -U postgres -d datainsight_markethub -v ON_ERROR_STOP=1 -c "SET search_path TO bronze;" \
--     -f "learning/02-sql-learning/sql-skill-push/datasets/02-intermediate/ecommerce_pg.sql"
--
-- ── Case 03 — NovaTel ─────────────────────────────────
--   psql -U postgres -c "CREATE DATABASE datainsight_novatel;"
--   psql -U postgres -d datainsight_novatel -f script/01-sql/data-to-insight/00-bootstrap.sql
--   psql -U postgres -d datainsight_novatel -v ON_ERROR_STOP=1 -c "SET search_path TO bronze;" \
--     -f "learning/02-sql-learning/sql-skill-push/datasets/03-advanced/telecom_pg.sql"
--
-- NOTE: the `_pg.sql` files CREATE/DROP tables UNQUALIFIED, so they
-- land in `bronze` when search_path is set to bronze (as above).
-- =====================================================

-- Create the three medallion schemas (idempotent)
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

-- Sanity check after loading: list tables and confirm row counts.
--   MarketHub: categories 16, vendors 14, products 120, customers 500,
--              orders 2800, order_items 7102, payments 2283, shipments 1864.
--   NovaTel:   plans 6, subscribers 4500, billing 7996, payments 6588,
--              usage_logs 7418, tickets 3800, churn 427.
SELECT schemaname, tablename
FROM pg_tables
WHERE schemaname IN ('bronze', 'silver', 'gold')
ORDER BY schemaname, tablename;
