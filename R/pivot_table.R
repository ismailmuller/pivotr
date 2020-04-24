#' Pivot table
#' 
#' @description Calculates aggregates in pivot tables
#' 
#' @author Ismail Muller
#'
#' @param df A dataframe
#' @param rows A vector of variable names that will be on the rows of the pivot table
#' @param cols A vector of variable names that will be on the columns of the pivot table
#' @param ... calculations that are passed to `dplyr::summarise()` via the `pivotr::cube()` function
#' @param .totals A string of how output totals are labeled in the rows and cols
#' @param .keep_total one of "all", "overall", "none"
#' 
#' @import magrittr
#' 
#' @return a tibble
#' 
#' @export
#' 
#' @examples 
#' 
#' pvt(mtcars, cyl, am, N = n(), Avg = mean(mpg))
#' pvt(mtcars, cyl, am, Avg = mean(wt), N = n())
#' pvt(mtcars, NULL, am, Avg = mean(wt))
#' pvt(mtcars, c(vs,am), cyl, N = n(), .keep_total = "overall")

pvt <- function(df, rows = NULL, cols = NULL, ..., .totals = "Total", .keep_total = "all"){
  calculations <- rlang::enquos(...)
  rows <- rlang::enquos(rows)
  cols <- rlang::enquos(cols)
  rnames <- dplyr::select(df, !!!rows ) %>% base::names()
  cnames <- dplyr::select(df, !!!cols) %>% base::names()
  groups <- base::c(rnames, cnames)
  groups <- groups[!base::is.null(groups)]
  
  the_cube <- pivotr::cube(df, groups = tidyselect::all_of(groups), !!!calculations, .totals = .totals)
  calcnames <- base::setdiff(base::names(the_cube), base::c(rnames, cnames))
  
  # pivot only if cols is not null
  if(base::length(cnames) > 0){
    res <- tidyr::pivot_wider(
      the_cube,
      id_cols = tidyselect::all_of(rnames),
      names_from = tidyselect::all_of(cnames),
      values_from = tidyselect::all_of(calcnames))
  } else {
    res <- the_cube
  }
  
  # arrange the rows
  res <- res %>% 
    dplyr::mutate_at(tidyselect::all_of(rnames), as.character) %>% 
    dplyr::arrange_at(tidyselect::all_of(rnames), 
                      .funs = base::list(function(x){!base::is.na(x) & x == "Total"} ))
  
  # keep only the wanted totals
  res <- base::switch(.keep_total,
                "all" = res,
                "overall" = dplyr::bind_rows(dplyr::filter_at(res, tidyselect::all_of(rnames), ~ .x != .totals | base::is.na(.x)),
                                             dplyr::slice(res, dplyr::n())),
                "none" =  dplyr::filter_at(res, tidyselect::all_of(rnames), ~ .x != .totals))
  
  base::return(res)
}

pivot_table <- pvt
