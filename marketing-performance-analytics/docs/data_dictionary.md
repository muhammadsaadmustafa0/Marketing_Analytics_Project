# Data dictionary

## customers.csv → `raw.customers`

| Field | Type | Definition |
|---|---|---|
| `customer_id` | Text | Stable synthetic customer key |
| `first_name`, `last_name` | Text | Synthetic names |
| `email` | Text | Synthetic contact-shaped field using `example.com` |
| `signup_date` | Date | Simulated signup date; some signups precede 2025 |
| `region` | Category | Simulated market region |
| `acquisition_channel` | Category | Simulated original acquisition channel |
| `customer_segment` | Category | Simulated customer segment |

## products.csv → `raw.products`

| Field | Type | Definition |
|---|---|---|
| `product_id` | Text | Product key |
| `product_name` | Text | Synthetic catalog name |
| `category` | Category | Product family |
| `list_price`, `cost_price` | Decimal | Simulated unit price and unit cost |
| `is_active` | Boolean / bit | Whether product is active in the sample catalog |

## campaigns.csv → `raw.campaigns`

`campaign_id` is the key. `campaign_name`, `channel`, and `campaign_type` describe the simulated campaign; `start_date` and `end_date` bound the campaign; `budget` is the planned budget amount for the full campaign.

## customer_journey.csv → `raw.customer_journey`

| Field | Type | Definition |
|---|---|---|
| `journey_id` | Text | Unique row key |
| `customer_id`, `session_id` | Text | Customer and session keys |
| `session_date` | Date | Session date |
| `campaign_id`, `product_id` | Text | Campaign/product attribution in the sample |
| `stage` | Category | Highest funnel stage reached in the session: Awareness, Consideration, Intent, Purchase |
| `device` | Category | Simulated device class |
| `source`, `medium` | Category | Simulated traffic source/medium |
| `landing_page` | Text | Simulated landing page path |
| `converted` | Integer / bit | 1 only for Purchase stage |
| `order_value` | Decimal | Simulated order value for converted sessions; otherwise 0 |

This is a simplified one-row-per-session dataset, not an event stream. It supports a cumulative stage funnel because each row records the highest stage reached.

## campaign_spend_daily.csv → `raw.campaign_spend_daily`

One row per active campaign and date. `spend`, `impressions`, `clicks`, `conversions`, and `revenue_attributed` are synthetic ad-platform-style metrics. The pair (`spend_date`, `campaign_id`) is the primary key. `conversions` are campaign-attributed counts and are not expected to match session purchases.

## content_engagement.csv → `raw.content_engagement`

One row per synthetic content-performance record. `content_id` identifies the content item, while `campaign_id` and `product_id` associate it with a campaign and product. `views`, `clicks`, `likes`, `shares`, and `comments` are non-negative integer counts.

## customer_reviews.csv → `raw.customer_reviews`

One row per review. `review_id` is the primary key; `customer_id` and `product_id` link to dimensions; `review_date` is the date; `rating` is an integer from 1 to 5; `review_text` is synthetic text and may contain extra whitespace to demonstrate cleaning.

## Grain / double-counting warnings

- `campaign_spend_daily` is campaign-date grain.
- `customer_journey` is session grain.
- `content_engagement` is content-record grain.
- `customer_reviews` is review grain.
- Do not join these facts together directly and aggregate afterward. Aggregate each fact first or let Power BI dimensions filter the facts independently.
