#!/usr/bin/env bash
# Antonio Berlanga-Taylor
# July 2018
# Process dbsnp file for gat
# Usage:
# bash dbsnp_to_bed.sh 

###########################
# Set bash script options

# exit when a command fails
set -o errexit

# exit if any pipe commands fail
set -o pipefail

# exit when your script tries to use undeclared variables
set -o nounset

# trace what gets executed
set -o xtrace

set -o errtrace
###########################


###########################
infile=$1
interval=$2
outfile=${infile}.noheader
outfile2=${infile}.chrpos
outfile3=${infile}.minus
outfile4=${infile}.plus
outfile5=${infile}.delim
outfile6=${infile}.${interval}.bed
###########################

###########################
#Downloaded chr positions from dbSNP, which lifted to dbSNP147:
#http://www.ncbi.nlm.nih.gov/projects/SNP/dbSNP.cgi?list=rslist

# Delete first line:
#sed '1d' ${infile} > ${outfile}

# Keep only chr pos:
cat ${infile} | cut -d ' ' -f2,3 > ${outfile2}
#head snp146Common_MatrixEQTL_snp_pos.txt | cut -d ' ' -f2,3 > snp146Common_MatrixEQTL_snp_pos.txt2

# awk add new column with minus 1 kb, note no header here:
cat ${outfile2} | awk -v OFS=" " -v var=${interval} '{print $0,($2-var)}' > ${outfile3}
#head snp146Common_MatrixEQTL_snp_pos.txt2 | awk -v OFS=" " '{print $0,($2-10000)}' > snp146Common_MatrixEQTL_snp_pos.txt3

# awk add new column with plus 1 kb, note no header here:
cat ${outfile3} | awk -v OFS=" " -v var=${interval} '{print $0,($2+var)}' > ${outfile4}
#head snp146Common_MatrixEQTL_snp_pos.txt3 | awk -v OFS=" " '{print $0,($2+10000)}' > snp146Common_MatrixEQTL_snp_pos.txt4

# Keep only chr, chr start and chr end columns for gat:
cat ${outfile4} | cut -d ' ' -f1,3,4 > ${outfile5}
#head snp146Common_MatrixEQTL_snp_pos.txt4 | cut -d ' ' -f1,3,4 > snp146Common_MatrixEQTL_snp_pos.txt5

# Change sep to tab:
cat ${outfile5} | tr ' ' '\t' > ${outfile6}
#head snp146Common_MatrixEQTL_snp_pos.txt5 | tr ' ' '\t' > snp146Common_MatrixEQTL_snp_pos.txt6

# Check:
cat ${outfile6} | wc -l

# Delete intermediate files:
rm -f ${outfile} ${outfile2} ${outfile3} ${outfile4} ${outfile5}


# TO DO: sanity check intervals, convert negatives to 0, test GAT interval merging for positions where starts
# are highers than ends

echo 'Done'
###########################