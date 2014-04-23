#' Fetch a dataset from Enigma.
#' 
#' @import httr RJSONIO assertthat 
#' @importFrom plyr rbind.fill
#' @export
#' @param dataset Dataset name. Required.
#' @param limit (numeric) Number of rows of the dataset to return. Default: 50
#' @param select (character) Vector of columns to be returned with each row. Default is to return 
#' all columns.
#' @param sort (character) Sort rows by a particular column in a given direction. + denotes 
#' ascending order, - denotes descending. See examples.
#' @param page (numeric) Paginate row results and return the nth page of results. Pages are 
#' calculated based on the current limit, which defaults to 50.
#' @param where (character) Filter results with a SQL-style "where" clause. Only applies to 
#' numerical columns - use the \code{search} parameter for strings. Valid operators are >, < and =. 
#' Only one \code{where} clause per request is currently supported.
#' @param search (character) Filter results by only returning rows that match a search query. By 
#' default this searches the entire table for matching text. To search particular fields only, use 
#' the query format "@@fieldname query". To match multiple queries, the | (or) operator can be used 
#' eg. "query1|query2".
#' @param key (character) An Enigma API key. Supply in the function call, or store in your
#' \code{.Rprofile} file, or do \code{options(enigmaKey = "<your key>")}. Required.
#' @param curlopts (list) Curl options passed on to \code{httr::GET}
#' @examples \dontrun{
#' enigma_data(dataset='us.gov.whitehouse.visitor-list')
#' enigma_data(dataset='us.gov.whitehouse.visitor-list', select=c('namelast','visitee_namelast','last_updatedby'))
#' enigma_data(dataset='us.gov.whitehouse.visitor-list', sort='+namelast')
#' enigma_data(dataset='us.gov.whitehouse.visitor-list', where='total_people > 5')
#' enigma_data(dataset='us.gov.whitehouse.visitor-list', search='@@namefull=Vitale')
#' enigma_data(dataset='us.gov.whitehouse.visitor-list', search='@@namefirst=SOPHIA')
#' 
#' # Domestic Market Flight Statistics (Final Destination)
#' enigma_data(dataset='us.gov.dot.rita.trans-stats.air-carrier-statistics.t100d-market-all-carrier')
#' }

enigma_data <- function(dataset=NULL, limit=50, select=NULL, sort=NULL, page=NULL, where=NULL, 
                        search=NULL, key=NULL, curlopts=list())
{
  if(is.null(key))
    key <- getOption("enigmaKey", stop("need an API key for the Enigma API"))
  
  if(!is.null(select)) select <- paste(select, collapse = ",")

  url <- 'https://api.enigma.io/v2/data/%s/%s'
  url <- sprintf(url, key, dataset)
  args <- engigma_compact(list(limit=limit, select=select, sort=sort, page=page, 
                               where=where, search=search))
  res <- GET(url, query=args, curlopts)
  json <- error_handler(res)
  meta <- json$info
  json$result <- lapply(json$result, as.list)
  dat2 <- do.call(rbind.fill, 
                  lapply(json$result, function(x){ 
                    x[sapply(x, is.null)] <- NA; data.frame(x, stringsAsFactors = FALSE) 
          }))
  out <- list(success = json$success, datapath = json$datapath, info = meta, result = dat2)
  class(out) <- "enigma"
  return( out )
}