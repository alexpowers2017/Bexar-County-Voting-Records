
# Read in ElectionReport classes and factory
source('code/election_report_classes/initialize_election_report_classes.R')


# Get manually created dataset with report URLs and other election data
elections_metadata <- get_elections_metadata() %>%
    top_n(3) # TEMPORARY STEP: Selecting a few recent elections to populate while this project is in development



get_all_election_reports <- function(meta_df) {
    # Empty data frame that each election report will be inserted into
    combined_df <- as.data.frame(matrix(nrow = 0, ncol = 8))
    colnames(combined_df) <- c('precinct', 'office', 'candidate', 'votes', 'election_county', 'election_date', 'election_type', 'election_description')
    
    # Factory to create appropriate ElectionReport object based on metadata
    election_report_factory <- ElectionReportFactory$new()
    
    for(i in 1:nrow(meta_df)) {
        # Create ElectionReport object for a single election
        report <- election_report_factory$create_election_report_object(elections_metadata[3,])
        
        # Download precinct-level file from Bexar County Elections website
        report$retrieve_data()
        
        # full election report with vote totals for each candidate at the precinct level
        full_df <- report$create_lines_df() %>%  # 1-column dataframe where each row is a line of text in the report
            report$get_full_df_from_lines() %>%
            report$finalize_full_df()
        
        combined_df <- rbind(combined_df, full_df)
        
        rm(report)
        rm(full_df)
    }
    
    return(combined_df)
}


all_elections <- get_all_election_reports(elections_metadata)


# Read in district 125 special elections from .csv files
source('code/adhocs_and_manual_steps/get_125_special_elections.R')
special_elections <- get_full_special_df()

# Combine automated pull with special elections data
all_elections <- rbind(all_elections, special_elections)


# Write out to csv file
write.csv(all_elections, 'data/all_elections.csv')
