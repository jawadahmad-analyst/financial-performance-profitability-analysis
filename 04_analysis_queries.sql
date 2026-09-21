-- ============================================================
-- 04_analysis_queries.sql
-- Example analysis on top of dashboard_master.
-- Amounts are in the source dataset's reporting unit.
-- ============================================================

-- 1. Top 10 companies by annual profit
SELECT "Name", "Industry", annual_sales, annual_profit
FROM dashboard_master
WHERE annual_profit IS NOT NULL
ORDER BY annual_profit DESC
LIMIT 10;

-- 2. Industry summary: sales, profit and net margin
SELECT
    "Industry",
    COUNT(*)                                                          AS companies,
    ROUND(SUM(annual_sales), 2)                                       AS total_sales,
    ROUND(SUM(annual_profit), 2)                                      AS total_profit,
    ROUND(100 * SUM(annual_profit) / NULLIF(SUM(annual_sales), 0), 2) AS net_margin_pct
FROM dashboard_master
GROUP BY "Industry"
HAVING SUM(annual_sales) > 0
ORDER BY total_sales DESC;

-- 3. Leverage: debt-to-assets by industry, excluding banks
--    (bank "debt" includes customer deposits, so it is not comparable)
SELECT
    "Industry",
    ROUND(100 * SUM(total_debt) / NULLIF(SUM(total_assets), 0), 2) AS debt_to_assets_pct
FROM dashboard_master
WHERE "Industry" NOT ILIKE 'Banks%'
GROUP BY "Industry"
HAVING SUM(total_assets) > 0
ORDER BY debt_to_assets_pct DESC
LIMIT 15;

-- 4. Loss-making companies
SELECT COUNT(*) AS loss_making,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM dashboard_master), 1) AS pct_of_all
FROM dashboard_master
WHERE annual_profit < 0;

-- 5. ROE: median vs average (extreme outliers distort the average)
SELECT
    ROUND(AVG(roe), 2)                                                     AS avg_roe,
    ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY roe))::numeric, 2) AS median_roe,
    MAX(roe)                                                               AS max_roe
FROM dashboard_master
WHERE roe IS NOT NULL;

-- 6. Outlier check: companies with ROE above 100%
SELECT "Name", "Industry", roe, annual_profit
FROM dashboard_master
WHERE roe > 100
ORDER BY roe DESC;
