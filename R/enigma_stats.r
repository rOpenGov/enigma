#' Fetch a dataset from Enigma.
#' 
#' @param dataset Dataset name. Required.
#' @param select (character) Column to get statistics on. Required.
#' @param operation (character) Operation to run on a given column. For a numerical column, valid operations 
#' are sum, avg, stddev, variance, max, min and frequency. For a date column, valid operations are 
#' max, min and frequency. For all other columns, the only valid operation is frequency. Defaults 
#' to all available operations based on the column's type.
#' @param by (character) Compound operation to run on a given pair of columns. Valid compound 
#' operations are sum and avg. When running a compound operation query, the \code{of} parameter is 
#' required (see below).
#' @param of (character) Numerical column to compare against when running a compound operation. 
#' Required when using the \code{by} parameter. Must be a numerical column.
#' @param limit (numeric) Limit the number of frequency, compound sum, or compound average results 
#' returned. Max: 500; Default: 500.
#' @param search (character) Filter results by only returning rows that match a search query. By 
#' default this searches the entire table for matching text. To search particular fields only, use 
#' the query format "@@fieldname query". To match multiple queries, the | (or) operator can be used 
#' eg. "query1|query2".
#' @param where (character) Filter results with a SQL-style "where" clause. Only applies to 
#' numerical columns - use the \code{search} parameter for strings. Valid operators are >, < and =. 
#' Only one \code{where} clause per request is currently supported.
#' @param sort (character) Sort frequency, compound sum, or compound average results in a given 
#' direction. + denotes ascending order, - denotes descending
#' @param page (numeric) Paginate frequency, compound sum, or compound average results and return 
#' the nth page of results. Pages are calculated based on the current limit, which defaults to 500.
#' @param key (character) An Enigma API key. Supply in the function call, or store in your
#' \code{.Rprofile} file, or do \code{options(enigmaKey = "<your key>")}. Required.
#' @param curlopts (list) Curl options passed on to \code{httr::GET}
#' @import httr RJSONIO assertthat 
#' @importFrom plyr rbind.fill
#' @export
#' @examples \dontrun{
#' # stats on a varchar column
#' enigma_stats(dataset='us.gov.whitehouse.visitor-list', select='type_of_access')
#' 
#' # stats on a numeric column
#' enigma_stats(dataset='us.gov.whitehouse.visitor-list', select='total_people')
#' 
#' # stats on a date column
#' enigma_stats(dataset='us.gov.whitehouse.visitor-list', select='release_date')
#' 
#' # stats on a date column, by the average of a numeric column
#' enigma_stats(dataset='us.gov.whitehouse.visitor-list', select='release_date', by='avg', 
#'    of='total_people')
#' }

enigma_stats <- function(dataset=NULL, select=NULL, operation=NULL, by=NULL, of=NULL, limit=500, 
  search=NULL, where=NULL, sort=NULL, page=NULL, key=NULL, curlopts=list())
{
  if(is.null(key))
    key <- getOption("enigmaKey", stop("need an API key for PLoS Journals"))

  url <- 'https://api.enigma.io/v2/stats/%s/%s/select/%s'
  url <- sprintf(url, key, dataset, select)
  args <- engigma_compact(list(operation=operation, by=by, of=of, limit=limit, 
                               search=search, where=where, sort=sort, page=page))
  res <- GET(url, query=args, curlopts)
  stop_for_status(res)
  assert_that(res$headers$`content-type` == 'application/json; charset=utf-8')
  dat <- content(res, as = "text", encoding = 'utf-8')
  json <- fromJSON(dat)
  
  if(json$info$column$type %in% c('type_numeric','type_date')){
    sum_stats <- json$result[!names(json$result) %in% 'frequency']
    freq_stats <- json$result$frequency
    frequency <- do.call(rbind.fill, lapply(freq_stats, function(z){ 
        zz <- as.list(z)
        zz[sapply(zz, is.null)] <- "null"
        data.frame(zz, stringsAsFactors = FALSE)
      })
    )
  } else if(json$info$column$type %in% 'type_varchar'){
    sum_stats <- NULL
    frequency <- do.call(rbind.fill, lapply(json$result$frequency, function(z){ 
        zz <- as.list(z)
        zz[sapply(zz, is.null)] <- "null"
        data.frame(zz, stringsAsFactors = FALSE)
      })
    )
  } else {
    NULL
  }
   
  out <- list(success = json$success, meta = json$info, sum_stats = sum_stats, frequency = frequency)
  class(out) <- "enigma_stats"
  return( out )
}