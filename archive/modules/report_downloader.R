
report_downloader <- module({
    
    import('pdftools')
    import('stringr')
    import('utils')
    import('dplyr')
    import('lubridate')
    
    
    
    download_report_to_df <- function(row) 
        row %>% 
            .download_and_read_report() %>%
            .add_metadata_to_df(row)
    
        .download_and_read_report <- function(row) 
            .read_report_as_df(.download_report(row))
            
    
        .download_report <- function(row) {
            download.file(row$url, .get_report_name(row), mode='wb')
            return(.get_report_name(row))
        }
    
            # 
            .get_report_name <- function(row)
                paste('data/', row$description, ' ', row$date, '.pdf', sep='')
        
    
        # Takes filepath to Election report PDF and returns dataframe with 1 column
        #   named 'lines', where every row is a line of text from the PDF
        .read_report_as_df <- function(file_name) 
            file_name %>%
                pdftools::pdf_text() %>%
                .collapse_pages() %>%
                as.data.frame() %>%
                dplyr::rename(lines = '.')
    
        
            # Election report PDFs are read in as lists with each page as an element.
            .collapse_pages <- function(file_text) {
                single_string <-  stringr::str_c(file_text, collapse="\n") # Collapse all pages into one string, separated by \n
                lines <- stringr::str_split(single_string, '\n')[[1]] # Reads each line as an element in a char vector
                return(lines)
            }
            
        
        # Takes date, primary party, and description information from URL dataset
        #   and adds a column for each one
        .add_metadata_to_df <- function(df, row) {
            df$date <- .get_date(row$url)
            df$primary_party <- .get_party(row$url)
            df$description <- row$description
            return(df)
        }
            
            # Takes string date with the format 'MONTHNAME-DD-YYYY' and returns lubridate date value
            .get_date <- function(url) 
                lubridate::mdy(.extract_date_text(url))
                
                # Takes url of election report and extracts the date in the format 'MONTHNAME-DD-YYYY'
                .extract_date_text <- function(url) 
                    stringr::str_extract(url, "[A-Za-z]{3,9}-\\d{1,2}-\\d{2,4}")
                
                
            # Takes url of election report and returns 'R' or 'D' if the election
            #   is specific to a party
            .get_party <- function(url) 
                dplyr::case_when(
                    .contains_republican(url) ~ "R",
                    .contains_democrat(url) ~ "D",
                    TRUE ~ "X"
                )
                
                .contains_republican <- function(url) 
                    stringr::str_detect(url, "[Rr]epub")
                
                .contains_democrat <- function(url) 
                    stringr::str_detect(url, "[Dd]emocr")
        
})
