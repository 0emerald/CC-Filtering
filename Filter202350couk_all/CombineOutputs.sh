#!/bin/bash

#SBATCH --job-name=CombineOutputs_UK
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

module load lang/python/anaconda/3.7-2019.10

source activate

export OMP_NUM_THREADS=1

# State the crawl date
crawlDate="202350"
# Input value of n - this is the number of .wet files in the crawl
n=90000
# State the value of c = the number of chunks
c=10
# NOTE: these crawlDate, n and c values must be the same as specified in bashScript1toRun.sh

python CombineOutputs_UK.py "${c}" "${n}" "${crawlDate}"
