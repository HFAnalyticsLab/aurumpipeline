


## create obs parquet file
aurum_pipeline(type = 'Observation'
               , dataloc = here::here('tests')
               , saveloc = tmpdir)

## load codelists
codes <- read_multimorb_codelists(codeloc = here::here('tests', 'sample_codelists'),
                                  file_pattern = 'list')

#double check can open it 
#opendt(file.path(tmpdir, 'data/Observation/1/data.parquet'))


test_that('We can match run the function without error', {
  
  expect_error(get_codes(dataloc = file.path(data_proc, 'Observation'),
                        enddate = as.Date('2020-01-01'),
                        codelist = codes)
               , NA)
  
})


### remove obs parquet files
if (file.exists(file.path(tmpdir, 'data/Observation/1/data.parquet'))){
  
  file.remove(file.path(tmpdir, 'data/Observation/1/data.parquet'))
  
}
