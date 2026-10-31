"""
Project : Cognistream - Developer Flow State and cognitive Load Analytics

Purpose:
To perform python based data analsis on developer activity,flowstate,and cognitive load.
This file contain data loading ,data cleaning,statistical analysis,visualization,and key insights.
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

print("python analysis environment initialization")                                                                                                       
#Commit 3: Load and inspect the dataset

df = pd.read_excel(
   "/Data/CogniStream
   _Developer_Flow_State_Cognitive_Load_10000.xlsx"
)

print("First Five rows:")
print(df.head())

print("\nColumn names:")
print(df.columns.tolist())

print("\nDataset shape:")
print(df.shape)

print("\nDataset information:")
df.info()

print("\nSummary statistics:")
print(df.describe(include="all"))

# Missing Values Analysis
print("\nMissing Values Analysis:")
missing_values = df.isnull().sum()
print("missing_values")
print(missing_values)

total_missing = missing_values.sum()
print("\nTotal Missing Values:",
total_missing)

# Check duplicate records
duplicate_count = df.duplicated().sum()
print("Total Duplicate Records:", duplicate_count)
# Display duplicate records
duplicates = df[df.duplicated()]
print("\nDuplicate Records:")
print(duplicates)

# Review data types
print(df.dtypes)

# Prepare data for analysis
df.columns = df.columns.str.strip()
print("Dataset prepared for analysis")

# Select numerical columns
numerical_data = df.select_dtypes(include='number')

# Calculate basic statistics
statistics = numerical_data.describe()

# Display results
print("BASIC STATISTICAL ANALYSIS")
print(statistics)

# Additional statistical measures
print("\nMean:")
print(numerical_data.mean())

print("\nMedian:")
print(numerical_data.median())

print("\nMode:")
print(numerical_data.mode().iloc[0])

print("\nStandard Deviation:")
print(numerical_data.std())

# Analyze Developer Flow State Data
# Display basic information about the dataset
print("Developer Flow State Data Analysis")

# Display cognitive load columns
cognitive_columns = [
    col for col in df.columns
    if "cognitive" in col.lower() or "load" in col.lower()
]
print("Cognitive Load Columns:")
print(cognitive_columns)

# Display basic statistics
if cognitive_columns:
    print("\nCognitive Load Statistics:")
    print(df[cognitive_columns].describe())

    # Check missing values
    print("\nMissing Values:")
    print(df[cognitive_columns].isnull().sum())

    # Plot cognitive load distributions
    for col in cognitive_columns:
        if pd.api.types.is_numeric_dtype(df[col]):
            df[col].dropna().hist(bins=20)
            plt.title(f"Distribution of {col}")
            plt.xlabel(col)
            plt.ylabel("Frequency")
            plt.tight_layout()
            plt.show()
else:
    print("No cognitive load columns found.")
    print("Available columns:", df.columns.tolist())

# Select relevant numerical variables
variables = [
    "Flow_State_Score",
    "Cognitive_Load_Score",
    "Focus_Level",
    "Productivity_Score"
]

# Keep only columns available in the dataset
available_variables = [
    col for col in variables if col in df.columns
]

print("Relevant Variables Found:")
print(available_variables)

if len(available_variables) >= 2:
    # Calculate correlations between variables
    correlation_matrix = df[available_variables].corr(
        numeric_only=True
    )

    print("\nCorrelation Matrix:")
    print(correlation_matrix)

    print("\nStrong Relationships:")
    for i in range(len(available_variables)):
        for j in range(i + 1, len(available_variables)):
            col1 = available_variables[i]
            col2 = available_variables[j]

            correlation = correlation_matrix.loc[col1, col2]

            if pd.notna(correlation):
                print(
                    f"{col1} vs {col2}: "
                    f"Correlation = {correlation:.3f}"
                )
else:
    print(
        "\nPlease check the dataset column names "
        "and select at least two numerical variables."
    )
from google.colab import files

# Upload Excel dataset
uploaded = files.upload()
df = pd.read_excel(next(iter(uploaded)))

# Display column names
print("Dataset shape:", df.shape)
print("Columns:", df.columns.tolist())

# Plot average values of numeric columns
numeric_df = df.select_dtypes(include="number")

if not numeric_df.empty:
    numeric_df.mean().plot(kind="bar", figsize=(10, 5))
    plt.title("Developer Flow State Chart Analysis")
    plt.xlabel("Metrics")
    plt.ylabel("Average Value")
    plt.xticks(rotation=45, ha="right")
    plt.tight_layout()
    plt.savefig("developer_flow_state_chart.png")
    plt.show()
    print("Chart created successfully!")
else:
    print("No numeric columns found in the dataset.")

from google.colab import files

# 1. Upload the dataset
uploaded = files.upload()
file_name = next(iter(uploaded))

# 2. Load the Excel dataset
df = pd.read_excel(file_name)

# 3. Clean column names
df.columns = df.columns.str.strip()

print("Dataset shape:", df.shape)
print("Columns:", df.columns.tolist())

# 4. Identify the cognitive load column
matches = [
    col for col in df.columns
    if "cognitive" in col.lower() and "load" in col.lower()
]

if not matches:
    print("Cognitive Load column not found.")
    print("Please check the column names printed above.")
else:
    col = matches[0]

    # 5. Convert values to numeric
    load = pd.to_numeric(df[col], errors="coerce").dropna()

    if load.empty:
        print("No valid numeric Cognitive Load values found.")
    else:
        # 6. Create distribution chart
        plt.figure(figsize=(9, 5))
        plt.hist(load, bins=20, edgecolor="black")

        plt.title("Cognitive Load Distribution Among Developers")
        plt.xlabel("Cognitive Load")
        plt.ylabel("Frequency")
        plt.grid(axis="y", alpha=0.3)
        plt.tight_layout()
        plt.show()

        # 7. Display summary statistics
        print("\nCognitive Load Statistics")
        print("Valid records:", len(load))
        print("Mean:", round(load.mean(), 2))
        print("Median:", round(load.median(), 2))
        print("Standard deviation:", round(load.std(), 2))
        print("Minimum:", round(load.min(), 2))
        print("Maximum:", round(load.max(), 2))

# Standardize task type names
df["Task_Type_Clean"] = (
    df["Task_Type"]
    .astype(str)
    .str.strip()
    .str.title()
)

# Count developer activities
activity_counts = df["Task_Type_Clean"].value_counts()

# Plot chart
plt.figure(figsize=(10, 6))
activity_counts.sort_values().plot(kind="barh")

plt.title("Developer Activity by Task Type")
plt.xlabel("Number of Records")
plt.ylabel("Task Type")
plt.tight_layout()
plt.show()

# Display summary
print("Developer Activity Summary:")
print(activity_counts)

# Load dataset
df = pd.read_excel('/content/CogniStream_Developer_Flow_State_Cognitive_Load_10000 (2).xlsx')

# Select relevant metrics
metrics = [
    'Cognitive_Load_Score',
    'Task_Duration_Minutes',
    'Interruptions_Count',
    'Task_Completion_Percent',
    'Flow_Efficiency_Score',
    'Self_Reported_Focus_Score'
]

# Calculate average values
avg_metrics = df[metrics].mean()

# Display comparison
print("Comparison of Relevant Metrics")
print(avg_metrics)

# Create bar chart
plt.figure(figsize=(12, 6))
avg_metrics.plot(kind='bar', edgecolor='black')

plt.title('Comparison of Relevant Developer Metrics')
plt.xlabel('Developer Metrics')
plt.ylabel('Average Values')
plt.xticks(rotation=35, ha='right')
plt.grid(axis='y', linestyle='--', alpha=0.5)
plt.tight_layout()
plt.show()

print("FLOW STATE PATTERNS:\n", df['Flow_State'].value_counts())
print("\nCOGNITIVE LOAD:\n", df['Cognitive_Load_Score'].describe())
print("\nTASK DURATION:\n", df.groupby('Flow_State')['Task_Duration_Minutes'].mean())
print("\nINTERRUPTIONS:\n", df.groupby('Flow_State')['Interruptions_Count'].mean())
print("\nDEVELOPER ACTIVITY:\n", df.groupby('Developer_ID')['Commit_Count'].mean())

df.groupby('Flow_State')['Task_Duration_Minutes'].mean().plot(kind='bar')
plt.title('Task Duration by Flow State')
plt.xlabel('Flow State')
plt.ylabel('Average Duration')
plt.tight_layout()
plt.show()

df.groupby('Flow_State')['Interruptions_Count'].mean().plot(kind='bar')
plt.title('Interruptions by Flow State')
plt.xlabel('Flow State')
plt.ylabel('Average Interruptions')
plt.tight_layout()
plt.show()

import matplotlib.pyplot as plt
df['Session_Date'] = pd.to_datetime(df['Session_Date'], errors='coerce')
daily = df.groupby('Session_Date')['Cognitive_Load_Score'].mean()
daily.plot(figsize=(10, 5), marker='o')
plt.title('Cognitive Load Trend Over Time'); plt.xlabel('Session Date'); plt.ylabel('Average Cognitive Load'); plt.show()

df.groupby('Flow_State')['Flow_Efficiency_Score'].mean().plot(kind='bar')
plt.title('Flow Efficiency by Flow State')
plt.xlabel('Flow State')
plt.ylabel('Average Flow Efficiency')
plt.tight_layout()
plt.show()

print("KEY FINDINGS AND INSIGHTS")
print("Top Flow State:\n", df['Flow_State'].value_counts().head(3))
print("Average Cognitive Load:", df['Cognitive_Load_Score'].mean())
print("Average Task Duration:\n", df.groupby('Flow_State')['Task_Duration_Minutes'].mean())
print("Average Flow Efficiency:\n", df.groupby('Flow_State')['Flow_Efficiency_Score'].mean())
