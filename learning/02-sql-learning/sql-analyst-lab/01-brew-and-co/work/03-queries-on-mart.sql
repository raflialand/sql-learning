-- [STEP B: INSIGHT COMPONENTS]

-- [Component 1: TREND]
-- Mart Source: gold.mart_retail
-- Spot-test reminder: "Does this fact describe direction over time?"

-- "What is the chain-wide Revenue trend over time?" | Revenue · Month
SELECT *
FROM gold.mart_retail;
--
SELECT
	month_key,
	ROUND(SUM (line_revenue), 2) AS revenue
FROM gold.mart_retail
GROUP BY month_key
ORDER BY month_key ASC;