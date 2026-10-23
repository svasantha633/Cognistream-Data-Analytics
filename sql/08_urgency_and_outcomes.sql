-- ====================================================================
-- CogniStream Developer Analytics: Deadline Urgency & Outcome Analysis
-- Author: Tahseen Parvej (Data Analyst & SQL Database Engineer)
-- File: sql/08_urgency_and_outcomes.sql
-- ====================================================================

-- 1. Performance & Cognitive Metric Distribution by Deadline Urgency
SELECT 
    Deadline_Urgency,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(COUNT(Record_ID) * 100.0 / (SELECT COUNT(*) FROM cognistream_sessions), 2) AS Urgency_Share_Percent,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
    ROUND(AVG(Task_Completion_Percent), 2) AS Avg_Completion_Rate,
    ROUND(AVG(Error_Count), 2) AS Avg_Errors_Per_Session
FROM cognistream_sessions
GROUP BY Deadline_Urgency
ORDER BY 
    CASE Deadline_Urgency 
        WHEN 'Critical' THEN 1 
        WHEN 'High' THEN 2 
        WHEN 'Medium' THEN 3 
        WHEN 'Low' THEN 4 
        ELSE 5 
    END;

-- 2. Session Outcome Rates by Urgency Level
SELECT 
    Deadline_Urgency,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(SUM(CASE WHEN Session_Outcome = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(Record_ID), 2) AS Completion_Rate_Percent,
    ROUND(SUM(CASE WHEN Session_Outcome = 'Partially Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(Record_ID), 2) AS Partial_Rate_Percent,
    ROUND(SUM(CASE WHEN Session_Outcome = 'Blocked' THEN 1 ELSE 0 END) * 100.0 / COUNT(Record_ID), 2) AS Blocked_Rate_Percent,
    ROUND(SUM(CASE WHEN Session_Outcome = 'Abandoned' THEN 1 ELSE 0 END) * 100.0 / COUNT(Record_ID), 2) AS Abandoned_Rate_Percent
FROM cognistream_sessions
GROUP BY Deadline_Urgency
ORDER BY 
    CASE Deadline_Urgency 
        WHEN 'Critical' THEN 1 
        WHEN 'High' THEN 2 
        WHEN 'Medium' THEN 3 
        WHEN 'Low' THEN 4 
        ELSE 5 
    END;

-- 3. Cognitive Overload Risk (Score >= 7.0) & Error Density
SELECT 
    Deadline_Urgency,
    COUNT(Record_ID) AS Total_Sessions,
    SUM(CASE WHEN Cognitive_Load_Score >= 7.0 THEN 1 ELSE 0 END) AS High_Load_Sessions,
    ROUND(SUM(CASE WHEN Cognitive_Load_Score >= 7.0 THEN 1 ELSE 0 END) * 100.0 / COUNT(Record_ID), 2) AS Overload_Risk_Percent,
    SUM(Error_Count) AS Total_Errors,
    ROUND(SUM(Error_Count) * 1.0 / (SUM(Task_Duration_Minutes) / 60.0), 2) AS Errors_Per_Developer_Hour
FROM cognistream_sessions
GROUP BY Deadline_Urgency
ORDER BY Overload_Risk_Percent DESC;

-- 4. Cross-Analysis: Urgency Level vs Experienced Flow State
SELECT 
    Deadline_Urgency,
    Flow_State,
    COUNT(Record_ID) AS Session_Count,
    ROUND(AVG(Task_Completion_Percent), 2) AS Avg_Completion_Rate,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency
FROM cognistream_sessions
GROUP BY Deadline_Urgency, Flow_State
ORDER BY Deadline_Urgency, Session_Count DESC;

-- 5. Time Investment & Keystroke Intensity Under Deadline Pressure
SELECT 
    Deadline_Urgency,
    ROUND(AVG(Task_Duration_Minutes), 1) AS Avg_Session_Duration_Mins,
    ROUND(AVG(Keystrokes_Per_Minute), 1) AS Avg_Keystrokes_Per_Min,
    ROUND(AVG(Active_Window_Switches), 2) AS Avg_Window_Switches,
    ROUND(AVG(Idle_Time_Minutes), 1) AS Avg_Idle_Minutes
FROM cognistream_sessions
GROUP BY Deadline_Urgency
ORDER BY Avg_Keystrokes_Per_Min DESC;
