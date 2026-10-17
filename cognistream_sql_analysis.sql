-- CogniStream: Create developer sessions table

CREATE TABLE developer_sessions (
    record_id VARCHAR(50),
    developer_id VARCHAR(50),
    session_date DATE,
    device_type VARCHAR(50),
    operating_system VARCHAR(50),
    deadline_urgency VARCHAR(50),
    session_outcome VARCHAR(50),
    flow_efficiency_score NUMERIC(5,2)
);

-- CogniStream: Data Overview

-- Total number of records
SELECT COUNT(*) AS total_records
FROM cognistream_data;

-- Check the dataset structure
SELECT *
FROM cognistream_data
LIMIT 10;

-- Check duplicate Record IDs
SELECT record_id, COUNT(*) AS id_count
FROM cognistream_data
GROUP BY record_id
HAVING COUNT(*) > 1
ORDER BY id_count DESC;

-- Check missing values in important columns
SELECT
    COUNT(*) FILTER (WHERE record_id IS NULL) AS missing_record_ids,
    COUNT(*) FILTER (WHERE developer_id IS NULL) AS missing_developer_ids,
    COUNT(*) FILTER (WHERE cognitive_load_score IS NULL) AS missing_cognitive_scores
FROM cognistream_data;

-- CogniStream: Data Overview

SELECT COUNT(*) AS total_sessions
FROM cognistream_data;

SELECT *
FROM cognistream_data
LIMIT 10;

SELECT record_id, COUNT(*) AS occurrences
FROM cognistream_data
GROUP BY record_id
HAVING COUNT(*) > 1;