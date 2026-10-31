import pandas as pd

# Load the dataset
df=pd.read_csv("../data/cleaned_data.csv")


#Check the number of rows and 
columns
print("Dataset Shape:", df.shape)

#Display the number of rows
print("Number of Rows:",
df.shape[0])

#Display the number of columns
print("Number of Columns:",
df.shape[1])

#Display all column names
print("\nColumn Names:")
print(df.columns.tolist())

#Display dataset structure and data 
types
print("\nDataset Information:")
df.info()
