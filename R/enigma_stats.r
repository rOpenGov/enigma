#' Get statistics on columns of a dataset from Enigma.
#' 
#' @import httr RJSONIO assertthat 
#' @importFrom plyr rbind.fill
#' @export
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
#' @param ... Named options passed on to \code{httr::GET}
#' @examples \dontrun{
#' # stats on a varchar column
#' cbase <- 'com.crunchbase.info.companies.acquisition'
#' enigma_stats(dataset=cbase, select='acquired_month')
#' 
#' # stats on a numeric column
#' enigma_stats(dataset=whvis, select='price_amount')
#' 
#' # stats on a date column
#' pakistan <- 'gov.pk.secp.business-registry.all-entities'
#' enigma_metadata(dataset=pakistan)
#' enigma_stats(dataset=pakistan, select='registration_date')
#' 
#' # stats on a date column, by the average of a numeric column
#' aust <- 'gov.au.government-spending.federal-contracts'
#' enigma_metadata(dataset=aust)
#' enigma_stats(dataset=aust, select='contractstart', by='avg', of='value')
#' 
#' # Get frequency of distances traveled, and plot
#' ## get columns for the air carrier dataset
#' dset <- 'us.gov.dot.rita.trans-stats.air-carrier-statistics.t100d-market-all-carrier'
#' enigma_metadata(dset)$columns$table[,c(1:4)]
#' out <- enigma_stats(dset, select='distance')
#' library("ggplot2")
#' library("ggthemes")
#' df <- out$result$frequency
#' df <- data.frame(distance=as.numeric(df$distance), count=as.numeric(df$count))
#' ggplot(df, aes(distance, count)) + 
#'  geom_bar(stat="identity") + 
#'  geom_point() +
#'  theme_grey(base_size = 18) +
#'  labs(y="flights", x="distance (miles)")
#' }

enigma_stats <- function(dataset=NULL, select=NULL, operation=NULL, by=NULL, of=NULL, limit=500, 
  search=NULL, where=NULL, sort=NULL, page=NULL, key=NULL, ...)
{
  if(is.null(key))
    key <- getOption("enigmaKey", stop("need an API key for the Enigma API"))
  if(is.null(dataset))
    stop("You must provide a dataset")
  
  url <- 'https://api.enigma.io/v2/stats/%s/%s/select/%s'
  url <- sprintf(url, key, dataset, select)
  args <- engigma_compact(list(operation=operation, by=by, of=of, limit=limit, 
                               search=search, where=where, sort=sort, page=page))
  res <- GET(url, query=args, ...)
  json <- error_handler(res)
  
#   if(json$info$column$type %in% c('type_numeric','type_date')){
#     sum_stats <- enigma_stats_dat_parser(json)
#   } else if(json$info$column$type %in% 'type_varchar'){
    sum_stats <- enigma_stats_dat_parser(json)
#   }
   
  out <- list(success = json$success, datapath = json$datapath, info = json$info, result = sum_stats)
  class(out) <- "enigma_stats"
  return( out )
}

enigma_stats_dat_parser <- function(x){
  nn <- names(x$result)
  res <- lapply(nn, function(z){
    tmp <- x$result[[z]]
    if(length(tmp) > 1){
      do.call(rbind.fill, lapply(tmp, function(w){ 
        b <- as.list(w)
        b[sapply(b, is.null)] <- "null"
        data.frame(b, stringsAsFactors = FALSE)
      }))
    } else { tmp }
  })
  names(res) <- nn
  res
}