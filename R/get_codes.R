### allow observation/drugissue data to be passed or if missing, load in, and flag for either

#' Get (med/prod)codes from data
#'
#' @param dataloc path to aurum data files
#' @param startdate date to include observations / drug issues from
#' @param enddate date to include observations / drug issues to
#' @param recs observation or drug issue data if already in environment
#' @param obsflag flag to indicate observation (T) or drug issue (F)
#' @param codelist existing codelist (medcodes for obsevations, prodcodes for drug issues)
#'
#' @return data.table() of relevent codes
#' @export
#'
#' @examples \dontrun{
#' diag_obs_test <- get_codes(enddate = '2016-01-01', codelist = medcodelist)}
get_codes <- function(dataloc = ''
                      , startdate = '1800-01-01'
                      , enddate
                      , recs = NULL
                      , obsflag = T
                      , codelist){
  
  ## declare vars to avoid check() notes:
  medcodeid <- obstypeid <- . <- patid <- obsdate <- prodcodeid <- NULL
  
  if (obsflag){ ## if observation set correct names
    
    cols_in <- c('patid', 'medcodeid', 'obsdate', 'obstypeid')
    date_in <- 'obsdate'
    
    if (dataloc == '') {dataloc = 'Observation'} ## set location if default
    
  } else { ## set for drugissue
    
    cols_in = c('patid', 'prodcodeid', 'issuedate')
    date_in = 'issuedate'
    
    if (dataloc == '') {dataloc = 'DrugIssue'} ## set location if default
    
  }
  
  if (is.null(recs)){ ##if no data supplied get it
    
    recs <- opendt(dataloc ## get data before required date
                   , cols_in = cols_in
                   , date_in = date_in
                   , start_date = '1800-01-01'
                   , end_date = enddate)
    
  } else { ## if data supplied filter it
    
    recs <- recs[date_in >= startdate & date_in <= enddate, cols_in]
    
  }
  
  ## then filter:
  if(obsflag){
    
    recs <- recs[medcodeid %in% codelist$medcodeid & obstypeid != 4, ] %>%
      .[, .(patid, medcodeid, obsdate)] %>% #select columns
      unique() ## remove duplicates
    
  } else {
    
    recs <- recs[prodcodeid %in% codelist$prodcodeid, ] %>%
      unique() ## remove duplicates
    
  }
  
  gc()
  return(recs)
  
}
