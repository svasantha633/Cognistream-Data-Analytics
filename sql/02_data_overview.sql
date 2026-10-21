-- ====================================================================
-- CogniStream Developer Analytics: Data Overview & Table Verification
-- Author: Tahseen Parvej (Data Analyst & SQL Database Engineer)
-- File: sql/02_data_overview.sql
-- ====================================================================

-- 1. Total Session Count and Date Boundary
SELECT 
    COUNT(*) AS Total_Sessions,
    MIN(Session_Date) AS Earliest_Session_Date,
    MAX(Session_Date) AS Latest_Session_Date,
    COUNT(DISTINCT Session_Date) AS Unique_Session_Days
FROM cognistream_sessions;

-- 2. Entity Cardinality and Scope Summary
SELECT 
    COUNT(DISTINCT Developer_ID) AS Total_Unique_Developers,
    COUNT(DISTINCT Project_ID) AS Total_Unique_Projects,
    COUNT(DISTINCT Role) AS Total_Unique_Roles,
    COUNT(DISTINCT Task_Type) AS Total_Task_Types,
    COUNT(DISTINCT Application_Used) AS Total_Applications_Used,
    COUNT(DISTINCT Device_Type) AS Total_Device_Types,
    COUNT(DISTINCT Operating_System) AS Total_Operating_Systems
FROM cognistream_sessions;

-- 3. Telemetry Aggregation Snapshot
SELECT 
    ROUND(SUM(Task_Duration_Minutes), 1) AS Total_Task_Minutes,
    ROUND(SUM(Task_Duration_Minutes) / 60.0, 1) AS Total_Task_Hours,
    ROUND(AVG(Task_Duration_Minutes), 2) AS Avg_Session_Duration_Minutes,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency_Percent,
    SUM(Interruptions_Count) AS Total_Interruptions_Recorded,
    SUM(Error_Count) AS Total_Errors_Logged
FROM cognistream_sessions;

-- 4. Flow State Distribution Breakdown
SELECT 
    Flow_State,
    COUNT(*) AS Session_Count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cognistream_sessions), 2) AS Share_Percentage,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Efficiency
FROM cognistream_sessions
GROUP BY Flow_State
ORDER BY Session_Count DESC;

-- 5. Session Outcome Breakdown
SELECT 
    Session_Outcome,
    COUNT(*) AS Total_Sessions,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cognistream_sessions), 2) AS Percentage,
    ROUND(AVG(Task_Completion_Percent), 2) AS Avg_Completion_Rate,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load
FROM cognistream_sessions
GROUP BY Session_Outcome
ORDER BY Total_Sessions DESC;

-- 6. Sample 5 Records Preview
SELECT 
    Record_ID,
    Session_Date,
    Developer_ID,
    Role,
    Task_Type,
    Flow_State,
    Cognitive_Load_Score,
    Task_Duration_Minutes,
    Flow_Efficiency_Score,
    Session_Outcome
FROM cognistream_sessions
ORDER BY Session_Date, Session_Start_Time
LIMIT 5;
