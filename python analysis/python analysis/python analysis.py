"""
Project :Second Project
Purpose :Python Data Analysis
This file will contain the 
python analysis
for our project dataset.
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

print("python analysis environment initialization")                                                                                                       
#Commit 3: Load and inspect the dataset

df = pd.read_excel(
   "../Data/
CogniStream_Developer_Flow_State_Cog
nitive_Load_10000.xlsx"
)

print("First 5 rows:")
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
print(missing_values)

total_missing = missing_values.sum()
print("\nTotal Missing Values:",
total_missing)


import pandas as pd

# Load dataset
df = pd.read_excel('/content/CogniStream_Developer_Flow_State_Cognitive_Load_10000 (2).xlsx')

# Check missing values
missing_values = df.isnull().sum()

print("Missing Values in Each Column:")
print(missing_values)

print("\nTotal Missing Values:", df.isnull().sum().sum())



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
print(df.head())
print(df.shape)
print(df.dtypes)


import pandas as pd

# Load dataset
df = pd.read_excel('/content/CogniStream_Developer_Flow_State_Cognitive_Load_10000 (2).xlsx')

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

print("\nDataset Shape:")
print(df.shape)

print("\nColumn Names:")
print(df.columns.tolist())

# Analyze numerical columns
print("\nNumerical Data Summary:")
print(df.describe())

# Check data types
print("\nData Types:")
print(df.dtypes)

# Check missing values
print("\nMissing Values:")
print(df.isnull().sum())

# Check duplicate records
print("\nDuplicate Records:")
print(df.duplicated().sum())


import pandas as pd
import matplotlib.pyplot as plt

# Load the Cognistream dataset
df = pd.read_excel(
    "data/Cognistream _Developer _Flow_state_Cognitive_Load_10000.xlsx"
)

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


import pandas as pd
import numpy as np

# Load the Cognistream dataset
file_path = "../data/Cognistream _Developer _Flow_state_Cognitive_Load_10000.xlsx"
df = pd.read_excel(file_path)

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


import pandas as pd
import matplotlib.pyplot as plt
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



import pandas as pd
import matplotlib.pyplot as plt
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



import pandas as pd
import matplotlib.pyplot as plt

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



import pandas as pd
import matplotlib.pyplot as plt

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
