
line_scanner <- module({
    import('stringr')
 
    export('is_office')
    is_office <- function(txt) 
        !is_precinct(txt) & 
        !is_result(txt) & 
        !is_useless_line(txt)
    
        export('is_precinct')
        is_precinct <- function(txt) txt %>% 
            stringr::str_detect('^\\d{3,5}$')
        
        export('is_result')
        is_result <- function(txt) txt %>% 
            stringr::str_detect('[\\d|\\W]+\\s+[\\d|\\W]+?\\s+[\\d|\\W]+\\s+[\\d|\\W]+')
        
        export('is_useless_line')
        is_useless_line <- function(txt) 
            .is_blank(txt) |
            .is_header(txt) |
            .is_footer(txt) |
            .is_vote_for(txt) |
            .is_col_name(txt)
        
            .is_blank <- function(txt) 
                stringr::str_trim(txt) == ''
            
            .is_header <- function(txt) 
                .is_date(txt) |
                .is_official_results(txt) |
                .is_title(txt)
            
                .is_date <- function(txt) txt %>% 
                    stringr::str_detect('[A-Za-z]{3,9}\\s\\d{1,2}\\W\\s\\d{2,4}')
                
                .is_official_results <- function(txt) txt %>% 
                    stringr::str_detect('OFFICIAL\\sRESULTS$')
                
                .is_title <- function(txt) txt %>% 
                    stringr::str_detect('^.+Election$')
                
            .is_footer <- function(txt) 
                .is_page_num(txt) |
                .is_copyright(txt)
            
                .is_page_num <- function(txt) txt %>% 
                    stringr::str_detect('Summary.+\\d\\sof\\s\\d')
                
                .is_copyright <- function(txt) txt %>% 
                    stringr::str_detect('Report generated with')
                
            .is_vote_for <- function(txt) txt %>%
                stringr::str_detect('Vote\\sFor\\s\\d')
                
            .is_col_name <- function(txt) 
                .is_col_name_1(txt) | 
                .is_col_name_2(txt)
            
                .is_col_name_1 <- function(txt) txt %>% 
                    stringr::str_detect("^\\s+TOTAL\\s+VOTE.+Election\\s+Absentee\\s+Early$")
                
                .is_col_name_2 <- function(txt) txt %>% 
                    stringr::str_detect("^\\s+Day\\s+Voting$")
    
})


