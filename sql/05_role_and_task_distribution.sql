-- ====================================================================
-- CogniStream Developer Analytics: Role and Task Type Distribution Analysis
-- Author: Tahseen Parvej (Data Analyst & SQL Database Engineer)
-- File: sql/05_role_and_task_distribution.sql
-- ====================================================================

-- 1. Developer Role Performance & Cognitive Load Matrix
SELECT 
    Role,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(COUNT(Record_ID) * 100.0 / (SELECT COUNT(*) FROM cognistream_sessions), 2) AS Role_Share_Percent,
    ROUND(SUM(Task_Duration_Minutes) / 60.0, 1) AS Total_Hours_Logged,
    ROUND(AVG(Task_Duration_Minutes), 1) AS Avg_Duration_Mins,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
    ROUND(AVG(Task_Completion_Percent), 2) AS Avg_Completion_Rate,
    ROUND(SUM(Interruptions_Count) * 1.0 / COUNT(Record_ID), 2) AS Avg_Interruptions_Per_Session,
    ROUND(SUM(Error_Count) * 1.0 / COUNT(Record_ID), 2) AS Avg_Errors_Per_Session
FROM cognistream_sessions
GROUP BY Role
ORDER BY Total_Sessions DESC;

-- 2. Task Type Distribution & Cognitive Strain Breakdown
SELECT 
    Task_Type,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(COUNT(Record_ID) * 100.0 / (SELECT COUNT(*) FROM cognistream_sessions), 2) AS Task_Share_Percent,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Efficiency_Score,
    ROUND(AVG(Task_Completion_Percent), 2) AS Avg_Completion_Percent,
    ROUND(AVG(Active_Window_Switches), 2) AS Avg_Context_Switches
FROM cognistream_sessions
GROUP BY Task_Type
ORDER BY Avg_Cognitive_Load DESC;

-- 3. High Cognitive Load (> 7.0) Burnout Risk by Role
SELECT 
    Role,
    COUNT(*) AS Total_Sessions,
    SUM(CASE WHEN Cognitive_Load_Score >= 7.0 THEN 1 ELSE 0 END) AS High_Cognitive_Sessions,
    ROUND(SUM(CASE WHEN Cognitive_Load_Score >= 7.0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS High_Load_Risk_Percent,
    ROUND(AVG(Error_Count), 2) AS Avg_Errors_During_High_Load
FROM cognistream_sessions
GROUP BY Role
ORDER BY High_Load_Risk_Percent DESC;

-- 4. Cross-Analysis: Role vs Primary Task Allocation (Hours Logged)
SELECT 
    Role,
    Task_Type,
    COUNT(*) AS Session_Count,
    ROUND(SUM(Task_Duration_Minutes) / 60.0, 1) AS Total_Hours,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency
FROM cognistream_sessions
GROUP BY Role, Task_Type
HAVING COUNT(*) >= 50
ORDER BY Role, Total_Hours DESC;

-- 5. Task Outcomes & Failure/Abandonment Rates by Task Type
SELECT 
    Task_Type,
    COUNT(*) AS Total_Sessions,
    ROUND(SUM(CASE WHEN Session_Outcome = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Completion_Rate_Percent,
    ROUND(SUM(CASE WHEN Session_Outcome = 'Abandoned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Abandonment_Rate_Percent,
    ROUND(SUM(CASE WHEN Session_Outcome = 'Blocked' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Blocked_Rate_Percent,
    ROUND(AVG(Idle_Time_Minutes), 1) AS Avg_Idle_Minutes
FROM cognistream_sessions
GROUP BY Task_Type
ORDER BY Abandonment_Rate_Percent DESC;
