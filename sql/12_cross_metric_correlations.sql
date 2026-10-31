-- ====================================================================
-- CogniStream Developer Analytics: Cross-Metric Behavioral Correlations
-- Author: Tahseen Parvej (Data Analyst & SQL Database Engineer)
-- File: sql/12_cross_metric_correlations.sql
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. Keystroke Velocity Bands vs Focus, Cognitive Load & Flow Efficiency
-- Investigates whether higher raw typing cadence correlates with deeper
-- flow state or serves as a symptom of cognitive hyperactivity / stress.
-- --------------------------------------------------------------------
SELECT 
    CASE 
        WHEN Keystrokes_Per_Minute < 120 THEN '1. Low Velocity (<120 KPM)'
        WHEN Keystrokes_Per_Minute BETWEEN 120 AND 180 THEN '2. Moderate Velocity (120-180 KPM)'
        WHEN Keystrokes_Per_Minute BETWEEN 180.01 AND 240 THEN '3. High Velocity (180-240 KPM)'
        ELSE '4. Peak Velocity (>240 KPM)'
    END AS Keystroke_Tier,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(COUNT(Record_ID) * 100.0 / (SELECT COUNT(*) FROM cognistream_sessions), 2) AS Tier_Share_Pct,
    ROUND(AVG(Keystrokes_Per_Minute), 1) AS Avg_KPM,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
    ROUND(AVG(Error_Count), 2) AS Avg_Errors_Per_Session
FROM cognistream_sessions
GROUP BY 1
ORDER BY 1;

-- --------------------------------------------------------------------
-- 2. Context Switching Intensity (Switches Per Hour) vs Flow Degradation
-- Normalizes raw active window switches by session duration (switches/hr)
-- to assess cognitive fragmentation thresholds.
-- --------------------------------------------------------------------
SELECT 
    CASE 
        WHEN (Active_Window_Switches * 60.0 / Task_Duration_Minutes) < 10 THEN '1. Focused Focus (<10/hr)'
        WHEN (Active_Window_Switches * 60.0 / Task_Duration_Minutes) BETWEEN 10 AND 25 THEN '2. Moderate Switching (10-25/hr)'
        WHEN (Active_Window_Switches * 60.0 / Task_Duration_Minutes) BETWEEN 25.01 AND 50 THEN '3. High Fragmentation (25-50/hr)'
        ELSE '4. Severe Thrashing (>50/hr)'
    END AS Context_Switch_Tier,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(AVG(Active_Window_Switches * 60.0 / Task_Duration_Minutes), 1) AS Avg_Switches_Per_Hour,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
    ROUND(AVG(Task_Completion_Percent), 2) AS Avg_Completion_Rate,
    ROUND(AVG(Error_Count), 2) AS Avg_Errors
FROM cognistream_sessions
WHERE Task_Duration_Minutes > 0
GROUP BY 1
ORDER BY 1;

-- --------------------------------------------------------------------
-- 3. Interruption Burden Matrix: Count & Duration vs Lost Friction
-- Measures the compounding effect of frequent short interruptions versus
-- prolonged single disruptions on idle friction and developer recovery.
-- --------------------------------------------------------------------
SELECT 
    CASE 
        WHEN Interruptions_Count = 0 THEN '0 Disruptions (Deep Focus)'
        WHEN Interruptions_Count BETWEEN 1 AND 2 THEN '1-2 Disruptions (Minor)'
        WHEN Interruptions_Count BETWEEN 3 AND 5 THEN '3-5 Disruptions (Moderate)'
        ELSE '6+ Disruptions (Severe Friction)'
    END AS Interruption_Frequency_Tier,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(AVG(Interruptions_Count), 1) AS Avg_Disruptions,
    ROUND(AVG(Idle_Time_Minutes), 1) AS Avg_Idle_Mins,
    ROUND(AVG(Idle_Time_Minutes * 100.0 / Task_Duration_Minutes), 2) AS Avg_Idle_Ratio_Pct,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
    ROUND(AVG(Task_Completion_Percent), 2) AS Avg_Completion_Pct
FROM cognistream_sessions
WHERE Task_Duration_Minutes > 0
GROUP BY 1
ORDER BY Avg_Disruptions ASC;

