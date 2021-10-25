# Bexar County Voting Records
 Processes publicly available election reports to make the data accesible for analysis.

### Description
This project will allow users to easily analyze election data at the voting district (or precinct) level, the most granular level available. In its current state, it can parse two of 4 common report formats published by Electionware systems, the software used by Bexar County and many other counties in Texas. As development continues, this project will parse the remaining report formats and allow a user to choose specific information about specific elections they'd like to see, rather than pulling all of the data into one dataframe as it does now.

### Tools Used

##### R
A majority of this project is currently in R. Within the R programs, most of the heavy lifting is done with R6 classes. Class definitions are located in the [election_report_classes](/code/election_report_classes) folder. 

##### BigQuery
The output of this project is exported to a csv, where it will be loaded into a BigQuery dataset. The table creation script and entity relationship diagram for this dataset are located in the [sql_scripts](/code/sql_scripts) folder. The primary and foreign key constraints outlined in the diagram are mostly conceptual, as BigQuery datasets aren't made to be as strict as a traditional data warehouse.


### Walkthrough
Here's a page from one of the elections reports, with the sections we're especially interested in labelled.
![Report Layout](data/election_reports/report_layout.jpeg)

As you can see, the precinct and office information is slightly separated from the tables detailing the vote totals, and there is a lot of boiler plate text and extranneous information to sort through. Because of this, we won't be able to directly extract any tables from this file. Instead, the file is initially read in as a single-column dataframe, with each row containing a line of text from the report. The following code is from the [ElectionReport_BexarPDF](code/election_report_classes/ElectionReport_BexarPDF.R) class definition.
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


 
 
