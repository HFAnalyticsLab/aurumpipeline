## Testing aurum_pipeline
## need to create dummy data to test on
## code to do that for patients:
# 
# data.table::data.table(
# 
#   patid = stringi::stri_rand_strings(10, 19, pattern = '[0-9]')
#   , pracid = stringi::stri_rand_strings(10, 5, pattern = '[0-9]')
#   , usualgpstaffid = stringi::stri_rand_strings(10, 10, pattern = '[0-9]')
#   , gender = stringi::stri_rand_strings(10, 1, pattern = '[1-4]')
#   , yob = sample(1900:2020, 10, replace = T)
#   , mob = sample(1:12, 10, replace = T)
#   , regstartdate = as.Date('2020-12-31') - sample(1:365 * 50, 10)
#   , patienttypeid = sample(1:32, 10, replace = T)
#   , regenddate = as.Date('2020-12-31') - sample(1:365 * 50, 10)
#   , acceptable = rep(1, 10)
#   , cprd_ddate = as.Date('2020-12-31') - sample(1:365 * 50, 10)
# 
# ) %>% write.table(file = './tests/patient_dummy.txt'
#                   , sep = '\t'
#                   , row.names = FALSE
#                   , quote = FALSE)

test_that('Patients data source not given correctly', {
  expect_error(aurum_pipeline(type = 'Patient'
              , dataloc = './tests/doesnt_exist'
              , saveloc = tmpdir))

  ## clean up after testing             
  # on.exit(unlink(tmpdir, recursive = TRUE))

})

test_that('Pipeline creates file that can be read', {
  
  ## because tests are run in alphabetical order this already exists
  #expect_false(file.exists(file.path(tmpdir, 'data/Patient/1/data.parquet'))) ## doesn't exist to start with
  
  aurum_pipeline(type = 'Patient'
                 , dataloc = syn_data_loc
                 , saveloc = tmpdir)
  
  expect_true(file.exists(file.path(tmpdir, 'Patient/1/data.parquet'))) ## does now
  
  expect_error(arrow::read_parquet(file.path(tmpdir, 'Patient/1/data.parquet')), NA) ## can open the file
  
  expect_error(aurum_pipeline(type = 'Patient'
                              , dataloc = syn_data_loc
                              , saveloc = tmpdir),
               NA) ## no errors running pipeline function

  expect_error(aurum_pipeline(type = 'Patient'
                              , dataloc = syn_data_loc
                              , saveloc = tmpdir
                              , check = TRUE
                              , patids = 5371880837297113105),
               NA) ## no errors running pipeline with all args
  
  ## clean up after testing
  if (file.exists(file.path(tmpdir, 'Patient/1/data.parquet'))){
    
    file.remove(file.path(tmpdir, 'Patient/1/data.parquet'))
    
  }
  
  #rm(pats)

})

### For AWS S3 testing:
if(aws){
  
  test_that('Pipeline creates file that can be read', {

    aurum_pipeline(type = 'Staff'
                   , dataloc = syn_data_loc
                   , saveloc = tmpdir
                   , cols = 'dii'
                   , check = TRUE)

    expect_true(file.exists(file.path(tmpdir, 'Check/Staff/1/data.parquet'))) ## does now
    
    if (file.exists(file.path(tmpdir, 'Check/Staff/1/data.parquet'))){
      
      file.remove(file.path(tmpdir, 'Check/Staff/1/data.parquet'))
      
    } 
    
    aurum_pipeline(type = 'Staff'
                   , dataloc = syn_data_loc
                   , saveloc = tmpdir
                   , check = TRUE)
    
    expect_true(file.exists(file.path(tmpdir, 'Check/Staff/1/data.parquet'))) ## does now
    
    
    }) # end test that
  
    ## clean up after testing
    if (file.exists(file.path(tmpdir, 'Check/Staff/1/data.parquet'))){
      
      file.remove(file.path(tmpdir, 'Check/Staff/1/data.parquet'))
      
    } # end clean
    
} # end aws tests
