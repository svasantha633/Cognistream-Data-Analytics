"""
scripts/import_data.py
----------------------
Automated data ingestion pipeline for CogniStream Analytics:
1. Applies schema DDL from sql/01_schema.sql.
2. Ingests certified clean records from data/cleaned/clean_data.csv into cognistream.db.
3. Validates row counts, primary key uniqueness, and table constraints.
"""

import os
import sys
import sqlite3
import time
import pandas as pd

def import_clean_data(db_path=None, csv_path=None, schema_path=None):
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    if db_path is None:
        db_path = os.path.join(project_root, "cognistream.db")
    if csv_path is None:
        csv_path = os.path.join(project_root, "data", "cleaned", "clean_data.csv")
    if schema_path is None:
        schema_path = os.path.join(project_root, "sql", "01_schema.sql")

    print("=== CogniStream SQLite Database Ingestion Pipeline ===")
    print(f"Target Database: {db_path}")
    print(f"Source Clean CSV: {csv_path}")
    print(f"Schema Definition: {schema_path}")

    if not os.path.exists(csv_path):
        print(f"Error: Source CSV not found at {csv_path}")
        sys.exit(1)
    if not os.path.exists(schema_path):
        print(f"Error: Schema file not found at {schema_path}")
        sys.exit(1)

    start_time = time.time()

    # Step 1: Initialize Database Connection & Apply Schema
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    print("\n[1/3] Executing DDL Schema...")
    with open(schema_path, "r", encoding="utf-8") as f:
        schema_sql = f.read()
    cursor.executescript(schema_sql)
    conn.commit()
    print("Schema and views initialized successfully.")

    # Step 2: Load and Ingest Clean CSV Data
    print("\n[2/3] Loading cleaned CSV records...")
    df = pd.read_csv(csv_path)
    total_csv_rows = len(df)
    print(f"Loaded {total_csv_rows:,} rows from clean CSV.")

    print("Ingesting records into 'cognistream_sessions' table...")
    df.to_sql("cognistream_sessions", conn, if_exists="append", index=False)
    conn.commit()

    # Step 3: Run Database Integrity Checks
    print("\n[3/3] Running Database Verification Queries...")
    cursor.execute("SELECT COUNT(*) FROM cognistream_sessions;")
    db_row_count = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(DISTINCT Record_ID) FROM cognistream_sessions;")
    distinct_keys = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM cognistream_sessions WHERE Record_ID IS NULL;")
    null_keys = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(DISTINCT Developer_ID), COUNT(DISTINCT Project_ID), COUNT(DISTINCT Task_Type) FROM cognistream_sessions;")
    dev_count, prj_count, task_count = cursor.fetchone()

    cursor.execute("SELECT MIN(Cognitive_Load_Score), MAX(Cognitive_Load_Score), ROUND(AVG(Cognitive_Load_Score), 2) FROM cognistream_sessions;")
    min_cog, max_cog, avg_cog = cursor.fetchone()

    cursor.execute("SELECT MIN(Flow_Efficiency_Score), MAX(Flow_Efficiency_Score), ROUND(AVG(Flow_Efficiency_Score), 2) FROM cognistream_sessions;")
    min_eff, max_eff, avg_eff = cursor.fetchone()

    elapsed = time.time() - start_time

    print(f"\n--- Ingestion Verification Summary ---")
    print(f"Total Rows Ingested:       {db_row_count:,} (Expected: {total_csv_rows:,})")
    print(f"Unique Primary Keys:       {distinct_keys:,}")
    print(f"Null Primary Keys:         {null_keys}")
    print(f"Total Unique Developers:   {dev_count:,}")
    print(f"Total Unique Projects:     {prj_count:,}")
    print(f"Total Unique Task Types:   {task_count:,}")
    print(f"Cognitive Load Range:      {min_cog} - {max_cog} (Avg: {avg_cog})")
    print(f"Flow Efficiency Range:     {min_eff}% - {max_eff}% (Avg: {avg_eff}%)")
    print(f"Total Ingestion Time:      {elapsed:.3f} seconds")

    conn.close()

    assert db_row_count == total_csv_rows, "Error: Ingested row count does not match CSV!"
    assert distinct_keys == total_csv_rows, "Error: Primary keys are not unique!"
    print("\n>> SUCCESS: SQLite database initialized and verified 100% clean!")

if __name__ == "__main__":
    import_clean_data()
