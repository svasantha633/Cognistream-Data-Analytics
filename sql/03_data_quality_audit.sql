-- ====================================================================
-- CogniStream Developer Analytics: Data Quality & Integrity Audit
-- Author: Tahseen Parvej (Data Analyst & SQL Database Engineer)
-- File: sql/03_data_quality_audit.sql
-- ====================================================================

-- 1. Comprehensive Null Checks Across All Attributes
SELECT 
    SUM(CASE WHEN Record_ID IS NULL THEN 1 ELSE 0 END) AS Null_Record_IDs,
    SUM(CASE WHEN Session_Date IS NULL THEN 1 ELSE 0 END) AS Null_Session_Dates,
    SUM(CASE WHEN Developer_ID IS NULL THEN 1 ELSE 0 END) AS Null_Developer_IDs,
    SUM(CASE WHEN Role IS NULL THEN 1 ELSE 0 END) AS Null_Roles,
    SUM(CASE WHEN Task_Type IS NULL THEN 1 ELSE 0 END) AS Null_Task_Types,
    SUM(CASE WHEN Cognitive_Load_Score IS NULL THEN 1 ELSE 0 END) AS Null_Cognitive_Loads,
    SUM(CASE WHEN Flow_Efficiency_Score IS NULL THEN 1 ELSE 0 END) AS Null_Flow_Efficiencies,
    SUM(CASE WHEN Session_Outcome IS NULL THEN 1 ELSE 0 END) AS Null_Session_Outcomes
FROM cognistream_sessions;

-- 2. Primary Key Uniqueness & Collision Check
SELECT 
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Record_ID) AS Unique_Keys,
    COUNT(*) - COUNT(DISTINCT Record_ID) AS Duplicate_Key_Violations
FROM cognistream_sessions;

-- 3. Rating Scale Domain Boundary Audits (Scale: 1.0 - 10.0)
SELECT 
    'Cognitive_Load_Score' AS Metric_Name,
    MIN(Cognitive_Load_Score) AS Observed_Min,
    MAX(Cognitive_Load_Score) AS Observed_Max,
    SUM(CASE WHEN Cognitive_Load_Score < 1.0 OR Cognitive_Load_Score > 10.0 THEN 1 ELSE 0 END) AS Out_Of_Bounds_Count
FROM cognistream_sessions
UNION ALL
SELECT 
    'Self_Reported_Focus_Score' AS Metric_Name,
    MIN(Self_Reported_Focus_Score) AS Observed_Min,
    MAX(Self_Reported_Focus_Score) AS Observed_Max,
    SUM(CASE WHEN Self_Reported_Focus_Score < 1.0 OR Self_Reported_Focus_Score > 10.0 THEN 1 ELSE 0 END) AS Out_Of_Bounds_Count
FROM cognistream_sessions;

-- 4. Percentage Boundary Audits (Scale: 0.0% - 100.0%)
SELECT 
    'Task_Completion_Percent' AS Metric_Name,
    MIN(Task_Completion_Percent) AS Observed_Min,
    MAX(Task_Completion_Percent) AS Observed_Max,
    SUM(CASE WHEN Task_Completion_Percent < 0.0 OR Task_Completion_Percent > 100.0 THEN 1 ELSE 0 END) AS Out_Of_Bounds_Count
FROM cognistream_sessions
UNION ALL
SELECT 
    'Flow_Efficiency_Score' AS Metric_Name,
    MIN(Flow_Efficiency_Score) AS Observed_Min,
    MAX(Flow_Efficiency_Score) AS Observed_Max,
    SUM(CASE WHEN Flow_Efficiency_Score < 0.0 OR Flow_Efficiency_Score > 100.0 THEN 1 ELSE 0 END) AS Out_Of_Bounds_Count
FROM cognistream_sessions;

-- 5. Non-Negative Telemetry Values Audit
SELECT 
    SUM(CASE WHEN Task_Duration_Minutes < 1.0 THEN 1 ELSE 0 END) AS Invalid_Durations,
    SUM(CASE WHEN Interruptions_Count < 0 THEN 1 ELSE 0 END) AS Negative_Interruptions,
    SUM(CASE WHEN Keystrokes_Per_Minute < 0 THEN 1 ELSE 0 END) AS Negative_Keystrokes,
    SUM(CASE WHEN Active_Window_Switches < 0 THEN 1 ELSE 0 END) AS Negative_Window_Switches,
    SUM(CASE WHEN Idle_Time_Minutes < 0 THEN 1 ELSE 0 END) AS Negative_Idle_Time,
    SUM(CASE WHEN Error_Count < 0 THEN 1 ELSE 0 END) AS Negative_Errors,
    SUM(CASE WHEN Meeting_Minutes < 0 THEN 1 ELSE 0 END) AS Negative_Meetings
FROM cognistream_sessions;

-- 6. Logical Cross-Field Consistency Checks
SELECT 
    SUM(CASE WHEN Idle_Time_Minutes > Task_Duration_Minutes THEN 1 ELSE 0 END) AS Idle_Exceeding_Duration_Violations,
    SUM(CASE WHEN Task_Duration_Minutes <= 0 THEN 1 ELSE 0 END) AS Non_Positive_Duration_Violations,
    SUM(CASE WHEN Keystrokes_Per_Minute < 0 THEN 1 ELSE 0 END) AS Negative_Activity_Violations
FROM cognistream_sessions;

-- 7. Categorical Standardization Whitelist Verification
SELECT 
    'Device_Type' AS Attribute,
    Device_Type AS Distinct_Value,
    COUNT(*) AS Record_Count
FROM cognistream_sessions
GROUP BY Device_Type
UNION ALL
SELECT 
    'Deadline_Urgency' AS Attribute,
    Deadline_Urgency AS Distinct_Value,
    COUNT(*) AS Record_Count
FROM cognistream_sessions
GROUP BY Deadline_Urgency
ORDER BY Attribute, Record_Count DESC;
