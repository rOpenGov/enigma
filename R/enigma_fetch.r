#' Download a gzipped csv file of a dataset.
#'
#' @export
#' 
#' @template key-curl
#' @param dataset Dataset name. Required.
#' @param select (character) Vector of columns to be returned with each row. 
#' Default is to return all columns.
#' @param conjunction one of "and" or "or". Only applicable when more than one 
#' \code{search} or \code{where} parameter is provided. Default: "and"
#' @param sort (character) Sort rows by a particular column in a given 
#' direction. + denotes ascending order, - denotes descending. See examples.
#' @param where (character) Filter results with a SQL-style "where" clause. 
#' Only applies to numerical columns - use the \code{search} parameter for 
#' strings. Valid operators are >, < and =. Only one \code{where} clause per 
#' request is currently supported.
#' @param search (character) Filter results by only returning rows that match 
#' a search query. By default this searches the entire table for matching text.
#' To search particular fields only, use the query format "@@fieldname query". 
#' To match multiple queries, the | (or) operator can be used 
#' eg. "query1|query2".
#' @param path File name and path of output zip file. Defaults to write a zip 
#' file to your home directory with name of the dataset, and file extension 
#' \code{.csv.gz}.
#' @param poll_sleep (integer) Time to sleep between polling events to fetch 
#' data. For very large datasets, it could take a while to be ready. By 
#' default, we poll continuously. If you are requesting a large dataset and/or 
#' have not much left on your allowed requests with Enigam (see 
#' \code{\link{rate_limit}}) you may want to insert some sleep time between 
#' pollings.
#'
#' @details Note that \code{\link[enigma]{enigma_fetch}} downloads the file, 
#' and gives back a path to the file. In a separte function, 
#' \code{\link[enigma]{enigma_read}}, you can read in the data. 
#' \code{\link[enigma]{enigma_fetch}} doesn't read in data in case the file 
#' is very large which may make your R session crash or slow down 
#' significantly.
#' 
#' This function makes a request to ask Enigma to get a download ready. We 
#' then poll the  provided URL from Enigma until it is ready. Once ready we 
#' fetch it and write it to disk.
#' 
#' If file exists already, we overwrite it.
#' 
#' @return A (character) path to the file on your machine
#'
#' @examples \dontrun{
#' ## After obtaining an API key from Enigma's website, pass in your key to 
#' ## the function call or set in your options (see above instructions for the 
#' ## key parameter) If you pass in your key to the function call use the 
#' ## key parameter
#'
#' # Fetch a dataset
#' res <- enigma_fetch(dataset = 'edu.umd.start.gtd')
#' enigma_read(res)
#'
#' # Use the select parameter to limit fields returned
#' res <- enigma_fetch(dataset = 'edu.umd.start.gtd',
#'    select = c("country_txt", "resolution", "attacktype1"))
#' enigma_read(res)
#'
#' # Use the search parameter to query entire table or particular fields
#' res <- enigma_fetch(dataset = 'edu.umd.start.gtd', search = "armed")
#' enigma_read(res)
#'
#' # Use the search parameter to query entire table or particular fields
#' res <- enigma_fetch(dataset = 'edu.umd.start.gtd',
#'    where = "nkill > 0", select = c("country_txt", "attacktype1", "nkill"))
#' enigma_read(res)
#' }

enigma_fetch <- function(dataset = NULL, select = NULL, search = NULL, 
  where = NULL, conjunction = NULL, sort = NULL, path = NULL, 
  key = NULL, poll_sleep = 0, ...) {

  if (!class(poll_sleep) %in% c('numeric', 'integer')) {
    stop("poll_sleep must be integer or numeric", call. = FALSE)
  }
  url <- sprintf('%s/export/%s/%s', en_base(), check_key(key), 
                 check_dataset(dataset))
  sw <- proc_search_where(search, where)
  if (!is.null(select)) select <- paste(select, collapse = ",")
  args <- list(select = select, conjunction = conjunction, sort = sort)
  args <- as.list(unlist(ec(c(sw, args))))
  if (length(args) == 0) args <- NULL
  cli <- crul::HttpClient$new(url = url)
  res <- cli$get(query = args, ...)
  json <- error_handler(res)
  if (is.null(path)) {
    path <- file.path(Sys.getenv('HOME'), 
                      basename(strsplit(json$export_url, "\\?")[[1]][1]))
  }
  
  not_ready <- TRUE
  while (not_ready) {
    Sys.sleep(poll_sleep)
    bincli <- crul::HttpClient$new(url = json$export_url)
    bin <- bincli$get(disk = path)
    if (bin$status_code == 200) not_ready <- FALSE
  }
  
  if (bin$status_code > 201) {
    if (grepl("xml", bin$headers$`content-type`)) {
      x <- bin$parse("UTF-8")
      xml <- xml2::read_xml(x)
      mssg <- unlist(xml2::as_list(xml), FALSE)
      stop("\n  ", 
           paste(names(mssg), unname(mssg), sep = ": ", collapse = "\n  "), 
           call. = FALSE)
    } else {
      bin$raise_for_status()
    }
  }
  message(sprintf("On disk at %s", bin$content))
  structure(path, class = "enigma_fetch", dataset = dataset)
}

#' @export
print.enigma_fetch <- function(x, ...) {
  stopifnot(inherits(x, 'enigma_fetch'))
  cat("<<enigma download>>", "\n", sep = "")
  cat("  Dataset: ", attr(x, "dataset"), "\n", sep = "")
  cat("  Path: ", x, "\n", sep = "")
  cat("  see enigma_read()")
}

#' @export
#' @param input The output from \code{enigma_fetch} or a path to a file d
#' ownloaded from Enigma.io
#' @rdname enigma_fetch
enigma_read <- function(input) {
  input <- as.enigma_fetch(input)
  tibble::as_tibble(
    utils::read.delim(input[[1]], header = TRUE, sep = ",",
                      stringsAsFactors = FALSE)
  )
}

as.enigma_fetch <- function(x) UseMethod("as.enigma_fetch")
as.enigma_fetch.enigma_fetch <- function(x) x
as.enigma_fetch.character <- function(x) structure(x, class = 'enigma_fetch', 
                                                   dataset = NA)
