#!/bin/bash

#SBATCH --job-name=bash202350-parallelAttempt
#SBATCH --time=01:00:00
#SBATCH --partition=compute
#SBATCH --mem=25G
#SBATCH --account=math026082

cd "${SLURM_SUBMIT_DIR}"

echo Running on host "$(hostname)"
echo Time is "$(date)"
echo Directory is "$(pwd)"
echo Slurm job ID is "${SLURM_JOBID}"
echo This jobs runs on the following machines:
echo "${SLURM_JOB_NODELIST}"

module load lang/python/anaconda/3.7-2019.10

source activate

export OMP_NUM_THREADS=1

# Number of loops
N=8000
# Server URL start
SERVER_URL="https://data.commoncrawl.org/"

for ((i=8000; i<(N+8000); i++)); do
  # Find the file name from warc.paths
  warcpathslinenumber=$((i+1))
  warcpaths="wet.paths"
  FILE_NAME=$(sed -n "${warcpathslinenumber}{p;q}" "$warcpaths")

  SEGMENT_NUMBER=$(printf "%05d" "$i")
  OUTPUT_FILE_NAME="crawldata202221segment${SEGMENT_NUMBER}.wet.gz"
  FILE_NAME_TO_DELETE="crawldata202221segment${SEGMENT_NUMBER}.wet"
  
  # Download the file using curl
  curl --retry 1000 --retry-delay 1 -o "${OUTPUT_FILE_NAME}" "${SERVER_URL}${FILE_NAME}"
  
  # Use gzip to unzip the file
  gzip -d "$OUTPUT_FILE_NAME"

  # Execute the Python script with the output file name
  PY_OUTPUT_FILE_NAME="crawldata202221segment${SEGMENT_NUMBER}.csv"
  OUTPUT_MTX_NAME="crawldata202221segment${SEGMENT_NUMBER}.mtx"
  
  # run python script
  python read_wet_2023.py

  # rename file
  mv "outputdf.csv" "$PY_OUTPUT_FILE_NAME"
  mv "X.mtx" "$OUTPUT_MTX_NAME"

  # Delete the .warc file
  rm "$FILE_NAME_TO_DELETE"
done
