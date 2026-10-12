/* Marketing Performance Analytics | SQL Server 2019+
   Create objects before loading data. Safe to re-run: existing tables are not dropped. */
SET NOCOUNT ON;
GO
IF SCHEMA_ID('raw') IS NULL EXEC('CREATE SCHEMA raw AUTHORIZATION dbo;');
IF SCHEMA_ID('mart') IS NULL EXEC('CREATE SCHEMA mart AUTHORIZATION dbo;');
GO
IF OBJECT_ID('raw.customers','U') IS NULL
CREATE TABLE raw.customers (
    customer_id         varchar(12)   NOT NULL CONSTRAINT PK_customers PRIMARY KEY,
    first_name          varchar(60)   NOT NULL,
    last_name           varchar(60)   NOT NULL,
    email               varchar(160)  NOT NULL,
    signup_date         date          NOT NULL,
    region              varchar(40)   NOT NULL,
    acquisition_channel varchar(40)   NOT NULL,
    customer_segment    varchar(30)   NOT NULL
);
GO
IF OBJECT_ID('raw.products','U') IS NULL
CREATE TABLE raw.products (
    product_id   varchar(12)    NOT NULL CONSTRAINT PK_products PRIMARY KEY,
    product_name varchar(120)   NOT NULL,
    category     varchar(50)    NOT NULL,
    list_price   decimal(12,2)  NOT NULL,
    cost_price   decimal(12,2)  NOT NULL,
    is_active    bit            NOT NULL,
    CONSTRAINT CK_products_prices CHECK (list_price >= 0 AND cost_price >= 0)
);
GO
IF OBJECT_ID('raw.campaigns','U') IS NULL
CREATE TABLE raw.campaigns (
    campaign_id   varchar(12)   NOT NULL CONSTRAINT PK_campaigns PRIMARY KEY,
    campaign_name varchar(160)  NOT NULL,
    channel       varchar(40)   NOT NULL,
    campaign_type varchar(50)   NOT NULL,
    start_date    date          NOT NULL,
    end_date      date          NOT NULL,
    budget        decimal(14,2) NOT NULL,
    CONSTRAINT CK_campaigns_dates CHECK (end_date >= start_date),
    CONSTRAINT CK_campaigns_budget CHECK (budget >= 0)
);
GO
IF OBJECT_ID('raw.customer_journey','U') IS NULL
CREATE TABLE raw.customer_journey (
    journey_id   varchar(12)    NOT NULL CONSTRAINT PK_customer_journey PRIMARY KEY,
    customer_id  varchar(12)    NOT NULL,
    session_id   varchar(12)    NOT NULL,
    session_date date           NOT NULL,
    campaign_id  varchar(12)    NOT NULL,
    product_id   varchar(12)    NOT NULL,
    stage        varchar(30)    NOT NULL,
    device       varchar(20)    NOT NULL,
    source       varchar(40)    NOT NULL,
    medium       varchar(40)    NOT NULL,
    landing_page varchar(120)   NOT NULL,
    converted    bit            NOT NULL,
    order_value  decimal(12,2)  NOT NULL,
    CONSTRAINT UQ_customer_journey_session UNIQUE (session_id),
    CONSTRAINT FK_journey_customer FOREIGN KEY (customer_id) REFERENCES raw.customers(customer_id),
    CONSTRAINT FK_journey_campaign FOREIGN KEY (campaign_id) REFERENCES raw.campaigns(campaign_id),
    CONSTRAINT FK_journey_product FOREIGN KEY (product_id) REFERENCES raw.products(product_id),
    CONSTRAINT CK_journey_stage CHECK (stage IN ('Awareness','Consideration','Intent','Purchase')),
    CONSTRAINT CK_journey_order CHECK (order_value >= 0 AND (converted = 1 OR order_value = 0))
);
GO
IF OBJECT_ID('raw.campaign_spend_daily','U') IS NULL
CREATE TABLE raw.campaign_spend_daily (
    spend_date         date          NOT NULL,
    campaign_id        varchar(12)   NOT NULL,
    spend              decimal(12,2) NOT NULL,
    impressions        int           NOT NULL,
    clicks             int           NOT NULL,
    conversions        int           NOT NULL,
    revenue_attributed decimal(14,2) NOT NULL,
    CONSTRAINT PK_campaign_spend_daily PRIMARY KEY (spend_date, campaign_id),
    CONSTRAINT FK_spend_campaign FOREIGN KEY (campaign_id) REFERENCES raw.campaigns(campaign_id),
    CONSTRAINT CK_spend_metrics CHECK (spend >= 0 AND impressions >= 0 AND clicks >= 0 AND conversions >= 0 AND revenue_attributed >= 0 AND clicks <= impressions)
);
GO
IF OBJECT_ID('raw.content_engagement','U') IS NULL
CREATE TABLE raw.content_engagement (
    engagement_id  varchar(12)  NOT NULL CONSTRAINT PK_content_engagement PRIMARY KEY,
    content_id     varchar(12)  NOT NULL,
    campaign_id    varchar(12)  NOT NULL,
    product_id     varchar(12)  NOT NULL,
    engagement_date date        NOT NULL,
    content_type   varchar(50)  NOT NULL,
    views          int          NOT NULL,
    clicks         int          NOT NULL,
    likes          int          NOT NULL,
    shares         int          NOT NULL,
    comments       int          NOT NULL,
    CONSTRAINT FK_engagement_campaign FOREIGN KEY (campaign_id) REFERENCES raw.campaigns(campaign_id),
    CONSTRAINT FK_engagement_product FOREIGN KEY (product_id) REFERENCES raw.products(product_id),
    CONSTRAINT CK_engagement_metrics CHECK (views >= 0 AND clicks >= 0 AND likes >= 0 AND shares >= 0 AND comments >= 0)
);
GO
IF OBJECT_ID('raw.customer_reviews','U') IS NULL
CREATE TABLE raw.customer_reviews (
    review_id   varchar(12)   NOT NULL CONSTRAINT PK_customer_reviews PRIMARY KEY,
    customer_id varchar(12)   NOT NULL,
    product_id  varchar(12)   NOT NULL,
    review_date date          NOT NULL,
    rating      tinyint       NOT NULL,
    review_text varchar(1000) NOT NULL,
    CONSTRAINT FK_reviews_customer FOREIGN KEY (customer_id) REFERENCES raw.customers(customer_id),
    CONSTRAINT FK_reviews_product FOREIGN KEY (product_id) REFERENCES raw.products(product_id),
    CONSTRAINT CK_reviews_rating CHECK (rating BETWEEN 1 AND 5)
);
GO
/* Helpful join/filter indexes. */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_journey_date_campaign' AND object_id=OBJECT_ID('raw.customer_journey'))
    CREATE INDEX IX_journey_date_campaign ON raw.customer_journey(session_date, campaign_id) INCLUDE(stage, converted, order_value, customer_id);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_reviews_product_date' AND object_id=OBJECT_ID('raw.customer_reviews'))
    CREATE INDEX IX_reviews_product_date ON raw.customer_reviews(product_id, review_date) INCLUDE(rating);
GO
PRINT 'Raw tables created or already existed.';
