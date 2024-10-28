#!/bin/bash
#SBATCH --job-name=CombineOutputs_all
#SBATCH --time=00:10:00
#SBATCH --partition=compute
#SBATCH --mem=4G
#SBATCH --account=math026082

# Array of crawl dates
crawlDates=("202104" "202110" "202117" "202121" "202125" "202131" "202139" "202143" "202149")
# List of corresponding number of .wet files for each crawl date
n_list=(79840 64000 64000 64000 64000 72000 72000 72000 64000)
# Number of chunks
c=10
# Account
account="math026082"

# Loop through each crawl date with index to retrieve the corresponding n value
for i in "${!crawlDates[@]}"; do
    crawlDate="${crawlDates[i]}"
    n="${n_list[i]}"
    echo "Processing crawl date: $crawlDate with $n files"

    # Change to the directory corresponding to the crawl date
    cd "$crawlDate" || { echo "Directory $crawlDate not found"; exit 1; }

    # Create a SLURM job script
    cat <<EOF > "CombineOutputs_${crawlDate}.sh"
#!/bin/bash

#SBATCH --job-name=CombineOutputs_${crawlDate}
#SBATCH --time=3-00:00:00
#SBATCH --partition=compute
#SBATCH --mem=128G
#SBATCH --account=${account}

cd "\${SLURM_SUBMIT_DIR}"

echo Running on host "\$(hostname)"
echo Time is "\$(date)"
echo Directory is "\$(pwd)"
echo Slurm job ID is "\${SLURM_JOBID}"
echo This job runs on the following machines:
echo "\${SLURM_JOB_NODELIST}"

export OMP_NUM_THREADS=1

# State the crawl date
crawlDate="${crawlDate}"
# Input value of n - this is the number of .wet files in the crawl
n=${n}
# State the value of c = the number of chunks
c=${c}

python CombineOutputs.py "\${c}" "\${n}" "\${crawlDate}"

EOF

    # Make the script executable
    chmod +x "CombineOutputs_${crawlDate}.sh"

    # Submit the SLURM job
    sbatch "CombineOutputs_${crawlDate}.sh"

    # Move back to the parent directory for the next crawl date
    cd ..

done
