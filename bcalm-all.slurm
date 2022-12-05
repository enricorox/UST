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
abundance_min=2
PATH="/nfsd/bcb/bcbg/prog_9/bin/bcalm":$PATH

echo "*** Reading input sequences..."
sequences=$(awk -F '-' '{print $1}' sequences.txt| grep -vE "#" sequences.txt)

cd SRR

for srr in $sequences; do
  cd "$srr"
  for s in "$srr"*.fasta; do
    outfile_base="${s:0:-6}.a${abundance_min}"
    outfile="${outfile_base}.unitigs.fa"
    echo "*** Running bcalm with NTHREAD=$NTHREAD, abundance_min=$abundance_min, s=$s..."
    [ ! -f "$outfile" ] || continue
    srun bcalm -max-memory 16000 -nb-cores $NTHREAD -kmer-size 31 -abundance-min $abundance_min \
    -in "$s" -all-abundance-counts -out "$outfile"
  done
  cd ..
done

echo "Computed unitigs for all!"
