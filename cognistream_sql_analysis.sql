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