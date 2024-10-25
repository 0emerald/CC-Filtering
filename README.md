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

## **HOW TO REPRODUCE. Uses only the code that is in CodeToReproduce folder - this is manually copied in**
----`CodeToReproduce` is one folder with bashChunking and CombineOutputs scripts and files all in one place, so the user just copies one folder and runs stuff----

* Copy this repo into a workspace, e.g. HPC, which has enough RAM to run things and go into folder `CodeToReproduce` OR just copy the folder `CodeToReproduce` and be inside this folder.
* Edit lines 7 and 17 in `bashScript1toRun.sh` to be your account.
* Check line 10 in `bashScript1toRun.sh` is the crawl you are interested in.
* Check line 12 (where $n$ is specified) matches the number of wet files in the crawl you are interested in.
* If you change the crawl, you will also need to download the correct corresponding `wet.paths` file and copy this into the folder and remove the old `wet.paths` file. The one currently in there corresponds to the 202350 crawl. Just changing line 10 will NOT change the data you download and look at, just the file naming.
* Check line 15 (where $c$, the number of chunks, is specified) suits your requirements, and that $n/c$ is an integer. 
* Run `bashScript1toRun.sh` (files: `'wet.paths`, `read_wet.py`, and `BristolPostcodeLookup.csv` must be present in the folder).
``` bash
sbatch bashScript1toRun.sh
```
* This will run one job, then it will create $c$ further jobs. Once these are all complete, run
``` bash
sbatch CombineOutputs.sh
```
This will put all the $n$ csv files into one csv file called: `dfYYYYWW.csv` (where YYYYWW represents the crawl date. YYYYWW=203050 for the example code).
* I am not sure if/where to store the file for access to `df202350.csv` (it is 2.5GB in size).
* 

## Crawl all UK postcodes for 202350 crawl as above

**FilterPostcodeLookup:**
* Run `UK_PCfilter.ipynb` to create `UK_PostcodeLookup.csv`. Copy the output file into the folder `Filter202350couk_all`. (all UK postcode lookup file too large to host on GitHub). This is inside the same folder the BristolPostcodeLookup is generated in.

**Filter202350couk_all:**
## **HOW TO REPRODUCE. Uses only the code that is in Filter202350couk_all folder and the UK_PostcodeLookup.csv file which must be made as it cannot be hosted on GitHub**

* Copy this folder (Filter202350couk_all) into a workspace, e.g. HPC, which has enough RAM to run things and be inside this folder.
* Make sure you have `UK_PostcodeLookup.csv` in this folder. 
* Edit lines 7 and 17 in `bashScript1toRun.sh` to be your account.
* Check line 10 in `bashScript1toRun.sh` is the crawl you are interested in.
* Check line 12 (where $n$ is specified) matches the number of wet files in the crawl you are interested in.
* If you change the crawl, you will also need to download the correct corresponding `wet.paths` file and copy this into the folder and remove the old `wet.paths` file. The one currently in there corresponds to the 202350 crawl. Just changing line 10 will NOT change the data you download and look at, just the file naming.
* Check line 15 (where $c$, the number of chunks, is specified) suits your requirements, and that $n/c$ is an integer. 
* Run `bashScript1toRun.sh` (files: `'wet.paths`, `read_wet.py`, and `BristolPostcodeLookup.csv` must be present in the folder).
``` bash
sbatch bashScript1toRun.sh
```
* This will run one job, then it will create $c$ further jobs. Once these are all complete, run
``` bash
sbatch CombineOutputs.sh
```
This will put all the $n$ csv files into one csv file called: `dfYYYYWW.csv` (where YYYYWW represents the crawl date. YYYYWW=203050 for the example code).
* This is going to output a file that is super large.

# ALL 2021 crawls 
Here we want to go through all 9 of the crawls carried out by the CommonCrawl and filter out (for now) all *.co.uk* websites with 1+ postcodes in "English" language. All the data and scripts required are inside the `All2021Crawls` folder. 

**Pipeline to reproduce**:
* Copy the folder `All2021Crawls` into HPC workspace and go into the folder.
* 
