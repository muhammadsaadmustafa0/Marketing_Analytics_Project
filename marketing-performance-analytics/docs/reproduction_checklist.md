# Reproduction checklist

## Environment

- [ ] SQL Server 2019+ is available, with SSMS or another T-SQL client.
- [ ] Power BI Desktop is available if you want to build the report.
- [ ] Repository files are downloaded locally; no credentials or external services are required.

## SQL execution

- [ ] Create a new empty database for the portfolio exercise.
- [ ] Run `sql/00_setup/01_create_schema_and_tables.sql`.
- [ ] Edit the absolute folder path in `sql/00_setup/02_load_csv_files.sql` before executing it, or import the CSVs with the SSMS import wizard.
- [ ] Load dimension-like tables before fact tables because foreign keys are enabled.
- [ ] Run `sql/01_quality/01_data_quality_checks.sql`; investigate any non-zero exceptions.
- [ ] Run `sql/02_transform/02_create_analytics_views.sql`.
- [ ] Run `sql/04_validation/01_validation_queries.sql` and compare row counts with the README inventory.
- [ ] Run the SQL files in `sql/03_analytics/` one at a time and save results/screenshots for the portfolio write-up.

## Power BI execution

- [ ] Import the CSVs or connect to SQL views.
- [ ] Rename tables to match the names in the model instructions.
- [ ] Create one-to-many, single-direction dimension-to-fact relationships.
- [ ] Do not directly join the campaign-spend fact to the customer-journey fact.
- [ ] Apply `powerbi/marketing_theme.json` and create the measures in `powerbi/measures.dax`.
- [ ] Build pages from `powerbi/report_specification.md`.
- [ ] Check all totals against independent SQL query results.
- [ ] Save the completed `.pbix` from Power BI Desktop into `powerbi/` only after validating it locally.

## Publishing to your own GitHub

- [ ] Replace the author placeholder in `docs/attribution.md`.
- [ ] Check that your name, project title, and report screenshots reflect work you understand and have actually completed.
- [ ] Commit the files into a new repository you control rather than overwriting the source repository.
- [ ] Keep synthetic-data labels visible in the repository and dashboard.
- [ ] If you later add real data, remove personal data and credentials before publishing.

## Push to a new repository you control

Create an empty GitHub repository first, then from this project folder run:

```bash
git init
git add .
git commit -m "Create marketing performance analytics portfolio"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/marketing-performance-analytics.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your GitHub username. This setup publishes a new repo and does not overwrite the source repository.
