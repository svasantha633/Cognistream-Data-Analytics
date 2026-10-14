import pandas as pd

# Step 1: Load the raw Excel dataset
file_path = "data/raw/CogniStream_Developer_Flow_State_Cognitive_Load_10000.xlsx"

df = pd.read_excel(file_path, sheet_name="Raw_Data")

# Step 2: Check the dataset dimensions
print("Dataset shape:", df.shape)

# Step 3: Display the first five rows
print("\nFirst five rows:")
print(df.head())

# Step 4: Check column names
print("\nColumn names:")
print(df.columns.tolist())

# Step 5: Check data types
print("\nData types:")
print(df.dtypes)

# Step 6: Check missing values
print("\nMissing values per column:")
print(df.isnull().sum())

# Step 7: Check exact duplicate rows
print("\nExact duplicate rows:", df.duplicated().sum())

# Step 8: Check numerical statistics
print("\nNumerical summary:")
print(df.describe())

# Step 9: Check total missing values
print("\nTotal missing values:", df.isnull().sum().sum())

# Step 10: Show columns with missing values
print("\nColumns with missing values:")
print(df.isnull().sum()[df.isnull().sum() > 0])

# Step 11: Check duplicate rows
print("\nDuplicate rows:", df.duplicated().sum())

# Step 12: Check repeated Record_ID values
print("\nRepeated Record_ID values:")
print(df["Record_ID"].duplicated().sum())

# Step 13: Find placeholder values
placeholders = ["N/A", "NULL", "unknown", "-"]

print("\nPlaceholder counts:")
for value in placeholders:
    count = (
        df.astype("string")
        .apply(lambda col: col.str.strip().str.upper() == value.upper())
        .sum()
        .sum()
    )
    print(f"{value}: {count}")

    # Step 14: Standardize placeholder values
placeholder_values = ["N/A", "NULL", "unknown", "-"]

df = df.replace(
    r"^\s*(?:N/A|NULL|unknown|-)\s*$",
    pd.NA,
    regex=True
)

print("\nMissing values after placeholder replacement:")
print(df.isnull().sum()[df.isnull().sum() > 0])

print("\nTotal missing values after replacement:")
print(df.isnull().sum().sum())

# Step 15: Show missing values by column
missing_summary = df.isnull().sum()

print("\nMissing values by column:")
print(missing_summary[missing_summary > 0].sort_values(ascending=False))

print("\nPercentage of missing values by column:")
missing_percentage = (df.isnull().mean() * 100).round(2)
print(missing_percentage[missing_percentage > 0].sort_values(ascending=False))

# Step 16: Review column data types
print("\nColumn data types:")
print(df.dtypes.to_string())

# Step 17: Check values outside expected ranges

print("\nCognitive Load Score outside 1-10:")
print((~df["Cognitive_Load_Score"].between(1, 10)).sum())

print("\nSelf-Reported Focus Score outside 1-10:")
print((~df["Self_Reported_Focus_Score"].between(1, 10)).sum())

print("\nTask Completion Percent outside 0-100:")
print((~df["Task_Completion_Percent"].between(0, 100)).sum())

print("\nFlow Efficiency Score outside 0-100:")
print((~df["Flow_Efficiency_Score"].between(0, 100)).sum())

print("\nNegative Task Duration values:")
print((df["Task_Duration_Minutes"] < 0).sum())

print("\nNegative Interruption Counts:")
print((df["Interruptions_Count"] < 0).sum())

# Step 18: Inspect invalid score values

print("\nInvalid cognitive load scores:")
print(
    df.loc[
        ~df["Cognitive_Load_Score"].between(1, 10),
        ["Record_ID", "Cognitive_Load_Score"]
    ].head(10)
)

print("\nInvalid task completion percentages:")
print(
    df.loc[
        ~df["Task_Completion_Percent"].between(0, 100),
        ["Record_ID", "Task_Completion_Percent"]
    ].head(10)
)

print("\nNegative task durations:")
print(
    df.loc[
        df["Task_Duration_Minutes"] < 0,
        ["Record_ID", "Task_Duration_Minutes"]
    ]
)

# Step 19: Separate missing and invalid values

score_columns = [
    "Cognitive_Load_Score",
    "Self_Reported_Focus_Score"
]

for col in score_columns:
    invalid = df[col].notna() & ~df[col].between(1, 10)
    print(f"\n{col}")
    print("Missing:", df[col].isna().sum())
    print("Outside 1-10:", invalid.sum())

percentage_columns = [
    "Task_Completion_Percent",
    "Flow_Efficiency_Score"
]

for col in percentage_columns:
    invalid = df[col].notna() & ~df[col].between(0, 100)
    print(f"\n{col}")
    print("Missing:", df[col].isna().sum())
    print("Outside 0-100:", invalid.sum())

    # Step 20: Correct invalid numeric values

