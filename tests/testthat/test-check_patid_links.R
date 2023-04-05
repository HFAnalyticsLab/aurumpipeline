
## create parquet files
aurum_pipeline(type = 'Patient'
                             , dataloc = here::here('tests')
                             , saveloc = tmpdir)

aurum_pipeline(type = 'Observation' ### create obs parquet (should be available for all)
                             , dataloc = here::here('tests')
                             , saveloc = tmpdir)

test_that('check_patid_links can check pipeline output', {
  
  expect_error(check_patid_links(dataloc = tmpdir
                                 , dts = 'Observation'), ## checking observation only but all use the same code
               NA) ## no errors running check function
  

})
