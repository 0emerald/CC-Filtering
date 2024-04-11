import pandas as pd
import numpy as np
import os
import sys

# Access arguments passed from the Bash script
try:
    c = int(sys.argv[1])
except ValueError:
    print("Error: The provided argument for c is not a valid integer.")
    
try: 
    n = int(sys.argv[2])
except ValueError:
    print("Error: The provided argument for n is not a valid integer.") 
    
crawlDate = sys.argv[3]

N = n//c # integer division
    
# initialize empty dataframe
df = pd.DataFrame()

idx = 0

for i in range(c):
    folder_name = 'folder' + str(i)
    # go into the folder called folder_name
    folder_path = os.path.join(os.getcwd(), folder_name)
    os.chdir(folder_path)

    # read in the csv files
    for file in range(N):
        file_name = "crawldata" + crawlDate +"segment" + str(idx+file).zfill(5) + ".csv"
        # read in the file if it exists
        try:
            df_segment = pd.read_csv(file_name, header=None)
            df = df.append(df_segment, ignore_index=True)
        except FileNotFoundError:
            pass

    # go back out of the chunk folder
    current_directory = os.getcwd()
    # Go up one level in the directory
    parent_directory = os.path.dirname(current_directory)
    os.chdir(parent_directory)
    idx += N

df.to_csv("df" + crawlDate + ".csv", index=False, header=False)
