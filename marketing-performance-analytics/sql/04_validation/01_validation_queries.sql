/* Quick smoke tests after loading and creating views. Expected source row counts are documented in README.md. */
SELECT 'customers' AS object_name, COUNT_BIG(*) AS rows_found, CAST(160 AS bigint) AS expected_rows FROM raw.customers UNION ALL
SELECT 'products', COUNT_BIG(*), CAST(12 AS bigint) FROM raw.products UNION ALL
SELECT 'campaigns', COUNT_BIG(*), CAST(8 AS bigint) FROM raw.campaigns UNION ALL
SELECT 'customer_journey', COUNT_BIG(*), CAST(1800 AS bigint) FROM raw.customer_journey UNION ALL
SELECT 'campaign_spend_daily', COUNT_BIG(*), CAST(2040 AS bigint) FROM raw.campaign_spend_daily UNION ALL
SELECT 'content_engagement', COUNT_BIG(*), CAST(950 AS bigint) FROM raw.content_engagement UNION ALL
SELECT 'customer_reviews', COUNT_BIG(*), CAST(520 AS bigint) FROM raw.customer_reviews;

-- The following outputs should contain no null IDs or invalid domain values.
SELECT COUNT_BIG(*) AS invalid_rating_rows FROM raw.customer_reviews WHERE rating NOT BETWEEN 1 AND 5;
SELECT COUNT_BIG(*) AS invalid_stage_rows FROM raw.customer_journey WHERE stage NOT IN ('Awareness','Consideration','Intent','Purchase');
SELECT COUNT_BIG(*) AS zero_spend_rows_with_revenue FROM raw.campaign_spend_daily WHERE spend = 0 AND revenue_attributed > 0;
SELECT COUNT_BIG(*) AS cleaned_reviews_still_containing_tab_or_newline
FROM mart.vw_customer_reviews_clean WHERE review_text_clean LIKE '%' + CHAR(9) + '%' OR review_text_clean LIKE '%' + CHAR(10) + '%' OR review_text_clean LIKE '%' + CHAR(13) + '%';

-- Check for non-empty analytical output.
SELECT COUNT_BIG(*) AS campaign_summary_rows FROM mart.vw_campaign_summary;
SELECT COUNT_BIG(*) AS funnel_stage_rows FROM mart.vw_customer_funnel;
SELECT COUNT_BIG(*) AS product_summary_rows FROM mart.vw_product_review_summary;
