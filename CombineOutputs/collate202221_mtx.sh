#!/bin/bash

#SBATCH --job-name=collate202221_mtx
#SBATCH --time=3-00:00:00
#SBATCH --partition=compute
#SBATCH --mem=100G
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

python collate202221_mtx.py