

source('test-setup_report_tests.R')


sample_report <- ElectionReport$new(sample_row)

test_that("ElectionReport superclass init", {
    expect_equal(sample_report$description, 'sample description')
    expect_equal(sample_report$date, mdy('August-3-2021'))
    expect_equal(sample_report$election_type, 'sample election type')
    expect_equal(sample_report$county, 'sample county')
    expect_equal(sample_report$report_type, 'sample report type')
    expect_equal(sample_report$url, 'sample url')
})

test_that("ElectionReport file_path function", {
    expect_equal(sample_report$get_file_path(), 'data/election_reports/sample description 2021-08-03.pdf')
})
