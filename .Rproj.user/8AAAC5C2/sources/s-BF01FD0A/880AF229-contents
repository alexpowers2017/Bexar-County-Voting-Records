
# I'm still working on a method for parsing the web formatted election
# reports and Rep. Lopez wants this data to see where his strong/weak points
# would be if he has a republican opponent in 2022. 

# For now, I just copied it into a .csv and put the data in the same format
# as the rest of the election reports.



get_empty_df <- function(rows) {
    new_df <- as.data.frame(matrix(nrow = rows, ncol = 3))
    colnames(new_df) <- c('precinct', 'candidate', 'votes')
    return(new_df)
}

clean_special_column_names <- function(col_names) {
    clean_names <- col_names %>%
        str_replace('ï..precinct', 'precinct') %>%
        str_replace('Steve.Huerta', 'Steve Huerta') %>%
        str_replace('Fred.A..Rangel', 'Fred A. Rangel') %>%
        str_replace('Ray.Lopez', 'Ray Lopez') %>%
        str_replace('Coda.Rayo.Garza', 'Coda Rayo Garza') %>%
        str_replace('Arthur..Art..Reyna', 'Arthur "Art" Reyna')
    return(clean_names)
}

get_single_special_dataset <- function(metadata_row) {
    
    special_csv <- read.csv(metadata_row$file)
    special_colnames <- clean_special_column_names(colnames(special_csv))
    
    new_special <- get_empty_df(0)
    
    for(row_index in 1:nrow(special_csv)) {
        for(col_index in 2:ncol(special_csv)) {
            temp_df <- get_empty_df(1)
            temp_df$precinct <- special_csv[row_index, 1]
            temp_df$candidate <- special_colnames[col_index]
            temp_df$votes <- special_csv[row_index, col_index]
            new_special <- rbind(new_special, temp_df)
        }
    }
    
    new_special$office <- 'State Representative, District 125'
    new_special$election_county <- metadata_row$county
    new_special$election_date <- metadata_row$date
    new_special$election_type <- metadata_row$election_type
    new_special$election_description <- metadata_row$description
    
    
    return(new_special %>% select(
        precinct, 
        office, 
        candidate, 
        votes, 
        election_county,
        election_date,
        election_type,
        election_description
        
    ))
}


get_full_special_df <- function() {
    
    special_metadata <- get_elections_metadata() %>%
        filter(stringr::str_detect(description, 'District 125')) %>%
        arrange(date)
    
    special_metadata['file'] <- c(
        'data/manually_created/Special St Rep 125 Election February-12-2019 results.csv',
        'data/manually_created/Special St Rep 125 Runoff Election March-12-2019.csv'
    )
    
    special_df <- get_single_special_dataset(special_metadata[1,])
    runoff_df <- get_single_special_dataset(special_metadata[2,])
    
    return(rbind(special_df, runoff_df))
}




