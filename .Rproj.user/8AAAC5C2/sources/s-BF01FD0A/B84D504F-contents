################## ElectionReport_BexarPDF_BS.R #####################
#                                                                   #
#   This program defines a subclass of the ElectionReport_BexarPDF  #
#   class. The name comes from the fact that many precinct names    #
#   in the report add the suffix 'BS' for some reason.              #
#                                                                   #
#   Like its superclass, this class is used to download the         #
#   precinct-level report for an election and create a dataframe    #
#   where each row contains the number of votes a single candidate  #
#   received for a given office in a single precinct.               #
#                                                                   #
#                                                                   #
#   This class inherits from the 'ElectionReport_BexarPDF' class,   #
#   so that must be read in before running this program.            #
#                                                                   #
#####################################################################


# Example of this report format located at 'https://www.bexar.org/DocumentCenter/View/31319/September-28-2021-Special-St-Rep-118-Election-Precinct-Report'

library(stringr)

ElectionReport_BexarPDF_BS <- R6Class('ElectionReport_BexarPDF_BS',
    inherit = ElectionReport_BexarPDF,
    
    public = list(
        
        #' @override
        finalize_full_df = function(df) {
            return(df %>% 
                dplyr::filter(office != 'Statistics TOTAL')
            )
        },
        
        #' @override
        is_result = function(line) {
            result <- 
                (   stringr::str_detect(line, '^[A-Z].+[\\d|\\%]$') |   # starts with letter and ends with either digit or '%'
                    stringr::str_detect(line, 'Overvote') | 
                    stringr::str_detect(line, 'Undervote')   ) &
                !stringr::str_detect(line, '\\:') &                     # does not contain colon
                !stringr::str_detect(line, 'Copyright')                 # does not contain 'Copyright'
            return(result)
        },
        
        #' @override
        is_precinct = function(line) {
            return(stringr::str_detect(self$remove_bs(line), '^\\d{3,5}$')) # Line whose only value is 3-5 consecutive digits
        },
        
            remove_bs = function(line) {
                return(stringr::str_replace(line, '\\sBS\\s\\d', ''))       # Removes ' BS #' from string
            },
        
        #' @override
        is_col_name = function(line) {
            result <- 
                stringr::str_detect(line, 'TOTAL') &
                !stringr::str_detect(line, 'Statistics')
            return(result)
        }
        
    )
)
