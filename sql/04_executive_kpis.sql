-- ====================================================================
-- CogniStream Developer Analytics: Executive KPIs & Productivity Metrics
-- Author: Tahseen Parvej (Data Analyst & SQL Database Engineer)
-- File: sql/04_executive_kpis.sql
-- ====================================================================

-- 1. High-Level Executive Scorecard
SELECT 
    COUNT(Record_ID) AS Total_Sessions_Analyzed,
    COUNT(DISTINCT Developer_ID) AS Total_Active_Developers,
    COUNT(DISTINCT Project_ID) AS Total_Active_Projects,
    ROUND(SUM(Task_Duration_Minutes) / 60.0, 1) AS Total_Developer_Hours,
    ROUND(AVG(Task_Duration_Minutes), 1) AS Avg_Session_Duration_Mins,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Overall_Avg_Cognitive_Load,
    ROUND(AVG(Self_Reported_Focus_Score), 2) AS Overall_Avg_Focus_Score,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Overall_Avg_Flow_Efficiency,
    ROUND(AVG(Task_Completion_Percent), 2) AS Overall_Avg_Completion_Rate
FROM cognistream_sessions;

-- 2. Flow State Ratio & Cognitive Friction Indicators
SELECT 
    ROUND(SUM(CASE WHEN Flow_State IN ('Flow', 'Focused') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Deep_Work_Rate_Percent,
    ROUND(SUM(CASE WHEN Flow_State = 'Interrupted' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Interruption_Rate_Percent,
    ROUND(SUM(CASE WHEN Flow_State = 'Blocked' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Blocked_Rate_Percent,
    ROUND(SUM(CASE WHEN Flow_State = 'Multitasking' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Context_Switching_Rate_Percent,
    ROUND(SUM(CASE WHEN Cognitive_Load_Score >= 7.0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS High_Cognitive_Load_Risk_Percent,
    ROUND(SUM(CASE WHEN Self_Reported_Focus_Score >= 8.0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS High_Focus_Session_Percent
FROM cognistream_sessions;

-- 3. Developer Lost Time & Idle Friction Analysis
SELECT 
    ROUND(SUM(Idle_Time_Minutes) / 60.0, 1) AS Total_Idle_Hours_Lost,
    ROUND(AVG(Idle_Time_Minutes), 2) AS Avg_Idle_Minutes_Per_Session,
    ROUND(SUM(Idle_Time_Minutes) * 100.0 / SUM(Task_Duration_Minutes), 2) AS Idle_Time_Friction_Ratio_Percent,
    SUM(Interruptions_Count) AS Total_Interruptions,
    ROUND(SUM(Interruptions_Count) * 1.0 / (SUM(Task_Duration_Minutes) / 60.0), 2) AS Interruptions_Per_Developer_Hour,
    SUM(Error_Count) AS Total_Errors_Logged,
    ROUND(SUM(Error_Count) * 1.0 / (SUM(Task_Duration_Minutes) / 60.0), 2) AS Errors_Per_Developer_Hour
FROM cognistream_sessions;

-- 4. Session Outcome Success vs Attrition Ratios
SELECT 
    ROUND(SUM(CASE WHEN Session_Outcome = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Completion_Success_Rate,
    ROUND(SUM(CASE WHEN Session_Outcome = 'Partially Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Partial_Completion_Rate,
    ROUND(SUM(CASE WHEN Session_Outcome = 'Blocked' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Blocked_Session_Rate,
    ROUND(SUM(CASE WHEN Session_Outcome = 'Abandoned' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Abandonment_Rate
FROM cognistream_sessions;

-- 5. Executive Summary Matrix by Flow State
SELECT 
    Flow_State,
    COUNT(*) AS Session_Count,
    ROUND(AVG(Task_Duration_Minutes), 1) AS Avg_Duration_Mins,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
    ROUND(AVG(Interruptions_Count), 2) AS Avg_Interruptions,
    ROUND(AVG(Active_Window_Switches), 2) AS Avg_Window_Switches,
    ROUND(AVG(Task_Completion_Percent), 2) AS Avg_Completion_Percent,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Efficiency_Score
FROM cognistream_sessions
GROUP BY Flow_State
ORDER BY Session_Count DESC;
