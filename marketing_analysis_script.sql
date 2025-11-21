-- =========================================================
-- 1. INITIAL EXPLORATION AND DATA QUALITY CHECKS
-- =========================================================

-- 1.1 Row counts per table
-- Use UNION ALL to combine counts from all base tables
SELECT 'users'     AS table_name, COUNT(*) AS row_count FROM users
UNION ALL
SELECT 'campaigns' AS table_name, COUNT(*) AS row_count FROM campaigns
UNION ALL
SELECT 'ads'       AS table_name, COUNT(*) AS row_count FROM ads
UNION ALL
SELECT 'ad_events' AS table_name, COUNT(*) AS row_count FROM ad_events;

/*
users      -> 10 000
campaigns  -> 50
ads        -> 200
ad_events  -> 400 000
*/


-- 1.2 Null checks on key columns

-- Null-check for ad_events
SELECT
    SUM(event_id    IS NULL) AS null_event_id,
    SUM(ad_id       IS NULL) AS null_ad_id,
    SUM(user_id     IS NULL) AS null_user_id,
    SUM(`timestamp` IS NULL) AS null_timestamp,
    SUM(event_type  IS NULL) AS null_event_type
FROM ad_events;

-- Null-check for ads
SELECT
    SUM(ad_id       IS NULL) AS null_ad_id,
    SUM(campaign_id IS NULL) AS null_campaign_id
FROM ads;

-- Null-check for users
SELECT 
    SUM(user_id     IS NULL) AS null_user_id,
    SUM(user_gender IS NULL) AS null_gender,
    SUM(country     IS NULL) AS null_country
FROM users;

-- Null-check for campaigns
SELECT
    SUM(campaign_id  IS NULL) AS null_campaign_id,
    SUM(total_budget IS NULL) AS null_budget
FROM campaigns;

/*
There are no missing values in the selected columns
*/

-- 1.3 Duplicate checks

-- Duplicates in ad_events (by event_id)
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT event_id) AS distinct_events,
    COUNT(*) - COUNT(DISTINCT event_id) AS duplicate_event_ids
FROM ad_events;

-- Duplicates in ads (by ad_id)
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT ad_id) AS distinct_ads,
    COUNT(*) - COUNT(DISTINCT ad_id) AS duplicate_ad_ids
FROM ads;

-- Duplicates in campaigns (by campaign_id)
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT campaign_id) AS distinct_campaigns,
    COUNT(*) - COUNT(DISTINCT campaign_id) AS duplicate_campaign_ids
FROM campaigns;

/*
No duplicates in ad_events, ads or campaigns
*/

-- Duplicates in users (by user_id)
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT user_id) AS distinct_users,
    COUNT(*) - COUNT(DISTINCT user_id) AS duplicate_user_ids
FROM users;

/*
There are 50 duplicate user_ids (10 000 total rows, 9 950 distinct user_ids)
*/

-- Inspect which user_ids are duplicated
SELECT 
    user_id,
    COUNT(*) AS row_count
FROM users
GROUP BY user_id
HAVING COUNT(*) > 1
ORDER BY row_count DESC;

/*
Most duplicated user_ids have exactly 2 rows
*/

-- Sanity check: distinct vs total user count
SELECT COUNT(DISTINCT user_id) AS distinct_users FROM users;
SELECT COUNT(*)               AS total_rows     FROM users;

/*
Confirms 10 000 total rows and 9 950 distinct user_ids
*/


-- =========================================================
-- 2. CLEAN USERS TABLE (REMOVE DUPLICATE USER_IDS)
-- =========================================================

-- Create a clean user view with one row per user_id
-- If duplicates exist, keep the record with highest user_age
CREATE OR REPLACE VIEW users_clean AS
SELECT
    user_id,
    user_gender,
    user_age,
    age_group,
    country,
    location,
    interests
FROM (
    SELECT 
        u.*,
        ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY user_age DESC
        ) AS rn
    FROM users u
) t
WHERE rn = 1;

-- Check users_clean
SELECT 
    COUNT(*)               AS total_clean,
    COUNT(DISTINCT user_id) AS unique_clean_users
FROM users_clean;

-- Quality check
SELECT *
FROM users_clean
LIMIT 20;

/*
We now have 9 950 clean rows with unique user_ids
*/

-- =========================================================
-- 3. FACT TABLE FOR AD EVENTS
-- =========================================================

