


source('test-setup_report_tests.R')


bexar_pdf <- ElectionReport_BexarPDF$new(sample_row)

test_that("Bexar PDF init", {
    expect_equal(bexar_pdf$description, 'sample description')
    expect_equal(bexar_pdf$date, mdy('August-3-2021'))
    expect_equal(bexar_pdf$election_type, 'sample election type')
    expect_equal(bexar_pdf$county, 'sample county')
    expect_equal(bexar_pdf$report_type, 'sample report type')
    expect_equal(bexar_pdf$url, 'sample url')
})

# Make sure it inherited file_path function correctly
test_that("Bexar PDF file_path function", {
    expect_equal(bexar_pdf$get_file_path(), 'data/election_reports/sample description 2021-08-03.pdf')
})




###################################
#  LINE CATEGORIZATION FUNCTIONS  #
###################################


test_that("Bexar PDF is_col_name function", {
    # Cases for 1st line of column names
    expect_equal(bexar_pdf$is_col_name("TOTAL VOTE Election Absentee Early"), TRUE)
    expect_equal(bexar_pdf$is_col_name("   TOTAL      VOTE        Election      Absentee       Early   "), TRUE)
    expect_equal(bexar_pdf$is_col_name("Statistics       TOTAL"), FALSE)
    
    # Cases for 2nd line of column names
    expect_equal(bexar_pdf$is_col_name("  Day  Voting "), TRUE)
    expect_equal(bexar_pdf$is_col_name("        Day           Voting        "), TRUE)
})


test_that("Bexar PDF is_vote_for function", {
    expect_equal(bexar_pdf$is_vote_for('Vote For 1'), TRUE)
    expect_equal(bexar_pdf$is_vote_for('Vote For 20'), TRUE)
    expect_equal(bexar_pdf$is_vote_for('    Vote     for      1'), FALSE)
    expect_equal(bexar_pdf$is_vote_for('Vote For Pedro'), FALSE)
    expect_equal(bexar_pdf$is_vote_for('vote for 1'), FALSE)
})


test_that("Bexar PDF is_header_footer function", {
    # Cases for Date on 3nd line of page
    expect_equal(bexar_pdf$is_header_footer('   September 3, 2019   '), TRUE)
    expect_equal(bexar_pdf$is_header_footer('May 30, 2020'), TRUE)
    
    # Cases for 1st line of each page
    expect_equal(bexar_pdf$is_header_footer('OFFICIAL RESULTS'), TRUE)
    expect_equal(bexar_pdf$is_header_footer('Summary Results Report           OFFICIAL RESULTS'), TRUE)
    
    # Cases for election description on 2nd line of each page
    expect_equal(bexar_pdf$is_header_footer(' Election'), TRUE)
    expect_equal(bexar_pdf$is_header_footer('Joint General, Special, Charter and Bond Election'), TRUE)
    expect_equal(bexar_pdf$is_header_footer('  ejs  sfo36l%%jf24lj Election'), TRUE)
    
    # Cases for page number line in footer - 2nd to last line of page
    expect_equal(bexar_pdf$is_header_footer('  Summary 3 of 39  '), TRUE)
    expect_equal(bexar_pdf$is_header_footer('Precinct Summary - 11/14/2020 11:23 AM        2 of 4,494'), TRUE)
    
    # Cases for last line of each page
    expect_equal(bexar_pdf$is_header_footer('Report generated with lots of monkeys on typewriters'), TRUE)
    expect_equal(bexar_pdf$is_header_footer('     Report generated with     spaces     before/after   keywords'), TRUE)
    
    
    expect_equal(bexar_pdf$is_header_footer('TOTAL VOTE Election Absentee Early'), FALSE)     # column names value
    expect_equal(bexar_pdf$is_header_footer('James "Jim" Wright 113 21.40% 13 13 87'), FALSE) # results value
})


test_that("Bexar PDF is_blank function", {
    expect_equal(bexar_pdf$is_blank(''), TRUE)
    expect_equal(bexar_pdf$is_blank('   '), TRUE)
    expect_equal(bexar_pdf$is_blank('e'), FALSE)
})


test_that("Bexar PDF is_useless_line function", {
    # values that would pass is_header_footer_test
    expect_equal(bexar_pdf$is_useless_line('OFFICIAL RESULTS'), TRUE)
    expect_equal(bexar_pdf$is_useless_line('May 30, 2020'), TRUE)
    expect_equal(bexar_pdf$is_header_footer('Joint General, Special, Charter and Bond Election'), TRUE)
    
    # values that would pass is_col_name test
    expect_equal(bexar_pdf$is_useless_line('TOTAL VOTE Election Absentee Early'), TRUE)
    expect_equal(bexar_pdf$is_useless_line('  Day  Voting '), TRUE)
    
    expect_equal(bexar_pdf$is_useless_line(''), TRUE)             # value that would pass is_blank test
    expect_equal(bexar_pdf$is_useless_line('Vote For 1'), TRUE)   # value that would pass is_vote_for test
    
    # Sample 'result' values
    expect_equal(bexar_pdf$is_useless_line('James "Jim" Wright 113 21.40% 13 13 87'), FALSE)
    expect_equal(bexar_pdf$is_useless_line('Total Votes Cast        528     100.00%      36     84     408'), FALSE)
    
    # Sample 'precinct' values
    expect_equal(bexar_pdf$is_useless_line('1001'), FALSE)
    
    # Sample 'office' values
    expect_equal(bexar_pdf$is_useless_line('Chief Justice, Supreme Court'), FALSE)
    expect_equal(bexar_pdf$is_useless_line('President and Vice President'), FALSE)
    expect_equal(bexar_pdf$is_useless_line('State Senator, District 26'), FALSE)

})


