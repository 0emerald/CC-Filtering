import pandas as pd
import pyarrow.parquet as pq
import pyarrow as pa

csv_file_path = 'input.csv'
parquet_file_path = 'output.parquet'

# Read the first chunk to infer schema
# specify chunksize
first_chunk = pd.read_csv(csv_file_path, chunksize=1000).__next__()
schema = pa.Table.from_pandas(first_chunk).schema

# Initialize ParquetWriter with the inferred schema
with pq.ParquetWriter(parquet_file_path, schema=schema, compression='SNAPPY') as writ$
    # Write the first chunk
    writer.write_table(pa.Table.from_pandas(first_chunk))

    # Write remaining chunks
    for chunk in pd.read_csv(csv_file_path, chunksize=1000):
        table = pa.Table.from_pandas(chunk)
        writer.write_table(table)


