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

df = pd.read_excel("data/CogniStream_Developer_Flow_State_Cognitive_Load_10000.xlsx")

# Check for duplicate rows in the dataset

duplicate_count =
df.duplicated().sum()

print("Number of duplicate rows:",
duplicate_count)

# Display duplicate rows
duplicate_rows = df[df.duplicated()]

print(duplicate_rows)

# Review data types
print(df.dtypes)

# Prepare data for analysis

df.columns = df.columns.str.strip()

print("Dataset prepared for analysis")
print(df.head())
print(df.shape)
print(df.dtypes)

# Calculate basic statistics
print("Basic Statistics:")
print(df.describe())


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
