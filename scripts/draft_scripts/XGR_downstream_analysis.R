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
setwd('~/Documents/quickstart_projects/chronic_inflammation_Airwave.p_q/results/annotation_QTL_core_illumina/')

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
source('~/Documents/github.dir/EpiCompBio/downstream_annotation/code/downstream_annotation/BESTD_copies_downstream_analysis/gene_expression_functions.R')
# source('/ifs/devel/antoniob/projects/BEST-D/gene_expression_functions.R')
####################

####################
# Run with cmd arguments:
args <- commandArgs(trailingOnly = TRUE)

# Gene or SNP files:
hits_file <- as.character(args[1])
# hits_file <- 'QTL_1DNMR_results/col_1_rows_del_1_matched_all.clean-base.A-transpose-NA-NA.MxEQTL.tsv'

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
snp_enricher

xEnrichViewer(snp_enricher)



for (i in ontology_terms){
  ontology_term <- i
  print(ontology_term)
  run_XGR_xEnricherGenes(hits_data, background_data, ontology_term, hits_file)
}
####################

####################
# Concatenate results:
run_cmd <- sprintf('cat %s*enrichments.txt > XGR_%s.txt', hits_file, hits_file)
run_cmd
system(run_cmd)
####################

####################
# view enrichment results for the top significant terms
# View(xEnrichViewer(enrichment_result))

# # Visualise the top 10 significant terms in the ontology hierarchy
# # Set an ontology term:
# ontology_term <- 'MsigdbC2KEGG'
# 
# # Run enrichment analysis for a particular ontology:
# enrichment_result <- run_XGR_xEnricherGenes(hits_data, background_data, ontology_term, hits_file)
# enrichment_result
# 
# # Load ig.XXX (an object of class "igraph" storing as a directed graph):
# # g <- xRDataLoader(RData=sprintf('ig.%s', ontology_term))
# g <- xRDataLoader(RData=sprintf('org.Hs.eg%s', ontology_term))
# g
# nodes_query <- names(sort(enrichment_result$adjp)[1:10])
# nodes.highlight <- rep("red", length(nodes_query))
# names(nodes.highlight) <- nodes_query
# subg <- dnet::dDAGinduce(g, nodes_query)
# # TO DO: errors: Error in dnet::dDAGinduce(g, nodes_query) : The function must apply to either 'igraph' or 'graphNEL' object.
# class(g)
# 
# # Colour-code terms according to adjusted p-values (taking the form of 10-based negative logarithm):
# png(sprintf("%s_%s_ontology_hierarchy.png", hits_file, ontology_term), width = 12, height = 12, units = 'in', res = 300)
# dnet::visDAG(g=subg, data=-1*log10(enrichment_result$adjp[V(subg)$name]),
#              node.info="both", zlim=c(0,2), node.attrs=list(color=nodes.highlight))
# # color-code terms according to the z-scores
# dnet::visDAG(g=subg, data=enrichment_result$zscore[V(subg)$name], node.info="both",
#              colormap="darkblue-white-darkorange",
#              node.attrs=list(color=nodes.highlight))
# dev.off()
####################

####################
# # TO DO: run SNPs as separate script
# # Test SNPs:
# ontology_term <- 'EF'
# enrichment_result <- xEnricherSNPs(data = hits_data, ontology = ontology_term)
# # view enrichment results for the top significant terms
# xEnrichViewer(enrichment_result)
# # save enrichment results to file:
# save_enrichment <- xEnrichViewer(enrichment_result, top_num=length(enrichment_result$adjp), sortBy="adjp", details=TRUE)
# output_enrichment <- data.frame(term=rownames(save_enrichment), save_enrichment)
# utils::write.table(output_enrichment, file=sprintf("%s_%s_enrichments.txt", hits_file, ontology_term), sep="\t", row.names=FALSE)
####################

####################
# TO DO/clean up
# # Test overlap between gene lists using XGR:
# # xEnricherYours requires dataframes as files, simply provide file names:
# enrichment_result <- xEnricherYours(data.file = hits_file, annotation.file = annotation_file, background.file = background_file)
# xEnrichViewer(enrichment_result)
# save_enrichment <- xEnrichViewer(enrichment_result, top_num=length(enrichment_result$adjp), sortBy="adjp", details=TRUE)
# output_enrichment <- data.frame(term=rownames(save_enrichment), save_enrichment)
# utils::write.table(output_enrichment, file=sprintf("%s_%s_overlap.txt", hits_file, background_file), sep="\t", row.names=FALSE)
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
