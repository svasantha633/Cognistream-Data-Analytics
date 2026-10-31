# Raw Data Documentation: CogniStream Developer Analytics

## Dataset Overview
- **File Name**: `CogniStream_Developer_Flow_State_Cognitive_Load_10000.xlsx`
- **Total Rows**: 10,000 observations
- **Total Columns**: 25 attributes
- **Source**: Enterprise Developer Productivity Tracking & Cognitive Load Study

## Included Worksheets
1. **`Raw_Data`**:
   - Contains 10,000 developer session records recording telemetry data such as session duration, flow state, interruptions, active window switches, keystroke frequency, cognitive load score, focus rating, and session outcomes.
2. **`Data_Dictionary`**:
   - Defines column names, intended measurement scales, expected ranges (e.g., Cognitive Load: 1–10, Task Duration: 1–240 minutes), and known data collection caveats.

## Current State & Known Anomalies (Pre-Cleaning)
- **Missing Values**: Nulls present across session dates, developer identifiers, tool types, and interruption categories.
- **Duplicates**: Duplicate records and repeated composite primary keys.
- **Inconsistent Formats**: Trailing whitespaces and mixed casing in operating systems, devices, and session outcomes.
- **Outliers / Sentinels**: Out-of-bound ratings (>10), negative durations/counts, and sentinel values (`999`, `9999`).
