#!/bin/bash

#SBATCH --job-name=createChunksandRun
#SBATCH --time=00:10:00
#SBATCH --partition=compute
#SBATCH --mem=4G
#SBATCH --account=math026082

print("Hello world")

# Account
account="math026082"

# Array of crawl dates
crawlDate="202110"
n=64000
# Number of chunks
c=16

echo "Processing crawl date: $crawlDate with $n files"

# Create a directory for each crawl date
mkdir "$crawlDate"
cd "$crawlDate" || exit 1

# Copy the date-specific wet.paths file
cp "../wetpaths/wet$crawlDate.paths" "wet.paths"

# Create c folders for chunks
for k in $(seq 0 $((c-1))); do
    folder="folder$k"
    mkdir "$folder"
    
    # Copy necessary files into each chunk folder
    cp ../read_wet.py "$folder"
    cp wet.paths "$folder"
    cp ../UK_PostcodeLookup.csv "$folder"

    # Calculate the number of loops for this chunk
    N=$((n/c))
    start=$((k * N))
    end=$((start + N))
