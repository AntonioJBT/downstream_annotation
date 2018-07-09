#!/usr/bin/env python3
'''
prep_gat.py
================

:Author: Antonio Berlanga-Taylor
:Release: |version|
:Date: |today|


Purpose
=======

Prepare file for GAT from matrixEQTL output


Usage and options
=================

Usage:
       prep_gat.py (-I FILE) [options]
       prep_gat.py [--kb-add]
       prep_gat.py [-h | --help] [-V | --version] [-f --force] [-L | --log]

Options:
    -I FILE             Input file name
    --kb-add            Number of kilobases to add to SNP position [default: 5]
    -h --help           Show this screen

Input and output:

    MatrixEQTL output, reads in with pandas, cuts the first column (SNPs)
    and adds chr, bp, SNP minus kb, SNP plus kb.
    Output is in bed format with no header and chr, start, end, SNP
    Outfile has the suffix .snp.bed


'''
##############
# Get all the modules needed
import docopt
import os
import sys
import pandas

def process_SNPnexus(infile):
    'Get SNP column fro QTL output and add string needed for dbsnp input to SNPNexus'
    df = pandas.read_table(infile)
    #df_SNPs = df.loc[:, 'SNP']
    df['string'] = 'dbsnp'
    df.to_csv('{}.snpnexus.txt'.format(infile),
              columns = ['string', 'SNP'],
              header = False,
              index = False,
              sep = '\t',
              )
    return

def main():
    ''' with docopt main() expects a dictionary with arguments from docopt()
    docopt will automatically check your docstrings for usage, set -h, etc.
    '''
    options = docopt.docopt(__doc__)
    try:
        if options['-I']:
            infile = str(options['-I']).strip('[]').strip("''")
            process_SNPnexus(infile)

        else:
            print(''' Script errored.
                      Exiting...
                  ''')
            sys.exit()

    # Handle exceptions:
    except docopt.DocoptExit:
        raise
##############


##############
# Finish and exit with docopt arguments:
if __name__ == '__main__':
    sys.exit(main())
##############
