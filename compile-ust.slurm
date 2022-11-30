#!/bin/bash
#SBATCH --job-name compile-ust
#SBATCH --output compile-ust.txt
#SBATCH --error compile-ust.txt
#SBATCH --mail-user enrico.rossignolo@studenti.unipd.it
#SBATCH --mail-type ALL
#SBATCH
#SBATCH --time 10:00:00
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --partition allgroups
#SBATCH --mem 4G

set -e

cd "/nfsd/bcb/bcbg/prog_9/UST"
make
