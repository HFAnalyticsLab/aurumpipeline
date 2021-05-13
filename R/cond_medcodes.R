## function to get conditions from medcodes in observation data
## Requires a defined codeslist with read time for each condition
## (how far back to look for observations in days)

#' Conditions from medcodes
#'
#' @param diag_obs observation data 
#' @param codelist codelist of conditions
#' @param var_name column to read conditions from in codelist
#' @param enddate date to record conditions to
#'
#' @return data.table() of medcodes and conditions
#' @export
#'
#' @examples \dontrun{
#' cond_medcodes(diag_obs = diag_obs
#' , codelist = codelist, var_name = 'Colname', enddate = '2016-01-01')}
cond_medcodes <- function(diag_obs, codelist, var_name, enddate){
  
  ## define vars to avoid check() notes:
  . <- medcodeid <- obsdate <- read <- other_conds <- NULL
  
  enddate <- as.Date(enddate) ## make sure date format for time calc
  
  ### dates for disease diagnoses, cancer first as treated differently
  if('cancer' %in% codelist[, get(var_name)]){
    
    cancer <- diag_obs[codelist[get(var_name) == 'cancer'], on = .(medcodeid)][ #restrict to relevant medcodes using a join
      order(obsdate), .SD[.N], by = c('patid', var_name)][ #retain newest cancer record per patient
        obsdate < enddate & obsdate >= (enddate - read)][ #see if newest was in last 5 years
          , .(mcount = 1, oldest_cond = min(obsdate), recent_cond = max(obsdate)) ## both dates are the same as only most recent diagnoses kept
          , by = c('patid', var_name, 'read')]
    
  } else {
    
    cancer <- data.table::data.table()
    
  }
  
  # other conditions by medcode
  other_conds <- diag_obs[codelist[get(var_name) != 'cancer'], on = .(medcodeid), allow.cartesian = TRUE][ #restrict to relevant medcodes using a join
    obsdate < enddate & obsdate >= (enddate - read)][ #restrict to required date range
      , .(mcount = .N, oldest_cond = min(obsdate), recent_cond = max(obsdate))
      , by = c('patid', var_name, 'read')] #count by patient/condition
  
  return(rbind(cancer, other_conds))
  
}
