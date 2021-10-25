# Bexar County Voting Records
 Processes publicly available [election reports](https://www.bexar.org/2186/Historical-Election-Results) to make the data accesible for analysis.

## Contents
1. [About](#about)
   1. [Tools Used](#tools-used)
   2. [Testing](#testing)
2. [Walkthrough](#walkthrough)
   1. [Reading data from the report](#reading-data-from-the-report)
   2. [Matching vote counts with offices and precincts](#matching-vote-counts-with-offices-and-precincts)
   3. [Extracting candidate and vote totals](#extracting-candidate-and-vote-totals)
   4. [Accomodating multiple report formats](#accomodating-multiple-report-formats)
   5. [Putting it all together](#putting-it-all-together)
3. [License](#license) 
## About
This project will allow users to easily analyze election data at the voting district (or precinct) level, the most granular level available. In its current state, it can parse two of 4 common report formats published by Electionware systems, a software product used by Bexar County and many other counties in Texas. The next few goals for development are: 
   1. Finish BigQuery ELT to fit the data into [this data warehouse schema](https://github.com/alexpowers2017/Bexar-County-Voting-Records/blob/main/code/sql_scripts/big%20query%20dataset%20diagram.png)
   2. Parse the remaining report formats 
   3. Expand collection to Collin County, TX
   4. Allow a user to choose specific information about specific elections/offices they'd like to see
  

### Tools Used


**R**: A majority of this project is currently in R. Within the R programs, most of the heavy lifting is done with [R6](https://github.com/r-lib/R6) classes. Class definitions are located in the [election_report_classes](/code/election_report_classes) folder. 

**BigQuery**: The output of this project is exported to a csv, where it will be loaded into a BigQuery dataset. The table creation script and entity relationship diagram for this dataset are located in the [sql_scripts](/code/sql_scripts) folder. The primary and foreign key constraints outlined in the diagram are mostly conceptual, as BigQuery datasets aren't made to be as strict as a traditional data warehouse.

### Testing
Unit tests are written using the [testthat](https://github.com/r-lib/testthat/) package. Testing scripts are located in the [testthat](tests/testthat) folder. Currently, around 77% of functions and methods used in this program are covered by tests. While some tests were written after the fact, most of the regular expression and line identifications were written using test-driven development.

<br>   
   
## Walkthrough
This section provides detailed explanations, with code samples, for critical steps in the project.

### Reading data from the report
----------------------------------
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

This would be the data frame returned by these methods if ran on the report sample above:
lines|
-----|
Summary Results &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Report OFFICIAL RESULTS|
Joint General, Special, Charter, and Bond Election|
November 3, 2020 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Bexar County|
2010|
President and Vice President|
Vote For 1|
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; TOTAL   VOTE %   ELECTION   Absentee   Early|
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DAY &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Voting|
Donald J. Trump/Michael R. Pence  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 322    36.97%   60         24         238|
Joseph R. Biden /Kamala D. Harris &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 533 61.19% 70 80 383|
...|
United States Senator|
Vote For 1|
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; TOTAL   VOTE %   ELECTION   Absentee   Early|
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DAY &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Voting|
John Cornyn &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 320 37.87% 54 27 239|
Mary "MJ" Hegar &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 489 57.87% 65 75 349|
...|
<br>   

   
### Matching vote counts with offices and precincts
----------------------------------
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
 The example table would now look like this:
 lines|precinct|office
-----|-------|-----
Summary Results &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Report OFFICIAL RESULTS|NA|NA
Joint General, Special, Charter, and Bond Election|NA|NA
November 3, 2020 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Bexar County|NA|NA
2010|2010|NA
President and Vice President|NA|President and Vice President
Vote For 1|NA|NA
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; TOTAL   VOTE %   ELECTION   Absentee   Early|NA|NA
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DAY &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Voting|NA|NA
Donald J. Trump/Michael R. Pence  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 322    36.97%   60         24         238|NA|NA
Joseph R. Biden /Kamala D. Harris &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 533 61.19% 70 80 383|NA|NA
...|...|...
United States Senator|NA|United States Senator
Vote For 1|NA|NA
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; TOTAL   VOTE %   ELECTION   Absentee   Early|NA|NA
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; DAY &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Voting|NA|NA
John Cornyn &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 320 37.87% 54 27 239|NA|NA
Mary "MJ" Hegar &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 489 57.87% 65 75 349|NA|NA
...|...|...
 <br>   
    
 Then, all of the NA values are filled in with whichever precinct or office value came before it.
 ```R
 fill_NA_precincts_and_offices = function(df) {
    # Here we have 'precinct' and 'office' columns, with the only values being held on the
        # first line of their section. by taking the columns as vectors and filling in the 
        # NA values, each row can be directly tied to its corresponding precinct/office
    df['precinct'] <- self$fill_NAs_in_vector(df[,'precinct'])
    df['office'] <- self$fill_NAs_in_vector(df[,'office'])
    return(df)
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
   
These methods are then all wrapped up into ```create_precinct_and_office_columns```.
```R
create_precinct_and_office_columns = function(df) {
    new_df <- df %>%
        self$add_first_values() %>%
        self$fill_NA_precincts_and_offices() %>%
        self$remove_first_precinct_and_office_lines()
    return(new_df)
},
```
The final product of these methods (and the ```is_useless_line``` method which filters out headers, footers, column titles, etc.) would be:
 lines|precinct|office
-----|-------|-----
Donald J. Trump/Michael R. Pence  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 322    36.97%   60         24         238|2010|President and Vice President
Joseph R. Biden /Kamala D. Harris &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 533 61.19% 70 80 383|2010|President and Vice President
...|...|...
John Cornyn &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 320 37.87% 54 27 239|2010|United States Senator
Mary "MJ" Hegar &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 489 57.87% 65 75 349|2010|United States Senator
...|...|...
<br>   
   
### Extracting candidate and vote totals
----------------------------------
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
Using these methods, and removing the ```lines``` column after the data is extracted, our example table becomes:
precinct|office|candidate|votes
-------|-----|-------|------
2010|President and Vice President|Donald J. Trump/Michael R. Pence|322
2010|President and Vice President|Joseph R. Biden /Kamala D. Harris|533
...|...|...|...
John Cornyn 2010|United States Senator|John Cornyn|320
Mary "MJ" Hegar 2010|United States Senator|Mary "MJ" Hegar
...|...|...|...

Now we've pretty much obtained our finished product. The program also adds metadata about the election to each line in new columns, which is not very efficient, but allows us to draw strict lines between extracting information from reports and defining structure/schema for storage. This data will all be sent to BigQuery, which is a better tool for data storage and organization.
<br>   
   
### Accomodating multiple report formats
----------------------------------
This program relies heavily on R6 classes and polymorphism to handle the different formats of election reports appropriately. The basic class structure is as follows:
![Class Diagram](https://raw.githubusercontent.com/alexpowers2017/Bexar-County-Voting-Records/main/code/election_report_classes/ElectionReport%20classes%20UML.png)
   
The overall logic and steps are the same for all published reports, but some information is presented or formatted differently, so many smaller steps have to be adjusted. The simplest example is how it identifies whether a line holds a precinct value or not.

This is the ```is_precinct``` method definition in the ```ElectionReport_BexarPDF``` class:
```R
is_precinct = function(line) {
    return(stringr::str_detect(line, '^\\d{3,5}$'))     # Line whose only value is 3-5 consecutive digits
},
```

In another form of the report (named ```ElectionReport_BexarPDF_BS``` because this was the first difference I noticed), some precincts have the suffix 'BS 1', as shown below:
![BS Layout Example](https://raw.githubusercontent.com/alexpowers2017/Bexar-County-Voting-Records/main/data/election_reports/bs_report_layout.JPG)
   
So in the ```ElectionReport_BexarPDF_BS``` class, the ```is_precinct``` method is overridden as:
```R
#' @override
is_precinct = function(line) {
    return(stringr::str_detect(self$remove_bs(line), '^\\d{3,5}$')) # Line whose only value is 3-5 consecutive digits
},

    remove_bs = function(line) {
        return(stringr::str_replace(line, '\\sBS\\s\\d', ''))       # Removes ' BS #' from string
    },
```
   
<br>
   
### Putting it all together
----------------------------------
The mainprogram is currently designed to read in information about each election from a manually created 'elections metadata' .csv file, download all reports, extract the data from each, and put it all into one big dataframe. 
```R
get_all_election_reports <- function(meta_df) {
    # Empty data frame that each election report will be inserted into
    combined_df <- as.data.frame(matrix(nrow = 0, ncol = 8))
    colnames(combined_df) <- c('precinct', 'office', 'candidate', 'votes', 'election_county', 'election_date', 'election_type', 'election_description')
    
    # Factory to create appropriate ElectionReport object based on metadata
    election_report_factory <- ElectionReportFactory$new()
    
    for(i in 1:nrow(meta_df)) {
        # Create ElectionReport object for a single election
        report <- election_report_factory$create_election_report_object(elections_metadata[i,])
        
        # Download precinct-level file from Bexar County Elections website
        report$retrieve_data()
        
        # full election report with vote totals for each candidate at the precinct level
        full_df <- report$create_lines_df() %>%  # 1-column dataframe where each row is a line of text in the report
            report$get_full_df_from_lines() %>%
            report$finalize_full_df()
        
        combined_df <- rbind(combined_df, full_df)
    }
    
    return(combined_df)
}
```



## License
This project is published under the [GNU AGPLv3](https://choosealicense.com/licenses/agpl-3.0/) license. When a modified version is used to provide a service over a network, the complete source code of the modified version must be made available.
