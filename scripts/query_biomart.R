#!/usr/bin/env Rscript

######################
# R script to run with docopt for command line options:
"
query_biomart.R
=================

Author: Antonio Berlanga-Taylor
Date: July 2018


Purpose
=======

This is a simple wrapper to query Biomart. Options not available are the default ones.


Usage and options
=================

To run, type:
query_biomart.R -I <INPUT_FILE> --attribs <FILE> --filters <FILE> [options]

Usage: query_biomart.R (-I <INPUT_FILE> | --all) (--attribs <FILE>) (--filters <FILE>)
       query_biomart.R [options]
       query_biomart.R [-h | --help]

Options:
  -I <INPUT_FILE>                 Input file name, pass a tab separated data frame with values to query
  --all                           Specify this option to get all attributes based on filter instead of passing a file (slow)
  --col <INT>                     Column to read containing SNPs, gene names, etc. [default: 1]
  --attribs <FILE>                File as data frame with attributes in column 1
  --filters <FILE>                File as data frame with filters in column 1
  -O <OUTPUT_FILE>                Output file name (.tsv suffix is added)
  --biomart <MART>                Specify mart [default: ENSEMBL_MART_SNP]
  --dataset <SEPCIES>             Specify species [default: hsapiens_snp]
  --host <HOST>                   Specify page to access [default: www.ensembl.org]
  --list                          Print what is available (long print screen usually)
  --session <R_SESSION_NAME>      R session name if to be saved
  -h --help                       Show this screen

Input:

Input, attribs and filters files need to be tab separated with headers. These are read with data.table and 
stringsAsFactors = FALSE.
Input is anything Biomart accepts, usually a list of SNPs, gene names, etc. Specify the column to read.
Attributes (to retrieve from biomart query) and filters (to match input values against in query)
must be provided as separate files in a single column with headers.

Output:

The biomart query in a tab separated file saved to disk.

Requirements:

library(docopt)
library(data.table)
library(biomaRt)

Documentation
=============

For more information see:

|url|
" -> doc

# Load docopt:
library(docopt, quietly = TRUE)
# Retrieve the command-line arguments:
args <- docopt(doc)

# Print to screen:
str(args)
# Within the script specify options as:
# args[['--session']]
# args $ `-I` == TRUE
# Arguments:
biomart <- as.character(args[['--biomart']])
dataset <- as.character(args[['--dataset']])
host <- as.character(args[['--host']])
list_marts <- as.logical(args[['--list']])
col_keep <- as.integer(args[['--col']])
######################

######################
# Import libraries
# source('http://bioconductor.org/biocLite.R')
# biocLite(biomaRt)
library(data.table)
library(biomaRt)
# source functions from a different R script:
#source(file.path(Rscripts_dir, 'moveme.R')) #, chdir = TRUE)
######################

######################
# Query biomaRt:
# https://www.bioconductor.org/packages/release/bioc/vignettes/biomaRt/inst/doc/biomaRt.html
# Set the source (database) and species to use:
# biomart <- "ENSEMBL_MART_SNP"
# dataset <- 'hsapiens_snp'
# host <- 'www.ensembl.org'
# Example query: get SNPs
# snp_mart = useMart("ENSEMBL_MART_SNP", dataset="hsapiens_snp")
get_mart <- useMart(biomart = biomart,
                    dataset = dataset,
                    host = host)
######################

######################
# Print the datasets available:
# Needs to be after useMart() and before getBM() to avoid too much scripting
# TO DO: stop and exit at end of this
if (args[['--list']] == TRUE) {
  print('Change what is displayed with biomart and dataset options.')
  print('Marts available: ')
  print(
    # Check what's available:
    listMarts()
  )
  print(sprintf('Species available for %s: ', biomart))
  print(
    # See what datasets (each species is a dataset) are available for that mart:
    listDatasets(get_mart)
  )
  print(sprintf('Filters available for %s: ', biomart))
  print(listFilters(get_mart))
  print(sprintf('Attributes available for %s: ', biomart))
  print(listAttributes(get_mart))
  print(attributePages(get_mart))
}
######################

