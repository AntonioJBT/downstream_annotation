#!/usr/bin/env Rscript

######################
# R script to run with docopt for command line options:
'
biomart_to_bed.R
===================

Author: Antonio J Berlanga-Taylor
Date: July 2018


Purpose
=======

Convert a biomart SNP output into bed format (to use as input for GAT for example).
Bed:
https://www.ensembl.org/info/website/upload/bed.html

Usage and options
=================

To run, type:
    biomart_to_bed.R -I <INPUT_FILE> --chr <INT> --start <INT> --end <INT> [options]

Usage: biomart_to_bed.R (-I <INPUT_FILE>) (--chr <INT>) (--start <INT>) (--end <INT>)
       biomart_to_bed.R [options]
       biomart_to_bed.R [-h | --help]

Options:
  -I <INPUT_FILE>                 Input file name
  -O <OUTPUT_FILE>                Output file name
  --chr <STRING>                  Column name with chr_name
  --start <STRING>                Column name with chr_start
  --end <STRING>                  Column name with chr_end
  --annot <STRING>                Column name with an annotation
  --interval <INT>                Create chr interval, substitutes coordinates given
  --session=<R_SESSION_NAME>      R session name if to be saved
  -h --help                       Show this screen

Input:

    A tab separated file with headers as output from eg query_biomart.R
    Specify the columns with chr_name, chrom_start and chrom_end.
    Optionally specify the name (annotation) column. Other fields are discarded.
    chr_name is expected to not have chr, which is added.

Output:

    A tab separated bed-formatted file without headers and chr_name, chr_start,
    chr_end in the first three columns and possibly a name/annotation in column 4.


Requirements:

    library(docopt)
    library(data.table)

Documentation
=============

    For more information see:

    |url|
' -> doc

# Load docopt:
library(docopt, quietly = TRUE)
# Retrieve the command-line arguments:
args <- docopt(doc)

# Print to screen:
str(args)
# Arguments to read:
chr_name <- as.character(args[['--chr']])
chr_start <- as.character(args[['--start']])
chr_end <- as.character(args[['--end']])
annot <- as.character(args[['--annot']])
interval <- as.integer(args[['--interval']])
######################

######################
# This function allows other R scripts to obtain the path to a script directory
# (ie where this script lives). Useful when using source('some_script.R')
# without having to pre-specify the location of where that script is.
# This is taken directly from:
# How to source another_file.R from within your R script · molgenis/molgenis-pipelines Wiki
# https://github.com/molgenis/molgenis-pipelines/wiki/How-to-source-another_file.R-from-within-your-R-script
# Couldn't find a licence at the time (12 June 2018)
LocationOfThisScript = function() # Function LocationOfThisScript returns the location of this .R script (may be needed to source other files in same dir)
{   
    this.file = NULL
    # This file may be 'sourced' 
    for (i in -(1:sys.nframe())) {
        if (identical(sys.function(i), base::source)) this.file = (normalizePath(sys.frame(i)$ofile))
    }
    
    if (!is.null(this.file)) return(dirname(this.file))
    
    # But it may also be called from the command line
    cmd.args = commandArgs(trailingOnly = FALSE) 
    cmd.args.trailing = commandArgs(trailingOnly = TRUE)
    cmd.args = cmd.args[seq.int(from=1, length.out=length(cmd.args) - length(cmd.args.trailing))]
    res = gsub("^(?:--file=(.*)|.*)$", "\\1", cmd.args)
    
    # If multiple --file arguments are given, R uses the last one
    res = tail(res[res != ""], 1)
    if (0 < length(res)) return(dirname(res))
    
    # Both are not the case. Maybe we are in an R GUI?
    return(NULL)
}
Rscripts_dir <- LocationOfThisScript()
print('Location where this script lives:')
Rscripts_dir
# R scripts sourced with source() have to be in the same directory as this one
# (or the path constructed appropriately with file.path)
######################

######################
# Import libraries
# source('http://bioconductor.org/biocLite.R')
# biocLite()
library(data.table)
# source functions from a different R script:
# source(file.path(Rscripts_dir, 'moveme.R')) #, chdir = TRUE)
######################

######################
##########
# Read files, this is with data.table:
if (is.null(args[['-I']]) == FALSE &
    is.null(args[['--chr']]) == FALSE &
    is.null(args[['--start']]) == FALSE &
    is.null(args[['--end']]) == FALSE) {
  input_name <- as.character(args[['-I']])
  input_data <- as.data.frame(fread(input_name,
                                    # select = c(chr_name, chr_start, chr_end),
                                    sep = '\t',
                                    header = TRUE,
                                    stringsAsFactors = FALSE))
} else {
  # Stop if arguments not given:
  print('You need to provide an input file, chr_name, chr_start and chr_end column positions.')
  stopifnot(!is.null(args[['-I']]) == TRUE)
}

print('File being used: ')
print(input_name)
##########

##########
if (is.null(args[['--annot']]) == FALSE) {
  cols_keep <- c(chr_name, chr_start, chr_end, annot)
} else{
  print('Annotation column not provided.')
  cols_keep <- c(chr_name, chr_start, chr_end)
}
##########  

##########
# Set output file names:
suffix <- 'bed'
if (is.null(args[['-O']])) {
  stopifnot(!is.null(args[['-I']]))
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
# Create chr string to add to chr_name (which should only be numbers, X, etc.):
input_data$chr <- 'chr'
input_data$chr_name <- paste(input_data$chr, input_data$chr_name, sep = '')
input_data$chr <- NULL
input_data <- input_data[, cols_keep]

# If interval given add and substract:
if (is.null(args[['--interval']]) == FALSE) {
  print(sprintf('Adding interval to chr_start and chr_end, plus/minus: %s', interval))
  input_data[, chr_start] <- apply(as.matrix(input_data[, chr_start]), 2, function(x) x - interval)
  input_data[, chr_end] <- apply(as.matrix(input_data[, chr_end]), 2, function(x) x + interval)
} else{
  print('Interval not created.')
}

# TO DO: sanity check intervals, convert negatives to 0, test GAT interval merging for positions where starts
# are highers than ends
print('Output file first few lines:')
head(input_data)
######################


######################
# Save file:
fwrite(input_data,
       output_file_name,
       sep = '\t',
       na = 'NA',
       col.names = FALSE,
       row.names = FALSE,
       quote = FALSE)
######################

######################
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
