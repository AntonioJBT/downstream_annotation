#!/usr/bin/env bash

###########################
# Antonio J Berlanga-Taylor
# July 2018
# Unix commands to pre-process files for GAT input
# Usage:
# bash run_GAT.sh


# GAT:
# http://gat.readthedocs.io/en/latest/tutorialIntervalOverlap.html

# Prepare files with eg:
#./query_biomart.R -I airwave-illumina_core_non_imp-all_chrs-CPMG_high_res_log-plasma.MxEQTL.tsv --attribs attributes.txt --filters filters.txt
#./biomart_to_bed.R -I airwave-illumina_core_non_imp-all_chrs-CPMG_high_res_log-plasma.MxEQTL.biomart.tsv --chr chr_name --start chrom_start --end chrom_end --annot refsnp_id --interval 10000
#dbsnp_to_bed.sh
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
segments=$1
# aka tracks or intervals of interest
annotations=$2
# intervals to test against (are tracks enriched for these annotations?)
workspace=$3
# the universe/background to sample from
samples=$4
outfile=$5
ANNOTATIONS_LABEL=all_annotations
###########################



#########
# Files are in:


# Run gat:
gat-run.py \
   --segments=${segments} \
   --annotations=${annotations} \
   --workspace=${workspace} \
   --ignore-segment-tracks \
   --num-samples=${samples} \
   --annotations-label=${ANNOTATIONS_LABEL} \
   --log=gat.log > ${outfile}
#########



#########
# Test overlap of differentially expressed genes
# Did this using Fisher's test in R package, see script gene_list_overlap.R
#########


#########
# Unix commands to get reQTLs eGenes and eSNPs for overlap testing for overlap R script. These are output as FDR 5% already:
#cat cis_tx_fdr5_reQTLs_annot_all_Tx_joint_cis.txt | cut -f11 > eGenes_cis_tx_fdr5_reQTLs_annot_all_Tx_joint_cis.txt
#cat cis_tx_fdr5_reQTLs_annot_all_Tx_joint_cis.txt | cut -f2 > eSNPs_cis_tx_fdr5_reQTLs_annot_all_Tx_joint_cis.txt
#cat cis_tx_fdr5_reQTLs_annot_all_Tx_joint_trans.txt | cut -f2 > eSNPs_cis_tx_fdr5_reQTLs_annot_all_Tx_joint_trans.txt
#cat cis_tx_fdr5_reQTLs_annot_all_Tx_joint_trans.txt | cut -f11 > eGenes_cis_tx_fdr5_reQTLs_annot_all_Tx_joint_trans.txt
#########