score_columns = [
    "Cognitive_Load_Score",
    "Self_Reported_Focus_Score"
]

for col in score_columns:
    invalid = ~df[col].between(1, 10)
    df.loc[invalid, col] = pd.NA

percentage_columns = [
    "Task_Completion_Percent",
    "Flow_Efficiency_Score"
]

for col in percentage_columns:
    invalid = ~df[col].between(0, 100)
    df.loc[invalid, col] = pd.NA

# Negative durations are invalid
df.loc[df["Task_Duration_Minutes"] < 0, "Task_Duration_Minutes"] = pd.NA

# Negative interruption counts are invalid
df.loc[df["Interruptions_Count"] < 0, "Interruptions_Count"] = pd.NA

print("\nInvalid numeric values handled.")

for col in score_columns + percentage_columns:
    print(f"{col}: {df[col].isna().sum()} missing values")

    # Step 21: Remove exact duplicate rows

duplicates_before = df.duplicated().sum()

print("\nDuplicate rows before cleaning:", duplicates_before)

df = df.drop_duplicates()

print("Dataset shape after removing duplicates:", df.shape)
print("Duplicate rows after cleaning:", df.duplicated().sum())




# Step 22: Inspect repeated Record_ID values

print("\nRepeated Record_ID values after duplicate removal:")
print(df["Record_ID"].duplicated().sum())


# Step 23: Normalize text columns

text_columns = df.select_dtypes(include=["object", "string"]).columns

for col in text_columns:
    df[col] = df[col].apply(
        lambda x: x.strip() if isinstance(x, str) else x
    )

print("\nWhitespace cleaned from text columns.")


# Step 24: Convert date and time columns

df["Session_Date"] = pd.to_datetime(
    df["Session_Date"], errors="coerce"
)

print("\nInvalid or missing session dates:")
print(df["Session_Date"].isna().sum())


# Step 25: Save cleaned dataset

output_path = "data/cleaned/cleaned_data.csv"

df.to_csv(output_path, index=False)

print("\nCleaned dataset saved to:", output_path)
print("Final dataset shape:", df.shape)

# Step 26: Verify the exported CSV

check_df = pd.read_csv(output_path)

print("\n--- Export Verification ---")
print("CSV shape:", check_df.shape)
print("Exact duplicate rows:", check_df.duplicated().sum())
print("Total missing values:", check_df.isnull().sum().sum())
print("File loaded successfully:", check_df.shape == df.shape)

# Step 27: Inspect repeated Record_ID values

repeated_ids = df[df["Record_ID"].duplicated(keep=False)]

print("\nRepeated Record_ID rows:")
print(repeated_ids[["Record_ID", "Session_Date", "Developer_ID"]].head(20))

print("\nNumber of rows with repeated IDs:", len(repeated_ids))
print("Number of unique repeated IDs:", repeated_ids["Record_ID"].nunique())

# Step 28: Inspect conflicting Record_ID values

repeated_ids = df[df["Record_ID"].duplicated(keep=False)]

id_summary = repeated_ids.groupby("Record_ID").agg(
    rows=("Record_ID", "size"),
    unique_developers=("Developer_ID", "nunique"),
    unique_dates=("Session_Date", "nunique")
)

print("\nRepeated ID summary:")
print(id_summary.head(20))

print("\nRepeated IDs with multiple developers:")
print(id_summary[id_summary["unique_developers"] > 1])

# Step 29: Compare rows with repeated Record_ID values

example_id = id_summary[
    id_summary["unique_developers"] > 1
].index[0]

print(f"\nComparing records for ID: {example_id}")

print(
    df.loc[
        df["Record_ID"] == example_id
    ].T.to_string()
)

# Step 30: Flag repeated IDs for review

df["Duplicate_Record_ID_Flag"] = df["Record_ID"].duplicated(
    keep=False
)

print("\nRows flagged for repeated Record_ID values:")
print(df["Duplicate_Record_ID_Flag"].sum())

print("\nRepeated IDs retained for investigation:")
print(
    df.loc[
        df["Duplicate_Record_ID_Flag"],
        ["Record_ID", "Developer_ID", "Session_Date"]
    ].head(10)
)

# Step 31: Export the final cleaned dataset

output_path = "data/cleaned/cleaned_data.csv"

df.to_csv(output_path, index=False)

print("\n--- Final Cleaning Report ---")
print("Final dataset shape:", df.shape)
print("Exact duplicate rows:", df.duplicated().sum())
print("Rows flagged for repeated Record_ID:",
      df["Duplicate_Record_ID_Flag"].sum())
print("Total missing values:", df.isnull().sum().sum())

# Step 32: Verify the exported file

check_df = pd.read_csv(output_path)

print("\n--- Export Verification ---")
print("CSV shape:", check_df.shape)
print("CSV loaded successfully:", check_df.shape == df.shape)
print("CSV saved at:", output_path)