-- [STEP B: INSIGHT COMPONENTS]
-- Mart Source: gold.mart_retail

-- [Component 1: TREND]
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
-- Findings:
-- Chain-wide revenue rose from $4.0k (Jan-25) to a peak of $6.4k (Aug-25), dipped to $4.5k (Oct-25), 
-- then recovered to an all-time high of $6.6k (Jan-26) — +64.4% over 13 months.

-- [Component 2: FLUCTUATION]
-- Spot-test: "Does it name a specific spike, dip, or recurring seasonal moment?"
WITH revenue_trend AS(
	SELECT
		month_key,
		ROUND(SUM (line_revenue), 2) AS revenue
	FROM gold.mart_retail
	GROUP BY month_key
	ORDER BY month_key ASC
)
SELECT *,
	ROUND((revenue - LAG(revenue) OVER (ORDER BY month_key)) * 100.00 / LAG(revenue) OVER (ORDER BY month_key), 2) AS diff_pct
FROM revenue_trend;
-- Findings:
-- Revenue didn't rise smoothly — it dipped in May (−17%) and Sep (−17%) and spiked in Feb (+22%) and Aug (+15%) within 2025, 
-- recovering into Nov (+5%) and Jan — a dip-then-recover shape worth watching next year, but not yet proven seasonality.
