#' Computes grouped aggregates
#'
#' @description Calculates aggregates functions for groups of variables and all their combinations
#'
#' @param df A dataframe
#' @param groups variables names
#' @param ... calculations passed to `dplyr::summarize(...)`
#' @param .totals A string of how output totals are labeled in the rows and cols
#' 
#' @import magrittr
#' 
#' @export
#' 
#' @example
#' cube(mtcars, c(cyl, am), Avg = mean(mpg))

cube <- function(df, groups = NULL, ..., .totals = "Total"){
  if( missing(df) || (!is.data.frame(df)) ){base::stop("df must be of class data.frame")}
  groups <- rlang::enquos(groups)
  rnames <- dplyr::select(df, !!!groups) %>% base::names()
  calculations <- rlang::enquos(...)
  
  add_rnames_columns <- function(df, total_replacement = .totals){
    cols_to_add <- base::setdiff(rnames, base::names(df))
    if(base::length(cols_to_add) > 0 & !base::is.na(.totals)){
      for( r in cols_to_add ){
        df <- dplyr::mutate(df, !! r := total_replacement)
      }
      }
    base::return(df)
  }

  combinations <- purrr::map(c(0, base::seq_along(rnames)), ~ utils::combn(rnames, .x) %>% base::as.data.frame(stringsAsFactors = FALSE) )
  res <- purrr::map(combinations,
             ~ purrr::map(.x, ~ dplyr::group_by_at(df, .x) %>%
                            dplyr::summarize( !!!calculations ) %>%
                            dplyr::ungroup() %>%
                            dplyr::mutate_at(tidyselect::all_of(.x), as.character) %>%
                            add_rnames_columns()) %>%
               dplyr::bind_rows()) %>%
    dplyr::bind_rows() %>%
    dplyr::select_at( dplyr::vars( tidyselect::all_of(rnames), dplyr::everything() ) ) %>%
    dplyr::arrange_at( tidyselect::all_of(rnames), ~ (!is.na(.x) & .x == .totals )  )
  
  if( base::any(base::dim(res) == 0) ){base::stop("No combinations, nor calculations")}
  
  return(res)
}
