/* Business question: which campaigns produce return efficiently?
   Aggregate at campaign grain. Never join daily spend directly to session rows before aggregating. */
SELECT campaign_name, channel, campaign_type,
       total_spend, attributed_revenue, attributed_conversions,
       ctr, click_to_conversion_rate, cost_per_conversion, roas,
       budget,
       CAST(total_spend / NULLIF(budget, 0) AS decimal(12,4)) AS budget_utilisation
FROM mart.vw_campaign_summary
ORDER BY roas DESC, attributed_revenue DESC;

/* Channel roll-up: ratios are recalculated from sums, not averaged across campaigns. */
SELECT channel,
       SUM(total_spend) AS total_spend,
       SUM(attributed_revenue) AS attributed_revenue,
       SUM(attributed_conversions) AS attributed_conversions,
       CAST(1.0 * SUM(attributed_revenue) / NULLIF(SUM(total_spend), 0) AS decimal(12,3)) AS roas,
       CAST(1.0 * SUM(clicks) / NULLIF(SUM(impressions), 0) AS decimal(12,5)) AS ctr,
       CAST(1.0 * SUM(total_spend) / NULLIF(SUM(attributed_conversions), 0) AS decimal(12,2)) AS cost_per_conversion
FROM mart.vw_campaign_summary
GROUP BY channel
ORDER BY attributed_revenue DESC;

/* Trend: monthly return with zero-safe denominators. */
SELECT DATEFROMPARTS(YEAR(spend_date), MONTH(spend_date), 1) AS month_start,
       SUM(spend) AS spend,
       SUM(revenue_attributed) AS attributed_revenue,
       SUM(conversions) AS attributed_conversions,
       CAST(1.0 * SUM(revenue_attributed) / NULLIF(SUM(spend), 0) AS decimal(12,3)) AS roas
FROM raw.campaign_spend_daily
GROUP BY DATEFROMPARTS(YEAR(spend_date), MONTH(spend_date), 1)
ORDER BY month_start;
