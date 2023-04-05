### declare global variables or data:
utils::globalVariables(c('tabledata'))



# Function to determine if dates are in future
#' Future Date Check
#'
#' @param x Date
#'
#' @return Boolean
#' @export
#'
#' @examples
#' future_date('2020-10-10')
future_date <- function(x){
  today <- Sys.Date() #store today's date
  ifelse(is.na(x), FALSE, x > today) #return FALSE unless there is a date which is in the future
}

## filepath identifying/cleaning function
#' Filepath Identifier
#'
#' @param f_path character
#'
#' @return vector
#' @export
#'
#' @examples
#' path_id('s3://thf-dap-tier3-projects-test123-8681-projectbucket-di2wwm3vl5fz/Data/Patient')
path_id <- function(f_path) {
  
  ## check if s3 location for save location and set up bucket if so
  if(substr(f_path, 1, 5) == 's3://'){
    
    ## s3 loc needs '/' at the end - check and add if missing
    if(stringr::str_sub(f_path, -1) != '/'){
      f_path <- paste0(f_path, '/')}
    
    keep_me <- unlist(gregexpr(pattern = '/', f_path))[-c(1 ,2)] ## nchar loc of '/' skipping the first 2
    
    saveloc_s3 <- substr(f_path, min(keep_me) + 1, max(keep_me))
    save_bucket <- substr(f_path, 6, min(keep_me) - 1)
    
    ## watch out for double forward slashes (S3 URIs end in a slash, most filespaths don't)
    saveloc_s3 <- gsub('//', '/', saveloc_s3)
    
    return(list(saveloc_s3, save_bucket, TRUE))
    
  } else {
    
    return(list(f_path, '', FALSE))
    
  }
  
}