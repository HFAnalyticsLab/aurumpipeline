#' Read in Multimorbidity Codelists
#'
#' @param codeloc Character string filespath to folder containing the codelists
#' @param file_pattern Use only the codelists with this in their name
#' @param coltypes If data types are known
#'
#' @return data.table() of combined codelists
#' @export
#'
read_multimorb_codelists <- function(codeloc, file_pattern = NULL, coltypes = NULL){
  
  ## declare variables
  medcodeid <- disease <- category <- read <- NULL
  
  ## get files and read in
  files <- list.files(here::here(codeloc), pattern = file_pattern, full.names = TRUE) #look for drug lists
  
  fileext <- substr(files[1], nchar(files[1]) - 3, nchar(files[1]))
  
  if (fileext == '.csv'){
    
    codes <- purrr::map(files, vroom::vroom, delim = ',', col_types = coltypes)
    
  } else {
    
    codes <- purrr::map(files, readxl::read_excel, col_types = coltypes)  
    
  }
  
  ## get only where there is a medcodeid and format correctly
  data <- data.table::rbindlist(codes)
  data.table::setDT(data)
  data <- data[!is.na(medcodeid), ]
  data$medcodeid <- bit64::as.integer64(data$medcodeid)
  
  data$read <- ifelse(data$system == 'Cancers', 5*365.25,
                      ifelse(data$system == 'Mental Health Disorders', 365, 9999999))
  
  data <- data <- data %>% dplyr::select(disease, category, system, medcodeid, read)
  
  data$disease <- gsub(' ', '_', data$disease)
  
  return(data)
}
