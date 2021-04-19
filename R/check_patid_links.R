#Check all data links to available patients ----
#' Check patients id links
#'
#' @param dataloc character filepath to parquet data folder (default to project directory)
#' @param dts character vector of activities to check
#'
#' @return Results of link tests as data.frame()
#' @export
#'
#' @examples \dontrun{
#' check_patid_links()}
check_patid_links <- function(dataloc = ''
                            , dts = c('Consultation', 'Observation', 'Referral', 'DrugIssue', 'Problem')){
  
  linked <- . <- NULL ## avoid R CMD notes for visible binding and global functions
  
  if (dataloc == '') { ## if no data location default to current project directory
    
    dataloc = here::here()
    
  }
  
  pats <- opendt(file.path(dataloc, 'Data', 'Patient')
                 , cols_in = c('patid')) %>% .[, linked := TRUE] #open patient dataset and add flag for use below
  
  #Function to check linkage of patients to activity datasets
  check_linkage <- function(activity_in){
    
    m1 <- opendt(data_in = file.path(dataloc, 'Data', activity_in)
                 , cols_in = 'patid') %>% #open activity data
      merge(pats, by = 'patid', all.x = TRUE) #merge patients onto activity data
    r <- nrow(m1) #get number of rows in merged/activity data 
    print(m1[linked == TRUE, .(activity = activity_in
                               , n_rows = r, perc_linked = 100 * .N / r)]) #print and return result
  }

  # run check_linkage, save output to csv and return
  res <- purrr::map_dfr(dts, check_linkage)
  
  rm(pats) #clean-up
  gc() #clear memory
  
  #logr::log_print(res)
  
  return(res)
  
}
