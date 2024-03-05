#!/bin/bash

#SBATCH --job-name=createChunksandRun
#SBATCH --time=00:10:00
#SBATCH --partition=compute
#SBATCH --mem=4G
#SBATCH --account=math026082

# state the crawl date
crawlDate="202350"
# Input value of n - this is the number of .wet files in the crawl
n=90000
# Define the value of c = the number of chunks
# NOTE: you need n to be divisible by c or you will have problems 
c=10
# need your account - this is mine
account="math026082"


# Create c folders
for k in $(seq 0 $((c-1))); do
    folder="folder$k"
    mkdir "$folder"
    # copy files into each folder
    cp read_wet.py "$folder"
    cp wet.paths "$folder"
    cp BristolPostcodeLookup.csv "$folder"
    # Create bash scripts
    cat <<EOF > "$folder/bash$k.sh"
#!/bin/bash

#SBATCH --job-name=bash${crawlDate}_chunk$k
#SBATCH --time=10-00:00:00
#SBATCH --partition=compute
#SBATCH --mem=25G
#SBATCH --account=${account}

cd "\${SLURM_SUBMIT_DIR}"

echo Running on host "\$(hostname)"
echo Start time is "\$(date)"
echo Directory is "\$(pwd)"
echo Slurm job ID is "\${SLURM_JOBID}"
echo This jobs runs on the following machines:
echo "\${SLURM_JOB_NODELIST}"

module load lang/python/anaconda/3.7-2019.10

source activate

export OMP_NUM_THREADS=1

# Number of loops (assuming integer division)
N=$((n/c))

# Server URL start
SERVER_URL="https://data.commoncrawl.org/"

for ((i=($k*N); i<(($k+1)*N); i++)); do
  # Find the file name from wet.paths - ignore that the things are called warc, it's the choice two lines below which defines the source
  warcpathslinenumber=\$((i+1))
  warcpaths="wet.paths"
  FILE_NAME=\$(sed -n "\${warcpathslinenumber}{p;q}" "\$warcpaths")

  SEGMENT_NUMBER=\$(printf "%05d" "\$i")
  OUTPUT_FILE_NAME="crawldata${crawlDate}segment\${SEGMENT_NUMBER}.wet.gz"
  FILE_NAME_TO_DELETE="crawldata${crawlDate}segment\${SEGMENT_NUMBER}.wet"
  
  # Download the file using curl
  curl --retry 1000 --retry-delay 1 -o "\${OUTPUT_FILE_NAME}" "\${SERVER_URL}\${FILE_NAME}"
  
  # Use gzip to unzip the file
  gzip -d "\$OUTPUT_FILE_NAME"

  # Execute the Python script with the output file name
  PY_OUTPUT_FILE_NAME="crawldata${crawlDate}segment\${SEGMENT_NUMBER}.csv"
  
  # run python script and pass arguments from the bash script in
  python read_wet.py "${SERVER_URL}" "${FILE_NAME}"

  # add the CC filepath as a row
  # { echo ${SERVER_URL}${FILE_NAME}; cat outputdf.csv; } > temp.csv

  # rename file
  mv "temp.csv" "$PY_OUTPUT_FILE_NAME"

  # rename file
  mv "outputdf.csv" "\$PY_OUTPUT_FILE_NAME"

  # Delete the .warc file
  rm "\$FILE_NAME_TO_DELETE"
done

echo End time is "\$(date)"

EOF
    chmod +x "$folder/bash$k.sh"
done

# Go into each folder and submit sbatch job for the corresponding bash script
for k in $(seq 0 $((c-1))); do
    folder="folder$k"
    cd "$folder" || exit 1
    sbatch "bash$k.sh"
    cd ..
done
