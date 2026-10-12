# Semantic model and relationships

## Tables and grain

| Table | Grain | Suggested role |
|---|---|---|
| `customers` | One customer | Dimension |
| `products` | One product | Dimension |
| `campaigns` | One campaign | Dimension |
| `customer_journey` | One session / highest journey stage | Fact |
| `campaign_spend_daily` | One active campaign per day | Fact |
| `content_engagement` | One content performance record | Fact |
| `customer_reviews` | One submitted review | Fact |
| `Calendar` | One calendar date | Date dimension |

## Relationships

Create 1-to-many relationships, with the dimension on the `1` side and single-direction filtering:

- `customers[customer_id]` → `customer_journey[customer_id]`
- `customers[customer_id]` → `customer_reviews[customer_id]`
- `products[product_id]` → `customer_journey[product_id]`
- `products[product_id]` → `content_engagement[product_id]`
- `products[product_id]` → `customer_reviews[product_id]`
- `campaigns[campaign_id]` → `customer_journey[campaign_id]`
- `campaigns[campaign_id]` → `campaign_spend_daily[campaign_id]`
- `campaigns[campaign_id]` → `content_engagement[campaign_id]`
- `Calendar[Date]` → `campaign_spend_daily[spend_date]` (active)
- `Calendar[Date]` → journey, review and engagement date fields (inactive, activate inside dedicated measures using `USERELATIONSHIP`)

Hide technical IDs from report view unless needed for drill-through. Keep a clear distinction between campaign-attributed conversions and purchase sessions found in the journey fact.

## Date table

Create this calculated table in Power BI Desktop:

```DAX
Calendar =
ADDCOLUMNS (
    CALENDAR ( DATE ( 2025, 1, 1 ), DATE ( 2025, 12, 31 ) ),
    "Year", YEAR ( [Date] ),
    "Month Number", MONTH ( [Date] ),
    "Month", FORMAT ( [Date], "MMM" ),
    "Year Month", FORMAT ( [Date], "YYYY-MM" ),
    "Quarter", "Q" & FORMAT ( [Date], "Q" )
)
```

Mark `Calendar` as the date table and sort `Calendar[Month]` by `Calendar[Month Number]`.

## Funnel visual table

Create a disconnected stage table using the `Funnel Stages = DATATABLE(...)` expression at the bottom of `measures.dax`. Sort `Funnel Stages[Stage]` by `Funnel Stages[StageOrder]`. Put `Funnel Stages[Stage]` on the visual and use `Sessions Reaching Funnel Stage` as the value; this measure treats each source row's `stage` as the highest stage reached and counts sessions cumulatively at each funnel step. Use its selected-date variant if the Calendar slicer must apply to the session fact.

## Date slicer behavior

The Calendar-to-spend relationship is active, so the campaign performance measures respond to the date slicer by default. Calendar relationships to journey, review and engagement dates are inactive to prevent ambiguous filtering between facts. Use the date-aware versions of those measures in `measures.dax` when the date slicer should apply. Test each page after building the model.
