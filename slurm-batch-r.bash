#!/bin/bash

#SBATCH -J cm_1_5000
#SBATCH -p bsudfq
#SBATCH -N 1
#SBACTH -n 48
#SBATCH -o log_cm_1_5000.o

module load borah-misc r/4.2.2

Rscript post_java_analysis.R