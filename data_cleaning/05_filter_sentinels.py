"""
data_cleaning/05_filter_sentinels.py
------------------------------------
Module 5 of the CogniStream Data Cleaning Pipeline.
Filters sentinel placeholder values and impossible telemetry records:
1. Filters out records with sentinel values (999, 9999) and out-of-bounds durations:
   - Task_Duration_Minutes < 1 or > 240 minutes (Data Dictionary: intended range 1-240)
   - Interruptions_Count < 0 or >= 100 (sentinel 999)
   - Keystrokes_Per_Minute < 10 or >= 1000 (sentinel 9999)
   - Error_Count < 0 or >= 100 (sentinel 999)
   - Meeting_Minutes < 0 or >= 500 (sentinel 999)
   - Idle_Time_Minutes < 0
2. Ensures task-level Idle_Time_Minutes does not exceed Task_Duration_Minutes.
3. Re-indexes primary key Record_ID sequentially (REC-00001 to REC-09892).
4. Exports checkpoint to data/cleaned/stage5_sentinels_filtered.csv.
"""

import os
import sys
import pandas as pd

def filter_sentinels(input_csv_path, output_csv_path):
    print(f"Loading Stage 4 dataset: {input_csv_path}...")
    df = pd.read_csv(input_csv_path)
    initial_rows = len(df)
    print(f"Initial rows before sentinel filtering: {initial_rows:,}")

    # Define sentinel / impossible condition mask
    sentinel_mask = (
        (df['Task_Duration_Minutes'] < 1.0) | (df['Task_Duration_Minutes'] > 240.0) |
        (df['Interruptions_Count'] < 0) | (df['Interruptions_Count'] >= 100) |
        (df['Keystrokes_Per_Minute'] < 10) | (df['Keystrokes_Per_Minute'] >= 1000) |
        (df['Error_Count'] < 0) | (df['Error_Count'] >= 100) |
        (df['Meeting_Minutes'] < 0) | (df['Meeting_Minutes'] >= 500) |
        (df['Idle_Time_Minutes'] < 0)
    )

    sentinel_count = sentinel_mask.sum()
    print(f"Corrupted sentinel records detected & pruned: {sentinel_count:,}")
    df_clean = df[~sentinel_mask].copy()

    # Cap Idle_Time_Minutes at Task_Duration_Minutes
    capped_idle = (df_clean['Idle_Time_Minutes'] > df_clean['Task_Duration_Minutes']).sum()
    df_clean['Idle_Time_Minutes'] = df_clean[['Idle_Time_Minutes', 'Task_Duration_Minutes']].min(axis=1).round(1)
    print(f"Bounded {capped_idle:,} rows where Idle Time exceeded Session Duration.")

    # Re-index Record_ID sequentially for clean database primary keying
    df_clean.reset_index(drop=True, inplace=True)
    df_clean['Record_ID'] = [f"REC-{i:05d}" for i in range(1, len(df_clean) + 1)]

    final_rows = len(df_clean)
    print(f"Final certified rows: {final_rows:,} | Unique Record_IDs: {df_clean['Record_ID'].nunique():,}")

    os.makedirs(os.path.dirname(output_csv_path), exist_ok=True)
    df_clean.to_csv(output_csv_path, index=False)
    print(f"Stage 5 checkpoint saved to: {output_csv_path}")
    return df_clean

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    stage4_path = os.path.join(project_root, "data", "cleaned", "stage4_ratings_fixed.csv")
    stage5_path = os.path.join(project_root, "data", "cleaned", "stage5_sentinels_filtered.csv")
    filter_sentinels(stage4_path, stage5_path)
