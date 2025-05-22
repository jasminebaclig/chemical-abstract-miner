# Abstract Miner for Chemical Compounds (unfinished project)
R and Java code for extracting chemical compounds from PubMed abstracts of a given list of plant species.

Author: Jasmine Baclig

## Content
- input_files: folder containing various input files needed by the two R programs.
- misc_files: folder containing example code from the [G2PMineR project](https://github.com/BuerkiLabTeam/G2PMineR) (the inspiration/starting point for this project) and various other R scripts and CSV files that are not used by the current state of this project.
- output_files: folder containing files outputed by the R and Java programs.
- ChemicalMiner.java: Java code that is ran second in the workflow shown in the figure below.
- pmid_getter.R: R code that is ran first in the workflow shown in the figure below.
- post_java_analysis.R: R code that is ran third in the workflow shown in the figure below.
- slurm-batch-java.bash: sbatch script for running ChemicalMiner.java in the Borah computing cluster.
- slurm-batch-r.bash: sbatch script for running post_java_analysis.R in the Borah computing cluster.

## Current Workflow
![](Figures.png)

## How To Use
- Run pmid_getter.R Currently, this code takes in the input file "caribou_species_list.csv" and gets all the plant species listed in the column "Species name". The program will make a file called "pmid.txt" which contains a list of all the PMIDs of PubMed articles that come up when each plant species is looked up in PubMed.