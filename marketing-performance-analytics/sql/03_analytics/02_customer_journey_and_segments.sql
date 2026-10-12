/* Business question: how many sessions reached each funnel stage?
   Each journey row is one session assigned its highest stage reached. */
SELECT stage, stage_order, sessions_reached, prior_stage_sessions, progression_rate
FROM mart.vw_customer_funnel
ORDER BY stage_order;

/* Journey completion by channel and device. The session table is intentionally separate from spend facts. */
SELECT channel, device,
       COUNT_BIG(*) AS sessions,
       SUM(CAST(converted AS bigint)) AS purchase_sessions,
       CAST(1.0 * SUM(CAST(converted AS bigint)) / NULLIF(COUNT_BIG(*), 0) AS decimal(12,5)) AS purchase_rate,
       SUM(order_value) AS journey_order_value,
       CAST(AVG(CASE WHEN converted = 1 THEN order_value END) AS decimal(12,2)) AS average_order_value
FROM mart.vw_journey_clean
GROUP BY channel, device
ORDER BY sessions DESC;

/* Customer-level value proxy; this is observed order value in the journey sample, not full lifetime value. */
SELECT customer_segment, region,
       COUNT_BIG(*) AS customers,
       SUM(journey_purchase_sessions) AS journey_purchase_sessions,
       SUM(journey_order_value) AS journey_order_value,
       CAST(AVG(CAST(journey_order_value AS decimal(14,2))) AS decimal(12,2)) AS average_journey_value_per_customer
FROM mart.vw_customer_value
GROUP BY customer_segment, region
ORDER BY journey_order_value DESC;
