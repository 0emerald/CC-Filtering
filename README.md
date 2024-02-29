# CC-Filtering
Prototype scripts that are easy to edit variables for different outputs. Example searches one crawl for all .co.uk websites geolocated by postcode to the Bristol area. 

**Crawl used in prototype:** 2023-50 (Dec 2023)

**PIPELINE.**

**FilterPostcodeLookup:**

Takes the ONS postcode lookup: https://geoportal.statistics.gov.uk/datasets/ons::national-statistics-postcode-lookup-2021-census-august-2023/about and filters this to a subset of postcodes of interest. `BristolPCfilter.ipynb` filters out the postcodes associated with Bristol for this prototype. Output file is called `postcodeLookup.csv` and is used in the next step. 

**bashChunking:**

Running `bashScript1toRun.sh` requires `wet.paths` for the crawl of interested downloaded from: https://commoncrawl.org/overview to be present in the folder, the script `read_wet.py` and `postcodeLookup.csv` to be in the folder. `bashScript1toRun.sh` creates a specified number of folders, copies the 3 aforementioned files into each folder, creates a bash file in each folder, and runs each of these bash scripts. Across the $c$ folders are $n$ csv and $n$ mtx files of data. Bash scripts are written for slurm. 

**CombineOutputs:**

Put $n$ outputs across $c$ files into one csv file. 


**HOW TO REPRODUCE.**

* Copy this repo into a workspace, e.g. HPC, which has enough RAM to run things.
* Edit lines 7 and 17 in `bashScript1toRun.sh` to be your account.
* Check line 10 in `bashScript1toRun.sh` is the crawl you are interested in.
* Check line 12 (where $n$ is specified) matches the number of wet files in the crawl you are interested in.
* In the folder **bashChunking**, run `bashScript1toRun.sh`.
``` bash
sbatch bashScript1toRun.sh
```
*
