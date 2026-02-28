/*
================================================================================
Task 2 – SQL Analysis

Please write queries below to answer the following questions.
Assume standard SQL syntax (e.g., PostgreSQL or SQLite).
================================================================================
*/
/*
1. Number of users by region and platform
    Assumption: We are using the raw data from the csv files, So region column has messy data like ('USA', 'US','United States', 'can', 'Canada). I need to clean this up using a CASE statement so the GROUP BY aggregates the users correctly.
*/
-- TODO: Write your query here
SELECT 
    CASE 
        WHEN region IN ('United States', 'USA', 'US') THEN 'US'
        WHEN region IN ('Canada', 'can', 'CA') THEN 'CA'
        ELSE region 
    END AS clean_region,
    platform,
    COUNT(user_id) AS total_users
FROM 
    users
GROUP BY 
    clean_region, 
    platform
ORDER BY 
    clean_region, 
    platform;

-- 2. Number of devices per user
/*  Assumption: I am using a LEFT JOIN starting from the users table. This ensures that 
    users who have signed up but haven't added any devices yet still show up in the results 
    with a count of 0.
*/
SELECT 
    u.user_id,
    COUNT(d.device_id) AS device_count
FROM 
    users u
LEFT JOIN 
    devices d ON u.user_id = d.user_id
GROUP BY 
    u.user_id
ORDER BY 
    device_count DESC;


-- 3. Event volume per device type per day
/*  Assumption: The event_ts is a full timestamp string, so I use DATE() to extract 
    just the year-month-day for daily grouping.
    JOIN to devices is needed to get device_type from the events table.
*/
SELECT 
    DATE(e.event_ts) AS event_date,
    d.device_type,
    COUNT(e.event_id) AS total_events
FROM 
    events e
JOIN 
    devices d ON e.device_id = d.device_id
GROUP BY 
    event_date, 
    d.device_type
ORDER BY 
    event_date ASC, 
    total_events DESC;
    
-- 4. Identify devices with unusually high event volume
    /* Assumption & Definition: I am defining unusually high as devices that fall into 
    the top 5% of total event volume (the 96th percentile and above).
    I used NTILE(100) to bucket all devices into 100 percentile groups by event count,
    then filtered for the top 5%. This flags the  highest-volume devices.
    */
WITH DeviceEventCounts AS (
    SELECT 
        device_id,
        COUNT(event_id) AS total_events
    FROM 
        events
    GROUP BY 
        device_id
),
DevicePercentiles AS (
    SELECT 
        device_id,
        total_events,
        NTILE(100) OVER (ORDER BY total_events ASC) AS percentile_bucket
    FROM 
        DeviceEventCounts
)
SELECT 
    dp.device_id,
    d.device_type,
    d.network,
    d.firmware_version,
    dp.total_events,
    dp.percentile_bucket
FROM 
    DevicePercentiles dp
LEFT JOIN 
    devices d ON dp.device_id = d.device_id
WHERE 
    dp.percentile_bucket >= 96
ORDER BY 
    dp.total_events DESC;

