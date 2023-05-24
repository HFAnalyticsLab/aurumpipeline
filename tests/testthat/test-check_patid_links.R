
test_that('check_patid_links can check pipeline output', {
  
  expect_error(check_patid_links(dataloc = data_proc
                                 , dts = 'Observation'), ## checking observation only but all use the same code
               NA) ## no errors running check function
  

})
