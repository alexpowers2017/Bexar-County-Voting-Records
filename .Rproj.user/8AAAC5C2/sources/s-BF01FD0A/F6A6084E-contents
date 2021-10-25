
source('test-setup_report_tests.R')

sample_bexar_pdf_bs_report <- ElectionReport_BexarPDF_BS$new(sample_row)

test_that("Properties are assigned correctly on initialization", {
    expect_equal(sample_bexar_pdf_bs_report$description, 'sample description')
    expect_equal(sample_bexar_pdf_bs_report$date, mdy('August-3-2021'))
    expect_equal(sample_bexar_pdf_bs_report$election_type, 'sample election type')
    expect_equal(sample_bexar_pdf_bs_report$county, 'sample county')
    expect_equal(sample_bexar_pdf_bs_report$report_type, 'sample report type')
    expect_equal(sample_bexar_pdf_bs_report$url, 'sample url')
})

test_that("file_path function was inherited correctly", {
    expect_equal(sample_bexar_pdf_bs_report$get_file_path(), 'data/election_reports/sample description 2021-08-03.pdf')
})


test_that("is_precinct function also includes values with 'BS' suffix", {
    expect_equal(sample_bexar_pdf_bs_report$is_precinct('1001'), TRUE)
    expect_equal(sample_bexar_pdf_bs_report$is_precinct('9999'), TRUE)
    expect_equal(sample_bexar_pdf_bs_report$is_precinct('10 01'), FALSE)
    expect_equal(sample_bexar_pdf_bs_report$is_precinct('1001 BS 1'), TRUE)   
})


test_that("remove_bs function returns pure precinct values", {
    expect_equal(sample_bexar_pdf_bs_report$remove_bs('1001 BS 1'), '1001')
    expect_equal(sample_bexar_pdf_bs_report$remove_bs('1001'), '1001')
    expect_equal(sample_bexar_pdf_bs_report$remove_bs('1001 BS'), '1001 BS')
})


test_that("is_col_name identifies column names correctly", {
    expect_equal(sample_bexar_pdf_bs_report$is_col_name("TOTAL"), TRUE)
    expect_equal(sample_bexar_pdf_bs_report$is_col_name("   TOTAL"), TRUE)
    
    expect_equal(sample_bexar_pdf_bs_report$is_col_name("Registered Voters - Total        2,618"), FALSE)
    expect_equal(sample_bexar_pdf_bs_report$is_col_name("Statistics                             TOTAL"), FALSE)
})


test_that("is_result correctly identifies results", {
    expect_equal(sample_bexar_pdf_bs_report$is_result('Desi Martinez                                8'), TRUE)
    expect_equal(sample_bexar_pdf_bs_report$is_result('Registered Voters - Total                  547'), TRUE)
    expect_equal(sample_bexar_pdf_bs_report$is_result('Voter Turnout - Total                   5.85%'), TRUE)
    expect_equal(sample_bexar_pdf_bs_report$is_result('  Overvotes                                  2'), TRUE)
    expect_equal(sample_bexar_pdf_bs_report$is_result('  Undervotes                                 0'), TRUE)
    
    expect_equal(sample_bexar_pdf_bs_report$is_result('  State Representative, District 118'), FALSE)
    expect_equal(sample_bexar_pdf_bs_report$is_result('Precinct Summary - 10/06/2021   12:25 PM                            1 of 68'), FALSE)
    expect_equal(sample_bexar_pdf_bs_report$is_result('Report generated with Electionware Copyright © 2007-2020'), FALSE)
    
})


test_that("is_office correctly identifies office", {
    expect_equal(sample_bexar_pdf_bs_report$is_office('  State Representative, District 118'), TRUE)
    expect_equal(sample_bexar_pdf_bs_report$is_office('Statistics                             TOTAL'), TRUE)
})






test_that("is_header_footer function correctly identifies header and footer lines", {
    
    # Cases for Date on 3nd line of page
    expect_equal(sample_bexar_pdf_bs_report$is_header_footer('   September 3, 2019   '), TRUE)
    expect_equal(sample_bexar_pdf_bs_report$is_header_footer('May 30, 2020'), TRUE)
    
    # Cases for 1st line of each page
    expect_equal(sample_bexar_pdf_bs_report$is_header_footer('OFFICIAL RESULTS'), TRUE)
    expect_equal(sample_bexar_pdf_bs_report$is_header_footer('Summary Results Report           OFFICIAL RESULTS'), TRUE)
    expect_equal(sample_bexar_pdf_bs_report$is_header_footer('OFFICIAL RESULTS '), FALSE)
    
    # Cases for election description on 2nd line of each page
    expect_equal(sample_bexar_pdf_bs_report$is_header_footer(' Election'), TRUE)
    expect_equal(sample_bexar_pdf_bs_report$is_header_footer('St Rep 118 Special Election'), TRUE)
    expect_equal(sample_bexar_pdf_bs_report$is_header_footer('  ejs  sfo36l%%jf24lj Election'), TRUE)
    
    # Cases for page number line in footer - 2nd to last line of page
    expect_equal(sample_bexar_pdf_bs_report$is_header_footer('Precinct Summary - 10/06/2021   12:25 PM                            1 of 68'), TRUE)
    expect_equal(sample_bexar_pdf_bs_report$is_header_footer('Summary 3  of  39'), FALSE)
    expect_equal(sample_bexar_pdf_bs_report$is_header_footer('Summary 1 of all'), FALSE)
    
    # Cases for last line of each page
    expect_equal(sample_bexar_pdf_bs_report$is_header_footer('Report generated with lots of monkeys on typewriters'), TRUE)
})



