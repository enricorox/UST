#!/bin/bash
#SBATCH --job-name bcalm
#SBATCH --output bcalm.txt
#SBATCH --error bcalm.txt
#SBATCH --mail-user enrico.rossignolo@studenti.unipd.it
#SBATCH --mail-type ALL
#SBATCH
#SBATCH --time 10:00:00
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --partition allgroups
#SBATCH --mem 20G

set -e

PATH="/nfsd/bcb/bcbg/prog_9/bin/bcalm":$PATH

cd /nfsd/bcb/bcbg/prog_9/UST
mkdir -p "bcalm-test-dir"
s="SRR/SRR001665/SRR001665_1.fasta"

srun bcalm -max-memory 16000 -nb-cores 8 -kmer-size 31 -abundance-min 1 \
-in "$s" -all-abundance-counts -verbose 3
mv "SRR001665_1.unitigs.fa" "bcalm-test-dir/SRR001665_1.unitigs.t8.fa"

srun bcalm -max-memory 16000 -nb-cores 4 -kmer-size 31 -abundance-min 1 \
-in "$s" -all-abundance-counts -verbose 3
mv "SRR001665_1.unitigs.fa" "bcalm-test-dir/SRR001665_1.unitigs.t4.fa"
