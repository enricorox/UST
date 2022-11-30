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
NTHREAD=8
source /nfsd/bcb/bcbg/prog_9/anaconda3/bin/activate
echo "*** Reading input sequences..."
sequences=$(awk -F '-' '{print $1}' sequences.txt| grep -vE "#" sequences.txt)

cd SRR

for srr in $sequences; do
  cd "$srr"
  for s in "$srr"*.fasta; do
    echo "*** Running bcalm on $s..."
    [ ! -f "${s:0:-6}.unitigs.fa" ] || continue
    srun bcalm -max-memory 16000 -nb-cores $NTHREAD -kmer-size 31 -abundance-min 1 \
    -in "$s" -all-abundance-counts -verbose 3
  done
  cd ..
done

echo "Computed unitigs for all!"