-- Central fact view combining events with ads, campaigns and users
CREATE OR REPLACE VIEW fact_ad_events AS
SELECT
    e.event_id,
    e.ad_id,
    e.user_id,
    e.`timestamp`,
    e.day_of_week,
    e.time_of_day,
    e.event_type,
    a.campaign_id,
    a.ad_platform,
    a.ad_type,
    a.target_gender,
    a.target_age_group,
    a.target_interests,
    u.user_gender,
    u.user_age,
    u.age_group,
    u.country,
    u.location,
    u.interests AS user_interests,
    c.name        AS campaign_name,
    c.start_date,
    c.end_date,
    c.duration_days,
    c.total_budget
FROM ad_events e
JOIN ads a 
    ON e.ad_id = a.ad_id
JOIN campaigns c 
    ON a.campaign_id = c.campaign_id
LEFT JOIN users_clean u 
    ON e.user_id = u.user_id;

-- Quality check
SELECT *
FROM fact_ad_events
LIMIT 20;


-- =========================================================
-- 4. CAMPAIGN DAILY METRICS AND KPIS
-- =========================================================

-- 4.1 Daily volume per campaign
CREATE OR REPLACE VIEW campaign_daily_metrics AS
SELECT
    campaign_id,
    campaign_name,
    DATE(`timestamp`) AS event_date,
    SUM(event_type = 'Impression') AS impressions,
    SUM(event_type = 'Click')      AS clicks,
    SUM(event_type = 'Like')       AS likes,
    SUM(event_type = 'Comment')    AS comments,
    SUM(event_type = 'Share')      AS shares,
    SUM(event_type = 'Purchase')   AS purchases
FROM fact_ad_events
GROUP BY
    campaign_id,
    campaign_name,
    DATE(`timestamp`);


-- Quality check
#SELECT * 
#FROM campaign_daily_metrics
#LIMIT 20; 

-- 4.2 Daily campaign KPIs (CTR and conversion rates)
CREATE OR REPLACE VIEW campaign_daily_kpis AS
SELECT
    campaign_id,
    campaign_name,
    event_date,
    impressions,
    clicks,
    purchases,
    -- CTR: share of impressions that lead to clicks
    CASE 
        WHEN impressions > 0 THEN clicks    * 1.0 / impressions 
        ELSE NULL 
    END AS ctr,
    -- Conversion rate from impressions to purchase
    CASE 
        WHEN impressions > 0 THEN purchases * 1.0 / impressions 
        ELSE NULL 
    END AS cvr_view,
    -- Conversion rate from clicks to purchase
    CASE 
        WHEN clicks > 0 THEN purchases * 1.0 / clicks      
        ELSE NULL 
    END AS cvr_click
FROM campaign_daily_metrics;


-- Quality check
#SELECT * 
#FROM campaign_daily_kpis 
#LIMIT 20;

-- =========================================================
-- 5. TOTAL CAMPAIGN METRICS AND COST KPIS
-- =========================================================

-- 5.1 Total campaign volume across the full period
CREATE OR REPLACE VIEW campaign_totals AS
SELECT
    c.campaign_id,
    c.name         AS campaign_name,
    c.total_budget,
    SUM(e.event_type = 'Impression') AS impressions,
    SUM(e.event_type = 'Click')      AS clicks,
    SUM(e.event_type = 'Purchase')   AS purchases
FROM campaigns c
JOIN ads a 
    ON c.campaign_id = a.campaign_id
JOIN ad_events e 
    ON a.ad_id = e.ad_id
GROUP BY
    c.campaign_id,
    c.name,
    c.total_budget;

-- Quality check
#SELECT * 
#FROM campaign_totals
#LIMIT 20;

-- 5.2 Economic KPIs per campaign (CPM, CPC, CPA)
CREATE OR REPLACE VIEW campaign_cost_kpis AS
SELECT
    campaign_id,
    campaign_name,
    total_budget,
    impressions,
    clicks,
    purchases,
    total_budget / NULLIF(impressions, 0) * 1.0  AS cost_per_impression,
    (total_budget / NULLIF(impressions, 0)) * 1000.0 AS cpm,
    total_budget / NULLIF(clicks, 0) * 1.0       AS cost_per_click,
    total_budget / NULLIF(purchases, 0) * 1.0    AS cost_per_purchase
FROM campaign_totals;


-- Quality check
#SELECT * 
#FROM campaign_cost_kpis
#LIMIT 20;

