
setwd('../..')

source('code/election_report_classes/initialize_election_report_classes.R')



test_that("get metadata function works", {
    metadata_df <- get_elections_metadata()
    expect_that(metadata_df, is_a('data.frame'))
    expect_gt(nrow(metadata_df), 1)
    expect_gt(ncol(metadata_df), 1)
})

sample_row <- dplyr::tribble(
    ~description, ~date, ~election_type, ~county, ~report_type, ~url,
    'sample description', mdy('August-3-2021'), 'sample election type', 'sample county', 'sample report type', 'sample url'
) %>% as.data.frame()
