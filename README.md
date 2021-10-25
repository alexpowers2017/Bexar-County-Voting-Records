# Bexar County Voting Records
 Processes publicly available election reports to make the data accesible for analysis.

### Description
This project will allow users to easily analyze election data at the voting district (or precinct) level, the most granular level available. In its current state, it can parse two of 4 common report formats published by Electionware systems, the software used by Bexar County and many other counties in Texas. As development continues, this project will parse the remaining report formats and allow a user to choose specific information about specific elections they'd like to see, rather than pulling all of the data into one dataframe as it does now.

### Tools Used

##### R
A majority of this project is currently in R. Within the R programs, most of the heavy lifting is done with R6 classes. Class definitions are located in the [election_report_classes](/code/election_report_classes) folder. 

##### BigQuery
The output of this project is exported to a csv, where it will be loaded into a BigQuery dataset. The table creation script and entity relationship diagram for this dataset are located in the [sql_scripts](/code/sql_scripts) folder. The primary and foreign key constraints outlined in the diagram are mostly conceptual, as BigQuery datasets aren't made to be as strict as a traditional data warehouse.

##### Testing
The testing suite for this project can be described in three words: **messy but thorough**. Better organizing the tests will be a priority, but for now you can view the scripts in the [testthat](tests/testthat) folder.

<br>   
   
## Walkthrough

#### Reading data from the report
Here's a page from one of the elections reports, with the sections we're especially interested in labelled.
![Report Layout](https://github.com/alexpowers2017/Bexar-County-Voting-Records/blob/main/data/election_reports/report_layout.JPG)

As you can see, the precinct and office information is slightly separated from the tables detailing the vote totals, and there is a lot of boiler plate text and extranneous information to sort through. Because of this, we won't be able to directly extract any tables from this file. Instead, the file is initially read in as a single-column dataframe, with each row containing a line of text from the report. 
   
The following code is from the [ElectionReport_BexarPDF](code/election_report_classes/ElectionReport_BexarPDF.R) class definition.
```R
create_lines_df = function() { 
    lines_df <- self$read_report_lines() %>%
        base::as.data.frame() %>%   # Convert to one-column dataframe
        dplyr::rename(lines = '.')  # Change the column name to 'lines'
    return(lines_df)
},

    read_report_lines = function() {
        lines <- pdftools::pdf_text(self$get_file_path()) %>%   # Reads the PDF file to char list (must already be downloaded using 'retrieve_data')
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
```
   
<br>   
   
#### Matching vote counts with offices and precincts
There are about a billion regular expressions (or maybe closer to 10, but it feels like a lot) to identify each type of line in this report, culminating with the functions ```is_precinct```, ```is_office```, and ```is_result```, which identify the sections of interest on the above diagram.
 
 First, we'll use these to create 'precinct' and 'office' columns, each filled with NAs except for the lines holding the precinct or office value.
 ```R
 add_first_values = function(df) {
    new_df <- df %>% dplyr::mutate(
        precinct = ifelse(self$is_precinct(lines), stringr::str_squish(lines), NA),
        office = ifelse(self$is_office(lines), stringr::str_squish(lines), NA)
    )
    return(new_df)
},
 ```
 
 <br>   
    
 Then, all of the NA values are filled in with whichever precinct or office value came before it.
 ```R
 fill_NA_precincts_and_offices = function(df) {
    # Here we have 'precinct' and 'office' columns, with the only values being held on the
        # first line of their section. by taking the columns as vectors and filling in the 
        # NA values, each row can be directly tied to its corresponding precinct/office
    df['precinct'] <- self$fill_NAs_in_vector(df[,'precinct'])
    df['office'] <- self$fill_NAs_in_vector(df[,'office'])

    return(self$remove_first_precinct_and_office_lines(df))
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
 ```
   
<br>   
   
#### Extracting candidate and vote totals
Now that we can match vote counts for candidates to precincts and offices, all that's left is to extract the candidate name and vote total from the 'result' lines
```R
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
```
