-- ====================================================================
-- CogniStream Developer Analytics: Application & Tool Productivity Breakdown
-- Author: Tahseen Parvej (Data Analyst & SQL Database Engineer)
-- File: sql/06_application_productivity.sql
-- ====================================================================

-- 1. Application Usage Share & Time Investment
SELECT 
    Application_Used,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(COUNT(Record_ID) * 100.0 / (SELECT COUNT(*) FROM cognistream_sessions), 2) AS Usage_Share_Percent,
    ROUND(SUM(Task_Duration_Minutes) / 60.0, 1) AS Total_Hours_Logged,
    ROUND(AVG(Task_Duration_Minutes), 1) AS Avg_Session_Duration_Mins
FROM cognistream_sessions
GROUP BY Application_Used
ORDER BY Total_Sessions DESC;

-- 2. Tool Flow Efficiency & Cognitive Strain Ranking
SELECT 
    Application_Used,
    COUNT(Record_ID) AS Session_Count,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
    ROUND(AVG(Task_Completion_Percent), 2) AS Avg_Completion_Rate
FROM cognistream_sessions
GROUP BY Application_Used
ORDER BY Avg_Flow_Efficiency DESC;

-- 3. Context Switching & Interruption Friction by Application
SELECT 
    Application_Used,
    ROUND(AVG(Active_Window_Switches), 2) AS Avg_Window_Switches,
    ROUND(AVG(Interruptions_Count), 2) AS Avg_Interruptions,
    ROUND(AVG(Idle_Time_Minutes), 1) AS Avg_Idle_Minutes,
    ROUND(SUM(Error_Count) * 1.0 / COUNT(Record_ID), 2) AS Avg_Errors_Per_Session
FROM cognistream_sessions
GROUP BY Application_Used
ORDER BY Avg_Window_Switches DESC;

-- 4. Operating System & Hardware Platform Comparison
SELECT 
    Operating_System,
    Device_Type,
    COUNT(Record_ID) AS Session_Count,
    ROUND(SUM(Task_Duration_Minutes) / 60.0, 1) AS Total_Hours,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Keystrokes_Per_Minute), 1) AS Avg_Keystrokes_Per_Min
FROM cognistream_sessions
GROUP BY Operating_System, Device_Type
ORDER BY Operating_System, Avg_Flow_Efficiency DESC;

-- 5. Error Rate & Session Abandonment by Primary Application
SELECT 
    Application_Used,
    COUNT(Record_ID) AS Total_Sessions,
    SUM(Error_Count) AS Total_Errors,
    ROUND(SUM(CASE WHEN Session_Outcome = 'Abandoned' THEN 1 ELSE 0 END) * 100.0 / COUNT(Record_ID), 2) AS Abandonment_Rate_Percent,
    ROUND(SUM(CASE WHEN Session_Outcome = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(Record_ID), 2) AS Completion_Rate_Percent
FROM cognistream_sessions
GROUP BY Application_Used
ORDER BY Abandonment_Rate_Percent DESC;