######################
##########
# Read files, this is with data.table:
if (is.null(args[['-I']]) == FALSE &
    args[['--all']] == FALSE) {
  input_name <- as.character(args[['-I']])
  input_data <- as.data.frame(fread(input_name,
                                    select = col_keep,
                                    sep = '\t',
                                    header = TRUE,
                                    stringsAsFactors = FALSE
  )
  )
  mart_values <- as.vector(as.character(input_data[, col_keep]))
  print('File being used: ')
  print(input_name)

  } else if (is.null(args[['-I']]) == TRUE &
             args[['--all']] == TRUE) {
    print(sprintf('Getting all values available for %s: ', biomart))
    input_name <- sprintf('all_values_%s_%s', biomart, dataset)
    mart_values <- ''

    } else {
  # Stop if arguments not given:
  print('You need to provide an input file or pass the --all option.
        Files have to be tab separated with headers.')
  stopifnot(!is.null(args[['-I']]) == FALSE
            & !args[['--all']] == TRUE
            )
  }
##########

##########
# Read the attributes file:
if (is.null(args[['--attribs']]) == FALSE) {
  attribs_name <- as.character(args[['--attribs']])
  mart_attribs <- as.data.frame(fread(attribs_name,
                                    select = 1,
                                    sep = '\t',
                                    header = TRUE,
                                    stringsAsFactors = FALSE
  )
  )
  mart_attribs <- as.vector(as.character(mart_attribs[, 1]))
} else {
  # Stop if arguments not given:
  print('You need to provide an attributes file (single column with header).')
  stopifnot(!is.null(args[['--attribs']]) == TRUE)
}
print('File being used for attributes: ')
print(attribs_name)
##########

##########
# Read the filters file:
if (is.null(args[['--filters']]) == FALSE) {
  filters_name <- as.character(args[['--filters']])
  mart_filters <- as.data.frame(fread(filters_name,
                                      select = 1,
                                      sep = '\t',
                                      header = TRUE,
                                      stringsAsFactors = FALSE
  )
  )
  mart_filters <- as.vector(as.character(mart_filters[, 1]))
} else {
  # Stop if arguments not given:
  print('You need to provide an filters file (single column with header).')
  stopifnot(!is.null(args[['--filters']]) == TRUE)
}
print('File being used for filters: ')
print(filters_name)
##########

##########
# Set output file names:
suffix <- 'biomart.tsv'
if (is.null(args[['-O']])) {
  # stopifnot(!is.null(args[['-I']]))
  print('Output file name not given. Using:')
  # Split infile name at the last '.':
  input_name <- strsplit(input_name, "[.]\\s*(?=[^.]+$)", perl = TRUE)[[1]][1]
  output_file_name <- sprintf('%s.%s', input_name, suffix)
  print(output_file_name)
} else {
  output_file_name <- as.character(args[['-O']])
  # output_file_name <- 'testing'
  output_file_name <- sprintf('%s.%s', output_file_name, suffix)
  print(sprintf('Output file names: %s', output_file_name))
}
##########
######################

######################
# The getBM() function is the main query tool, arguments are:
# attributes: vector of attributes to retrieve (ouptut)
# filters: vector as input to the query
# values: vector of values that correspond to the filter

# mart_values <- c("rs16828074", "rs17232800")
# mart_attribs <- c('refsnp_id', 'chr_name', 'chrom_start', 'chrom_end')
# mart_filters <- c("snp_filter")
print(mart_attribs)
print(mart_filters)
print(mart_values)

query_mart <- getBM(attributes = mart_attribs,
                    filters = mart_filters,
                    values = list(mart_values),
                    mart = get_mart
                    )

head(query_mart)
tail(query_mart)
dim(query_mart)
# str(query_mart)
####################

####################
# Write results to disk:
fwrite(query_mart,
       sprintf('%s', output_file_name),
       sep = '\t',
       na = 'NA',
       col.names = TRUE,
       row.names = FALSE,
       quote = FALSE)
####################

####################
# The end:
# Filename to save current R session, data and objects at the end:
if (is.null(args[['--session']]) == FALSE) {
  save_session <- as.character(args[['--session']]) #args $ `--session`
  R_session_saved_image <- sprintf('R_session_saved_image_%s.RData', save_session)
  print(sprintf('Saving an R session image as: %s', R_session_saved_image))
  save.image(file = R_session_saved_image, compress = 'gzip')
} else {
  print('Not saving an R session image, this is the default. Specify the --session option otherwise')
}

print('Finished successfully.')
sessionInfo()
q()
######################