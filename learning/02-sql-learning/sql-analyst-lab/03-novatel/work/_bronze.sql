-- [create table bronze.billing]
CREATE TABLE bronze.billing (LIKE public.billing INCLUDING ALL);
-- [input data]
INSERT INTO bronze.billing
SELECT * FROM public.billing;
-- [check]
SELECT * FROM bronze.billing;
--
--
-- [create table bronze.churn]
CREATE TABLE bronze.churn (LIKE public.churn INCLUDING ALL);
-- [input data]
INSERT INTO bronze.churn
SELECT * FROM public.churn;
-- [check]
SELECT * FROM bronze.churn;
--
--
-- [create table bronze.payments]
CREATE TABLE bronze.payments (LIKE public.payments INCLUDING ALL);
-- [input data]
INSERT INTO bronze.payments
SELECT * FROM public.payments;
-- [check]
SELECT * FROM bronze.payments;
--
--
-- [create table bronze.plans]
CREATE TABLE bronze.plans (LIKE public.plans INCLUDING ALL);
-- [input data]
INSERT INTO bronze.plans
SELECT * FROM public.plans;
-- [check]
SELECT * FROM bronze.plans;
--
--
-- [create table bronze.subscribers]
CREATE TABLE bronze.subscribers (LIKE public.subscribers INCLUDING ALL);
-- [input data]
INSERT INTO bronze.subscribers
SELECT * FROM public.subscribers;
-- [check]
SELECT * FROM bronze.subscribers;
--
--
-- [create table bronze.tickets]
CREATE TABLE bronze.tickets (LIKE public.tickets INCLUDING ALL);
-- [input data]
INSERT INTO bronze.tickets
SELECT * FROM public.tickets;
-- [check]
SELECT * FROM bronze.tickets;
--
--
-- [create table bronze.usage_logs]
CREATE TABLE bronze.usage_logs (LIKE public.usage_logs INCLUDING ALL);
-- [input data]
INSERT INTO bronze.usage_logs
SELECT * FROM public.usage_logs;
-- [check]
SELECT * FROM bronze.usage_logs;
--
--
-- [expected row check]
SELECT 'billing' t,		COUNT(*) FROM bronze.billing 		UNION ALL
SELECT 'churn', 		COUNT(*) FROM bronze.churn 			UNION ALL
SELECT 'payments', 		COUNT(*) FROM bronze.payments 		UNION ALL
SELECT 'plans', 		COUNT(*) FROM bronze.plans 			UNION ALL
SELECT 'subscribers',	COUNT(*) FROM bronze.subscribers	UNION ALL
SELECT 'tickets', 		COUNT(*) FROM bronze.tickets		UNION ALL
SELECT 'usage_logs',	COUNT(*) FROM bronze.usage_logs;