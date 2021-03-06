###################### initialize_classes.R #########################
#                                                                   #
#   This program will manage the initialization of the election     #
#   report classes. They're a bit too big to all be in the same     #
#   file, but they mostly depend on and inherit from each other.    #
#                                                                   #
#   This lets us initialize everything once in the correct order    #
#   instead of having a bunch of intertwined and redundant          #
#   'source' calls in each file.                                    #
#                                                                   #
#####################################################################

library(stringr)
source('code/election_report_classes/ElectionReport.R')
source('code/election_report_classes/ElectionReport_BexarPDF.R')
source('code/election_report_classes/ElectionReport_BexarPDF_BS.R')
source('code/election_report_classes/election_report_factory.R')
