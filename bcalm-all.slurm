#!/bin/bash
#SBATCH --job-name fasterq
#SBATCH --output output_fasterq.txt
#SBATCH --error errors_fasterq.txt
#SBATCH --mail-user enrico.rossignolo@studenti.unipd.it
#SBATCH --mail-type ALL
#SBATCH
#SBATCH --time 60:00
#SBATCH --ntasks 20
#SBATCH --partition allgroups
#SBATCH --mem 80G

set -e
echo "*** Reading input sequences..."
sequences=$(awk -F '-' '{print $1}' sequences.txt| grep -vE "#" sequences.txt)

cd SRR

for srr in $sequences; do
  cd "$srr"
  for s in "$srr"*.fasta; do
    echo "*** Running bcalm on $s..."
    [ ! -f "${s:0:-6}.unitigs.fa" ] || continue
    srun --ntasks 1 bcalm -nb-cores 4 -kmer-size 31 -abundance-min 1 \
    -in "$s" -all-abundance-counts -verbose 3 &
  done
  cd ..
done

wait

echo "Computed unitigs for all!"
