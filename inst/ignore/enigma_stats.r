#' Get statistics on columns of a dataset from Enigma.
#'
#' @export
#' @template key-curl
#' @param dataset Dataset name. Required.
#' @param select (character) Column to get statistics on. Required.
#' @param conjunction one of "and" or "or". Only applicable when more than 
#' one \code{search} or \code{where} parameter is provided. Default: "and"
#' @param operation (character) Operation to run on a given column. For a 
#' numerical column, valid operations are sum, avg, stddev, variance, max, 
#' min and frequency. For a date column, valid operations are max, min and 
#' frequency. For all other columns, the only valid operation is frequency. 
#' Defaults to all available operations based on the column's type.
#' @param by (character) Compound operation to run on a given pair of columns. 
#' Valid compound operations are sum and avg. When running a compound operation
#' query, the \code{of} parameter is required (see below).
#' @param of (character) Numerical column to compare against when running a 
#' compound operation. Required when using the \code{by} parameter. Must be 
#' a numerical column.
#' @param limit (numeric) Limit the number of frequency, compound sum, or 
#' compound average results returned. Max: 500; Default: 500.
#' @param search (character) Filter results by only returning rows that match 
#' a search query. By default this searches the entire table for matching 
#' text. To search particular fields only, use the query format 
#' "@@fieldname query". To match multiple queries, the | (or) operator can 
#' be used eg. "query1|query2".
#' @param where (character) Filter results with a SQL-style "where" clause. 
#' Only applies to numerical columns - use the \code{search} parameter for 
#' strings. Valid operators are >, < and =. Only one \code{where} clause 
#' per request is currently supported.
#' @param sort (character) Sort frequency, compound sum, or compound average 
#' results in a given direction. + denotes ascending order, - denotes 
#' descending
#' @param page (numeric) Paginate frequency, compound sum, or compound average 
#' results and return the nth page of results. Pages are calculated based on 
#' the current limit, which defaults to 500.
#' @references \url{https://app.enigma.io/api#stats}
#' @return A list with items:
#' \itemize{
#'  \item success - a boolean if query was successful or not
#'  \item datapath - the dataset path (this is not a file path on your machine)
#'  \item info - a list of length 6 with:
#'    \itemize{ 
#'     \item column - a list of information on the variable you requested
#'     stats on
#'     \item operations - a list of the operations you requested
#'     \item rows_limit - rows limit
#'     \item total_results - total items found (likely more than was returned)
#'     \item total_pages - total pages found (see also \code{current_page})
#'     \item current_page - page returned  (see also \code{total_pages})
#'     \item calls_remaining - number of requests remaining
#'     \item seconds_remaining - seconds remaining before your rate limit 
#'     resets
#'    }
#'  \item result - a named list of objects - depends on the data 
#'  source returned
#' }
#' @examples \dontrun{
#' # After obtaining an API key from Enigma's website, pass in your key to 
#' # the function call or set in your options (see above instructions for the 
#' # key parameter) If you pass in your key to the function call use the 
#' # key parameter
#'
#' # stats on a varchar column
#' x <- 'gov.mx.imss.compras.main'
#' enigma_stats(x, select='provider_id', limit = 10)
#'
#' # stats on a numeric column
#' enigma_stats(x, select='serialid', limit = 10)
#'
#' # stats on a date column
#' pakistan <- 'gov.pk.secp.business-registry.all-entities'
#' enigma_metadata(dataset=pakistan)
#' enigma_stats(dataset=pakistan, select='registration_date', limit = 10)
#'
#' # stats on a date column, by the average of a numeric column
#' aust <- 'gov.au.government-spending.federal-contracts'
#' enigma_metadata(dataset=aust)
#' enigma_stats(dataset=aust, select='contractstart', by='avg', of='value', 
#'   limit = 10)
#'
#' # Get frequency of distances traveled
#' ## get columns for the air carrier dataset
#' dset <- 'us.gov.dot.rita.trans-stats.air-carrier-statistics.t100d-market-all-carrier'
#' enigma_metadata(dset)$columns$table[,c(1:4)]
#' enigma_stats(dset, select='distance', limit = 10)
#' }

enigma_stats <- function(dataset=NULL, select, conjunction = NULL, 
  operation=NULL, by=NULL, of=NULL, limit=500, search=NULL, where=NULL, 
  sort=NULL, page=NULL, key=NULL, ...) {

  key <- check_key(key)
  check_dataset(dataset)

  url <- sprintf('%s/stats/%s/%s/select/%s', en_base(), key, dataset, select)
  sw <- proc_search_where(search, where)
  args <- list(operation = operation, conjunction = conjunction, by = by, 
               of = of, limit = limit, sort = sort, page = page)
  args <- as.list(unlist(ec(c(sw, args))))
  json <- enigma_GET(url, args, ...)
  sum_stats <- enigma_stats_dat_parser(json)
  structure(list(success = json$success, datapath = json$datapath, 
                 info = json$info, result = sum_stats), class = "enigma_stats")
}

enigma_stats_dat_parser <- function(x) {
  nn <- names(x$result)
  res <- lapply(nn, function(z){
    tmp <- x$result[[z]]
    if (length(tmp) > 1) {
      do.call(rbind.fill, lapply(tmp, function(w){
        b <- as.list(w)
        b[sapply(b, is.null)] <- "null"
        data.frame(b, stringsAsFactors = FALSE)
      }))
    } else {
      tmp
    }
  })
  names(res) <- nn
  res
}
