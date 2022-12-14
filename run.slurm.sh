#!/bin/bash

# compute file size
dim(){
  stat -c %s "${1}"
}

# exit if errors occur
set -e
# expand globs
shopt -s nullglob


# ust & wc-actg & enc
PATH=$PWD:$PATH
# pxz
PATH="/home/enrico/bio-bin/pxz":$PATH
# current abs path
ROOT_DIR=$(realpath .)

# choose dataset (1: all kmers, 2: filter singletons)
a=2
# default inputs
heurs=("d" "sr" "s-l" "s+l" "s+c" "s-c" "s-aa" "s-ma" "s+aa" "s+ma" "e-c" "e+c" "e+l" "e-l" "e=a" "e=ao") # "e=aa" "e=ma" \
#"s+aa e=ma" "s+ma e=ma" "s-c s+l" "s-c e=ma" "e+c s-c" "e+l s-l" "s-ma e-ma")


sequences=("$ROOT_DIR"/SRR/SRR*/SRR*".a${a}.unitigs.fa")

# cli input
if [ -n "$1" ]; then sequences=("$1"); fi
if [ -n "$2" ]; then heurs=("$2"); fi

mkdir -p "results-a${a}" && cd "results-a${a}"

for bcalm_unitigs_abs in "${sequences[@]}"; do
  # derive strings
  bcalm_unitigs=$(basename "$bcalm_unitigs_abs")
  seq_name=${bcalm_unitigs:0:-14} # remove ".ax.unitigs.fa" from "SRR001665_2.unitigs.fa"
  seq_dir=$(echo "$seq_name" | awk -F '_' '{printf $1};') # remove _1 or _2 if any

  results_csv="${ROOT_DIR}/${seq_name}.a${a}.csv"
  rm -rf "$results_csv"

  echo "*** Processing $bcalm_unitigs ($seq_dir:$seq_name) >> $results_csv"

  mkdir -p "$seq_name" && cd "$seq_name"

  ## reset outputs vars
  # data
  headers="${seq_name},"
  infile_empty_header_sizes="infile_empty_header_sizes,"
  n_kmers="n_kmers,"
  ust_c_lb="ust_c_lb,"
  ust_c="ust_c,"
  outfile_fa_sizes="outfile_fa_sizes,"
  outfile_fa_zipped_sizes="outfile_fa_zipped_sizes,"
  outfile_counts_sizes="outfile_counts_sizes,"
  outfile_counts_zipped_sizes="outfile_counts_zipped_sizes,"
  outfile_counts_enc1_sizes="outfile_counts_enc1_sizes,"
  outfile_counts_enc1_zipped_sizes="outfile_counts_enc1_zipped_sizes,"
  outfile_counts_enc2_sizes="outfile_counts_enc2_sizes,"
  outfile_counts_enc2_zipped_sizes="outfile_counts_enc2_zipped_sizes,"
  outfile_counts_enc3_sizes="outfile_counts_enc3_sizes,"
  outfile_counts_enc3_zipped_sizes="outfile_counts_enc3_zipped_sizes,"
  # ratios (to compute in worksheet)
  gap="gap (lower is better),"
  ratio_fasta_in_out="ratio_fasta_in_out,"
  ratio_counts_ust_out="ratio_counts_ust_out,"
  ratio_counts_ust_enc1="ratio_counts_ust_enc1,"
  ratio_counts_ust_enc2="ratio_counts_ust_enc2,"
  ratio_counts_ust_enc3="ratio_counts_ust_enc3,"

  ## file names
  infile="${ROOT_DIR}/SRR/${seq_dir}/${seq_name}.fasta"
  outfile_stat="${bcalm_unitigs}.stats.txt"
  outfile_fa="${bcalm_unitigs}.ust.fa"
  outfile_fa_zipped="${outfile_fa}.xz"
  outfile_counts="${bcalm_unitigs}.ust.counts"
  outfile_counts_zipped="${outfile_counts}.xz"
  outfile_counts_enc1="${outfile_counts}.enc1"
  outfile_counts_enc2="${outfile_counts}.enc2"
  outfile_counts_enc3="${outfile_counts}.enc3"
  outfile_counts_enc1_zipped="${outfile_counts_enc1}.xz"
  outfile_counts_enc2_zipped="${outfile_counts_enc2}.xz"
  outfile_counts_enc3_zipped="${outfile_counts_enc3}.xz"

   # same output for all sequences
  echo "Reading infile=$infile"
  infile_empty_header_size="$("wc-actg" "$infile" "-h=1")"

  for heur in "${heurs[@]}"; do
    echo "** heuristic: ${heur}"

    mkdir -p "$heur" && cd "$heur"

    # shellcheck disable=SC2086
    [ -f "$outfile_fa" ] ||  ust -k 31 -a 1 -h $heur -i "$bcalm_unitigs_abs"
    echo "* Compressing ${outfile_fa}..."
    [ -f "$outfile_fa_zipped" ] ||  pxz --extreme -k -f "$outfile_fa"
    echo "* Compressing ${outfile_counts}..."
    [ -f "$outfile_counts_zipped" ] ||  pxz --extreme -k -f "$outfile_counts"
    echo "* Encoding ${outfile_counts}..."
    [[ -f "${outfile_counts_enc1}" ]] || enc "$outfile_counts" 1 2 3 # avoid multiple reads of the same file
    echo "* Compressing ${outfile_counts_enc1}..."
    [ -f "$outfile_counts_enc1_zipped" ] ||  pxz --extreme -k -f "$outfile_counts_enc1"
    echo "* Compressing ${outfile_counts_enc2}..."
    [ -f "$outfile_counts_enc2_zipped" ] ||  pxz --extreme -k -f "$outfile_counts_enc2"
    echo "* Compressing ${outfile_counts_enc3}..."
    [ -f "$outfile_counts_enc3_zipped" ] ||  pxz --extreme -k -f "$outfile_counts_enc3"

    headers+="${heur},"
    infile_empty_header_sizes+="${infile_empty_header_size},"
    n_kmers+="$(grep "N_KMER" "$outfile_stat" | awk -F '=' '{print $2;}'),"
    ust_c_lb+="$(grep "C_LB" "$outfile_stat" | awk -F '=' '{print $2;}'),"
    ust_c+="$(grep "C_USTITCH_twoway" "$outfile_stat" | awk -F '=' '{print $2;}'),"
    outfile_fa_sizes+="$(dim "$outfile_fa"),"
    outfile_fa_zipped_sizes+="$(dim "$outfile_fa_zipped"),"
    outfile_counts_sizes+="$(dim "$outfile_counts"),"
    outfile_counts_zipped_sizes+="$(dim "$outfile_counts_zipped"),"
    outfile_counts_enc1_sizes+="$(dim "$outfile_counts_enc1"),"
    outfile_counts_enc1_zipped_sizes+="$(dim "$outfile_counts_enc1_zipped"),"
    outfile_counts_enc2_sizes+="$(dim "$outfile_counts_enc2"),"
    outfile_counts_enc2_zipped_sizes+="$(dim "$outfile_counts_enc2_zipped"),"
    outfile_counts_enc3_sizes+="$(dim "$outfile_counts_enc3"),"
    outfile_counts_enc3_zipped_sizes+="$(dim "$outfile_counts_enc3_zipped"),"

    cd ..
  done
  # save results_csv
  printf "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n,\n%s\n%s\n%s\n%s\n%s\n%s\n,\n,\n" \
  "$headers" "$infile_empty_header_sizes" "$n_kmers" "$ust_c_lb" "$ust_c" \
  "$outfile_fa_sizes" "$outfile_fa_zipped_sizes" "$outfile_counts_sizes" "$outfile_counts_zipped_sizes" \
  "$outfile_counts_enc1_sizes" "$outfile_counts_enc1_zipped_sizes" \
  "$outfile_counts_enc2_sizes" "$outfile_counts_enc2_zipped_sizes" \
  "$outfile_counts_enc3_sizes" "$outfile_counts_enc3_zipped_sizes" \
  "$gap" "$ratio_fasta_in_out" "$ratio_counts_ust_out" \
  "$ratio_counts_ust_enc1" "$ratio_counts_ust_enc2" "$ratio_counts_ust_enc3" >> "$results_csv"
  cd ..
done

cd ..

# all results in one file
cat ./*.csv > results_all.csv
