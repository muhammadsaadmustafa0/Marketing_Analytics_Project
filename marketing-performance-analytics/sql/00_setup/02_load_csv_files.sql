/* OPTIONAL: update @DataRoot to the absolute path of this repository's data/raw directory.
   SQL Server service account must be able to read the files. Run after 01_create_schema_and_tables.sql.
   Re-running inserts duplicates; clear target tables first only if you intentionally want a full reload. */
DECLARE @DataRoot nvarchar(4000) = N'C:\CHANGE_ME\marketing-performance-analytics\data\raw\';
DECLARE @sql nvarchar(max);

/* Dimensions must be loaded first because the fact tables have foreign keys. */
SET @sql = N'BULK INSERT raw.customers FROM ''' + @DataRoot + N'customers.csv'' WITH (FORMAT = ''CSV'', FIRSTROW = 2, CODEPAGE = ''65001'', TABLOCK);'; EXEC sys.sp_executesql @sql;
SET @sql = N'BULK INSERT raw.products FROM ''' + @DataRoot + N'products.csv'' WITH (FORMAT = ''CSV'', FIRSTROW = 2, CODEPAGE = ''65001'', TABLOCK);'; EXEC sys.sp_executesql @sql;
SET @sql = N'BULK INSERT raw.campaigns FROM ''' + @DataRoot + N'campaigns.csv'' WITH (FORMAT = ''CSV'', FIRSTROW = 2, CODEPAGE = ''65001'', TABLOCK);'; EXEC sys.sp_executesql @sql;
SET @sql = N'BULK INSERT raw.customer_journey FROM ''' + @DataRoot + N'customer_journey.csv'' WITH (FORMAT = ''CSV'', FIRSTROW = 2, CODEPAGE = ''65001'', TABLOCK);'; EXEC sys.sp_executesql @sql;
SET @sql = N'BULK INSERT raw.campaign_spend_daily FROM ''' + @DataRoot + N'campaign_spend_daily.csv'' WITH (FORMAT = ''CSV'', FIRSTROW = 2, CODEPAGE = ''65001'', TABLOCK);'; EXEC sys.sp_executesql @sql;
SET @sql = N'BULK INSERT raw.content_engagement FROM ''' + @DataRoot + N'content_engagement.csv'' WITH (FORMAT = ''CSV'', FIRSTROW = 2, CODEPAGE = ''65001'', TABLOCK);'; EXEC sys.sp_executesql @sql;
SET @sql = N'BULK INSERT raw.customer_reviews FROM ''' + @DataRoot + N'customer_reviews.csv'' WITH (FORMAT = ''CSV'', FIRSTROW = 2, CODEPAGE = ''65001'', TABLOCK);'; EXEC sys.sp_executesql @sql;

PRINT 'CSV import completed. Run the quality checks next.';
