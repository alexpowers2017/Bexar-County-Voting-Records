





# Read in csv file I put together with report urls and other info for each election
elections_metadata <- utils::read.csv('data/manually_created/Election Totals Report urls.csv') %>%
    transform(date = lubridate::mdy(date)) %>%
    dplyr::filter(report_type != '')  # Only working with a subset of reports that I've already categorized by layout and format


dplyr::tribble(
    ~col1, ~col2,
    'hello', 'there'
) %>% as.data.frame()


report1 <- ElectionReport_BexarPDF$new(elections_metadata[1,])

report1$download_and_create_lines_df()





# Module to help with getting PDF from web and read into data frame 
report_downloader <- modules::use('code/modules/report_downloader.r')$report_downloader

# Module to help take the lines of the PDF and turn them into a structured data 
#   frame with the results separated
line_processor <- modules::use('code/modules/line_processor.R')$line_processor

# Module to take the raw text of all the results and parse relevant information
#   like candidate names and vote counts
results_processor <- modules::use('code/modules/results_processor.r')$results_processor


results_df <- elections_metadata[2,] %>%
    report_downloader$download_report_to_df() %>%
    line_processor$get_results_with_pct_and_office()


skinny_df <- results_df %>%
    dplyr::mutate(candidate = results_processor$extract_candidate(lines)) %>%
    dplyr::mutate(vote_counts = results_processor$extract_vote_counts(lines)) %>%
    dplyr::mutate(vote_pct = results_processor$extract_vote_pct(lines)) %>%
    tidyr::separate(vote_counts, c('total', 'election_day', 'absentee', 'early'), sep=' ') %>%
    filter(
        !stringr::str_detect(total, '[:alpha:]') &
            !stringr::str_detect(election_day, '[:alpha:]') &
            !stringr::str_detect(absentee, '[:alpha:]') &
            !stringr::str_detect(early, '[:alpha:]') &
            office != 'City of Leon Valley For Council, Place No. 4' &
            candidate != 'Total Votes Cast' & 
            candidate != 'Overvotes' &
            candidate != 'Undervotes' 
    ) %>%
    transform(
        precinct = as.numeric(precinct),
        total = as.numeric(total),
        election_day = as.numeric(election_day),
        absentee = as.numeric(absentee),
        early = as.numeric(early)
    ) %>%
    select(-lines)




######################
#  DIMENSION TABLES  #
######################

### ELECTIONS DIMENSION TABLE ###
election_dim <- skinny_df %>%
    select(date, description, primary_party) %>%
    unique()

rownames(election_dim) <- seq(length=nrow(election_dim))

election_dim <- election_dim %>%
    tibble::rownames_to_column(var = 'election_id') %>%
    transform(election_id = as.numeric(election_id))


### OFFICE DIMENSION TABLE ###
office_dim <- skinny_df %>%
    select(office) %>%
    unique()

rownames(office_dim) <- seq(length=nrow(office_dim))

office_dim <- office_dim %>%
    tibble::rownames_to_column(var='office_id') %>%
    transform(office_id = as.numeric(office_id))


### CANDIDATE DIMENSION TABLE ###
candidate_dim <- skinny_df %>%
    select(candidate) %>%
    unique() 

rownames(candidate_dim) <- seq(length=nrow(candidate_dim))

candidate_dim <- candidate_dim %>%
    tibble::rownames_to_column(var='candidate_id') %>%
    transform(candidate_id = as.numeric(candidate_id))




################
#  FACT TABLE  #
################

votes <- sqldf('
    select e.election_id,
        main.precinct,
        o.office_id,
        c.candidate_id,
        main.total,
        main.election_day,
        main.absentee,
        main.early
    from skinny_df as main
    left join office_dim as o
        on main.office = o.office
    left join candidate_dim as c
        on main.candidate = c.candidate
    left join election_dim as e
        on main.description = e.description
        and main.primary_party = e.primary_party
        and main.date = e.date
')




###################
#  UPLOAD TO SQL  #
###################

sql_connection <- dbConnect(odbc(),
                            Driver = "ODBC Driver 17 for SQL Server",
                            Server = "clinicoeus-server.database.windows.net",
                            Database = "elections",
                            UID = "alex",
                            PWD = "QOSpwd123",
                            Port = 1433)


dbWriteTable(
    sql_connection,
    'election_dim',
    election_dim,
    append=TRUE
)

dbWriteTable(
    sql_connection,
    'office_dim',
    office_dim,
    append=TRUE
)

dbWriteTable(
    sql_connection,
    'candidate_dim',
    candidate_dim,
    append=TRUE
)


dbWriteTable(
    sql_connection,
    'votes',
    votes,
    append=TRUE
)

