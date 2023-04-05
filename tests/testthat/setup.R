## always devtools::check(cran = FALSE)
## library path R:/R_repository/bin/windows/contrib/4.0



### create temp dir for test files

tmpdir <- tempdir()

### data location for tests (CMD check tests run in different wd to devtools::test())
test_loc <- here::here() %>% gsub('tests/testthat/', '', ., fixed = TRUE)

## identify whether running on AWS

aws_os <- devtools::session_info()[1]$platform$os == 'Amazon Linux 2'
aws_system <- devtools::session_info()[1]$platform$system == 'x86_64, linux-gnu'

aws <- aws_os & aws_system ## use this to run the correct tests