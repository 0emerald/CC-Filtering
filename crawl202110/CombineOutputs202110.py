import os
import csv
import sys

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

# Initialize output CSV file
output_csv_path = "df" + crawlDate + ".csv"
with open(output_csv_path, mode='w', newline='') as output_csv_file:
    output_csv_writer = csv.writer(output_csv_file)
    
    idx = 0

    for i in range(c):
        folder_name = 'folder' + str(i)
        folder_path = os.path.join(os.getcwd(), folder_name)
        os.chdir(folder_path)

        for file_index in range(N):
            file_name = "crawldata" + crawlDate + "segment" + str(idx + file_index).zfill(5) + ".csv"
            try:
                with open(file_name, 'r') as csv_file:
                    csv_reader = csv.reader(csv_file)
                    # Iterate over each row in the CSV file and write it to the output CSV
                    for row in csv_reader:
                        output_csv_writer.writerow(row)
            except FileNotFoundError:
                pass

        parent_directory = os.path.dirname(os.getcwd())
        os.chdir(parent_directory)
        idx += N

