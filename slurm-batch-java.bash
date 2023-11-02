#!/bin/bash

#SBATCH -J chemical_miner
#SBATCH -p shortgpu
#SBATCH --gres=gpu:1
#SBATCH -o log_java.o

module load openjdk/18.0.2.1

javac ChemicalMiner.java
java ChemicalMiner