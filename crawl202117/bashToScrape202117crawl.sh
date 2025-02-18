#!/bin/bash

#SBATCH --job-name=createChunksandRun
#SBATCH --time=00:10:00
#SBATCH --partition=compute
#SBATCH --mem=4G
#SBATCH --account=math026082

# Account
account="math026082"

# Array of crawl dates
crawlDates=("202117") # "202110" "202117" "202121" "202125" "202131" "202139" "202143" "202149")
# List of corresponding number of .wet files for each crawl date
n_list=(64000 64000)
# Number of chunks
c=16

# Loop through each crawl date with index to retrieve the corresponding n value
for i in "${!crawlDates[@]}"; do
    crawlDate="${crawlDates[i]}"
    n="${n_list[i]}"
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

        # Create and write the bash script for each chunk
        cat <<EOF > "$folder/bash$k.sh"
#!/bin/bash

#SBATCH --job-name=bash${crawlDate}_chunk$k
#SBATCH --time=14-00:00:00
#SBATCH --partition=compute
#SBATCH --mem=45G
#SBATCH --account=${account}

cd "\${SLURM_SUBMIT_DIR}"

echo Running on host "\$(hostname)"
echo Start time is "\$(date)"
echo Directory is "\$(pwd)"
echo Slurm job ID is "\${SLURM_JOBID}"
echo This job runs on the following machines:
echo "\${SLURM_JOB_NODELIST}"

export OMP_NUM_THREADS=1

# Server URL start
SERVER_URL="https://data.commoncrawl.org/"

for ((i=${start}; i<${end}; i++)); do
  warcpathslinenumber=\$((i+1))
  warcpaths="wet.paths"
  FILE_NAME=\$(sed -n "\${warcpathslinenumber}{p;q}" "\$warcpaths")

  SEGMENT_NUMBER=\$(printf "%05d" "\$i")
  OUTPUT_FILE_NAME="crawldata${crawlDate}segment\${SEGMENT_NUMBER}.wet.gz"
  FILE_NAME_TO_DELETE="crawldata${crawlDate}segment\${SEGMENT_NUMBER}.wet"
  
  # Infinite loop to ensure the file is downloaded and is larger than 10MB
  while true; do
    echo "Attempting to download \${OUTPUT_FILE_NAME}..."
    curl --retry 10000 --retry-delay 1 -o "\${OUTPUT_FILE_NAME}" "\${SERVER_URL}\${FILE_NAME}"

    if [[ -f "\${OUTPUT_FILE_NAME}" ]]; then
      FILE_SIZE=\$(stat -c %s "\${OUTPUT_FILE_NAME}")
      if [[ "\${FILE_SIZE}" -gt 10485760 ]]; then
        echo "File \${OUTPUT_FILE_NAME} is larger than 10MB. Attempting to unzip..."
        gzip -d "\${OUTPUT_FILE_NAME}" 2>/dev/null

        if [[ \$? -eq 0 ]]; then
          echo "Successfully downloaded and unzipped \${OUTPUT_FILE_NAME}."
          break  # Exit the loop if everything is successful
        else
          echo "Failed to unzip \${OUTPUT_FILE_NAME}. Retrying download..."
          rm -f "\${OUTPUT_FILE_NAME}"  # Delete the corrupted file
        fi
      else
        echo "File \${OUTPUT_FILE_NAME} is smaller than 10MB. Retrying download..."
        rm -f "\${OUTPUT_FILE_NAME}"  # Delete the small file
      fi
    else
      echo "File \${OUTPUT_FILE_NAME} does not exist. Retrying download..."
    fi
    sleep 1  # Optional: Add a small delay
  done

  PY_OUTPUT_FILE_NAME="crawldata${crawlDate}segment\${SEGMENT_NUMBER}.csv"
  python read_wet.py "\${SERVER_URL}" "\${FILE_NAME}"
  mv "outputdf.csv" "\${PY_OUTPUT_FILE_NAME}"
  rm "\${FILE_NAME_TO_DELETE}"

done

echo End time is "\$(date)"
EOF
        # Make the script executable
        chmod +x "$folder/bash$k.sh"
    done

    # Submit sbatch jobs for each chunk script
    for k in $(seq 0 $((c-1))); do
        cd "folder$k" || exit 1
        sbatch "bash$k.sh"  # Uncomment to submit jobs
        cd ..
    done

    # Move back to the main directory for the next crawl date
    cd ..
done
