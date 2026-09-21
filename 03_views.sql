-- ============================================================
-- 03_views.sql
-- Cleaning helper + the two analysis views.
-- ============================================================

-- Converts text like '1,234.50' or '' into NUMERIC (blank -> NULL).
CREATE OR REPLACE FUNCTION to_num(t TEXT) RETURNS NUMERIC AS $$
    SELECT NULLIF(REPLACE(t, ',', ''), '')::NUMERIC;
$$ LANGUAGE SQL IMMUTABLE;


-- ------------------------------------------------------------
-- View 1: final_health_data  (inner join of the 4 core tables)
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW final_health_data AS
SELECT
    a."Name",
    a."Industry",
    to_num(a."Sales")                    AS total_sales,
    to_num(a."Net profit")               AS net_profit,
    to_num(b."Debt")                     AS total_debt,
    to_num(c."Free cash flow last year") AS free_cash_flow,
    to_num(r."Return on equity")         AS roe,
    -- NULL when debt is 0 or missing (a 0 here would wrongly look like "no profit cover")
    to_num(a."Net profit") / NULLIF(to_num(b."Debt"), 0) AS profit_to_debt_ratio
FROM annual_pl_1 a
JOIN balance_sheet     b ON a.join_key = b.join_key
JOIN cash_flow         c ON a.join_key = c.join_key
JOIN financial_ratios  r ON a.join_key = r.join_key;


-- ------------------------------------------------------------
-- View 2: dashboard_master  (feeds Power BI)
-- Missing values stay NULL. The original version wrapped every
-- column in COALESCE(..., 0), which turned "not reported" into a
-- real 0 and pulled averages (ROE, growth) toward zero.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW dashboard_master AS
SELECT
    a."Name",
    a."Industry",
    to_num(a."Sales")                       AS annual_sales,
    to_num(a."Net profit")                  AS annual_profit,
    to_num(q."Sales latest quarter")        AS latest_quarter_sales,
    to_num(q."Net Profit latest quarter")   AS latest_quarter_profit,
    to_num(q."YOY Quarterly sales growth")  AS q_sales_growth_pct,
    to_num(b."Total Assets")                AS total_assets,
    to_num(b."Debt")                        AS total_debt,
    to_num(r."Return on equity")            AS roe,
    to_num(r."Current Price")               AS stock_price
FROM annual_pl_1 a
LEFT JOIN balance_sheet        b ON a.join_key = b.join_key
LEFT JOIN quarterly_financials q ON a.join_key = q.join_key
LEFT JOIN financial_ratios     r ON a.join_key = r.join_key;

SELECT * FROM dashboard_master LIMIT 10;
