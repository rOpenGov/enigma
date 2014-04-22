#' Fetch a dataset from Enigma.
#' 
#' @param dataset Dataset name.
#' @param limit Number of rows of the dataset to return. Default: 100
#' @param select X
#' @param sort X
#' @param page X
#' @param where X
#' @param search X
#' @param key X
#' @import httr RJSONIO assertthat 
#' @importFrom plyr rbind.fill
#' @export
#' @examples \dontrun{
#' enigma_data(dataset='us.gov.whitehouse.visitor-list')
#' }

enigma_data <- function(dataset=NULL, limit=100, select=NULL, sort=NULL, page=NULL, where=NULL, search=NULL, key=NULL)
{
  enigma_key <- "9f146ed7308769047ecd7212cdd6f517"
  url <- 'https://api.enigma.io/v2/data/%s/%s'
  url <- sprintf(url, enigma_key, dataset)
  args <- engigma_compact(list(limit=limit, select=select, sort=sort, page=page, 
                               where=where, search=search))
  res <- GET(url, query=args)
  stop_for_status(res)
  assert_that(res$headers$`content-type` == 'application/json; charset=utf-8')
  dat <- content(res, as = "text", encoding = 'utf-8')
  json <- fromJSON(dat)
  meta <- json$info
  dat2 <- do.call(rbind.fill, 
                  lapply(json$result, function(x){ 
                    x[sapply(x, is.null)] <- NA; data.frame(x, stringsAsFactors = FALSE) 
          }))
  
  out <- list(meta = meta, data = dat2)
  class(out) <- "enigma"
  return( out )
}