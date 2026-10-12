# Data files

All CSV files here are synthetic demonstration data, not scraped data or production exports. They are deterministic for reproducible portfolio review and cover 2025 campaign activity.

## Raw data

| File | Grain | Primary key | Joins |
|---|---|---|---|
| `raw/customers.csv` | Customer | `customer_id` | Journey, reviews |
| `raw/products.csv` | Product | `product_id` | Journey, engagement, reviews |
| `raw/campaigns.csv` | Campaign | `campaign_id` | Journey, spend, engagement |
| `raw/customer_journey.csv` | Session | `journey_id`; `session_id` is unique in this dataset | Customer, campaign, product |
| `raw/campaign_spend_daily.csv` | Active campaign-date | `spend_date` + `campaign_id` | Campaign |
| `raw/content_engagement.csv` | Content performance record | `engagement_id` | Campaign, product |
| `raw/customer_reviews.csv` | Review | `review_id` | Customer, product |

## Processed example

`processed/customer_reviews_clean_sample.csv` demonstrates trimming leading/trailing whitespace and collapsing repeated whitespace in review text. The canonical transformation is implemented in SQL in `sql/02_transform/02_create_analytics_views.sql`; the processed file is provided as a transparent before/after example.

## Import tips

- Use UTF-8 encoding and a comma delimiter.
- Treat IDs as text; preserve leading zeros in the ID suffixes.
- Import dates as `DATE`, money values as decimal, counts as integers, and conversion flags as integers.
- Do not interpret synthetic email-shaped values as real people. All use `example.com`.
- Keep `campaign_spend_daily` separate from `customer_journey` when building Power BI measures to prevent fan-out.
