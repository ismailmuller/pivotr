#' Pivot table
#' 
#' @description Calculates aggregates in pivot tables
#' 
#' @author Ismail Muller
#'
#' @param df A dataframe
#' @param rows A vector of variable names that will be on the rows of the pivot table
#' @param cols A vector of variable names that will be on the columns of the pivot table
#' @param ... calculations that are passed to `dplyr::summarise()` via the `cube()` function
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
  rnames <- dplyr::select(df, !!!rows ) %>% names()
  cnames <- dplyr::select(df, !!!cols) %>% names()
  groups <- c(rnames, cnames)
  groups <- groups[!is.null(groups)]
  
  the_cube <- cube(df, groups = tidyselect::all_of(groups), !!!calculations, .totals = .totals)
  calcnames <- setdiff(names(the_cube), c(rnames, cnames))
  
  # pivot only if cols is not null
  if(length(cnames) > 0){
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
                      .funs = list(function(x){!is.na(x) & x == "Total"} ))
  
  # keep only the wanted totals
  res <- switch(.keep_total,
                "all" = res,
                "overall" = dplyr::bind_rows(dplyr::filter_at(res, tidyselect::all_of(rnames), ~ .x != .totals | is.na(.x)),
                                             dplyr::slice(res, n())),
                "none" =  dplyr::filter_at(res, tidyselect::all_of(rnames), ~ .x != .totals))
  
  return(res)
}

pivot_table <- pvt
