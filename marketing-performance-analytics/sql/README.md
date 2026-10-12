# SQL guide

Scripts are written for Microsoft SQL Server (T-SQL). Run them in numbered folder order unless a script is explicitly described as an optional analysis.

1. `00_setup/01_create_schema_and_tables.sql` — creates `raw` and `mart` schemas plus typed source tables.
2. `00_setup/02_load_csv_files.sql` — bulk-loads files from a local absolute path. Update the path and make sure the SQL Server service account can read it. The bulk-load script is optional if you import the CSVs with SSMS.
3. `01_quality/01_data_quality_checks.sql` — reports key duplicates, orphaned keys, nulls, invalid ranges, and reconciliation checks.
4. `02_transform/02_create_analytics_views.sql` — creates cleaned views and reusable aggregates.
5. `03_analytics/` — analytical questions to run independently.
6. `04_validation/01_validation_queries.sql` — post-load smoke tests.

The load file uses SQL Server's CSV-aware `BULK INSERT` support. If your SQL Server version or hosting policy does not support `FORMAT = 'CSV'`, use SSMS import or adapt the load step for your environment. Never enable server-wide ad hoc access solely for this project.
