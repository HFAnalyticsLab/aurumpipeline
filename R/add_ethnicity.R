# this gets all ethnicity observations and takes the most common for each patient
# in the case of a tie it takes the most recent observation
## for those with no multiple ethnicities recorded the same number of times
#' Ethnicity Coding
#'
#' @param obs observation data (requires fields obsdate, medcodeid, patientid)
#' @param codelist code list of defined ethnicity medcodes (requires medcodeid and ethnicity columns)
#' @param fieldnames character vector of ethnicity columns to keep from codelist
#'
#' @return data.table() of matched patient ids with ethnicity columns
#' @export
add_ethnicity <- function(obs, codelist, fieldnames) {
  
  ## Declare variables
  N <- . <- patid <- count <- obsdate <- NULL
  
  fieldnames <- c('patid', fieldnames)
  
  ethCPRD <- obs[codelist, on = 'medcodeid', nomatch = 0] #join onto ethcodes (keeping only records matching with ethcodes)
  
  ethCPRD_a <- ethCPRD[, .N, by = fieldnames][ #count codings by patient and ethnicity
    , max := max(N), by = .(patid)][ #identify max count by patid
      max == N][ #restrict to those ethnicities that are equal to their max count
        , count := .N, by = .(patid)][ #count number of remaining records per patient (to identify ties)
          count == 1, fieldnames, with = F] #keep only patients with no ties, and keep only patid and ethnic5
  
  fieldnamesdate <- c(fieldnames, 'obsdate')
  
  ## this gets all ethnicity observations that have the same number of different ethnicities recorded
  ethCPRD_b <- ethCPRD[, .(obsdate = max(obsdate), N = .N), by = fieldnames][ #count codings by patient and ethnicity
    , max := max(N), by = .(patid)][ #identify max count by patid
      max == N][ #restrict to those ethnicities that are equal to their max count
        , count := .N, by = .(patid)][ #count number of remaining records per patient (to identify ties)
          count > 1, fieldnamesdate, with = F][ #keep only patients with ties, keep observation date as well
            , .SD[which.max(obsdate)], by = patid][ ## keep only the most recent obs
              ## NOTE there may be times there are ties with the observation date
              ## will need to address this if it happens - although will be a very small number
              , fieldnames, with = F] ## remove date col
  
  ethCPRD <- rbind(ethCPRD_a, ethCPRD_b)
  
  return(ethCPRD)
  
}
