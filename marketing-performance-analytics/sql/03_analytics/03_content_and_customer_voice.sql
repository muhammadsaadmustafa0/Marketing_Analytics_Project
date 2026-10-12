/* Business question: which content formats attract interactions? */
SELECT campaign_name, channel, content_type, content_records,
       views, clicks, likes, shares, comments, view_to_click_rate, interaction_rate
FROM mart.vw_content_engagement_summary
ORDER BY interaction_rate DESC, views DESC;

/* Product rating summary. Read rating alongside review_count, not in isolation. */
SELECT product_name, category, review_count, average_rating, positive_reviews, negative_reviews,
       CAST(1.0 * positive_reviews / NULLIF(review_count, 0) AS decimal(12,4)) AS share_rated_4_or_5,
       CAST(1.0 * negative_reviews / NULLIF(review_count, 0) AS decimal(12,4)) AS share_rated_1_or_2
FROM mart.vw_product_review_summary
ORDER BY average_rating DESC, review_count DESC;

/* Inspect low-rated feedback after normalizing whitespace. */
SELECT TOP (30) r.review_date, p.product_name, r.rating, r.review_text_clean
FROM mart.vw_customer_reviews_clean r
INNER JOIN raw.products p ON p.product_id = r.product_id
WHERE r.rating <= 2
ORDER BY r.review_date DESC, r.rating ASC;
