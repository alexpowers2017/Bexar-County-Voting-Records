
results_processor <- modules::module({
    import('stringr')
    
    export('extract_vote_counts')
    extract_vote_counts <- function(txt) 
        txt %>%
            extract_results() %>%
            stringr::str_replace('\\d[\\d|\\.]+\\%', '') %>%
            stringr::str_replace_all('\\,','') %>%
            stringr::str_squish()
    
    
    export('extract_vote_pct')
    extract_vote_pct <- function(txt) {
        results <- txt %>% extract_results()
        if(stringr::str_detect(txt, '\\%')) {
            vote_pct <- results %>% stringr::str_extract('\\d[\\d|\\.]+\\%')
        } else {
            vote_pct <- NA
        }
        return(vote_pct)
    }
        
            
        export('extract_results')
        extract_results <- function(txt)
            txt %>%
                stringr::str_replace(extract_candidate(txt), '') %>%
                stringr::str_squish()
    
            export('extract_candidate')
            extract_candidate <- function(txt) 
                txt %>% 
                    stringr::str_extract('([:alpha:].+[:alpha:])\\s{5}') %>%
                    stringr::str_squish()
            
})
