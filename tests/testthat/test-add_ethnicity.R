## Testing add_ethnicity

obs_check <- aurum_pipeline(type = 'Observation' ### create obs parquet (not available for all tests)
                 , dataloc = syn_data_loc ## but parquet file is
                 , saveloc = tmpdir
                 , check = TRUE)
  
eth_obs <- opendt(file.path(tmpdir, 'Check/Observation/')) ## can open the file

eth_codelist <- data.table::data.table(
     
    medcodeid = sample(eth_obs$medcodeid, 20, replace = TRUE)
    , Group1 = sample(1:5, 20, replace = TRUE)
    , Group2 = sample(1:16, 20, replace = TRUE)
      
)
  
test_that('add_ethincity works', {  
    
  expect_error(add_ethnicity(eth_obs, eth_codelist, fieldnames = c('Group1', 'Group2'))
               , NA) ## add age works
  
  eth_result <- add_ethnicity(eth_obs, eth_codelist, fieldnames = c('Group1', 'Group2'))
    
  expect_true(is.numeric(eth_result$Group1))    
  expect_true(is.numeric(eth_result$Group2))    
    
})
