####################
# XGR Downstream analysis
# Hai's package
# 19 May 2016
####################

####################
# See:
# https://github.com/hfang-bristol/XGR
# https://cran.r-project.org/web/packages/XGR/XGR.pdf
# http://galahad.well.ox.ac.uk:3020/XGR_vignettes.html
# http://galahad.well.ox.ac.uk:3020/enricher/genes
####################

####################
options(echo = TRUE)
##Set working directory and file locations and names of required inputs:

# Working directory:
# setwd('/ifs/projects/proj043/analysis.dir/eqtl_analysis.dir/')
# setwd('/Users/antoniob/Desktop/BEST_D.DIR/scripts_to_upload/GAT_backgrounds_3/')
setwd('~/Documents/quickstart_projects/chronic_inflammation_Airwave.p_q/results/annotation_QTL_core_illumina/QTL_1DNMR_results/')

#Direct output to file as well as printing to screen (plots aren't redirected though, each done separately). 
#Input is not echoed to the output file either.

output_file <- file(paste("R_session_output_",Sys.Date(),".txt", sep=""))
output_file
sink(output_file, append=TRUE, split=TRUE, type = c("output", "message"))

#If the script can run from end to end, use source() with echo to execute and save all input 
#to the output file (and not truncate 150+ character lines):
#source(script_file, echo=TRUE, max.deparse.length=10000)

#Record start of session and locations:
Sys.time()
print(paste('Working directory :', getwd()))
getwd()

##TO DO extract parameters:

# Re-load a previous R session, data and objects:
# load('R_session_saved_image_XGR.RData', verbose=T)

# Filename to save current R session, data and objects at the end:
R_session_saved_image <- paste('R_session_saved_image_XGR','.RData', sep='')
R_session_saved_image
####################

####################
# Libraries:
library(XGR)
library(ggplot2)
library(data.table)
# Get additional functions needed:
####################

####################
# Run with cmd arguments:
args <- commandArgs(trailingOnly = TRUE)

# Gene or SNP files:
hits_file <- as.character(args[1])
# hits_file <- 'col_1_rows_del_1_matched_all.clean-base.A-transpose-NA-NA.MxEQTL.tsv'
outfile_name <- strsplit(hits_file, '[.]')
outfile_name <- outfile_name[[1]][1]

column_of_interest <- as.integer(args[2])
# column_of_interest <- 1

background_file <- as.character(args[3])
# background_file <- 'col_1_rows_del_1_matched_all.clean-base.A-transpose.matrixQTL.geno'

# To test enrichment against a particular set
# annotation_file <- as.character(args[3])
# annotation_file <- 'VD_exp_genes_Ramagopalan_2010.txt'

# Ontology term to test against:
# ontology_term <- as.character(args[3])
####################

####################
# Read data:
hits_data <- fread(hits_file, sep = '\t', header = TRUE, stringsAsFactors = FALSE, strip.white = TRUE)
# hits_data <- read.csv(hits_file, sep = '\t', header = FALSE, stringsAsFactors = FALSE, strip.white = TRUE)
hits_data <- as.data.frame(hits_data)
hits_data <- as.vector(hits_data[, column_of_interest])
class(hits_data)
str(hits_data)
head(hits_data)
length(hits_data)
length(unique(hits_data))

background_data <- read.csv(background_file, sep = '\t', header = FALSE, stringsAsFactors = FALSE, strip.white = TRUE)
background_data <- as.vector(background_data$V1)
str(background_data)

# TO DO/clean up
# annotation_data <- read.csv(annotation_file, sep = '\t', header = FALSE, stringsAsFactors = FALSE)
# str(annotation_data)
# head(annotation_data)
####################

