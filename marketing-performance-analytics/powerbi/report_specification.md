# Report specification

Design target: 16:9 desktop canvas. Use consistent spacing, short titles, and direct metric labels. The included theme file defines the palette; use restrained color and avoid implying that synthetic results represent actual performance.

## Page 1 — Executive overview

**Audience question:** is the current marketing mix producing efficient attributed return?

- KPI cards: Marketing Spend, Attributed Revenue, ROAS, Cost per Attributed Conversion, CTR.
- Line chart: monthly spend and attributed revenue.
- Bar chart: ROAS by channel; add a second visual for attributed revenue by channel rather than using a dual axis.
- Table: campaign, spend, revenue, conversions, ROAS, cost per conversion, budget utilisation.
- Slicers: date, channel, campaign type.

## Page 2 — Journey and conversion

- Funnel: sessions reaching Awareness, Consideration, Intent and Purchase (calculate cumulative reached sessions from each session's highest stage).
- Matrix: journey purchase rate by device, region, and acquisition channel.
- Bar chart: journey purchase sessions by campaign.
- Add a clear note that a session-level purchase is not identical to an ad platform's attributed conversion.

## Page 3 — Content and product

- Scatter: content views vs. interaction rate, sized by content records.
- Bar chart: view-to-click rate by content type.
- Product table: review count, average rating, 1–2 star share, 4–5 star share.
- Detail table: low-rated review text, with a product and date filter.

## Page 4 — Data trust

- Row counts by source table.
- Validation exception cards from `sql/01_quality/01_data_quality_checks.sql`.
- A small reconciliation table for attributed conversions vs. journey purchase sessions, with a note that differences are expected because definitions and sources differ.
- Display dataset note: “Synthetic portfolio dataset — not live company performance.”

## Visual QA checklist

- Format CTR / conversion rates as percentages and ROAS as a ratio, not a percentage.
- Use ratio-of-sums measures; do not average campaign-level ROAS values for channel ROAS.
- Confirm spend totals at campaign, channel, month, and grand-total levels.
- Confirm every KPI responds appropriately to date and campaign filters.
- Avoid funnel calculations based only on counts of the final stage, because the input stores each session's highest stage reached.