-- --------------------------------------------------------------------
-- 4. Statistical Pearson Correlation Matrix (Direct SQLite Formulation)
-- Computes Pearson r across critical telemetry metrics:
-- Formula: r = (N*sum(xy) - sum(x)*sum(y)) / (sqrt(N*sum(x^2)-(sum(x))^2) * sqrt(N*sum(y^2)-(sum(y))^2))
-- --------------------------------------------------------------------
WITH CorrelationMath AS (
    SELECT 
        -- Pair 1: Cognitive Load vs Self-Reported Focus
        ROUND(
            (COUNT(*) * SUM(Cognitive_Load_Score * Self_Reported_Focus_Score) - SUM(Cognitive_Load_Score) * SUM(Self_Reported_Focus_Score)) /
            (SQRT(COUNT(*) * SUM(Cognitive_Load_Score * Cognitive_Load_Score) - SUM(Cognitive_Load_Score) * SUM(Cognitive_Load_Score)) *
             SQRT(COUNT(*) * SUM(Self_Reported_Focus_Score * Self_Reported_Focus_Score) - SUM(Self_Reported_Focus_Score) * SUM(Self_Reported_Focus_Score))), 
            4
        ) AS R_Load_vs_Focus,

        -- Pair 2: Keystrokes Per Minute vs Flow Efficiency
        ROUND(
            (COUNT(*) * SUM(Keystrokes_Per_Minute * Flow_Efficiency_Score) - SUM(Keystrokes_Per_Minute) * SUM(Flow_Efficiency_Score)) /
            (SQRT(COUNT(*) * SUM(Keystrokes_Per_Minute * Keystrokes_Per_Minute) - SUM(Keystrokes_Per_Minute) * SUM(Keystrokes_Per_Minute)) *
             SQRT(COUNT(*) * SUM(Flow_Efficiency_Score * Flow_Efficiency_Score) - SUM(Flow_Efficiency_Score) * SUM(Flow_Efficiency_Score))), 
            4
        ) AS R_KPM_vs_Flow,

        -- Pair 3: Interruptions Count vs Error Count
        ROUND(
            (COUNT(*) * SUM(Interruptions_Count * Error_Count) - SUM(Interruptions_Count) * SUM(Error_Count)) /
            (SQRT(COUNT(*) * SUM(Interruptions_Count * Interruptions_Count) - SUM(Interruptions_Count) * SUM(Interruptions_Count)) *
             SQRT(COUNT(*) * SUM(Error_Count * Error_Count) - SUM(Error_Count) * SUM(Error_Count))), 
            4
        ) AS R_Interruptions_vs_Errors,

        -- Pair 4: Active Window Switches vs Error Count
        ROUND(
            (COUNT(*) * SUM(Active_Window_Switches * Error_Count) - SUM(Active_Window_Switches) * SUM(Error_Count)) /
            (SQRT(COUNT(*) * SUM(Active_Window_Switches * Active_Window_Switches) - SUM(Active_Window_Switches) * SUM(Active_Window_Switches)) *
             SQRT(COUNT(*) * SUM(Error_Count * Error_Count) - SUM(Error_Count) * SUM(Error_Count))), 
            4
        ) AS R_Switches_vs_Errors,

        -- Pair 5: Idle Time vs Task Duration
        ROUND(
            (COUNT(*) * SUM(Idle_Time_Minutes * Task_Duration_Minutes) - SUM(Idle_Time_Minutes) * SUM(Task_Duration_Minutes)) /
            (SQRT(COUNT(*) * SUM(Idle_Time_Minutes * Idle_Time_Minutes) - SUM(Idle_Time_Minutes) * SUM(Idle_Time_Minutes)) *
             SQRT(COUNT(*) * SUM(Task_Duration_Minutes * Task_Duration_Minutes) - SUM(Task_Duration_Minutes) * SUM(Task_Duration_Minutes))), 
            4
        ) AS R_Idle_vs_Duration
    FROM cognistream_sessions
)
SELECT 
    'Cognitive Load vs Focus Score' AS Metric_Pair, R_Load_vs_Focus AS Pearson_Correlation_R, 'Near-zero linear correlation - non-linear burnout thresholds dominate' AS Interpretation FROM CorrelationMath
UNION ALL
SELECT 'Keystrokes/Min vs Flow Efficiency', R_KPM_vs_Flow, 'Weak negative - high typing throughput does not guarantee high cognitive flow' FROM CorrelationMath
UNION ALL
SELECT 'Interruptions vs Error Count', R_Interruptions_vs_Errors, 'Mild positive - external context breaks introduce bug propagation risks' FROM CorrelationMath
UNION ALL
SELECT 'Window Switches vs Error Count', R_Switches_vs_Errors, 'Mild positive - frequent screen thrashing correlates with elevated defects' FROM CorrelationMath
UNION ALL
SELECT 'Idle Time vs Task Duration', R_Idle_vs_Duration, 'Moderate positive (+0.29) - longer sessions incur escalating cognitive fatigue and idle drift' FROM CorrelationMath;

-- --------------------------------------------------------------------
-- 5. Composite Friction Score & Final Session Outcome Correlation
-- Creates a standardized composite friction index (idle ratio + switching rate)
-- and analyzes its distribution across final session completion outcomes.
-- --------------------------------------------------------------------
WITH SessionCompositeFriction AS (
    SELECT 
        Record_ID,
        Developer_ID,
        Session_Outcome,
        Task_Duration_Minutes,
        Idle_Time_Minutes,
        Active_Window_Switches,
        Interruptions_Count,
        Cognitive_Load_Score,
        Flow_Efficiency_Score,
        ROUND((Idle_Time_Minutes * 100.0 / Task_Duration_Minutes) + (Active_Window_Switches * 60.0 / Task_Duration_Minutes), 2) AS Composite_Friction_Index
    FROM cognistream_sessions
    WHERE Task_Duration_Minutes > 0
)
SELECT 
    Session_Outcome,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(COUNT(Record_ID) * 100.0 / (SELECT COUNT(*) FROM cognistream_sessions), 2) AS Outcome_Share_Pct,
    ROUND(AVG(Composite_Friction_Index), 2) AS Avg_Composite_Friction_Index,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
    ROUND(AVG(Idle_Time_Minutes), 1) AS Avg_Idle_Minutes,
    ROUND(AVG(Active_Window_Switches), 1) AS Avg_Active_Switches
FROM SessionCompositeFriction
GROUP BY Session_Outcome
ORDER BY Avg_Composite_Friction_Index DESC;
