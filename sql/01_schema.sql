-- ====================================================================
-- CogniStream Developer Analytics: Database Schema Definition
-- Database Engine: SQLite 3
-- Author: Tahseen Parvej (Data Analyst & SQL Database Engineer)
-- File: sql/01_schema.sql
-- ====================================================================

DROP TABLE IF EXISTS cognistream_sessions;

CREATE TABLE cognistream_sessions (
    Record_ID                    TEXT PRIMARY KEY,
    Session_Date                 TEXT NOT NULL,
    Session_Start_Time           TEXT NOT NULL,
    Developer_ID                 TEXT NOT NULL,
    Role                         TEXT NOT NULL,
    Project_ID                   TEXT NOT NULL,
    Task_Type                    TEXT NOT NULL,
    Application_Used             TEXT NOT NULL,
    Flow_State                   TEXT NOT NULL,
    Cognitive_Load_Score         REAL NOT NULL CHECK(Cognitive_Load_Score BETWEEN 1.0 AND 10.0),
    Task_Duration_Minutes        REAL NOT NULL CHECK(Task_Duration_Minutes BETWEEN 1.0 AND 240.0),
    Interruptions_Count          INTEGER NOT NULL CHECK(Interruptions_Count >= 0),
    Interruption_Type            TEXT NOT NULL,
    Keystrokes_Per_Minute        REAL NOT NULL CHECK(Keystrokes_Per_Minute >= 0),
    Active_Window_Switches       INTEGER NOT NULL CHECK(Active_Window_Switches >= 0),
    Idle_Time_Minutes            REAL NOT NULL CHECK(Idle_Time_Minutes >= 0),
    Task_Completion_Percent      REAL NOT NULL CHECK(Task_Completion_Percent BETWEEN 0.0 AND 100.0),
    Error_Count                  INTEGER NOT NULL CHECK(Error_Count >= 0),
    Self_Reported_Focus_Score    REAL NOT NULL CHECK(Self_Reported_Focus_Score BETWEEN 1.0 AND 10.0),
    Meeting_Minutes              INTEGER NOT NULL CHECK(Meeting_Minutes >= 0),
    Device_Type                  TEXT NOT NULL,
    Operating_System             TEXT NOT NULL,
    Deadline_Urgency             TEXT NOT NULL,
    Session_Outcome              TEXT NOT NULL,
    Flow_Efficiency_Score        REAL NOT NULL CHECK(Flow_Efficiency_Score BETWEEN 0.0 AND 100.0)
);

-- Dimension Views for Modular Analysis
DROP VIEW IF EXISTS v_developer_summary;
CREATE VIEW v_developer_summary AS
SELECT 
    Developer_ID,
    Role,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(SUM(Task_Duration_Minutes) / 60.0, 2) AS Total_Hours_Logged,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Efficiency_Score,
    ROUND(AVG(Task_Completion_Percent), 2) AS Avg_Completion_Rate,
    SUM(Interruptions_Count) AS Total_Interruptions,
    SUM(Error_Count) AS Total_Errors
FROM cognistream_sessions
GROUP BY Developer_ID, Role;

DROP VIEW IF EXISTS v_flow_state_performance;
CREATE VIEW v_flow_state_performance AS
SELECT 
    Flow_State,
    COUNT(Record_ID) AS Session_Count,
    ROUND(COUNT(Record_ID) * 100.0 / (SELECT COUNT(*) FROM cognistream_sessions), 2) AS Percentage_Of_Total,
    ROUND(AVG(Cognitive_Load_Score), 2) AS Avg_Cognitive_Load,
    ROUND(AVG(Self_Reported_Focus_Score), 2) AS Avg_Focus_Score,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Flow_Efficiency,
    ROUND(AVG(Interruptions_Count), 2) AS Avg_Interruptions,
    ROUND(AVG(Error_Count), 2) AS Avg_Errors
FROM cognistream_sessions
GROUP BY Flow_State;
