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
- Run pmid_getter.R. Currently, this code takes in the input file "caribou_species_list.csv" and gets all the plant species listed in the column "Species name". The program will make a file called "pmid.txt" which contains a list of all the PMIDs of PubMed articles that come up when each plant species is looked up in PubMed.
- Compile and run ChemicalMiner.java. This code takes in the list of PMIDs in "pmid.txt" as its input and uses tmChem to mine each corresponding abstract for chemical names. The program then creates the output file "chemical.tsv" which contains in each row a plant species, a chemical name that could be associated with it, how many abstracts mentioned the chemical name, and a list of PMIDs of these abstracts.
  - Alternatively, this code can be run in a computing cluster using slurm-batch-java.bash.
  - Lines of code for running tmChem was taken from ["Beyond accuracy: creating interoperable and scalable text-mining web services"](https://academic.oup.com/bioinformatics/article/32/12/1907/1743015).
- Run post_java_analysis.R in a computing cluster using slurm-batch-r.bash. This uses "chemical.tsv" as its input file and starts to breakdown its content. Currently, this program creates the following files:
  - caribou_elements.csv: any instances of an element from the periodic table in "chemical.tsv".
  - caribou_amino_acids.csv: any instances of an amino acid in "chemical.tsv"
  - caribou_with_and.csv: