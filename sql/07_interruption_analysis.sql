-- ====================================================================
-- CogniStream Developer Analytics: Interruption Frequency & Cognitive Impact
-- Author: Tahseen Parvej (Data Analyst & SQL Database Engineer)
-- File: sql/07_interruption_analysis.sql
-- ====================================================================

-- 1. Interruption Type Share & Aggregate Impact
SELECT 
    Interruption_Type,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(COUNT(Record_ID) * 100.0 / (SELECT COUNT(*) FROM cognistream_sessions), 2) AS Session_Share_Percent,
    SUM(Interruptions_Count) AS Total_Interruptions,
    ROUND(AVG(Interruptions_Count), 2) AS Avg_Interruptions_Per_Session,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency
FROM cognistream_sessions
GROUP BY Interruption_Type
ORDER BY Avg_Cognitive_Load DESC;

-- 2. Interruption Volume Thresholds (Bucketing Analysis)
SELECT 
    CASE 
        WHEN Interruptions_Count = 0 THEN '0 (Uninterrupted Deep Work)'
        WHEN Interruptions_Count BETWEEN 1 AND 2 THEN '1-2 (Mild Disruption)'
        WHEN Interruptions_Count BETWEEN 3 AND 5 THEN '3-5 (Moderate Disruption)'
        ELSE '6+ (Severe Fragmentation)'
    END AS Interruption_Bucket,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(COUNT(Record_ID) * 100.0 / (SELECT COUNT(*) FROM cognistream_sessions), 2) AS Bucket_Share_Percent,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
    ROUND(AVG(Task_Completion_Percent), 2) AS Avg_Completion_Rate,
    ROUND(AVG(Error_Count), 2) AS Avg_Errors_Per_Session,
    ROUND(AVG(Idle_Time_Minutes), 1) AS Avg_Idle_Minutes
FROM cognistream_sessions
GROUP BY Interruption_Bucket
ORDER BY Avg_Cognitive_Load DESC;

-- 3. Error Rate Escalation & Cognitive Friction Analysis
SELECT 
    Interruptions_Count,
    COUNT(Record_ID) AS Session_Count,
    ROUND(AVG(Error_Count), 2) AS Avg_Errors,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
    ROUND(AVG(Active_Window_Switches), 2) AS Avg_Window_Switches
FROM cognistream_sessions
WHERE Interruptions_Count <= 8
GROUP BY Interruptions_Count
ORDER BY Interruptions_Count ASC;

-- 4. Context-Switching Recovery Cost (Idle Time Inflation by Interruption Vector)
SELECT 
    Interruption_Type,
    ROUND(AVG(Idle_Time_Minutes), 1) AS Avg_Idle_Time_Mins,
    ROUND(AVG(Task_Duration_Minutes), 1) AS Avg_Task_Duration_Mins,
    ROUND(AVG(Idle_Time_Minutes) * 100.0 / AVG(Task_Duration_Minutes), 2) AS Idle_To_Task_Ratio_Percent,
    ROUND(AVG(Active_Window_Switches), 1) AS Avg_Window_Switches
FROM cognistream_sessions
WHERE Interruption_Type != 'No Interruption'
GROUP BY Interruption_Type
ORDER BY Avg_Idle_Time_Mins DESC;

-- 5. Interruption Impact on Session Completion Outcomes
SELECT 
    Interruption_Type,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(SUM(CASE WHEN Session_Outcome = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(Record_ID), 2) AS Completion_Success_Rate,
    ROUND(SUM(CASE WHEN Session_Outcome IN ('Abandoned', 'Blocked') THEN 1 ELSE 0 END) * 100.0 / COUNT(Record_ID), 2) AS Failure_Blocked_Rate,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load
FROM cognistream_sessions
GROUP BY Interruption_Type
ORDER BY Failure_Blocked_Rate DESC;
