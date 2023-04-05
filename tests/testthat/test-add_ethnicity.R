## Testing add_ethnicity
## need to create dummy data to test on
## code to do that for observations:
# 
# data.table::data.table(
# 
#  patid = stringi::stri_rand_strings(10, sample(9:19, 10), pattern = '[0-9]')
#   , consid = stringi::stri_rand_strings(10, sample(9:19, 10), pattern = '[0-9]')
#   , pracid = stringi::stri_rand_strings(10, 5, pattern = '[0-9]')
#   , obsid = stringi::stri_rand_strings(10, sample(9:19, 10), pattern = '[0-9]')
#   , obsdate = as.Date('2020-12-31') - sample(1:365 * 50, 10)
#   , enterdate = as.Date('2020-12-31') - sample(1:365 * 50, 10)
#   , staffid = stringi::stri_rand_strings(10, sample(4:10, 10, replace = T), pattern = '[0-9]')
#   , parentobsid = stringi::stri_rand_strings(10, sample(9:19, 10), pattern = '[0-9]')
#   , medcodeid = stringi::stri_rand_strings(10, sample(6:18, 10), pattern = '[0-9]')
#   , value = sample(0:500, 10, replace = T)
#   , numintid = sample(1:10, 10, replace = T)
#   , obstypeid = sample(1:15, 10, replace = T)
#   , numrangelow = sample(0:500, 10, replace = T)
#   , numrangehigh = sample(0:500, 10, replace = T)
#   , probobsid = stringi::stri_rand_strings(10, sample(9:19, 10), pattern = '[0-9]')
#
# 
# ) %>% write.table(file = './tests/Observation_dummy.txt'
#                   , sep = '\t'
#                   , row.names = FALSE
#                   , quote = FALSE)

obs_check <- aurum_pipeline(type = 'Observation' ### create obs parquet (not available for all tests)
                 , dataloc = file.path(test_loc, 'tests') ## but parquet file is
                 , saveloc = tmpdir)
  
eth_obs <- opendt(file.path(tmpdir, 'Observation')) ## can open the file
  
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