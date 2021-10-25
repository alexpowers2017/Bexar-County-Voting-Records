

library(dplyr)
library(odbc)
library(stringr)
library(pdftools)

sql_connection <- dbConnect(odbc(),
    Driver = "ODBC Driver 17 for SQL Server",
    Server = "clinicoeus-server.database.windows.net",
    Database = "elections",
    UID = "alex",
    PWD = "QOSpwd123",
    Port = 1433)

office_dim <- dbReadTable(sql_connection, 'office_dim')


state_house_districts <- office_dim %>%
    filter(position == 'State Representative') %>%
    select(seat) %>%
    arrange(seat) %>%
    mutate(url = str_glue('https://wrm.capitol.texas.gov/fyiwebdocs/PDF/house/dist{seat}/r7.pdf')) %>%
    mutate(file_name = str_glue('data/house_{seat}_precincts.pdf'))


state_senate_districts <- office_dim %>%
    filter(position == 'State Senator') %>%
    select(seat) %>%
    arrange(seat) %>%
    mutate(url = str_glue('https://wrm.capitol.texas.gov/fyiwebdocs/PDF/senate/dist{seat}/r7.pdf')) %>%
    mutate(file_name = str_glue('data/senate_{seat}_precincts.pdf'))


for(i in 1:nrow(state_house_districts)) {
    row <- state_house_districts[i,]
    download.file(row$url, row$file_name, mode="wb")
}

for(i in 1:nrow(state_senate_districts)) {
    row <- state_senate_districts[i,]
    download.file(row$url, row$file_name, mode="wb")
}


house_df <- as.data.frame(matrix(nrow=0, ncol=2))
colnames(house_df) <- c('district', 'precinct')

for(i in 1:nrow(state_house_districts)) {
    row <- state_house_districts[i,]
    rm(new_df)
    new_df <- row$file_name %>%
        pdf_text() %>%
        str_c(collapse = '\n') %>%
        str_split('\n') %>%
        as.data.frame() %>% 
        mutate(district = row$seat)
    
    colnames(new_df) <- c('precinct', 'district')
    
    new_df <- new_df %>%  
        filter(!str_detect(precinct, '[:alpha:]')) %>%
        filter(str_detect(precinct, '[:digit:]')) %>%
        transform(precinct = str_replace_all(precinct, '\\*', '')) %>%
        transform(precinct = str_squish(precinct)) 
    
    house_df <- rbind(house_df, new_df)
    
}

dbWriteTable(
    sql_connection,
    'house_district_precincts',
    house_df,
    append=TRUE
)
