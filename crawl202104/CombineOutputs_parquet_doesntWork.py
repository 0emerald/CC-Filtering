import os
import csv
import sys
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq

# Increase the field size limit
csv.field_size_limit(sys.maxsize)

try:
    c = int(sys.argv[1])
except ValueError:
    print("Error: The provided argument for c is not a valid integer.")
    sys.exit(1)
    
try: 
    n = int(sys.argv[2])
except ValueError:
    print("Error: The provided argument for n is not a valid integer.") 
    sys.exit(1)
    
crawlDate = sys.argv[3]

N = n // c  # integer division

# # Initialize output CSV file
# output_csv_path = "df" + crawlDate + ".csv"
# with open(output_csv_path, mode='w', newline='') as output_csv_file:
#     output_csv_writer = csv.writer(output_csv_file)
    
#     idx = 0

#     for i in range(c):
#         folder_name = 'folder' + str(i)
#         folder_path = os.path.join(os.getcwd(), folder_name)
#         os.chdir(folder_path)

#         for file_index in range(N):
#             file_name = "crawldata" + crawlDate + "segment" + str(idx + file_index).zfill(5) + ".csv"
#             try:
#                 with open(file_name, 'r') as csv_file:
#                     csv_reader = csv.reader(csv_file)
#                     # Iterate over each row in the CSV file and write it to the output CSV
#                     for row in csv_reader:
#                         output_csv_writer.writerow(row)
#             except FileNotFoundError:
#                 pass

#         parent_directory = os.path.dirname(os.getcwd())
#         os.chdir(parent_directory)
#         idx += N


# Initialize output parquet file
output_csv_path = "df" + crawlDate + ".parquet"
with open(output_csv_path, mode='w', newline='') as output_csv_file:
    output_csv_writer = csv.writer(output_csv_file)
    
    idx = 0

    first_file = "folder0/crawldata" + crawlDate + "segment00000.parquet"
    schema = pq.ParquetFile(first_file).schema_arrow
    with pq.ParquetWriter(output_csv_path, schema=schema) as writer:

        for i in range(c):
            folder_name = 'folder' + str(i)
            folder_path = os.path.join(os.getcwd(), folder_name)
            os.chdir(folder_path)

            for file_index in range(N):
                if (idx+file_index) == 0:
                    continue
                else:
                    file_name = "crawldata" + crawlDate + "segment" + str(idx + file_index).zfill(5) + ".parquet"
                    try:
                        writer.write_table(pq.read_table(file_name, schema=schema))
                    except FileNotFoundError:
                        pass

            parent_directory = os.path.dirname(os.getcwd())
            os.chdir(parent_directory)
            idx += N
