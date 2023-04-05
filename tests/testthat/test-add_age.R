
aurum_pipeline(type = 'Patient' ### create patient parquet
               , dataloc = file.path(test_loc, 'tests')
               , saveloc = tmpdir)
  
pats <- opendt(file.path(tmpdir, 'Patient/')) ## open pats
  
test_that('Add_age works', {  
  
  expect_error(add_age(pats), NA) ## add age works
    
  pats <- add_age(pats) ## use it
    
  expect_true(is.numeric(pats$age)) ## check age is numeric
  expect_true(is.factor(pats$ageband)) ## check ageband is char
    
  ## clean up after testing             
  #rm(pats)
    
})
