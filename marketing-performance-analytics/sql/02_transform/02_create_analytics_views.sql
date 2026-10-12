/* Reusable reporting views. Run after source tables have been loaded. */
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER VIEW mart.vw_customer_reviews_clean AS
SELECT r.review_id,
       r.customer_id,
       r.product_id,
       r.review_date,
       CAST(r.rating AS int) AS rating,
       TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(r.review_text, CHAR(13), ' '), CHAR(10), ' '), CHAR(9), ' '), '  ', ' '), '  ', ' ')) AS review_text_clean
FROM raw.customer_reviews AS r;
GO
CREATE OR ALTER VIEW mart.vw_journey_clean AS
SELECT j.journey_id, j.session_id, j.session_date, j.customer_id,
       c.region, c.customer_segment, c.acquisition_channel,
       j.campaign_id, cp.campaign_name, cp.channel,
       j.product_id, p.product_name, p.category AS product_category,
       j.stage, j.device, j.source, j.medium, j.landing_page,
       CAST(j.converted AS int) AS converted, j.order_value
FROM raw.customer_journey AS j
INNER JOIN raw.customers AS c ON c.customer_id = j.customer_id
INNER JOIN raw.campaigns AS cp ON cp.campaign_id = j.campaign_id
INNER JOIN raw.products AS p ON p.product_id = j.product_id;
GO
CREATE OR ALTER VIEW mart.vw_campaign_performance_daily AS
SELECT s.spend_date, s.campaign_id, c.campaign_name, c.channel, c.campaign_type,
       c.budget, s.spend, s.impressions, s.clicks, s.conversions, s.revenue_attributed,
       CAST(1.0 * s.clicks / NULLIF(s.impressions, 0) AS decimal(12,5)) AS ctr,
       CAST(1.0 * s.conversions / NULLIF(s.clicks, 0) AS decimal(12,5)) AS click_to_conversion_rate,
       CAST(s.spend / NULLIF(s.conversions, 0) AS decimal(12,2)) AS cost_per_conversion,
       CAST(s.revenue_attributed / NULLIF(s.spend, 0) AS decimal(12,3)) AS roas
FROM raw.campaign_spend_daily AS s
INNER JOIN raw.campaigns AS c ON c.campaign_id = s.campaign_id;
GO
CREATE OR ALTER VIEW mart.vw_campaign_summary AS
SELECT c.campaign_id, c.campaign_name, c.channel, c.campaign_type, c.start_date, c.end_date, c.budget,
       SUM(s.spend) AS total_spend,
       SUM(s.impressions) AS impressions,
       SUM(s.clicks) AS clicks,
       SUM(s.conversions) AS attributed_conversions,
       SUM(s.revenue_attributed) AS attributed_revenue,
       CAST(1.0 * SUM(s.clicks) / NULLIF(SUM(s.impressions), 0) AS decimal(12,5)) AS ctr,
       CAST(1.0 * SUM(s.conversions) / NULLIF(SUM(s.clicks), 0) AS decimal(12,5)) AS click_to_conversion_rate,
       CAST(SUM(s.spend) / NULLIF(SUM(s.conversions), 0) AS decimal(12,2)) AS cost_per_conversion,
       CAST(SUM(s.revenue_attributed) / NULLIF(SUM(s.spend), 0) AS decimal(12,3)) AS roas
FROM raw.campaigns AS c
LEFT JOIN raw.campaign_spend_daily AS s ON s.campaign_id = c.campaign_id
GROUP BY c.campaign_id, c.campaign_name, c.channel, c.campaign_type, c.start_date, c.end_date, c.budget;
GO
CREATE OR ALTER VIEW mart.vw_customer_funnel AS
WITH stage_order AS (
    SELECT * FROM (VALUES
        ('Awareness', 1), ('Consideration', 2), ('Intent', 3), ('Purchase', 4)
    ) AS x(stage, stage_order)
), funnel_counts AS (
    SELECT s.stage, s.stage_order,
           COUNT_BIG(CASE WHEN j.stage_order >= s.stage_order THEN 1 END) AS sessions_reached
    FROM stage_order s
    CROSS JOIN (
        SELECT session_id,
               CASE stage WHEN 'Awareness' THEN 1 WHEN 'Consideration' THEN 2 WHEN 'Intent' THEN 3 WHEN 'Purchase' THEN 4 END AS stage_order
        FROM raw.customer_journey
    ) j
    GROUP BY s.stage, s.stage_order
)
SELECT stage, stage_order, sessions_reached,
       LAG(sessions_reached) OVER (ORDER BY stage_order) AS prior_stage_sessions,
       CAST(1.0 * sessions_reached / NULLIF(LAG(sessions_reached) OVER (ORDER BY stage_order), 0) AS decimal(12,5)) AS progression_rate
FROM funnel_counts;
GO
CREATE OR ALTER VIEW mart.vw_product_review_summary AS
SELECT p.product_id, p.product_name, p.category, p.list_price,
       COUNT_BIG(r.review_id) AS review_count,
       AVG(CAST(r.rating AS decimal(10,2))) AS average_rating,
       SUM(CASE WHEN r.rating >= 4 THEN 1 ELSE 0 END) AS positive_reviews,
       SUM(CASE WHEN r.rating <= 2 THEN 1 ELSE 0 END) AS negative_reviews
FROM raw.products AS p
LEFT JOIN raw.customer_reviews AS r ON r.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, p.list_price;
GO
CREATE OR ALTER VIEW mart.vw_customer_value AS
SELECT c.customer_id, c.region, c.customer_segment, c.signup_date, c.acquisition_channel,
       COUNT(DISTINCT CASE WHEN j.converted = 1 THEN j.session_id END) AS journey_purchase_sessions,
       COALESCE(SUM(j.order_value), 0) AS journey_order_value,
       MAX(j.session_date) AS most_recent_session_date
FROM raw.customers AS c
LEFT JOIN raw.customer_journey AS j ON j.customer_id = c.customer_id
GROUP BY c.customer_id, c.region, c.customer_segment, c.signup_date, c.acquisition_channel;
GO
CREATE OR ALTER VIEW mart.vw_content_engagement_summary AS
SELECT e.campaign_id, c.campaign_name, c.channel, e.content_type,
       COUNT_BIG(*) AS content_records,
       SUM(e.views) AS views,
       SUM(e.clicks) AS clicks,
       SUM(e.likes) AS likes,
       SUM(e.shares) AS shares,
       SUM(e.comments) AS comments,
       CAST(1.0 * SUM(e.clicks) / NULLIF(SUM(e.views), 0) AS decimal(12,5)) AS view_to_click_rate,
       CAST(1.0 * (SUM(e.likes) + SUM(e.shares) + SUM(e.comments)) / NULLIF(SUM(e.views), 0) AS decimal(12,5)) AS interaction_rate
FROM raw.content_engagement AS e
INNER JOIN raw.campaigns AS c ON c.campaign_id = e.campaign_id
GROUP BY e.campaign_id, c.campaign_name, c.channel, e.content_type;
GO
PRINT 'Analytics views created or refreshed.';
