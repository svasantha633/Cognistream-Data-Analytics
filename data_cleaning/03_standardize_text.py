"""
data_cleaning/03_standardize_text.py
-----------------------------------
Module 3 of the CogniStream Data Cleaning Pipeline.
Standardizes string and categorical attributes:
1. Strips leading and trailing whitespaces across all text columns.
2. Canonicalizes casing variations for:
   - Device_Type: Desktop, Laptop, Tablet
   - Operating_System: Windows 11, Windows 10, macOS, Ubuntu, Linux Mint
   - Deadline_Urgency: Low, Medium, High, Critical
   - Session_Outcome: Completed, Partially Completed, Blocked, Abandoned
   - Flow_State: Flow, Focused, Interrupted, Blocked, Multitasking, Idle
   - Role, Task_Type, Application_Used, Interruption_Type
3. Exports checkpoint to data/cleaned/stage3_text_standardized.csv.
"""

import os
import sys
import pandas as pd

def standardize_text(input_csv_path, output_csv_path):
    print(f"Loading Stage 2 dataset: {input_csv_path}...")
    df = pd.read_csv(input_csv_path)

    # 1. Strip whitespace on all string/object columns
    text_cols = df.select_dtypes(include=['object', 'string']).columns
    for col in text_cols:
        df[col] = df[col].astype(str).str.strip()

    # 2. Canonical mapping dictionaries
    device_map = {
        'desktop': 'Desktop', 'laptop': 'Laptop', 'tablet': 'Tablet'
    }
    df['Device_Type'] = df['Device_Type'].str.lower().map(device_map).fillna(df['Device_Type'].str.title())

    os_map = {
        'windows 11': 'Windows 11', 'windows 10': 'Windows 10',
        'macos': 'macOS', 'ubuntu': 'Ubuntu', 'linux mint': 'Linux Mint'
    }
    df['Operating_System'] = df['Operating_System'].str.lower().map(os_map).fillna(df['Operating_System'].str.title())

    urgency_map = {
        'low': 'Low', 'medium': 'Medium', 'high': 'High', 'critical': 'Critical'
    }
    df['Deadline_Urgency'] = df['Deadline_Urgency'].str.lower().map(urgency_map).fillna(df['Deadline_Urgency'].str.title())

    outcome_map = {
        'completed': 'Completed',
        'partially completed': 'Partially Completed',
        'blocked': 'Blocked',
        'abandoned': 'Abandoned'
    }
    df['Session_Outcome'] = df['Session_Outcome'].str.lower().map(outcome_map).fillna(df['Session_Outcome'].str.title())

    flow_map = {
        'flow': 'Flow',
        'focused': 'Focused',
        'interrupted': 'Interrupted',
        'blocked': 'Blocked',
        'multitasking': 'Multitasking',
        'idle': 'Idle'
    }
    df['Flow_State'] = df['Flow_State'].str.lower().map(flow_map).fillna(df['Flow_State'].str.title())

    # Standardize roles and task types with clean Title Case
    for col in ['Role', 'Task_Type', 'Application_Used', 'Interruption_Type']:
        df[col] = df[col].apply(lambda x: ' '.join(w.capitalize() if w.lower() not in ['ide', 'ai', 'bi', 'ui', 'ux'] else w.upper() for w in str(x).split()))

    # Log clean category counts
    print("\nCleaned Categorical Values:")
    print("Device_Type:", sorted(df['Device_Type'].unique()))
    print("Operating_System:", sorted(df['Operating_System'].unique()))
    print("Deadline_Urgency:", sorted(df['Deadline_Urgency'].unique()))
    print("Session_Outcome:", sorted(df['Session_Outcome'].unique()))
    print("Flow_State:", sorted(df['Flow_State'].unique()))

    os.makedirs(os.path.dirname(output_csv_path), exist_ok=True)
    df.to_csv(output_csv_path, index=False)
    print(f"\nStage 3 checkpoint saved to: {output_csv_path} (Shape: {df.shape})")
    return df

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    stage2_path = os.path.join(project_root, "data", "cleaned", "stage2_deduplicated.csv")
    stage3_path = os.path.join(project_root, "data", "cleaned", "stage3_text_standardized.csv")
    standardize_text(stage2_path, stage3_path)
