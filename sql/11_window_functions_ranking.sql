-- ====================================================================
-- CogniStream Developer Analytics: Window Functions & Longitudinal Rankings
-- Author: Tahseen Parvej (Data Analyst & SQL Database Engineer)
-- File: sql/11_window_functions_ranking.sql
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. Top Performers Ranking per Engineering Role (DENSE_RANK)
-- Identifies highest flow efficiency contributors within each job role,
-- accounting for cognitive load and self-reported focus.
-- --------------------------------------------------------------------
WITH DeveloperRoleMetrics AS (
    SELECT 
        Role,
        Developer_ID,
        COUNT(Record_ID) AS Total_Sessions,
        ROUND(SUM(Task_Duration_Minutes) / 60.0, 1) AS Total_Hours,
        ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
        ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
        ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
        ROUND(AVG(Task_Completion_Percent), 2) AS Avg_Completion_Rate
    FROM cognistream_sessions
    GROUP BY Role, Developer_ID
    HAVING COUNT(Record_ID) >= 10
)
SELECT 
    Role,
    DENSE_RANK() OVER (
        PARTITION BY Role 
        ORDER BY Avg_Flow_Efficiency DESC, Avg_Cognitive_Load ASC
    ) AS Efficiency_Rank,
    Developer_ID,
    Total_Sessions,
    Total_Hours,
    Avg_Flow_Efficiency,
    Avg_Cognitive_Load,
    Avg_Focus_Score,
    Avg_Completion_Rate
FROM DeveloperRoleMetrics
ORDER BY Role, Efficiency_Rank
LIMIT 40;

