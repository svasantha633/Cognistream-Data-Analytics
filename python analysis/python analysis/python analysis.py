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