-- =========================================================
-- 6. SEGMENT PERFORMANCE AND KPIS
-- =========================================================

-- 6.1 Segment performance per campaign and demographic
CREATE OR REPLACE VIEW segment_performance AS
SELECT
    campaign_id,
    campaign_name,
    user_gender,
    age_group,
    country,
    SUM(event_type = 'Impression') AS impressions,
    SUM(event_type = 'Click')      AS clicks,
    SUM(event_type = 'Purchase')   AS purchases
FROM fact_ad_events
GROUP BY
    campaign_id,
    campaign_name,
    user_gender,
    age_group,
    country;

-- Quality check
#SELECT * 
#FROM segment_performance
#LIMIT 20;

-- 6.2 Segment-level KPIs (CTR and conversion rates)
CREATE OR REPLACE VIEW segment_performance_kpis AS
SELECT
    campaign_id,
    campaign_name,
    user_gender,
    age_group,
    country,
    impressions,
    clicks,
    purchases,
    -- CTR: clicks per impression
    CASE 
        WHEN impressions > 0 THEN clicks    * 1.0 / impressions 
        ELSE NULL 
    END AS ctr,
    -- Conversion rate from impressions to purchase
    CASE 
        WHEN impressions > 0 THEN purchases * 1.0 / impressions 
        ELSE NULL 
    END AS cvr_view,
    -- Conversion rate from clicks to purchase
    CASE 
        WHEN clicks > 0 THEN purchases * 1.0 / clicks      
        ELSE NULL 
    END AS cvr_click
FROM segment_performance;

-- Quality check
#SELECT * 
#FROM segment_performance_kpis
#LIMIT 20;


-- =========================================================
-- 7. USER x CAMPAIGN FEATURE VIEW
-- =========================================================

-- Aggregated funnel and features per user per campaign
CREATE OR REPLACE VIEW user_campaign_features AS
SELECT
    f.campaign_id,
    f.campaign_name,
    -- User-level attributes
    f.user_id,
    f.user_gender,
    f.age_group,
    f.country,
    -- Aggregated funnel per user x campaign
    SUM(f.event_type = 'Impression') AS impressions,
    SUM(f.event_type = 'Click')      AS clicks,
    SUM(f.event_type = 'Like')       AS likes,
    SUM(f.event_type = 'Comment')    AS comments,
    SUM(f.event_type = 'Share')      AS shares,
    SUM(f.event_type = 'Purchase')   AS purchases,
    -- Binary target for modelling: has the user converted in this campaign?
    CASE
        WHEN SUM(f.event_type = 'Purchase') > 0 THEN 1
        ELSE 0
    END AS purchased_flag,
    -- Simple time info per user x campaign
    MIN(f.`timestamp`) AS first_event_timestamp,
    MAX(f.`timestamp`) AS last_event_timestamp,
    -- Total number of events for this user in this campaign
    COUNT(*) AS total_events
FROM fact_ad_events f
GROUP BY
    f.campaign_id,
    f.campaign_name,
    f.user_id,
    f.user_gender,
    f.age_group,
    f.country;

-- Quality check
#SELECT * 
#FROM user_campaign_features
#LIMIT 20;


-- 8. MAKE TABLES OF THE VIEWS BECAUSE OF LONG RUNTIME (4,3 min per view)

DROP TABLE IF EXISTS fact_ad_events_tbl;
CREATE TABLE fact_ad_events_tbl AS
SELECT * FROM fact_ad_events;

DROP TABLE IF EXISTS campaign_daily_kpis_tbl;
CREATE TABLE campaign_daily_kpis_tbl AS
SELECT * FROM campaign_daily_kpis;

DROP TABLE IF EXISTS campaign_cost_kpis_tbl;
CREATE TABLE campaign_cost_kpis_tbl AS
SELECT * FROM campaign_cost_kpis;

DROP TABLE IF EXISTS segment_performance_kpis_tbl;
CREATE TABLE segment_performance_kpis_tbl AS
SELECT * FROM segment_performance_kpis;

DROP TABLE IF EXISTS user_campaign_features_tbl;
CREATE TABLE user_campaign_features_tbl AS
SELECT * FROM user_campaign_features;

SELECT * FROM segment_performance_kpis_tbl;
SELECT * FROM campaign_daily_kpis_tbl;
SELECT * FROM campaign_cost_kpis_tbl;
