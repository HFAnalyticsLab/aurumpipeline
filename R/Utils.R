### declare global variables or data:
utils::globalVariables(c('tabledata', 'cons_mode', 'jobtype'))



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

