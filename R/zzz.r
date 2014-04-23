engigma_compact <- function (l) Filter(Negate(is.null), l)

#' Error handler function for enigma_* functions
#' @param x A response object from a call to \code{httr::GET}
#' @keywords internal
error_handler <- function(x){
  res_info <- content(x)$info
  if(x$status_code %in% c(400,500)){
    stop(sprintf("%s : %s", res_info$message, gsub('\"', "'", res_info$additional)), call. = FALSE)
  }
  assert_that(x$headers$`content-type` == 'application/json; charset=utf-8')
  dat <- content(x, as = "text", encoding = 'utf-8')
  fromJSON(dat)
}