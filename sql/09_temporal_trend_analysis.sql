-- ====================================================================
-- CogniStream Developer Analytics: Temporal & Time-of-Day Trend Analysis
-- Author: Tahseen Parvej (Data Analyst & SQL Database Engineer)
-- File: sql/09_temporal_trend_analysis.sql
-- ====================================================================

-- 1. Monthly Productivity & Cognitive Trajectory Across 2025
SELECT 
    SUBSTR(Session_Date, 1, 7) AS Year_Month,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(SUM(Task_Duration_Minutes) / 60.0, 1) AS Total_Hours_Logged,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
    ROUND(AVG(Task_Completion_Percent), 2) AS Avg_Completion_Rate,
    SUM(Error_Count) AS Total_Errors,
    SUM(Interruptions_Count) AS Total_Interruptions
FROM cognistream_sessions
GROUP BY SUBSTR(Session_Date, 1, 7)
ORDER BY Year_Month ASC;

-- 2. Day-of-Week Work Patterns & Focus Fluctuations
SELECT 
    CASE CAST(STRFTIME('%w', Session_Date) AS INTEGER)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS Day_Of_Week,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(AVG(Task_Duration_Minutes), 1) AS Avg_Session_Duration_Mins,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
    ROUND(AVG(Interruptions_Count), 2) AS Avg_Interruptions,
    ROUND(AVG(Error_Count), 2) AS Avg_Errors
FROM cognistream_sessions
GROUP BY STRFTIME('%w', Session_Date)
ORDER BY CAST(STRFTIME('%w', Session_Date) AS INTEGER);

-- 3. Time-of-Day / Shift Analysis: Optimal Focus Windows
SELECT 
    CASE 
        WHEN CAST(SUBSTR(Session_Start_Time, 1, 2) AS INTEGER) BETWEEN 6 AND 11 THEN 'Morning (06:00 - 11:59)'
        WHEN CAST(SUBSTR(Session_Start_Time, 1, 2) AS INTEGER) BETWEEN 12 AND 16 THEN 'Afternoon (12:00 - 16:59)'
        WHEN CAST(SUBSTR(Session_Start_Time, 1, 2) AS INTEGER) BETWEEN 17 AND 21 THEN 'Evening (17:00 - 21:59)'
        ELSE 'Night / Late Shift (22:00 - 05:59)'
    END AS Work_Shift,
    COUNT(Record_ID) AS Session_Count,
    ROUND(COUNT(Record_ID) * 100.0 / (SELECT COUNT(*) FROM cognistream_sessions), 2) AS Shift_Share_Percent,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
    ROUND(SUM(CASE WHEN Flow_State IN ('Flow', 'Focused') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Deep_Work_Rate_Percent,
    ROUND(AVG(Active_Window_Switches), 2) AS Avg_Context_Switches
FROM cognistream_sessions
GROUP BY Work_Shift
ORDER BY Deep_Work_Rate_Percent DESC;

-- 4. Quarterly Productivity & Burnout Risk Comparison
SELECT 
    CASE 
        WHEN SUBSTR(Session_Date, 6, 2) IN ('01', '02', '03') THEN 'Q1 (Jan - Mar)'
        WHEN SUBSTR(Session_Date, 6, 2) IN ('04', '05', '06') THEN 'Q2 (Apr - Jun)'
        WHEN SUBSTR(Session_Date, 6, 2) IN ('07', '08', '09') THEN 'Q3 (Jul - Sep)'
        ELSE 'Q4 (Oct - Dec)'
    END AS Quarter,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(SUM(Task_Duration_Minutes) / 60.0, 1) AS Total_Hours,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(SUM(CASE WHEN Cognitive_Load_Score >= 7.0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS High_Load_Risk_Percent,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
    ROUND(SUM(CASE WHEN Session_Outcome = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Completion_Rate_Percent
FROM cognistream_sessions
GROUP BY Quarter
ORDER BY Quarter ASC;

-- 5. Peak Interruption & Context Switching Hours
SELECT 
    SUBSTR(Session_Start_Time, 1, 2) || ':00' AS Hour_Of_Day,
    COUNT(Record_ID) AS Sessions_Started,
    ROUND(AVG(Interruptions_Count), 2) AS Avg_Interruptions,
    ROUND(AVG(Active_Window_Switches), 2) AS Avg_Window_Switches,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load
FROM cognistream_sessions
GROUP BY SUBSTR(Session_Start_Time, 1, 2)
ORDER BY Avg_Interruptions DESC
LIMIT 5;
