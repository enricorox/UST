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
#SBATCH --mem 8G

cd /nfsd/bcb/bcbg/prog_9/UST
#your working directory

set -e
NTHREAD=1
# PATH=/home/enrico/bio-bin/sratoolkit.3.0.0-ubuntu64/bin:$PATH
PATH="/nfsd/bcb/bcbg/prog_9/bin/sratoolkit.3.0.1-ubuntu64/bin":$PATH

sequences=$(awk -F '-' '{print $1}' sequences.txt| grep -vE "#" sequences.txt)

mkdir -p SRR && cd SRR

for s in $sequences; do
  echo
  echo "*** Converting $s..."
  [[ -f "${s}.fasta" || -f "${s}_1.fasta" || -f "${s}_2.fasta" ]] \
  || srun --ntasks 1 fasterq-dump --threads $NTHREAD --progress --fasta --split-files "$s" --outdir "$s" &
done

wait

echo "*** All converted!"
