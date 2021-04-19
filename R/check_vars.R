#' Check Aurum Variables
#'
#' @param table character vector of tables to check (subset of tabledata$table_name)
#' @param data output of Aurum_Pipeline()
#' @param chart boolean to create charts of pipeline output
#'
#' @return list of summarised table checks
#' @export
#'
#' @examples
#' \dontrun{
#' check_vars(c('Patient', 'Consultation', 'Observation'), res)}
check_vars <- function(table, data, chart = FALSE){
  
  ## declare variables
  variable <- func <- base <- prop <- temp <- NULL
  
  to_output <- list()
  i <- 1
  
  for (k in table){
    
    get_var <- k
    to_output[[i]] <- data[grep(get_var, data$dataset), ] %>%
      dplyr::group_by(variable, func) %>%
      dplyr::summarise(n = sum(is.na), base = sum(base)) %>%
      data.frame()
    
    to_output[[i]]$prop <- (to_output[[i]]$n / to_output[[i]]$base) * 100
    #temp$variable <- droplevels(temp$variable)
    
    if(chart){
      
      x <- ggplot2::ggplot(to_output[[i]], ggplot2::aes(x = variable, y = prop)) +
        ggplot2::geom_bar(stat = 'identity') + ggplot2::facet_wrap(~func, scales = 'free') +
        ggplot2::geom_text(ggplot2::aes(label = round(prop, 1)), vjust=0) +
        ggplot2::ggtitle(paste0('Proportion of data issues per variable - ', get_var)) +
        ggplot2::xlab('Variable name') + ggplot2::ylab('Proportion of records') +
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.3))
      
      dir.create(here::here('Output'), recursive = TRUE, showWarnings = FALSE)
      ggplot2::ggsave(here::here('Output', paste0('var_check_', get_var, '.png')), plot = x)
      
    }
    
    #logr::log_print(temp)
  
    i <- i + 1
    
  }
  
  return(to_output)
  
}
