#!/bin/bash

#SBATCH --job-name=CombineOutputs202110
#SBATCH --time=3-00:00:00
#SBATCH --partition=compute
#SBATCH --mem=128G
#SBATCH --account=math026082

cd "${SLURM_SUBMIT_DIR}"

echo Running on host "$(hostname)"
echo Time is "$(date)"
echo Directory is "$(pwd)"
echo Slurm job ID is "${SLURM_JOBID}"
echo This jobs runs on the following machines:
echo "${SLURM_JOB_NODELIST}"

export OMP_NUM_THREADS=1

# State the crawl date
crawlDate="202104"
# Input value of n - this is the number of .wet files in the crawl
n=79840
# State the value of c = the number of chunks
c=16
# NOTE: these crawlDate, n and c values must be the same as specified in bashScript1toRun.sh

python CombineOutputs202110.py "${c}" "${n}" "${crawlDate}"
