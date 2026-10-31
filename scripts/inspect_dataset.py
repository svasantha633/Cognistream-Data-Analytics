"""
inspect_dataset.py
------------------
Audits raw CogniStream telemetry dataset for quality defects:
- Missing values (Nulls / NaNs)
- Exact duplicates and composite key duplicates
- Inconsistent categorical casing & whitespace
- Out-of-bounds ratings & negative numbers
- Sentinel placeholder values (e.g., 999, 9999)
- Cross-field logical discrepancies
"""

import os
import sys
import pandas as pd
import numpy as np

def run_inspection(raw_file_path, output_report_path=None):
    if not os.path.exists(raw_file_path):
        print(f"Error: Raw file not found at {raw_file_path}")
        sys.exit(1)

    print(f"Loading raw dataset from: {raw_file_path}...")
    xl = pd.ExcelFile(raw_file_path)
    df_raw = pd.read_excel(raw_file_path, sheet_name='Raw_Data')
    df_dict = pd.read_excel(raw_file_path, sheet_name='Data_Dictionary')

    total_rows, total_cols = df_raw.shape
    print(f"Loaded Raw_Data: {total_rows:,} rows x {total_cols} columns")

    report_lines = []
    report_lines.append("# CogniStream Raw Dataset: Initial Quality Audit Report\n")
    report_lines.append(f"- **Source File**: `data/raw/CogniStream_Developer_Flow_State_Cognitive_Load_10000.xlsx`")
    report_lines.append(f"- **Total Raw Observations**: {total_rows:,}")
    report_lines.append(f"- **Total Telemetry Features**: {total_cols}\n")

    # 1. Duplicate Rows
    exact_dups = int(df_raw.duplicated().sum())
    key_dups = int(df_raw.duplicated(subset=['Record_ID']).sum())
    report_lines.append("## 1. Duplicate Records Audit")
    report_lines.append(f"- **Exact Duplicate Rows (across all 25 columns)**: {exact_dups}")
    report_lines.append(f"- **Duplicate Primary Keys (`Record_ID`)**: {key_dups}\n")

    # 2. Missing Values Analysis
    report_lines.append("## 2. Missing Values (Null) Breakdown")
    report_lines.append("| Column Name | Missing Count | Missing Percentage |")
    report_lines.append("| :--- | :--- | :--- |")
    null_counts = df_raw.isnull().sum()
    for col, count in null_counts[null_counts > 0].items():
        pct = (count / total_rows) * 100
        report_lines.append(f"| `{col}` | {count:,} | {pct:.2f}% |")
    report_lines.append("")

    # 3. Categorical Formatting & Inconsistency
    report_lines.append("## 3. Categorical Formatting Defects")
    cat_cols = ['Device_Type', 'Operating_System', 'Deadline_Urgency', 'Session_Outcome', 'Role', 'Task_Type', 'Flow_State']
    for col in cat_cols:
        vals = df_raw[col].dropna().astype(str).tolist()
        has_trailing = any(v != v.strip() for v in vals)
        unique_cnt = len(set(vals))
        report_lines.append(f"- **`{col}`**: {unique_cnt} raw unique variants (Whitespace artifacts present: `{has_trailing}`)")
    report_lines.append("")

    # 4. Out-of-Bounds & Sentinel Outliers
    report_lines.append("## 4. Range & Sentinel Outliers Audit")
    numeric_checks = [
        ('Cognitive_Load_Score', 1.0, 10.0),
        ('Self_Reported_Focus_Score', 1.0, 10.0),
        ('Task_Duration_Minutes', 1.0, 240.0),
        ('Interruptions_Count', 0.0, 50.0),
        ('Keystrokes_Per_Minute', 10.0, 500.0),
        ('Idle_Time_Minutes', 0.0, 240.0),
        ('Task_Completion_Percent', 0.0, 100.0),
        ('Error_Count', 0.0, 50.0),
        ('Meeting_Minutes', 0.0, 240.0),
        ('Flow_Efficiency_Score', 0.0, 100.0)
    ]

    report_lines.append("| Metric | Expected Range | Min Found | Max Found | Negative Count | Sentinel/Out-of-Range Count |")
    report_lines.append("| :--- | :--- | :--- | :--- | :--- | :--- |")
    for col, exp_min, exp_max in numeric_checks:
        s = df_raw[col].dropna()
        min_f = s.min()
        max_f = s.max()
        neg_cnt = (s < 0).sum()
        out_cnt = ((s < exp_min) | (s > exp_max)).sum()
        report_lines.append(f"| `{col}` | {exp_min} – {exp_max} | {min_f} | {max_f} | {neg_cnt} | {out_cnt} |")
    report_lines.append("")

    # 5. Logic Discrepancies
    report_lines.append("## 5. Cross-Field Logical Discrepancies")
    idle_exceeds = (df_raw['Idle_Time_Minutes'] > df_raw['Task_Duration_Minutes']).sum()
    meet_exceeds = (df_raw['Meeting_Minutes'] > df_raw['Task_Duration_Minutes']).sum()
    zero_interr_with_type = ((df_raw['Interruptions_Count'] == 0) & (df_raw['Interruption_Type'].notnull()) & (df_raw['Interruption_Type'] != 'None')).sum()

    report_lines.append(f"- **Sessions where Idle Time > Task Duration**: {idle_exceeds}")
    report_lines.append(f"- **Sessions where Meeting Minutes > Task Duration**: {meet_exceeds}")
    report_lines.append(f"- **Zero Interruptions with categorized Interruption Type**: {zero_interr_with_type}")

    report_content = "\n".join(report_lines)
    print("\n--- AUDIT SUMMARY PREVIEW ---")
    print(report_content[:1200])

    if output_report_path:
        os.makedirs(os.path.dirname(output_report_path), exist_ok=True)
        with open(output_report_path, "w", encoding="utf-8") as f:
            f.write(report_content)
        print(f"\nAudit report exported to: {output_report_path}")

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    raw_path = os.path.join(project_root, "data", "raw", "CogniStream_Developer_Flow_State_Cognitive_Load_10000.xlsx")
    report_path = os.path.join(project_root, "data", "raw", "raw_data_quality_report.md")
    run_inspection(raw_path, report_path)
