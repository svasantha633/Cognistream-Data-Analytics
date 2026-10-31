-- ====================================================================
-- CogniStream Developer Analytics: Flow Efficiency & Developer Segmentation CTEs
-- Author: Tahseen Parvej (Data Analyst & SQL Database Engineer)
-- File: sql/10_flow_efficiency_ctes.sql
-- ====================================================================

-- 1. Multi-Tier Developer Productivity & Burnout Risk Segmentation (CTE)
WITH DeveloperAggregates AS (
    SELECT 
        Developer_ID,
        Role,
        COUNT(Record_ID) AS Total_Sessions,
        ROUND(SUM(Task_Duration_Minutes) / 60.0, 1) AS Total_Hours,
        ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
        ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
        ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
        ROUND(AVG(Task_Completion_Percent), 2) AS Avg_Completion_Rate,
        SUM(Interruptions_Count) AS Total_Interruptions,
        SUM(Error_Count) AS Total_Errors
    FROM cognistream_sessions
    GROUP BY Developer_ID, Role
),
DeveloperSegmented AS (
    SELECT 
        *,
        CASE 
            WHEN Avg_Flow_Efficiency >= 75.0 AND Avg_Cognitive_Load <= 5.5 THEN 'Tier 1: High Flow & Low Strain'
            WHEN Avg_Flow_Efficiency >= 70.0 AND Avg_Cognitive_Load <= 6.5 THEN 'Tier 2: Steady Sustainable'
            WHEN Avg_Cognitive_Load >= 6.5 AND Avg_Flow_Efficiency < 70.0 THEN 'Tier 3: High Cognitive Burnout Risk'
            ELSE 'Tier 4: Fragmented / Low Efficiency'
        END AS Performance_Segment
    FROM DeveloperAggregates
)
SELECT 
    Performance_Segment,
    COUNT(Developer_ID) AS Developer_Count,
    ROUND(COUNT(Developer_ID) * 100.0 / (SELECT COUNT(*) FROM DeveloperSegmented), 2) AS Share_Percent,
    ROUND(AVG(Total_Hours), 1) AS Avg_Hours_Per_Dev,
    ROUND(AVG(Avg_Flow_Efficiency), 2) AS Segment_Avg_Efficiency,
    ROUND(AVG(Avg_Cognitive_Load), 2) AS Segment_Avg_Cognitive_Load,
    ROUND(AVG(Avg_Completion_Rate), 2) AS Segment_Avg_Completion_Rate
FROM DeveloperSegmented
GROUP BY Performance_Segment
ORDER BY Segment_Avg_Efficiency DESC;

-- 2. Context-Switching Cognitive Penalty Model (CTE)
WITH BaselineTaskMetrics AS (
    SELECT 
        Task_Type,
        ROUND(AVG(Keystrokes_Per_Minute), 1) AS Baseline_Keystrokes,
        ROUND(AVG(Cognitive_Load_Score), 2) AS Baseline_Cognitive_Load,
        ROUND(AVG(Flow_Efficiency_Score), 2) AS Baseline_Flow_Efficiency
    FROM cognistream_sessions
    GROUP BY Task_Type
),
SessionContextSwitches AS (
    SELECT 
        s.Record_ID,
        s.Task_Type,
        s.Active_Window_Switches,
        s.Keystrokes_Per_Minute,
        s.Cognitive_Load_Score,
        s.Flow_Efficiency_Score,
        CASE 
            WHEN s.Active_Window_Switches <= 3 THEN 'Low Switching (<= 3)'
            WHEN s.Active_Window_Switches BETWEEN 4 AND 7 THEN 'Moderate Switching (4-7)'
            ELSE 'Severe Multitasking (8+)'
        END AS Switching_Category,
        b.Baseline_Cognitive_Load,
        ROUND(s.Cognitive_Load_Score - b.Baseline_Cognitive_Load, 2) AS Cognitive_Load_Delta
    FROM cognistream_sessions s
    JOIN BaselineTaskMetrics b ON s.Task_Type = b.Task_Type
)
SELECT 
    Switching_Category,
    COUNT(*) AS Session_Count,
    ROUND(AVG(Keystrokes_Per_Minute), 1) AS Avg_Keystrokes,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Cognitive_Load_Delta), 2) AS Avg_Cognitive_Penalty,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency
FROM SessionContextSwitches
GROUP BY Switching_Category
ORDER BY Avg_Cognitive_Load DESC;

-- 3. Interruption Time Leakage & Friction Hours Quantification (CTE)
WITH InterruptionFriction AS (
    SELECT 
        Record_ID,
        Task_Type,
        Interruptions_Count,
        Task_Duration_Minutes,
        Idle_Time_Minutes,
        -- Estimated re-focus penalty: 5 minutes per interruption event
        ROUND(Interruptions_Count * 5.0, 1) AS Estimated_Refocus_Minutes,
        ROUND(Idle_Time_Minutes + (Interruptions_Count * 5.0), 1) AS Total_Friction_Minutes
    FROM cognistream_sessions
)
SELECT 
    Task_Type,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(SUM(Task_Duration_Minutes) / 60.0, 1) AS Total_Task_Hours,
    ROUND(SUM(Estimated_Refocus_Minutes) / 60.0, 1) AS Total_Refocus_Hours_Lost,
    ROUND(SUM(Total_Friction_Minutes) / 60.0, 1) AS Total_Friction_Hours_Lost,
    ROUND(SUM(Total_Friction_Minutes) * 100.0 / SUM(Task_Duration_Minutes), 2) AS Friction_Percentage_Of_Workload
FROM InterruptionFriction
GROUP BY Task_Type
ORDER BY Total_Friction_Hours_Lost DESC;

-- 4. Multi-Stage Project Friction & Health Index (CTE)
WITH ProjectMetrics AS (
    SELECT 
        Project_ID,
        COUNT(Record_ID) AS Total_Sessions,
        COUNT(DISTINCT Developer_ID) AS Developers_Assigned,
        ROUND(SUM(Task_Duration_Minutes) / 60.0, 1) AS Total_Hours,
        ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
        ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
        SUM(Error_Count) AS Total_Errors,
        SUM(Interruptions_Count) AS Total_Interruptions,
        ROUND(SUM(CASE WHEN Session_Outcome = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Completion_Rate
    FROM cognistream_sessions
    GROUP BY Project_ID
),
ProjectScoring AS (
    SELECT 
        *,
        -- Friction Score: (Errors + Interruptions) per developer hour
        ROUND((Total_Errors + Total_Interruptions) * 1.0 / Total_Hours, 2) AS Friction_Per_Hour,
        CASE 
            WHEN Completion_Rate >= 28.0 AND Avg_Cognitive_Load <= 5.6 THEN 'Healthy / High Velocity'
            WHEN Avg_Cognitive_Load >= 5.85 OR Completion_Rate < 23.0 THEN 'High Friction / Attrition Alert'
            ELSE 'Moderate / Normal'
        END AS Project_Health_Status
    FROM ProjectMetrics
)
SELECT 
    Project_ID,
    Developers_Assigned,
    Total_Hours,
    Avg_Cognitive_Load,
    Avg_Flow_Efficiency,
    Completion_Rate,
    Friction_Per_Hour,
    Project_Health_Status
FROM ProjectScoring
ORDER BY Friction_Per_Hour DESC
LIMIT 10;
