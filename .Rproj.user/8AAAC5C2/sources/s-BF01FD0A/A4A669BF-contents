library(R6)
library(stringr)
library(dplyr)
library(lubridate)


# Read in .csv file with information about each election, including URL for report
get_elections_metadata <- function() {
    file_path <- 'data/manually_created/Election Totals Report urls.csv'
    metadata_df <- utils::read.csv(file_path) %>%
        transform(date = lubridate::mdy(date)) %>%
        dplyr::filter(report_type != '')
    return(metadata_df)
}


# This object is a superclass which will contain all the information about
#   an election report and parse the data it contains
ElectionReport <- R6Class('ElectionReport',
    public = list(
    
        description = NULL,
        date = NULL,
        election_type = NULL,
        county = NULL,
        url = NULL,
        report_type = NULL,
        party = NULL,
        
        # the input to initialize this object will be a row from the elections metadata .csv file
        initialize = function(row) {
            self$description <- row$description
            self$date <- row$date
            self$election_type <- row$election_type
            self$county <- row$county
            self$url <- row$url
            self$report_type <- row$report_type
            self$party <- ifelse( stringr::str_detect(self$description, 'epublican'), 'R',
                ifelse( stringr::str_detect(self$description, 'emocrat'), 'D', NA ))
            
            self$describe()
        },
        
        get_file_path = function() {
            return(stringr::str_glue("data/election_reports/{self$description} {self$date}.pdf"))
        },
        
        describe = function() {
            message('\n----- REPORT OBJECT -----')
            message(stringr::str_glue('
                Description:   {self$description}
                Date:          {self$date}
                Election Type: {self$election_type}
                Party:         {self$party}
                Report Type:   {self$report_type}
                County:        {self$county}
                URL:           {self$url}'
            ))
            message('-------------------------\n')
        }
    
    ) # end public       
) # end ElectionReport definition


