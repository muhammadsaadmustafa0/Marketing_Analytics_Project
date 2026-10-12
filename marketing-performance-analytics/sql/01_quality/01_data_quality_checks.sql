/* Execute after loading the CSV files and before creating / refreshing report outputs. */
SET NOCOUNT ON;

-- 1. Table volume: compare with the synthetic-data inventory in README.md.
SELECT 'customers' AS table_name, COUNT_BIG(*) AS row_count FROM raw.customers UNION ALL
SELECT 'products', COUNT_BIG(*) FROM raw.products UNION ALL
SELECT 'campaigns', COUNT_BIG(*) FROM raw.campaigns UNION ALL
SELECT 'customer_journey', COUNT_BIG(*) FROM raw.customer_journey UNION ALL
SELECT 'campaign_spend_daily', COUNT_BIG(*) FROM raw.campaign_spend_daily UNION ALL
SELECT 'content_engagement', COUNT_BIG(*) FROM raw.content_engagement UNION ALL
SELECT 'customer_reviews', COUNT_BIG(*) FROM raw.customer_reviews;

-- 2. Null / blank checks for fields that should be populated.
SELECT 'customer email blank' AS check_name, COUNT_BIG(*) AS exceptions
FROM raw.customers WHERE NULLIF(LTRIM(RTRIM(email)), '') IS NULL
UNION ALL SELECT 'journey missing session date', COUNT_BIG(*) FROM raw.customer_journey WHERE session_date IS NULL
UNION ALL SELECT 'journey blank stage', COUNT_BIG(*) FROM raw.customer_journey WHERE NULLIF(LTRIM(RTRIM(stage)), '') IS NULL
UNION ALL SELECT 'review blank text', COUNT_BIG(*) FROM raw.customer_reviews WHERE NULLIF(LTRIM(RTRIM(review_text)), '') IS NULL;

-- 3. Range and logical checks.
SELECT 'invalid review rating' AS check_name, COUNT_BIG(*) AS exceptions
FROM raw.customer_reviews WHERE rating NOT BETWEEN 1 AND 5
UNION ALL SELECT 'negative campaign spend', COUNT_BIG(*) FROM raw.campaign_spend_daily WHERE spend < 0
UNION ALL SELECT 'clicks exceed impressions', COUNT_BIG(*) FROM raw.campaign_spend_daily WHERE clicks > impressions
UNION ALL SELECT 'non-purchase session has order value', COUNT_BIG(*) FROM raw.customer_journey WHERE converted = 0 AND order_value <> 0
UNION ALL SELECT 'purchase stage but converted flag is false', COUNT_BIG(*) FROM raw.customer_journey WHERE stage = 'Purchase' AND converted <> 1
UNION ALL SELECT 'campaign end before start', COUNT_BIG(*) FROM raw.campaigns WHERE end_date < start_date;

-- 4. Duplicate checks (primary keys should already prevent these; these queries document the tests).
SELECT 'duplicate journey_id' AS check_name, COUNT_BIG(*) AS duplicate_keys
FROM (SELECT journey_id FROM raw.customer_journey GROUP BY journey_id HAVING COUNT_BIG(*) > 1) d
UNION ALL SELECT 'duplicate session_id', COUNT_BIG(*)
FROM (SELECT session_id FROM raw.customer_journey GROUP BY session_id HAVING COUNT_BIG(*) > 1) d
UNION ALL SELECT 'duplicate campaign/date', COUNT_BIG(*)
FROM (SELECT campaign_id, spend_date FROM raw.campaign_spend_daily GROUP BY campaign_id, spend_date HAVING COUNT_BIG(*) > 1) d;

-- 5. Referential integrity checks are also protected by foreign-key constraints.
SELECT 'journey customer missing' AS check_name, COUNT_BIG(*) AS exceptions
FROM raw.customer_journey j LEFT JOIN raw.customers c ON c.customer_id = j.customer_id WHERE c.customer_id IS NULL
UNION ALL SELECT 'journey product missing', COUNT_BIG(*)
FROM raw.customer_journey j LEFT JOIN raw.products p ON p.product_id = j.product_id WHERE p.product_id IS NULL
UNION ALL SELECT 'spend campaign missing', COUNT_BIG(*)
FROM raw.campaign_spend_daily s LEFT JOIN raw.campaigns c ON c.campaign_id = s.campaign_id WHERE c.campaign_id IS NULL
UNION ALL SELECT 'review customer missing', COUNT_BIG(*)
FROM raw.customer_reviews r LEFT JOIN raw.customers c ON c.customer_id = r.customer_id WHERE c.customer_id IS NULL;

-- 6. Attribution reconciliation is a diagnostic, not a required equality:
-- spend-file conversions are campaign-attributed; journey purchase sessions are a separate source.
WITH spend_by_campaign AS (
    SELECT campaign_id, SUM(conversions) AS attributed_conversions
    FROM raw.campaign_spend_daily GROUP BY campaign_id
), journey_by_campaign AS (
    SELECT campaign_id, COUNT(DISTINCT CASE WHEN converted = 1 THEN session_id END) AS journey_purchase_sessions
    FROM raw.customer_journey GROUP BY campaign_id
)
SELECT c.campaign_id, c.campaign_name,
       COALESCE(s.attributed_conversions, 0) AS attributed_conversions,
       COALESCE(j.journey_purchase_sessions, 0) AS journey_purchase_sessions,
       COALESCE(s.attributed_conversions, 0) - COALESCE(j.journey_purchase_sessions, 0) AS difference
FROM raw.campaigns c
LEFT JOIN spend_by_campaign s ON s.campaign_id = c.campaign_id
LEFT JOIN journey_by_campaign j ON j.campaign_id = c.campaign_id
ORDER BY c.campaign_id;
-- Different definitions / attribution sources mean differences are expected; do not sum these metrics together.
