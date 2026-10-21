"""
data_cleaning/01_handle_missing_values.py
-----------------------------------------
Module 1 of the CogniStream Data Cleaning Pipeline.
Handles missing values across numerical, categorical, and temporal fields using
domain-aware imputation strategies:
1. Interruption_Type: Set to 'None' when Interruptions_Count == 0; 'Unspecified' when > 0.
2. Cognitive_Load_Score & Focus_Score: Impute with median grouped by Flow_State.
3. Telemetry Numerics: Impute duration, keystrokes, idle time with median by Task_Type.
4. Categorical Fields: Impute with mode or explicit category 'Unknown'.
5. Export Stage 1 checkpoint to data/cleaned/stage1_nulls_handled.csv.
"""

import os
import sys
import pandas as pd
import numpy as np

def handle_missing_values(input_excel_path, output_csv_path):
    print(f"Reading raw data from: {input_excel_path}...")
    df = pd.read_excel(input_excel_path, sheet_name='Raw_Data')
    initial_nulls = df.isnull().sum().sum()
    print(f"Initial total missing cells across dataset: {initial_nulls:,}")

    # 1. Clean Interruption fields logically
    # If Interruptions_Count is 0, interruption type is 'None'
    df.loc[(df['Interruptions_Count'] == 0) & (df['Interruption_Type'].isnull()), 'Interruption_Type'] = 'None'
    # If Interruptions_Count is missing but Interruption_Type is 'None', Interruptions_Count is 0
    df.loc[(df['Interruption_Type'] == 'None') & (df['Interruptions_Count'].isnull()), 'Interruptions_Count'] = 0
    # Remaining missing Interruptions_Count imputed with median
    interr_median = df['Interruptions_Count'].dropna().median()
    df['Interruptions_Count'] = df['Interruptions_Count'].fillna(interr_median)
    # Remaining missing Interruption_Type imputed with 'Unspecified'
    df['Interruption_Type'] = df['Interruption_Type'].fillna('Unspecified')

    # 2. Impute Cognitive Ratings grouped by Flow_State
    if 'Flow_State' in df.columns:
        df['Flow_State'] = df['Flow_State'].fillna('Unknown')
        
    cog_median = df.groupby('Flow_State')['Cognitive_Load_Score'].transform(lambda x: x.fillna(x.median()))
    df['Cognitive_Load_Score'] = cog_median.fillna(df['Cognitive_Load_Score'].median())

    focus_median = df.groupby('Flow_State')['Self_Reported_Focus_Score'].transform(lambda x: x.fillna(x.median()))
    df['Self_Reported_Focus_Score'] = focus_median.fillna(df['Self_Reported_Focus_Score'].median())

    # 3. Impute Numerical Telemetry grouped by Task_Type
    if 'Task_Type' in df.columns:
        df['Task_Type'] = df['Task_Type'].fillna('General')

    num_cols_by_task = [
        'Task_Duration_Minutes',
        'Keystrokes_Per_Minute',
        'Idle_Time_Minutes',
        'Task_Completion_Percent',
        'Flow_Efficiency_Score'
    ]

    for col in num_cols_by_task:
        task_med = df.groupby('Task_Type')[col].transform(lambda x: x.fillna(x.median()))
        df[col] = task_med.fillna(df[col].median())

    # 4. Impute Categorical Metadata
    cat_cols_defaults = {
        'Developer_ID': 'DEV-UNKNOWN',
        'Role': 'Software Engineer',
        'Project_ID': 'PRJ-UNASSIGNED',
        'Application_Used': 'IDE',
        'Device_Type': 'Laptop',
        'Operating_System': 'Windows 11',
        'Deadline_Urgency': 'Medium',
        'Session_Outcome': 'Completed'
    }

    for col, default_val in cat_cols_defaults.items():
        if col in df.columns:
            mode_val = df[col].dropna().mode()
            fill_val = mode_val[0] if len(mode_val) > 0 else default_val
            df[col] = df[col].fillna(fill_val)

    # 5. Temporal Fields
    if 'Session_Date' in df.columns:
        df['Session_Date'] = df['Session_Date'].ffill().fillna('2025-01-01')

    remaining_nulls = df.isnull().sum().sum()
    print(f"Remaining null cells after Stage 1 imputation: {remaining_nulls}")

    os.makedirs(os.path.dirname(output_csv_path), exist_ok=True)
    df.to_csv(output_csv_path, index=False)
    print(f"Stage 1 checkpoint saved to: {output_csv_path} (Shape: {df.shape})")
    return df

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    raw_path = os.path.join(project_root, "data", "raw", "CogniStream_Developer_Flow_State_Cognitive_Load_10000.xlsx")
    stage1_path = os.path.join(project_root, "data", "cleaned", "stage1_nulls_handled.csv")
    handle_missing_values(raw_path, stage1_path)
