#!/bin/bash

# Go into each folder and submit sbatch job for the corresponding bash script
for i in {0..3}; do
    folder="folder$i"
    cd "$folder" || exit 1
    sbatch "bash$i.sh"
    cd ..
done