test_that("Bexar PDF is_result function", {
    # Random results lines from the reports
    expect_equal(bexar_pdf$is_result('James "Jim" Wright 113 21.40% 13 13 87'), TRUE)
    expect_equal(bexar_pdf$is_result('Total Votes Cast     528     100.00%     36   84   408'), TRUE)
    expect_equal(bexar_pdf$is_result('Gabriel Lara    167       36.07%  25   19    123'), TRUE)
    expect_equal(bexar_pdf$is_result('AGAINST   107   24.88%   16   12   79'), TRUE)
    expect_equal(bexar_pdf$is_result('Undervotes   45   8   8   29'), TRUE)
    
    expect_equal(bexar_pdf$is_result('1001'), FALSE)                          # precinct value
    expect_equal(bexar_pdf$is_result('State Senator, District 26'), FALSE)    # office value
    expect_equal(bexar_pdf$is_result('May 30, 2020'), FALSE)                  # header value with some numbers
    expect_equal(bexar_pdf$is_result('Precinct Summary - 11/14/2020 11:23 AM      2 of 4,494'), FALSE) # footer value with some numbers
    
})


test_that("Bexar PDF is_precinct function", {
    expect_equal(bexar_pdf$is_precinct('1001'), TRUE)
    expect_equal(bexar_pdf$is_precinct('9999'), TRUE)
    expect_equal(bexar_pdf$is_precinct('10 01'), FALSE)
    expect_equal(bexar_pdf$is_precinct('1001 BS 1'), FALSE)   # This is sometimes present in other versions of the election reports
})


test_that("Bexar PDF is_office function", {
    # Sample office values
    expect_equal(bexar_pdf$is_office('Chief Justice, Supreme Court'), TRUE)
    expect_equal(bexar_pdf$is_office('President and Vice President'), TRUE)
    expect_equal(bexar_pdf$is_office('State Senator, District 26'), TRUE)
    expect_equal(bexar_pdf$is_office('CITY OF SAN ANTONIO - PROPOSITION A'), TRUE)
    
    expect_equal(bexar_pdf$is_office('1001'), FALSE)                                                  # precinct value
    expect_equal(bexar_pdf$is_office('James "Jim" Wright      113  21.40%   13   13   87'), FALSE)    # results value
    expect_equal(bexar_pdf$is_office('May 30, 2020'), FALSE)  # header value 
    expect_equal(bexar_pdf$is_office('Precinct Summary - 11/14/2020 11:23 AM     2 of 4,494'), FALSE) # footer value 
    expect_equal(bexar_pdf$is_office("TOTAL VOTE Election Absentee Early"), FALSE)                    # col_name value
    
})


# TODO: write test to read in shortened pdf file, located at 'tests/data/bexar_pdf.pdf'
# Will not do test for downloading file at the moment.





####################################
#  DATAFRAME PROCESSING FUNCTIONS  #
####################################

# A bunch of hand-typed dataframes showing the expected results of each function
source('tests/data/sample_dataframes_bexar_pdf.R')

test_that("remove_useless_lines from lines_df", {
    expect_equal(bexar_pdf$remove_useless_lines(sample_lines_df), expected_useless_lines_removed)
})

test_that("first precinct and office values are added correctly (add_first_values)", {
    expect_equal(bexar_pdf$add_first_values(expected_useless_lines_removed), expected_first_values)
})

test_that("fill_NAs_in_vector fills in values as it should", {
    sample_vect <- c(NA, 'a', NA, NA, NA, 'b', NA, NA, 'c')
    expected_vect <- c(NA, 'a', 'a', 'a', 'a', 'b', 'b', 'b', 'c')
    expect_equal(bexar_pdf$fill_NAs_in_vector(sample_vect), expected_vect)
})

test_that("office and precinct columns are created as expected" , {
    expect_equal(bexar_pdf$create_precinct_and_office_columns(expected_useless_lines_removed), expected_filled_values)
})

test_that("remove_extra_results removes unneeded vote total rows", {
    expect_equal(bexar_pdf$remove_extra_results(expected_filled_values), expected_filtered_values)
})

test_that("extract_candidate gets candidate name as expected", {
    expect_equal(bexar_pdf$extract_candidate("John Cornyn                 123   23.08%    13   14  96"), "John Cornyn")
    expect_equal(bexar_pdf$extract_candidate("Mary \"MJ\" Hegar           283   60.73%    27   54  202"), "Mary \"MJ\" Hegar")
}) 

test_that("extract_total_votes gets only the total # votes for a candidate", {
    expect_equal(bexar_pdf$extract_total_votes("Howie Hawkins /Angela Walker       2        0.37%    1    0    1"), "2")
    expect_equal(bexar_pdf$extract_total_votes("David B. Collins                   3,235    0.75%    1    0    3"), "3,235")
})

test_that("create_candidate_and_votes_columns", {
    expect_equal(bexar_pdf$create_candidate_and_votes_columns(expected_filtered_values), expected_candidate_and_votes)
})

test_that("add_metadata_to_df", {
    expect_equal(bexar_pdf$add_metadata_to_df(expected_candidate_and_votes), expected_full_df)
})

test_that("get_full_df_from_lines", {
    expect_equal(bexar_pdf$get_full_df_from_lines(sample_lines_df), expected_full_df)
})

