### adding basic variables and saving updated parquet files - patient data
#' Derive age and age band from year of birth
#'
#' @param data a data table of patient data including at least patient id and age
#' @param write boolean to save as parquet file
#' @param measurefrom date to measure patient age at (eg registration date)
#' @return data.table() of patient data with age and age band appended
#' @export
add_age <- function(data
                    , write = FALSE
                    , measurefrom = Sys.time()){
  
  age <- ageband <- NULL ## to avoid R CMD warnings or notes
  
  pats <- data
  pats$age <- lubridate::year(measurefrom) - pats$yob
  
  pats[, ageband := ifelse(age < 18, 'Under 18', ifelse(age < 25, '18-24',
                    ifelse(age < 35, '25-34', ifelse(age < 45, '35-44',
                    ifelse(age < 55, '45-54', ifelse(age < 65, '55-64',             
                    ifelse(age < 75, '65-74', '75+')))))))]
  
  pats$ageband <- factor(pats$ageband, levels = c('Under 18', '18-24', '25-34'
                                                  , '35-44', '45-54', '55-64', '65-74', '75+'))
  
  if (write) {
    
    if (saveloc == '') { ## if no save location default to current project directory
      
      saveloc = here::here()
      
    }
    
    dir.create(file.path(saveloc, 'Data', 'Patient_update'), recursive = TRUE, showWarnings = FALSE) #create output subfolder
    arrow::write_parquet(pats, file.path(saveloc, 'Data', 'Patient_update', 'data.parquet'))
    
  }
  
  return(pats)
  
}