####################
# Excluded: "HPMA",
# ontology_terms <- c("GOBP", "GOMF", "GOCC", "PS", "PS2", "SF", "Pfam", "DO",
# "HPPA", "HPMI", "HPCM", "HPMA", "MP", "EF", "MsigdbH", "MsigdbC1",
# "MsigdbC2CGP", "MsigdbC2CPall", "MsigdbC2CP", "MsigdbC2KEGG",
# "MsigdbC2REACTOME", "MsigdbC2BIOCARTA", "MsigdbC3TFT", "MsigdbC3MIR",
# "MsigdbC4CGN", "MsigdbC4CM", "MsigdbC5BP", "MsigdbC5MF", "MsigdbC5CC",
# "MsigdbC6", "MsigdbC7", "DGIdb", "GTExV4", "GTExV6p", "GTExV7",
# "CreedsDisease", "CreedsDiseaseUP", "CreedsDiseaseDN", "CreedsDrug",
# "CreedsDrugUP", "CreedsDrugDN", "CreedsGene", "CreedsGeneUP",
# "CreedsGeneDN", "KEGG", "KEGGmetabolism", "KEGGgenetic",
# "KEGGenvironmental",
# "KEGGcellular", "KEGGorganismal", "KEGGdisease", "REACTOME",
# "REACTOME_ImmuneSystem", "REACTOME_SignalTransduction", "CGL")

ontology <- c("EF", "EF_disease", "EF_phenotype", "EF_bp")
# Run enrichment analysis and save to file as a loop for all ontology terms:
# TO DO: continue even if errors:

snp_enricher <- xEnricherSNPs(data = hits_data,
                              background = background_data,
                              ontology = ontology,
                              include.LD = c("EUR"),
                              LD.r2 = 0.8,
                              p.adjust.method = c("BH"),
                              min.overlap = 3,
                              test = c("fisher"), # "hypergeometric test"
                              ontology.algorithm = c(),
                              elim.pvalue = 0.01,
                              p.tail = c("two-tails")
                              )

str(snp_enricher)

# view enrichment results for the top significant terms
xEnrichViewer(snp_enricher)

# save enrichment results
res <- xEnrichViewer(snp_enricher,
                     top_num = length(snp_enricher$adjp),
                     sortBy = "adjp",
                     details = TRUE)

output <- data.frame(term = rownames(res), res)
str(output)
utils::write.table(output,
                   file = sprintf('xEnricherSNPs_%s.tsv', outfile_name),
                   sep = "\t",
                   row.names = FALSE)

# barplot of significant enrichment results
svg(filename = sprintf('%s_xEnricherSNPs.svg', hits_file))
bp <- xEnrichBarplot(snp_enricher,
                     top_num = "auto",
                     displayBy = "adjp")
show(bp)
dev.off()
# visualise the top 10 significant terms in the ontology hierarchy
# color-code terms according to the adjust p-values (taking the form of 10-based negative logarithm)
# svg(filename = sprintf('%s_DAG.svg', hits_file))
# DAG <- xEnrichDAGplot(snp_enricher,
#                top_num = 10,
#                displayBy = "adjp",
#                node.info = c("full_term_name")
#                )
# dev.off()

# color-code terms according to the z-scores
# xEnrichDAGplot(snp_enricher, top_num=10, displayBy="zscore",
# node.info=c("full_term_name"))
####################


####################
# Run similarity analysis:


####################

####################
# Run network analysis:
####################

####################
# Visualise results:
# xCircos()
# xVisNet()

####################

####################
# Interpretation:
# 
# 
####################


####################
# Write results to disk:

####################

####################
# The end:
# Remove objects that are not necessary to save:

#rm(list=ls(arrayQualityMetrics_raw_cleaned, arrayQualityMetrics_preprocessed))

# To save R workspace with all objects to use at a later time:
# save.image(file=R_session_saved_image, compress='gzip')

#objects_to_save <- (c('normalised_expressed', 'normalised_filtered', 'membership_file_cleaned', 'FAILED_QC_unique'))
#save(list=objects_to_save, file=R_session_saved_image, compress='gzip')
sessionInfo()
q()

# Next: run the script for xxx.
####################