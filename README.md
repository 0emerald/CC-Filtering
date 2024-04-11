# CC-Filtering
Prototype scripts that are easy to edit variables for different outputs. Example searches one crawl for all .co.uk websites geolocated by postcode to the Bristol area. 

**Crawl used in prototype:** 2023-50 (Dec 2023)

## **PIPELINE.**

**FilterPostcodeLookup:**

Takes the ONS postcode lookup: https://geoportal.statistics.gov.uk/datasets/ons::national-statistics-postcode-lookup-2021-census-august-2023/about and filters this to a subset of postcodes of interest. This is not stored in the github repo due to file size, but you can download it from teh above link if needed. `BristolPCfilter.ipynb` filters out the postcodes associated with Bristol for this prototype. Output file is called `BristolPostcodeLookup.csv` and is used in the next step. `laua`=='E06000023'is the Bristol Local Authority (https://www.nomisweb.co.uk/reports/localarea?compare=E06000023). The file `BristolPostcodeLookup.csv` is copied into the *bashChunking* folder where it is used. 


**bashChunking:**

Running `bashScript1toRun.sh` requires `wet.paths` for the crawl of interested downloaded from: https://commoncrawl.org/overview to be present in the folder, the script `read_wet.py` and `postcodeLookup.csv` to be in the folder. `bashScript1toRun.sh` creates a specified number of folders, copies the 3 aforementioned files into each folder, creates a bash file in each folder, and runs each of these bash scripts. Across the $c$ folders are $n$ csv files of data. Bash scripts are written for slurm. 

**CombineOutputs:**

Put $n$ outputs across $c$ files into one csv file, to `df202350.csv`, by running `CombineOutputs.sh` on the HPC. 
* `CombineOutputs_v1` doesn't work quite right, so use `v2`. `v2` is the code in the *CodeToReproduce* Folder. 

----will want one folder with bashChunking and CombineOutputs scripts and files all in one place, so the user just copies one folder and runs stuff------------
## **HOW TO REPRODUCE.**

* Copy this repo into a workspace, e.g. HPC, which has enough RAM to run things.
* Edit lines 7 and 17 in `bashScript1toRun.sh` to be your account.
* Check line 10 in `bashScript1toRun.sh` is the crawl you are interested in.
* Check line 12 (where $n$ is specified) matches the number of wet files in the crawl you are interested in.
* If you change the crawl, you will also need to download the correct corresponding `wet.paths` file and copy this into the folder and remove the old `wet.paths` file. The one currently in there corresponds to the 202350 crawl. Just changing line 10 will NOT change the data you download and look at, just the file naming.
* Check line 15 (where $c$, the number of chunks, is specified) suits your requirements, and that $n/c$ is an integer. 
* In the folder **bashChunking**, run `bashScript1toRun.sh` (files: `'wet.paths`, `read_wet.py`, and `BristolPostcodeLookup.csv` must be present in the folder).
``` bash
sbatch bashScript1toRun.sh
```
* This will run one job, then it will create $c$ further jobs. Once these are all complete, run
``` bash
sbatch CombineOutputs.sh
```

