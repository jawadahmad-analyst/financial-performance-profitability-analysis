-- ============================================================
-- 02_load_data.sql
-- Load the raw CSV files into the tables from 01_create_tables.sql.
--
-- Run from psql (file paths are relative to where you start psql),
-- OR use pgAdmin: right-click table > Import/Export Data
-- (Format: csv, Header: on, Delimiter: ',').
--
-- NOTE: the raw source CSVs are NOT included in this repository.
-- Put them in data/raw/ (see README) and adjust the file names below.
-- ============================================================
\copy annual_pl_1           FROM 'data/raw/annual_pl.csv'            WITH (FORMAT csv, HEADER true)
\copy balance_sheet         FROM 'data/raw/balance_sheet.csv'        WITH (FORMAT csv, HEADER true)
\copy cash_flow             FROM 'data/raw/cash_flow.csv'            WITH (FORMAT csv, HEADER true)
\copy financial_ratios      FROM 'data/raw/financial_ratios.csv'     WITH (FORMAT csv, HEADER true)
\copy quarterly_financials  FROM 'data/raw/quarterly_financials.csv' WITH (FORMAT csv, HEADER true)

-- Sanity check: every table should return the same row count
SELECT 'annual_pl_1' AS tbl, COUNT(*) FROM annual_pl_1
UNION ALL SELECT 'balance_sheet',        COUNT(*) FROM balance_sheet
UNION ALL SELECT 'cash_flow',            COUNT(*) FROM cash_flow
UNION ALL SELECT 'financial_ratios',     COUNT(*) FROM financial_ratios
UNION ALL SELECT 'quarterly_financials', COUNT(*) FROM quarterly_financials;
