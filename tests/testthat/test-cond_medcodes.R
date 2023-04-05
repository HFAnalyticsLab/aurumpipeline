### Testing codelist use

codes <- read_multimorb_codelists(codeloc = here::here('tests', 'sample_codelists'),
                                  file_pattern = 'list')

### create observations

obs <- data.table::data.table(
  
  patid = stringi::stri_rand_strings(10, sample(9:19, 10), pattern = '[0-9]')
  , consid = stringi::stri_rand_strings(10, sample(9:19, 10), pattern = '[0-9]')
  , pracid = stringi::stri_rand_strings(10, 5, pattern = '[0-9]')
  , obsid = stringi::stri_rand_strings(10, sample(9:19, 10), pattern = '[0-9]')
  , obsdate = as.Date('2020-12-31') - sample(1:365 * 50, 10)
  , enterdate = as.Date('2020-12-31') - sample(1:365 * 50, 10)
  , staffid = stringi::stri_rand_strings(10, sample(4:10, 10, replace = T), pattern = '[0-9]')
  , parentobsid = stringi::stri_rand_strings(10, sample(9:19, 10), pattern = '[0-9]')
  , medcodeid = sample(codes$medcodeid, 10)
  , value = sample(0:500, 10, replace = T)
  , numintid = sample(1:10, 10, replace = T)
  , obstypeid = sample(1:15, 10, replace = T)
  , numrangelow = sample(0:500, 10, replace = T)
  , numrangehigh = sample(0:500, 10, replace = T)
  , probobsid = stringi::stri_rand_strings(10, sample(9:19, 10), pattern = '[0-9]')
)


test_that('We can match observations to codelists', {
  
  expect_error(cond_medcodes(obs, codes, 'disease', as.Date('2020-01-01'))
               , NA)
  
})

test_that('The columns created are the correct format', {
  
  proc_codes <- cond_medcodes(obs, codes, 'disease', as.Date('2020-01-01'))

  expect_true(is.numeric(proc_codes$mcount))
  expect_true(lubridate::is.Date(proc_codes$oldest_cond))
  expect_true(lubridate::is.Date(proc_codes$recent_cond))
  
})
