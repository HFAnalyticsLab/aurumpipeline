### Testing checkvars

## create pipeline output
pat_output <- aurum_pipeline(type = 'Patient'
                             , dataloc = syn_data_loc
                             , saveloc = tmpdir)

obs_output <- aurum_pipeline(type = 'Observation' ### create obs parquet (should be available for all)
                            , dataloc = syn_data_loc
                            , saveloc = tmpdir)

test_that('checkvars can combine pipeline output', {
  
  expect_error(check_vars('Patient', data = pat_output), ## patient info
             NA) ## no errors running check function
  
  expect_error(check_vars('Observation', data = obs_output), ## patient info
               NA) ## no errors running check function
  

})
