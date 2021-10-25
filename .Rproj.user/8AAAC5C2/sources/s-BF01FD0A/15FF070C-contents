
# This module helps take a dataframe where each row is just a line of text read
#   in from a pdf election report, assign the appropriate precinct and office to
#   each row, and filter it down to just rows with vote counts 
line_processor <- modules::module({
    import('dplyr')
    line_scanner <- modules::use("code/modules/line_scanner.R", attach = TRUE)$line_scanner
    
    
    
    # Takes a dataframe with pdf text read in as lines, adds columns with precinct
    #   and office names, and filters down to only rows with vote counts
    get_results_with_pct_and_office <- function(df)
        df %>%
            remove_useless_lines() %>%
            add_first_values() %>%
            fill_nulls_and_dedup()
    
        # Uses function from line scanner module to remove lines with information we're not interested in
        remove_useless_lines <- function(pdf_df) pdf_df %>%
            filter(!line_scanner$is_useless_line(lines)) 
        
        
        # Identifies lines with precinct and office values and adds those values to
        #   columns named 'precinct' and 'office', respectively
        add_first_values <- function(lines_only_df) lines_only_df %>%
            mutate(precinct = ifelse(line_scanner$is_precinct(lines), stringr::str_squish(lines), NA)) %>%
            mutate(office = ifelse(line_scanner$is_office(lines), stringr::str_squish(lines), NA))
    
        
        # Fills in all null values in the precinct and office columns and removes the
        #   original rows where the precinct and office values originally came from
        fill_nulls_and_dedup <- function(df) df %>% 
            fill_null_column('precinct') %>%
            fill_null_column('office') %>%
            filter(lines != precinct & lines != office)
        
    
            # Receives a dataframe and column name and fills all NAs in column with previous non-NA value
            fill_null_column <- function(df, col_name) {
                df[col_name] <- .fill_in_vect(df[,col_name])
                return(df)
            }
            
                # Receives a vector with NAs and fills all NAs with previous non-NA value
                # When the election report pdf is read, there are precinct and office names,
                #   followed by a bunch of lines with information related to that precinct/office.  
                #   This lets you add the precinct/office name to all of those related lines.
                .fill_in_vect <- function(vect) {
                    new_precinct <- NA
                    for(i in 1:length(vect)) {
                        if(!is.na(vect[i])) { new_precinct <- vect[i] } 
                        else { vect[i] <- new_precinct }
                    }
                    return(vect)
                }
})
