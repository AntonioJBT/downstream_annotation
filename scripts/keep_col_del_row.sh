#!/usr/bin/env bash

# Script to keep arbitrary column and delete arbitrary rows. 
# Run as e.g.:
#cat matched_all.clean-base.A-transpose-NA-NA.MxEQTL.tsv | cut -f1 | sed '1d' > QTL_1DNMR_SNPs.txt
#bash matrixEQTL2SNPsDepict.sh matched_all.clean-base.A-transpose-NA-NA.MxEQTL.tsv 1 1
# giving col_1_rows_del_1_matched_all.clean-base.A-transpose-NA-NA.MxEQTL.tsv


###########################
# Some references to check:
# https://kvz.io/blog/2013/11/21/bash-best-practices/
# http://jvns.ca/blog/2017/03/26/bash-quirks/
# Bash traps:
# http://aplawrence.com/Basics/trapping_errors.html
# https://stelfox.net/blog/2013/11/fail-fast-in-bash-scripts/
###########################

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
# Variables to substitute:
infile=$1
col_to_keep=$2
num_rows_del=$3
#outfile=$2
###########################

###########################
# Run command:
cat ${infile} | cut -f${col_to_keep} | sed "${num_rows_del}d" > col_${col_to_keep}_rows_del_${num_rows_del}_${infile}
echo 'Done'
###########################
