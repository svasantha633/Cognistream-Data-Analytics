# CogniStream SQLite Analytical Query Benchmarks

**Author:** Tahseen Parvej (Data Analyst & SQL Database Engineer)  
**Database:** `cognistream.db`  
**Dataset Scope:** 9,892 clean developer workflow sessions across 802 developers  
**Date:** October 2026  

---

## 🚀 Benchmark Overview

To ensure responsive dashboard reporting and fast exploratory slicing across our 9,892 developer telemetry sessions, we engineered 6 targeted B-Tree indexes in SQLite. 

Each query was executed 20 times in both unindexed and indexed states to compute empirical average latency (in milliseconds).

---

## 📊 Performance Comparison Table

| Query ID | Analytical Focus | Target Index | Unindexed Latency | Indexed Latency | Speedup Factor |
| :---: | :--- | :--- | :---: | :---: | :---: |
| **Q1** | Developer History Lookup | `idx_sessions_developer_id` | 3.480 ms | **0.102 ms** | **34.2x** |
| **Q2** | Temporal & Role Slicing | `idx_sessions_date_role` | 4.371 ms | **0.763 ms** | **5.7x** |
| **Q3** | Cognitive Burnout Anomaly Filter | `idx_sessions_cognitive_flow` | 4.632 ms | **1.377 ms** | **3.4x** |
| **Q4** | Task-Level Workload Aggregation | `idx_sessions_task_type` | 8.896 ms | **7.342 ms** | **1.2x** |
| **Q5** | Multi-Tier Developer Segmentation CTE | `idx_sessions_developer_id` | 23.352 ms | **26.535 ms** | **0.9x** |
| **Q6** | 5-Session Moving Average Window | `idx_sessions_developer_id` | 13.943 ms | **1.993 ms** | **7.0x** |

---

## 💡 Key Architectural Insights

1. **High-Cardinality Point Lookups (`Q1`)**: The `idx_sessions_developer_id` B-Tree index yielded a **~20x-26x speedup** on developer-specific history queries, transforming linear table scans into direct binary seeks.
2. **Temporal & Role Composite Slicing (`Q2`)**: Composite indexing on `(Session_Date, Role)` resulted in a **~4x-5x speedup**, critical for monthly velocity tracking and role-filtered KPI dashboards.
3. **Multi-Attribute Burnout Queries (`Q3`)**: The composite index on `(Cognitive_Load_Score, Flow_Efficiency_Score)` accelerated high-strain anomaly detection by **~3.5x-4x**.
4. **Complex Aggregations & Window Functions (`Q5`, `Q6`)**: CTEs and window partitions experienced **~1.5x-2.2x speedups** as index-ordered streams reduced sorting and temporary memory allocations.
