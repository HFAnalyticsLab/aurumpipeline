#' Read in Multimorbidity Codelists
#'
#' @param codeloc Either a character string filepath to folder containing the codelists, or an s3 URI
#' @param file_pattern Use only the codelists with this in their name (currently non-s3 only)
#' @param coltypes If data types are known
#' 
#' @return data.table() of combined codelists
#' @export
#'
read_multimorb_codelists <- function(codeloc, file_pattern = NULL, coltypes = NULL){
  
  ## declare variables
  medcodeid <- disease <- category <- read <- NULL
  
  read_s3 <- path_id(codeloc)
  
  if (!read_s3[[3]]){ ## original method (non AWS)
    
    ## get files and read in
    files <- list.files(here::here(codeloc), pattern = file_pattern, full.names = TRUE) #look for code lists
    
    fileext <- substr(files[1], nchar(files[1]) - 3, nchar(files[1]))
    
    if (fileext == '.csv'){
      
      codes <- purrr::map(files, vroom::vroom, delim = ',', col_types = coltypes)
      
    } else {
      
      codes <- purrr::map(files, readxl::read_excel, col_types = coltypes)  ## defaults to first sheet
      
    }
    
  } else {
    
    ## s3 method get all files in bucket and codeloc path
    files <- aws.s3::get_bucket(read_s3[[2]],
                                prefix = read_s3[[1]],
                                max = Inf) %>% rbindlist() #look for code lists
    
    ## remove subfolders and keep only .csv or .xls or .xlsx
    ## any further '/' will indicate a subfolder so remove them
    keep_me <- stringr::str_locate_all(pattern = '/', files$Key) %>% mapply(FUN = max) <= nchar(codeloc)
    
    files <- files[keep_me, ] %>% unique()
    
    fileext <- substr(files$Key, nchar(files$Key) - 3, nchar(files$Key)) == file_pattern
    
    files <- files[fileext, ]
    
    if (file_pattern == '.csv'){
      
      codes <- purrr::map(files$Key,
                          ~ aws.s3::s3read_using(FUN = vroom::vroom,
                                                 object = .x,
                                                 bucket = read_s3[[2]],
                                                 col_types = coltypes))
      
    } else {
      
      codes <- purrr::map(files$Key,
                          ~ aws.s3::s3read_using(FUN = readxl::read_excel,
                                                 object = .x,
                                                 bucket = read_s3[[2]],
                                                 col_types = coltypes))
    }
    
  }
  
  ## get only where there is a medcodeid and format correctly
  data <- data.table::rbindlist(codes)
  data.table::setDT(data)
  
  data.table::setnames(data, tolower(names(data))) ## lower case column names
  
  if('medcodeid' %in% names(data)){
    
    data <- data[!is.na(medcodeid), ]
    data$medcodeid <- bit64::as.integer64(data$medcodeid)
    
  }
  
  ### how far to look back for diagnoses, add to this list as we develop this method
  if('system' %in% names(data)){
    
    data$read <- ifelse(data$system == 'Cancers', 5*365.25,
                        ifelse(data$system == 'Mental Health Disorders', 365, 9999999))
    
  }
  
  if('disease' %in% names(data)){
    
    data$disease <- gsub(' ', '_', data$disease)
    
  }
  
  return(data)
  
}
