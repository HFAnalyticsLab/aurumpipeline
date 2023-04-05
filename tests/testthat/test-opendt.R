### Testing opendt

test_that('Opendt works correctly', {
  
  expect_error(opendt(file.path(tmpdir, 'Patient')), NA) ## can open the file
  
  expect_error(opendt(file.path(tmpdir, 'Patient'),
                      cols_in = c('patid', 'gender')),
               NA) ## can open the file with column specification
  
  expect_error(opendt(file.path(tmpdir, 'Patient'),
                      date_in = 'regstartdate',
                      start_date = '2021-01-01',
                      end_date = '2018-01-01'),
               NA) ## can open the file with date specification
  
  patlist <- data.table(patid = 5371880837297113105)
  expect_error(opendt(file.path(tmpdir, 'Patient'),
                      patient_list = patlist),
               NA) ## can open the file with patient list
  
  ## clean up after testing             
  #rm(pats) don't do this(!)
  
  ## R should clean all temp dirs after session close
  #on.exit(unlink(tmpdir, recursive = TRUE)) ## only do this at the end
  
})