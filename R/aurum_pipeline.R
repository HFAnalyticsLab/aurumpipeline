### function to process all raw data, save parquet files and produce charts of basic checks
### run with check = TRUE to use a small number of rows to investigate any errors
### updated to use a subset of patients and only create parquet files for those specified
### - requires vector of patient ids to use. Discuss methods to obtain these

#' Aurum Pipeline
#'
#' @param type character string of Aurum table
#' @param cols character string of column types (see tabledata with meta data for this)
#' @param saveloc character string of location to save parquet files - defaults to project/working directory (accepts S3 URIs as well)
#' @param dataloc character string of location of raw data (accepts S3 URIs as well)
#' @param patids vector of patient ids to filter to (if known)
#' @param check boolean run in check mode or regular
#'
#' @return data.frame of data checking results
#' @import data.table
#' @export
#'
#' @examples \dontrun{
#' aurum_pipeline(type = 'Patient', 
#' dataloc = 'C:/Pathto/Your/CPRD/Extract/Here', check = TRUE)}
aurum_pipeline <- function(type
                           , cols = NULL
                           , saveloc = ''
                           , dataloc
                           , patids = NULL
                           , check = FALSE){
  
  num.load <- Inf
  
 
  if (saveloc == '') { ## if no save location default to current project directory
    
    saveloc <- here::here('Data')
    
  }
  
  if (check) { ## modify based on check status
    
    num.load <- 100
    saveloc <- file.path(saveloc, 'Check')
    
  } 
  
  ## check if s3 location for save location and set up bucket if so
  save_s3 <- path_id(saveloc)

    # set up log filename
  name <- substr(as.character(Sys.time()), 1, 16)
  name <- gsub(' ', '_', name)
  name <- paste0('AurumPipeline_', gsub(':', '_', name), '.log')
  
  if(save_s3[[3]]){ ## create folder in s3
  
    aws.s3::put_folder(save_s3[[1]], bucket = save_s3[[2]])
    tmp_log <- here::here() ## create local log - move to bucket later
    pipeline_log <- logr::log_open(tmp_log)
    
  } else { ## create folder in saveloc
    
    dir.create(saveloc, recursive = TRUE, showWarnings = FALSE)
    tmp_log <- file.path(saveloc, name)
    pipeline_log <- logr::log_open(tmp_log)
    
  }

  # get pipeline version and git info
  logr::log_print(paste0('Created with package version ', utils::packageVersion('aurumpipeline')))
  
# gitinfo <- git2r::revparse_single(revision = 'HEAD') ## need to specify repo here
# logr::log_print('Last commit information:')          ## as it defaults to the repo you are in
# logr::log_print(gitinfo)                             ## errors if not in a repo
# logr::log_print(gitinfo$author)
  
  #################################################
  
  output_file <- data.frame()

  ## check if s3 location for read location and set up bucket if so
  read_s3 <- path_id(dataloc)
  
  if(read_s3[[3]]){
    
    ## s3 method get all files in bucket and codeloc path
    files <- aws.s3::get_bucket(read_s3[[2]],
                                prefix = read_s3[[1]],
                                max = Inf) %>% rbindlist() #look for all files first
    
    ## remove subfolders and keep only .txt
    ## any further '/' will indicate a subfolder so remove them
    keep_me <- stringr::str_locate_all(pattern = '/', files$Key) %>% mapply(FUN = max) <= nchar(dataloc)
    files <- files[keep_me, ] %>% unique()
    fileext <- substr(files$Key, nchar(files$Key) - 3, nchar(files$Key)) == '.txt'
    files <- files[fileext, ]
  
    filepaths <- files$Key
    filepaths <- filepaths[grep(type, filepaths)]
    
  } else {
    
    filepaths <- list.files(dataloc, pattern = type, full.names = TRUE) #list raw CPRD filepaths for type
  
  }
  
  for(i in 1:length(filepaths)){ # for each file...
    
    logr::log_print(filepaths[i]) # print the path to the console and log file

    if (is.null(cols)){
      
      # read in the raw data and let vroom sort the column definitions
        if(read_s3[[3]]){
        
          temp <- aws.s3::s3read_using(FUN = vroom::vroom,
                                       object = filepaths[i],
                                       bucket = read_s3[[2]],
                                       delim = '\t',
                                       locale = readr::locale(date_format = '%d/%m/%Y'),
                                       n_max = num.load)
          
        } else {
          
          temp <- vroom::vroom(filepaths[i],
                               delim = '\t',
                               locale = readr::locale(date_format = '%d/%m/%Y'),
                               n_max = num.load)
          
        }  
      
      ## if medcodeid exists then set it to integer64
      med_check <- names(temp)[stringr::str_detect(names(temp), 'medcodeid')]
      
      if(length(med_check) > 0){
        
        temp[[med_check]] <- bit64::as.integer64(temp[[med_check]])
        
      }
      
      ## if prodcodeid exists then set it to integer64
      prod_check <- names(temp)[stringr::str_detect(names(temp), 'prodcodeid')]
      
      if(length(prod_check) > 0){
        
        temp[[prod_check]] <- bit64::as.integer64(temp[[prod_check]])
        
      }
      
    } else { # read in the raw data with coltype definitions supplied
      
      if(read_s3[[3]]){
        
        temp <- aws.s3::s3read_using(FUN = vroom::vroom,
                                     object = filepaths[i],
                                     bucket = read_s3[[2]],
                                     delim = '\t',
                                     locale = readr::locale(date_format = '%d/%m/%Y'),
                                     n_max = num.load,
                                     col_types = cols)
        
      } else {
      
        temp <- vroom::vroom(filepaths[i],
                             delim = '\t',
                             col_types = cols,
                             locale = readr::locale(date_format = '%d/%m/%Y'),
                             n_max = num.load)
        
      }
      
    }
    
    if (type != 'Staff' & type != 'Practice' & check == FALSE & !is.null(patids)){
      
      temp <- dplyr::inner_join(temp, patids, by = 'patid')
      
    }
    
    ## clean column names
    names(temp) <- tolower(names(temp))
    names(temp) <- gsub('e_', '', names(temp))
    
    ## Write parquet file to appropriate location
    
  if(save_s3[[3]]){
    
    aws.s3::put_folder(paste0(save_s3[[1]], type, '/', i), bucket = save_s3[[2]])
    aws.s3::s3write_using(temp,
                  arrow::write_parquet,
                  object = paste0(save_s3[[1]], type, '/', i, '/data.parquet'),
                  bucket = save_s3[[2]])
    
  } else {
    
    # create a folder named /Data/type/i
    dir.create(file.path(saveloc, type, i), recursive = TRUE, showWarnings = FALSE)
    # write the parquet data file
    arrow::write_parquet(temp, file.path(saveloc, type, i, 'data.parquet'))
    
  }
    
    # define function within loop to avoid environment issue with nested functions
    check_vals <- function(data_in, cols_in, func_in){
      
      dataset <- . <- NULL # define global vars to avoid package build notes
      
      dat <- get(data_in) #get dataset based on string input
      data.table::setDT(dat)
      r <- nrow(dat) #count number of rows in dataset
      func <- get(func_in) #get the function func_in
      
      dat[, lapply(.SD, func), .SDcols = cols_in][ #apply func_in to all cols_in
        , lapply(.SD, sum)][ #sum the values (all func_in results are TRUE/FALSE)
          , dataset := data_in] %>% #add name of dataset 
        reshape2::melt(id.vars = 'dataset', value.name = func_in) %>% #melt to a long format
        .[, `:=` (base = r, perc = 100 * get(func_in) / r)] #divide by all rows and present as percentage
    }
    
    # check NA values and dates after current date
    pats_NAs <- check_vals('temp', names(temp), 'is.na') #use function to check NAs
    pats_NAs$func <- 'is.na'
    
    date_check <- names(temp)[stringr::str_detect(names(temp), 'date|lcd')] # don't forget about lcd date
    
    if(length(date_check) > 0){ # if there are date variables
      
      pats_bad_dates <- check_vals('temp', date_check, 'future_date') #use function to check future dates
      
      ## bind together and label with filename used or reference
      pats_bad_dates$func <- 'future date'
      test <- rbind(pats_NAs, pats_bad_dates, use.names = F) ## file to print to log
      test$dataset <- basename(filepaths[i])
      
      output_file <- rbind(test, output_file)
      
    } else { 
      
      pats_NAs$dataset <- basename(filepaths[i])
      output_file <- rbind(pats_NAs, output_file)
      test <- pats_NAs ## file to print to log when no date variables
      
    }
    
    gc() #clear memory - might not be necessary (also has speed implications)
    logr::log_print(test)
    
  }

  logr::log_close() ## Move log to s3 bucket or keep local?
  return(output_file) ## results of checks
  
}
