"""
data_cleaning/04_fix_rating_scales.py
-------------------------------------
Module 4 of the CogniStream Data Cleaning Pipeline.
Validates and corrects numerical rating scales and percentage bounds:
1. Cognitive_Load_Score: Clamps values to the intended 1.0 - 10.0 range.
2. Self_Reported_Focus_Score: Clamps values to the intended 1.0 - 10.0 range.
3. Task_Completion_Percent: Constrains percentages to the valid 0.0 - 100.0% range.
4. Flow_Efficiency_Score: Clamps efficiency indices to the valid 0.0 - 100.0% range.
5. Exports checkpoint to data/cleaned/stage4_ratings_fixed.csv.
"""

import os
import sys
import pandas as pd
import numpy as np

def fix_rating_scales(input_csv_path, output_csv_path):
    print(f"Loading Stage 3 dataset: {input_csv_path}...")
    df = pd.read_csv(input_csv_path)

    # 1. Cognitive Load Score (Scale: 1.0 to 10.0)
    cog_outliers = ((df['Cognitive_Load_Score'] < 1.0) | (df['Cognitive_Load_Score'] > 10.0)).sum()
    df['Cognitive_Load_Score'] = df['Cognitive_Load_Score'].clip(lower=1.0, upper=10.0).round(1)
    print(f"Cognitive_Load_Score: {cog_outliers} out-of-range records bounded to [1.0, 10.0]")

    # 2. Self Reported Focus Score (Scale: 1.0 to 10.0)
    focus_outliers = ((df['Self_Reported_Focus_Score'] < 1.0) | (df['Self_Reported_Focus_Score'] > 10.0)).sum()
    df['Self_Reported_Focus_Score'] = df['Self_Reported_Focus_Score'].clip(lower=1.0, upper=10.0).round(1)
    print(f"Self_Reported_Focus_Score: {focus_outliers} out-of-range records bounded to [1.0, 10.0]")

    # 3. Task Completion Percent (Range: 0.0 to 100.0%)
    comp_outliers = ((df['Task_Completion_Percent'] < 0.0) | (df['Task_Completion_Percent'] > 100.0)).sum()
    df['Task_Completion_Percent'] = df['Task_Completion_Percent'].clip(lower=0.0, upper=100.0).round(1)
    print(f"Task_Completion_Percent: {comp_outliers} out-of-range records bounded to [0.0, 100.0%]")

    # 4. Flow Efficiency Score (Range: 0.0 to 100.0%)
    eff_outliers = ((df['Flow_Efficiency_Score'] < 0.0) | (df['Flow_Efficiency_Score'] > 100.0)).sum()
    df['Flow_Efficiency_Score'] = df['Flow_Efficiency_Score'].clip(lower=0.0, upper=100.0).round(1)
    print(f"Flow_Efficiency_Score: {eff_outliers} out-of-range records bounded to [0.0, 100.0%]")

    # Verification
    print("\nVerified Ranges:")
    for col in ['Cognitive_Load_Score', 'Self_Reported_Focus_Score', 'Task_Completion_Percent', 'Flow_Efficiency_Score']:
        print(f"  {col}: min={df[col].min()}, max={df[col].max()}")

    os.makedirs(os.path.dirname(output_csv_path), exist_ok=True)
    df.to_csv(output_csv_path, index=False)
    print(f"\nStage 4 checkpoint saved to: {output_csv_path} (Shape: {df.shape})")
    return df

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    stage3_path = os.path.join(project_root, "data", "cleaned", "stage3_text_standardized.csv")
    stage4_path = os.path.join(project_root, "data", "cleaned", "stage4_ratings_fixed.csv")
    fix_rating_scales(stage3_path, stage4_path)
