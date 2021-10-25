#################### election_report_factory.R ######################
#                                                                   #
#   This program creates an R6 class which handles the creation     #
#   of new ElectionReport objects.                                  #
#                                                                   #
#   There are many subclasses of ElectionReport for different       #
#   report formats. This class will take the URL and other          #
#   manually-defined information about an election and create the   # 
#   ElectionReport object using the appropriate subclass.           #
#                                                                   #
#####################################################################


library(R6)
library(dplyr)
library(stringr)

ElectionReportFactory <- R6Class("ElectionReportFactory",
    public = list(
        create_election_report_object = function(row){
            if(row$report_type == 'bexar_pdf') {
                return(ElectionReport_BexarPDF$new(row))
            } 
            else if(row$report_type == 'bexar_pdf_bs') {
                return(ElectionReport_BexarPDF_BS$new(row))
            }
            else {
                message(stringr::str_glue('Report type "{row$report_type}" not supported yet.'))
            }
        }
    )
)

