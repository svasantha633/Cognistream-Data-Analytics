# CogniStream Raw Dataset: Initial Quality Audit Report

- **Source File**: `data/raw/CogniStream_Developer_Flow_State_Cognitive_Load_10000.xlsx`
- **Total Raw Observations**: 10,000
- **Total Telemetry Features**: 25

## 1. Duplicate Records Audit
- **Exact Duplicate Rows (across all 25 columns)**: 91
- **Duplicate Primary Keys (`Record_ID`)**: 154

## 2. Missing Values (Null) Breakdown
| Column Name | Missing Count | Missing Percentage |
| :--- | :--- | :--- |
| `Session_Date` | 41 | 0.41% |
| `Developer_ID` | 139 | 1.39% |
| `Role` | 104 | 1.04% |
| `Task_Type` | 102 | 1.02% |
| `Application_Used` | 145 | 1.45% |
| `Flow_State` | 100 | 1.00% |
| `Cognitive_Load_Score` | 252 | 2.52% |
| `Task_Duration_Minutes` | 80 | 0.80% |
| `Interruptions_Count` | 151 | 1.51% |
| `Interruption_Type` | 1,633 | 16.33% |
| `Keystrokes_Per_Minute` | 202 | 2.02% |
| `Idle_Time_Minutes` | 181 | 1.81% |
| `Task_Completion_Percent` | 118 | 1.18% |
| `Self_Reported_Focus_Score` | 199 | 1.99% |
| `Device_Type` | 81 | 0.81% |
| `Operating_System` | 102 | 1.02% |
| `Deadline_Urgency` | 81 | 0.81% |
| `Flow_Efficiency_Score` | 179 | 1.79% |

## 3. Categorical Formatting Defects
- **`Device_Type`**: 15 raw unique variants (Whitespace artifacts present: `True`)
- **`Operating_System`**: 25 raw unique variants (Whitespace artifacts present: `True`)
- **`Deadline_Urgency`**: 20 raw unique variants (Whitespace artifacts present: `True`)
- **`Session_Outcome`**: 20 raw unique variants (Whitespace artifacts present: `True`)
- **`Role`**: 40 raw unique variants (Whitespace artifacts present: `True`)
- **`Task_Type`**: 49 raw unique variants (Whitespace artifacts present: `True`)
- **`Flow_State`**: 30 raw unique variants (Whitespace artifacts present: `True`)

## 4. Range & Sentinel Outliers Audit
| Metric | Expected Range | Min Found | Max Found | Negative Count | Sentinel/Out-of-Range Count |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Cognitive_Load_Score` | 1.0 – 10.0 | -2.0 | 15.0 | 1 | 4 |
| `Self_Reported_Focus_Score` | 1.0 – 10.0 | 0.0 | 15.0 | 0 | 3 |
| `Task_Duration_Minutes` | 1.0 – 240.0 | -5.0 | 1200.0 | 1 | 4 |
| `Interruptions_Count` | 0.0 – 50.0 | -3.0 | 999.0 | 2 | 3 |
| `Keystrokes_Per_Minute` | 10.0 – 500.0 | -10.0 | 9999.0 | 1 | 3 |
| `Idle_Time_Minutes` | 0.0 – 240.0 | -10.0 | 500.0 | 2 | 3 |
| `Task_Completion_Percent` | 0.0 – 100.0 | -20.0 | 250.0 | 1 | 2 |
| `Error_Count` | 0.0 – 50.0 | -2 | 999 | 2 | 3 |
| `Meeting_Minutes` | 0.0 – 240.0 | -10 | 999 | 1 | 2 |
| `Flow_Efficiency_Score` | 0.0 – 100.0 | -25.0 | 999.0 | 1 | 3 |

## 5. Cross-Field Logical Discrepancies
- **Sessions where Idle Time > Task Duration**: 1785
- **Sessions where Meeting Minutes > Task Duration**: 1578
- **Zero Interruptions with categorized Interruption Type**: 931