-- --------------------------------------------------------------------
-- 2. Cumulative Monthly Logged Hours & Milestone Velocity by Project (SUM OVER)
-- Calculates cumulative developer hours per project over time, tracking
-- total effort burn-up and month-over-month resource allocation.
-- --------------------------------------------------------------------
WITH MonthlyProjectHours AS (
    SELECT 
        Project_ID,
        strftime('%Y-%m', Session_Date) AS Session_Month,
        ROUND(SUM(Task_Duration_Minutes) / 60.0, 1) AS Monthly_Hours,
        COUNT(Record_ID) AS Monthly_Sessions
    FROM cognistream_sessions
    GROUP BY Project_ID, strftime('%Y-%m', Session_Date)
)
SELECT 
    Project_ID,
    Session_Month,
    Monthly_Sessions,
    Monthly_Hours,
    ROUND(SUM(Monthly_Hours) OVER (
        PARTITION BY Project_ID 
        ORDER BY Session_Month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 1) AS Cumulative_Project_Hours,
    ROUND(SUM(Monthly_Hours) OVER (
        PARTITION BY Project_ID 
        ORDER BY Session_Month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) * 100.0 / SUM(Monthly_Hours) OVER (PARTITION BY Project_ID), 2) AS Cumulative_Project_Progress_Pct
FROM MonthlyProjectHours
ORDER BY Project_ID, Session_Month;

-- --------------------------------------------------------------------
-- 3. 5-Session Rolling Moving Average of Cognitive Load & Focus Score (AVG OVER ROWS BETWEEN)
-- Smooths short-term session noise to expose chronic cognitive strain
-- and deep work degradation trends for recurring engineers.
-- --------------------------------------------------------------------
SELECT 
    Record_ID,
    Developer_ID,
    Session_Date,
    Task_Type,
    Cognitive_Load_Score,
    ROUND(AVG(Cognitive_Load_Score) OVER (
        PARTITION BY Developer_ID 
        ORDER BY Session_Date, Record_ID 
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 2) AS Rolling_5Sess_Avg_Cognitive_Load,
    Self_Reported_Focus_Score,
    ROUND(AVG(Self_Reported_Focus_Score) OVER (
        PARTITION BY Developer_ID 
        ORDER BY Session_Date, Record_ID 
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 2) AS Rolling_5Sess_Avg_Focus,
    Flow_Efficiency_Score,
    ROUND(AVG(Flow_Efficiency_Score) OVER (
        PARTITION BY Developer_ID 
        ORDER BY Session_Date, Record_ID 
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 2) AS Rolling_5Sess_Avg_Flow
FROM cognistream_sessions
ORDER BY Developer_ID, Session_Date, Record_ID
LIMIT 50;

-- --------------------------------------------------------------------
-- 4. Session-over-Session Cognitive Load Shift & Fatigue Escalation (LAG)
-- Uses LAG() to evaluate consecutive session differentials in cognitive
-- strain and detect acute burnout escalation events (spike >= 2.0).
-- --------------------------------------------------------------------
WITH SessionDeltas AS (
    SELECT 
        Record_ID,
        Developer_ID,
        Session_Date,
        Session_Start_Time,
        Task_Type,
        Deadline_Urgency,
        Cognitive_Load_Score,
        LAG(Cognitive_Load_Score, 1) OVER (
            PARTITION BY Developer_ID 
            ORDER BY Session_Date, Session_Start_Time, Record_ID
        ) AS Prev_Cognitive_Load,
        Flow_Efficiency_Score,
        LAG(Flow_Efficiency_Score, 1) OVER (
            PARTITION BY Developer_ID 
            ORDER BY Session_Date, Session_Start_Time, Record_ID
        ) AS Prev_Flow_Efficiency,
        Error_Count,
        Interruptions_Count
    FROM cognistream_sessions
)
SELECT 
    Record_ID,
    Developer_ID,
    Session_Date,
    Task_Type,
    Deadline_Urgency,
    Cognitive_Load_Score,
    Prev_Cognitive_Load,
    ROUND(Cognitive_Load_Score - Prev_Cognitive_Load, 2) AS Cognitive_Load_Shift,
    ROUND(Flow_Efficiency_Score - Prev_Flow_Efficiency, 2) AS Flow_Efficiency_Shift,
    CASE 
        WHEN Prev_Cognitive_Load IS NULL THEN 'Initial Session'
        WHEN Cognitive_Load_Score - Prev_Cognitive_Load >= 2.0 THEN 'Acute Strain Spike (Risk)'
        WHEN Cognitive_Load_Score - Prev_Cognitive_Load <= -2.0 THEN 'Significant Recovery'
        ELSE 'Stable Load'
    END AS Fatigue_State_Change
FROM SessionDeltas
WHERE Prev_Cognitive_Load IS NOT NULL
ORDER BY Developer_ID, Session_Date
LIMIT 50;

-- --------------------------------------------------------------------
-- 5. Interruption Quartile Distribution & Performance Degradation (NTILE)
-- Divides all sessions into 4 statistical quartiles based on interruption
-- frequency to quantify impact on flow efficiency and completion rates.
-- --------------------------------------------------------------------
WITH RankedInterruptions AS (
    SELECT 
        Record_ID,
        Developer_ID,
        Role,
        Task_Duration_Minutes,
        Idle_Time_Minutes,
        Interruptions_Count,
        Cognitive_Load_Score,
        Self_Reported_Focus_Score,
        Flow_Efficiency_Score,
        Task_Completion_Percent,
        NTILE(4) OVER (ORDER BY Interruptions_Count ASC) AS Interruption_Quartile
    FROM cognistream_sessions
)
SELECT 
    Interruption_Quartile,
    CASE Interruption_Quartile
        WHEN 1 THEN 'Q1: Minimal Disruptions (0 - 1)'
        WHEN 2 THEN 'Q2: Low Disruptions (1 - 2)'
        WHEN 3 THEN 'Q3: Moderate Disruptions (2 - 3)'
        WHEN 4 THEN 'Q4: Severe Disruptions (3 - 11)'
    END AS Interruption_Tier_Label,
    COUNT(Record_ID) AS Total_Sessions,
    MIN(Interruptions_Count) AS Min_Interruptions,
    MAX(Interruptions_Count) AS Max_Interruptions,
    ROUND(AVG(Interruptions_Count), 1) AS Avg_Interruptions,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
    ROUND(AVG(Task_Completion_Percent), 2) AS Avg_Completion_Rate,
    ROUND(AVG(Idle_Time_Minutes), 1) AS Avg_Idle_Minutes
FROM RankedInterruptions
GROUP BY Interruption_Quartile
ORDER BY Interruption_Quartile;

-- --------------------------------------------------------------------
-- 6. High Friction Anomaly Identification via PERCENT_RANK()
-- Pinpoints top 5% most friction-heavy sessions (idle time to duration ratio)
-- for immediate workflow re-engineering and tool audit.
-- --------------------------------------------------------------------
WITH SessionFrictionRank AS (
    SELECT 
        Record_ID,
        Developer_ID,
        Role,
        Task_Type,
        Task_Duration_Minutes,
        Idle_Time_Minutes,
        Interruptions_Count,
        Error_Count,
        Cognitive_Load_Score,
        Flow_Efficiency_Score,
        ROUND(Idle_Time_Minutes * 100.0 / Task_Duration_Minutes, 2) AS Friction_Ratio_Pct,
        PERCENT_RANK() OVER (ORDER BY (Idle_Time_Minutes * 1.0 / Task_Duration_Minutes) DESC) AS Friction_Percentile
    FROM cognistream_sessions
    WHERE Task_Duration_Minutes > 0
)
SELECT 
    Record_ID,
    Developer_ID,
    Role,
    Task_Type,
    Task_Duration_Minutes,
    Idle_Time_Minutes,
    Friction_Ratio_Pct,
    Interruptions_Count,
    Error_Count,
    Cognitive_Load_Score,
    Flow_Efficiency_Score,
    ROUND(Friction_Percentile, 4) AS Friction_Percentile_Rank
FROM SessionFrictionRank
WHERE Friction_Percentile <= 0.05
ORDER BY Friction_Percentile ASC
LIMIT 30;
