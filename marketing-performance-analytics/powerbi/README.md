# Power BI handoff

This folder contains the DAX measure library, a JSON report theme, and implementation specs. The `.pbix` binary is intentionally not fabricated here: open Power BI Desktop to connect the model and save the report in that format.

## Recommended build order

1. Import the seven CSV files from `data/raw/` or connect to the SQL Server views in the `mart` schema.
2. Rename imported tables to match their CSV stems: `customers`, `products`, `campaigns`, `customer_journey`, `campaign_spend_daily`, `content_engagement`, and `customer_reviews`.
3. Create the relationships specified in `model_and_report_plan.md` using one-to-many, single-direction filtering from dimensions to facts.
4. Import `marketing_theme.json` from **View → Themes → Browse for themes**.
5. Add measures from `measures.dax`; set percentage measures to Percentage, spend/revenue/value to currency, and ROAS to a decimal with two digits.
6. Build the pages from `report_specification.md` and validate each card against SQL outputs from `sql/03_analytics/`.

## Important modeling rule

Do not create a direct many-to-many relationship between `customer_journey` and `campaign_spend_daily`. They are independent fact tables at different grains. Use dimensions to filter them, and compare the two conversion measures without adding them together.
