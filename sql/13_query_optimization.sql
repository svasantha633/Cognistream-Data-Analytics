-- ====================================================================
-- CogniStream Developer Analytics: B-Tree Indexing & Query Optimization
-- Author: Tahseen Parvej (Data Analyst & SQL Database Engineer)
-- File: sql/13_query_optimization.sql
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. Index Audit: Inspect Pre-Existing Indexes on cognistream_sessions
-- --------------------------------------------------------------------
PRAGMA index_list(cognistream_sessions);

-- --------------------------------------------------------------------
-- 2. Performance Index Architecture (B-Tree Single & Composite Indexes)
-- Engineered to eliminate full-table scans on high-cardinality lookups,
-- temporal slicing, window partitioning, and multi-tier segmentations.
-- --------------------------------------------------------------------

-- Index 1: Developer ID lookup & window function partitioning
CREATE INDEX IF NOT EXISTS idx_sessions_developer_id 
ON cognistream_sessions (Developer_ID);

-- Index 2: Composite temporal & engineering role filtering
CREATE INDEX IF NOT EXISTS idx_sessions_date_role 
ON cognistream_sessions (Session_Date, Role);

-- Index 3: Task type aggregation & cognitive strain classification
CREATE INDEX IF NOT EXISTS idx_sessions_task_type 
ON cognistream_sessions (Task_Type);

-- Index 4: Project velocity tracking & milestone aggregations
CREATE INDEX IF NOT EXISTS idx_sessions_project_id 
ON cognistream_sessions (Project_ID);

-- Index 5: Flow state categorical filtering (Deep Work vs Distracted)
CREATE INDEX IF NOT EXISTS idx_sessions_flow_state 
ON cognistream_sessions (Flow_State);

-- Index 6: Composite covering index for acute burnout risk detection
CREATE INDEX IF NOT EXISTS idx_sessions_cognitive_flow 
ON cognistream_sessions (Cognitive_Load_Score, Flow_Efficiency_Score);

-- --------------------------------------------------------------------
-- 3. Query Plan Verification via EXPLAIN QUERY PLAN
-- Verifies that execution engine utilizes B-Tree indexes (SEARCH TABLE)
-- rather than linear exhaustive scans (SCAN TABLE).
-- --------------------------------------------------------------------

-- Test A: Individual developer history lookup (uses idx_sessions_developer_id)
EXPLAIN QUERY PLAN
SELECT 
    Record_ID,
    Developer_ID,
    Session_Date,
    Flow_Efficiency_Score,
    Cognitive_Load_Score
FROM cognistream_sessions
WHERE Developer_ID = 'DEV-0100';

-- Test B: Date range and role filtering (uses idx_sessions_date_role)
EXPLAIN QUERY PLAN
SELECT 
    Role,
    COUNT(Record_ID) AS Total_Sessions,
    ROUND(AVG(Flow_Efficiency_Score), 2) AS Avg_Efficiency
FROM cognistream_sessions
WHERE Session_Date >= '2025-06-01' AND Role = 'Developer'
GROUP BY Role;

-- Test C: High burnout anomaly threshold (uses idx_sessions_cognitive_flow)
EXPLAIN QUERY PLAN
SELECT 
    Record_ID,
    Developer_ID,
    Cognitive_Load_Score,
    Flow_Efficiency_Score
FROM cognistream_sessions
WHERE Cognitive_Load_Score >= 7.0 AND Flow_Efficiency_Score <= 60.0;

-- --------------------------------------------------------------------
-- 4. Database Statistics Generation & Query Optimizer Calibration
-- Analyzes table and index distribution to calibrate SQLite query planner.
-- --------------------------------------------------------------------
ANALYZE cognistream_sessions;

-- Verify updated index metadata
PRAGMA index_list(cognistream_sessions);
