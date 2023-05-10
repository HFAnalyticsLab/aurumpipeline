### opendt function with extra filter for patient ids
#' Open Data Table
#'
#' @param data_in character filepath to data or an S3 URI. If data saved in standard structure from aurum_pipeline()
#' then only table name is required, eg 'Observation', otherwise use full file path.
#' @param cols_in character vector of column names to load in
#' @param date_in character name of date field to filter on
#' @param start_date Date to filter from (inclusive)
#' @param end_date Date to filter to (inclusive)
#' @param patient_list Vector of patient ids to filter to
#'
#' @return A data.table()
#' @export
#'
#' @examples \dontrun{
#' opendt('Patient', date_in = 'regstartdate', start_date = '2020-01-01', end_date = '2020-01-31')}
opendt <- function(data_in, cols_in = NULL
                        , date_in = NULL, start_date = NULL, end_date = NULL
                        , patient_list = NULL){
  
  patid <- NULL # assign global variable to reduce CMD notes
  reg_tables <- tabledata$table_name
  
  if (data_in %in% reg_tables){ ## if name of table given only look in regular place
    
    data_in <- here::here('Data', data_in)
    
  } ## otherwise open at specified path
  
  pq <- arrow::open_dataset(data_in) 
    
  if(!is.null(date_in)){ #if a date col is provided...
    
    pq <- pq %>% dplyr::filter(get(date_in) >= as.Date(start_date), get(date_in) <= as.Date(end_date)) #filter date_in to between start_date & end_date
  
  }
  
  if(!is.null(cols_in)){ #if a col_in is provided...
    
    pq <- pq %>% dplyr::select(tidyselect::all_of(cols_in)) #select all cols in cols_in
    
  }
  

  if(!is.null(patient_list)){ # if a patient id list is provided
    
    pq <- pq %>% dplyr::filter(patid %in% patient_list$patid) # use only the patients in the list
    
  }
  
  pq %>% dplyr::collect() %>% #collect data
    data.table::as.data.table() %>% #set as data table
    
    return() #return dataset
}

