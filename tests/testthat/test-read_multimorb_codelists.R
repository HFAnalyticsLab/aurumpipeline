### Testing read_multimorb_codeslists

## csv first
test_that('we can read in dummy codelists', {
  
  expect_error(read_multimorb_codelists(codeloc = here::here('tests', 'sample_codelists'),
                                              file_pattern = 'list')
               , NA)

})

test_that('medcodeid is the correct format', {
  
  codes <- read_multimorb_codelists(codeloc = here::here('tests', 'sample_codelists'),
                                    file_pattern = 'list')
  
  expect_true(bit64::is.integer64(codes$medcodeid))

})

## test for excel worksheet
test_that('we can read in dummy codelists', {
  
  expect_error(read_multimorb_codelists(codeloc = here::here('tests', 'sample_codelists'),
                                        file_pattern = 'excel')
               , NA)
  
  
})

test_that('medcodeid is the correct format', {

  codes2 <- read_multimorb_codelists(codeloc = here::here('tests', 'sample_codelists'),
                                     file_pattern = 'excel')
  
  expect_true(bit64::is.integer64(codes2$medcodeid))
  
})

## AWS S3 testing:
if(aws){
  
  test_that('we can read in codelists from S3', {
    
    expect_error(read_multimorb_codelists(codeloc = codelist_loc,
                                          file_pattern = 'acne.csv')
                 , NA)
    })
  
}