#' Metadata about CPRD table structure
#' 
#' A dataset with information on CPRD tables and variable formats
#' 
#' @format A tibble with 8 rows and 3 variables:
#' \describe{
#' \item{table_name}{The tables from a CPRD Aurum extract}
#' \item{cols}{The data types of the variables (from the DFPC extract)}
#' \item{main_date}{The most commonly used date for each table (where it exists)}
#' }
'tabledata'
