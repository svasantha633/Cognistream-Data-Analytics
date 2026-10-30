# Contributing to CogniStream Developer Analytics

Thank you for your interest in this project. This guide explains how to reproduce the analysis, understand the pipeline structure, and contribute improvements.

---

## Project Context

This repository contains a complete data cleaning and SQL analytics pipeline for the **CogniStream Developer Flow State & Cognitive Load** dataset. The work was done as part of a collaborative data analytics project, with this branch (`Tahseen_Parvej`) focusing on:

- Python-based multi-stage data cleaning
- SQLite relational database design and ingestion
- Modular SQL analytical suites (13 files)
- Query performance benchmarking
- Business insights reporting

---

## Reproducing the Analysis

Follow these steps to run the full pipeline from scratch on your local machine.

### 1. Prerequisites

```bash
# Python 3.11 or later
python --version

# Install required packages
pip install pandas openpyxl
```

No other external libraries are required. SQLite 3 is bundled with Python.

### 2. Clone the Repository

```bash
git clone -b Tahseen_Parvej https://github.com/svasantha633/Cognistream-Data-Analytics.git
cd Cognistream-Data-Analytics
```

### 3. Run the Data Cleaning Pipeline

The pipeline runs in 5 sequential stages. Each stage reads from the previous stage's output CSV.

```bash
python data_cleaning/01_handle_missing_values.py
python data_cleaning/02_remove_duplicates.py
python data_cleaning/03_standardize_text.py
python data_cleaning/04_fix_rating_scales.py
python data_cleaning/05_filter_sentinels.py
```

Or run the consolidated orchestrator directly:

```bash
python data_cleaning/clean_data.py
```

Expected output: `data/cleaned/clean_data.csv` with exactly **9,892 rows**, 0 nulls, and 0 duplicate keys.

### 4. Inspect the Raw Dataset

```bash
python scripts/inspect_dataset.py
```

This generates a quality audit summary of the raw data including null counts, duplicate records, and out-of-range values.

### 5. Import into SQLite

```bash
python scripts/import_data.py
```

This creates `cognistream.db` and verifies the row count matches the clean CSV exactly.

### 6. Run SQL Analytical Suites

Open the database and run any of the 13 modular SQL suites:

```bash
sqlite3 cognistream.db < sql/01_schema.sql
sqlite3 cognistream.db < sql/04_executive_kpis.sql
sqlite3 cognistream.db < sql/10_flow_efficiency_ctes.sql
sqlite3 cognistream.db < sql/11_window_functions_ranking.sql
sqlite3 cognistream.db < sql/12_cross_metric_correlations.sql
sqlite3 cognistream.db < sql/13_query_optimization.sql
```

### 7. Run Query Benchmarks

```bash
python scripts/benchmark_queries.py
```

This runs 20 iterations of 6 representative queries in both unindexed and indexed states, printing a latency comparison table and saving results to `benchmarks/query_benchmark_results.md`.

---

## Dataset Details

| Field | Value |
| :--- | :--- |
| Source File | `CogniStream_Developer_Flow_State_Cognitive_Load_10000.xlsx` |
| Raw Records | 10,000 rows |
| Clean Records | **9,892 rows** (after removing 91 duplicates and 17 sentinel records) |
| Columns | 25 features per session |
| Primary Key | `Record_ID` — sequential from `REC-00001` to `REC-09892` |
| Date Range | Full calendar year 2025 (365 days) |
| Developers | 802 unique developer IDs |
| Projects | 30 unique project IDs |

---

## Data Cleaning Notes

- **Missing values**: Imputed using domain-aware strategies — `Interruption_Type` mapped to `'No Interruption'` when `Interruptions_Count = 0`; cognitive load and focus scores imputed with flow-state group medians.
- **Duplicates**: 91 exact duplicate rows removed; `Record_ID` re-indexed sequentially after deduplication.
- **Rating scales**: Cognitive Load Score clamped to `[1.0, 10.0]`; Task Completion clamped to `[0.0, 100.0]`.
- **Sentinel values**: 17 records with `999` or `9999` in numeric fields removed. Negative idle time values capped at 0.
- **Text normalization**: All categorical columns (Role, Task_Type, Application_Used, OS, Device_Type, Flow_State) stripped of whitespace and converted to title/standard case.
- **Date/time**: Malformed date strings handled with `pd.to_datetime(errors='coerce')` followed by forward-fill.

---

## SQL File Naming Convention

Files follow a numbered sequential naming scheme to reflect the natural analytical progression:

```
01_schema.sql                  → Table DDL, CHECK constraints, views
02_data_overview.sql           → Row counts, date range, unique keys
03_data_quality_audit.sql      → 0-null and 0-duplicate verification
04_executive_kpis.sql          → Core business KPIs
05_role_and_task_distribution.sql
06_application_productivity.sql
07_interruption_analysis.sql
08_urgency_and_outcomes.sql
09_temporal_trend_analysis.sql
10_flow_efficiency_ctes.sql    → CTEs, developer segmentation
11_window_functions_ranking.sql → DENSE_RANK, LAG, NTILE, PERCENT_RANK
12_cross_metric_correlations.sql → Pearson r correlation matrix
13_query_optimization.sql      → B-Tree indexes, EXPLAIN QUERY PLAN
```

---

## Verified Baseline Numbers

If you run the pipeline correctly, your results should match these numbers exactly:

| Verification Check | Expected Value |
| :--- | :---: |
| Total clean rows | **9,892** |
| Null values in any column | **0** |
| Duplicate Record_IDs | **0** |
| Avg Cognitive Load Score | **5.75** |
| Avg Flow Efficiency Score | **71.57%** |
| Total developer hours | **19,833.4 hrs** |
| Unique developers | **802** |
| Unique projects | **30** |

Any deviation from these numbers indicates a pipeline issue — check your Python version and pandas compatibility (`pandas >= 2.0` required).

---

## Reporting Issues

If you find a discrepancy in the data cleaning output or a query that fails against the schema, open a GitHub issue on the repository with:

1. The exact command you ran
2. The error message or unexpected output
3. Your Python and pandas version (`python --version` and `pip show pandas`)

---

*Branch: `Tahseen_Parvej` · Contributor: Tahseen Parvej (Data Analyst & SQL Database Engineer)*
