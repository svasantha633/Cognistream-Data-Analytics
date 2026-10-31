"""
data_cleaning/02_remove_duplicates.py
-------------------------------------
Module 2 of the CogniStream Data Cleaning Pipeline.
Handles duplicate records and standardizes primary keys:
1. Detects and removes exact duplicate rows across all telemetry attributes (91 duplicates).
2. Resolves primary key collisions on Record_ID.
3. Standardizes Record_ID to a clean, sequential, zero-padded identifier (REC-00001 to REC-09909).
4. Exports checkpoint to data/cleaned/stage2_deduplicated.csv.
"""

import os
import sys
import pandas as pd

def remove_duplicates(input_csv_path, output_csv_path):
    print(f"Loading Stage 1 dataset: {input_csv_path}...")
    df = pd.read_csv(input_csv_path)
    initial_count = len(df)
    print(f"Total rows before deduplication: {initial_count:,}")

    # 1. Exact duplicates across all columns
    exact_dups_count = df.duplicated().sum()
    print(f"Exact duplicate rows detected: {exact_dups_count:,}")
    df_dedup = df.drop_duplicates().copy()
    print(f"Rows remaining after dropping exact duplicates: {len(df_dedup):,}")

    # 2. Check collisions on Record_ID
    id_dups_count = df_dedup['Record_ID'].duplicated().sum()
    print(f"Colliding Record_IDs across distinct sessions: {id_dups_count:,}")

    # 3. Standardize Record_ID sequentially to ensure primary key integrity
    df_dedup.reset_index(drop=True, inplace=True)
    df_dedup['Record_ID'] = [f"REC-{i:05d}" for i in range(1, len(df_dedup) + 1)]

    # Final integrity verification
    final_count = len(df_dedup)
    unique_ids = df_dedup['Record_ID'].nunique()
    print(f"Final rows: {final_count:,} | Unique Record_IDs: {unique_ids:,}")
    assert final_count == unique_ids, "Error: Record_ID is not strictly unique!"

    os.makedirs(os.path.dirname(output_csv_path), exist_ok=True)
    df_dedup.to_csv(output_csv_path, index=False)
    print(f"Stage 2 checkpoint saved to: {output_csv_path}")
    return df_dedup

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    stage1_path = os.path.join(project_root, "data", "cleaned", "stage1_nulls_handled.csv")
    stage2_path = os.path.join(project_root, "data", "cleaned", "stage2_deduplicated.csv")
    remove_duplicates(stage1_path, stage2_path)
