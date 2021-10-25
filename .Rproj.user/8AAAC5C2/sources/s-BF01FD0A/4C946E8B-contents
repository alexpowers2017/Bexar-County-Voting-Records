#################### ElectionReport_BexarPDF.R ######################
#                                                                   #
#   This program defines the first subclass for PDF reports from    #
#   Bexar County.                                                   #
#                                                                   #
#   The class is used to download the precinct-level report for     #
#   an election and create a dataframe where each row contains the  #
#   number of votes a single candidate received for a given office  #
#   in a single precinct.                                           #
#                                                                   #
#   There are several different formats Bexar County uses for       #
#   precinct-level election reports, so this class will provide     #
#   the main methods needed to parse these reports, and act as a    # 
#   superclass to all other PDF report formats Bexar County uses.   #
#                                                                   #
#   This class inherits from the 'ElectionReport' class, so that    #
#   must be read in before running this program.                    #
#                                                                   #
#####################################################################

# Example of this report format located at 'https://www.bexar.org/DocumentCenter/View/28533/November-3-2020-General-Election-by-Precinct'


library(R6)
library(stringr)
library(dplyr)
library(pdftools)


ElectionReport_BexarPDF <- R6Class('ElectionReport_BexarPDF',
    inherit = ElectionReport,
    public = list(
        
        ##########################
        #   DOWNLOADING REPORT   #
        ##########################
        
        retrieve_data = function() {
            download.file(self$url, self$get_file_path() , mode='wb')
        },
        
        create_lines_df = function() { 
            lines_df <- self$read_report_lines() %>%
                base::as.data.frame() %>%   # Convert to one-column dataframe
                dplyr::rename(lines = '.')  # Change the column name to 'lines'
            return(lines_df)
        },
        
            read_report_lines = function() {
                lines <- pdftools::pdf_text(self$get_file_path()) %>%   # Reads the PDF file (must already be downloaded using 'retrieve_data') to char list 
                    self$collapse_pages()                               # Creates char vect - each PDF line is an element
                return(lines)
            },
        
                # Election report PDFs are read in as lists with each page as an element.
                    # This method converts it to one long character vector, where each 
                    # element is a single line from the report, ignoring pages
                collapse_pages = function(file_text) {
                    single_string <- stringr::str_c(file_text, collapse="\n")   # Collapse all pages into one string, separated by \n
                    lines <- stringr::str_split(single_string, '\n')[[1]]       # Reads each line as an element in a char vector
                    return(lines)
                },
        
        
        
        
        ###########################
        #   PROCESSING LINES DF   #
        ###########################
        
        # useless here, but subclasses can override this to make final edits to the full dataframe, while keeping the main logic the same
        finalize_full_df = function(df) {
            return(df %>% dplyr::filter(
                stringr::str_detect(office, 'President|Representative|Senator|Judge|Justice|Mayor')
            ))
        },
        
        get_full_df_from_lines = function(df) {
            full_df <- df %>%
                self$remove_useless_lines() %>%
                self$create_precinct_and_office_columns() %>%
                self$remove_extra_results() %>%
                self$create_candidate_and_votes_columns() %>%
                self$add_metadata_to_df()
            return(full_df)
        },
        
            remove_useless_lines = function(df) {
                new_df <- df %>% dplyr::filter(
                    !self$is_useless_line(lines)
                )
                return(new_df)
            },
        
            create_precinct_and_office_columns = function(df) {
                new_df <- df %>%
                    self$add_first_values() %>%
                    self$fill_NA_precincts_and_offices() %>%
                    self$remove_first_precinct_and_office_lines()
                return(new_df)
            },
            
                add_first_values = function(df) {
                    new_df <- df %>% dplyr::mutate(
                        precinct = ifelse(self$is_precinct(lines), stringr::str_squish(lines), NA),
                        office = ifelse(self$is_office(lines), stringr::str_squish(lines), NA)
                    )
                    return(new_df)
                },
                
                fill_NA_precincts_and_offices = function(df) {
                    # Here we have 'precinct' and 'office' columns, with the only values being held on the
                        # first line of their section. by taking the columns as vectors and filling in the 
                        # NA values, each row can be directly tied to its corresponding precinct/office
                    df['precinct'] <- self$fill_NAs_in_vector(df[,'precinct'])
                    df['office'] <- self$fill_NAs_in_vector(df[,'office'])
                    return(df)
                },
                
                    # Takes a character vector and replaces all NAs with the most recent non-NA value
                        # The PDF report is read in line by line, so one line will have a precinct or office
                        # value, while the following lines contain information relevant to that precinct/office
                    fill_NAs_in_vector = function(vect) {
                        new_value <- NA
                        for(i in 1:length(vect)) {
                            if(!is.na(vect[i])) new_value <- vect[i] 
                            else vect[i] <- new_value 
                        }
                        return(vect)
                    },
            
                remove_first_precinct_and_office_lines = function(df) {
                    return(
                        df %>% dplyr::filter(
                            stringr::str_squish(lines) != precinct & 
                            stringr::str_squish(lines) != office
                        )
                    )
                },
            
                remove_extra_results = function(df) {
                    return(df %>% dplyr::filter(
                        !stringr::str_detect(lines, 'Write|Total Votes|ervotes')
                    ))
                },

            create_candidate_and_votes_columns = function(df) {
                new_df <- df %>% dplyr::mutate(
                    candidate = self$extract_candidate(lines),
                    votes     = self$extract_total_votes(lines)
                ) %>% select(-lines)
                return(new_df)
            },
        
                extract_total_votes = function(line) {
                    return(line %>%
                       stringr::str_replace(self$extract_candidate(line), '') %>%  # remove 'candidate' value from the line
                       stringr::str_squish() %>%                                   # remove all leading and trailing spaces
                       stringr::str_extract('[\\d|\\,]+')                          # take the first number in what is left of the line - this is the 'total votes'
                    )
                },
        
                    extract_candidate = function(line) {
                        full_name <- line %>%
                            stringr::str_extract('([:alpha:].+[:alpha:])\\s{5}') %>%  # Sequence starting with a letter, ending with a letter, and followed by at least 5 spaces
                            stringr::str_squish()
                        return(full_name)
                    },
            
            add_metadata_to_df = function(df) {
                new_df <- df %>% dplyr::mutate(
                    election_county      = self$county,
                    election_date        = self$date,
                    election_type        = self$election_type,
                    election_description = self$description
                )
                return(new_df)
            },
            
        
        
        ########################
        #   CATEGORIZE LINES   #
        ########################
        
        # 'Office' is the hardest one to get - I had to identify every other kind of line, and call those that don't fit 'office'
        is_office = function(line) {
            result <- stringr::str_detect(line, '[A-Za-z]+\\W?\\s+[A-Za-z]+') &
                !self$is_precinct(line) & 
                !self$is_result(line) & 
                !self$is_useless_line(line)
            return(result)
        },
            
            is_precinct = function(line) {
                return(stringr::str_detect(line, '^\\d{3,5}$'))     # Line whose only value is 3-5 consecutive digits
            },
            
            # A 'result' line will contain the candidates name and vote totals
            is_result = function(line) {
                # Checks that row contains 3-4 sequences of digits/punctuation separated by spaces. Will pick up under/overvotes
                return(stringr::str_detect(line, '[\\d|[:punct:]]+\\s+[\\d|[:punct:]]+?\\s+[\\d|[:punct:]]+\\s+[\\d|\\W]+'))
            },
                
            # Identifies all lines that don't provide any information we're interested in
            is_useless_line = function(line) {
                result <- self$is_blank(line) |
                    self$is_header_footer(line) |
                    self$is_vote_for(line) |
                    self$is_col_name(line)
                return(result)
            },
        
                is_blank = function(line) {
                    return(stringr::str_trim(line) == '')
                },
                    
                is_header_footer = function(line) { 
                    result <- stringr::str_detect(line, '[A-Za-z]{3,9}\\s\\d{1,2}\\W\\s\\d{2,4}') |  # Date at top of each page 
                        stringr::str_detect(line, 'OFFICIAL\\sRESULTS$') |      # line ends with 'OFFICIAL RESULTS'
                        stringr::str_detect(line, '^.+Election$') |             # Line ends with 'Election' - 2nd line in header
                        stringr::str_detect(line, 'Summary.+\\d\\sof\\s\\d') |  # line contains both 'Summary' and '# of #' - page number in footer
                        stringr::str_detect(line, 'Report generated with')      # Bottom line of footer showing the software the report was made with
        
                    return(result)
                },
                    
                is_vote_for = function(line) {
                    return(stringr::str_detect(line, 'Vote\\sFor\\s\\d')) # Line contains "Vote For #"  
                },
                
                is_col_name = function(line) { 
                    result <- stringr::str_detect(line, "TOTAL\\s+VOTE.+Election\\s+Absentee\\s+Early") | 
                        stringr::str_detect(line, "\\s+Day\\s+Voting")
                    return(result)
                }
        
        
    ) # end public list 
) # end ElectionReport_BexarPDF definition








