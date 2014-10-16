#' Download a gzipped csv file of a dataset.
#'
#' @export
#'
#' @param dataset Dataset name. Required.
#' @param path File name and path of output zip file. Defaults to write a zip file to your home
#' directory with name of the dataset, and file extension \code{.csv.gz}.
#' @param overwrite Will only overwrite existing path if TRUE.
#' @param key (character) Required. An Enigma API key. Supply in the function call, or store in 
#' your \code{.Rprofile} file, or do \code{options(enigmaKey = "<your key>")}. Obtain an API key 
#' by creating an account with Enigma at \url{http://enigma.io}, then obtain an API key from 
#' your account page.
#' @param ... Named options passed on to \code{\link[httr]{GET}}
#' 
#' @details Note that \code{\link[enigma]{enigma_fetch}} downloads the file, and gives back a 
#' path to the file. In a separte function, \code{\link[enigma]{enigma_read}}, you can read in the
#' data. \code{\link[enigma]{enigma_fetch}} doesn't read in data in case the file is very large
#' which may make your R session crash or slow down significantly.
#'
#' @examples \donttest{
#' # After obtaining an API key from Enigma's website, pass in your key to the function call
#' # or set in your options (see above instructions for the key parameter)
#' # If you pass in your key to the function call use the key parameter
#' 
#' # Fetch the Crunchbase companies info dataset 
#' res <- enigma_fetch(dataset='com.crunchbase.info.companies.acquisition')
#' enigma_read(res)
#'
#' # Piping workflow
#' library('dplyr')
#' enigma_fetch(dataset='com.crunchbase.info.companies.acquisition') %>%
#'    enigma_read %>%
#'    glimpse
#'
#' # Curl debugging
#' library('httr')
#' enigma_fetch(dataset='com.crunchbase.info.companies.acquisition', config=verbose())
#' }

enigma_fetch <- function(dataset=NULL, path=NULL, overwrite = TRUE, key=NULL, ...)
{
  url <- sprintf('%s/export/%s/%s', en_base(), check_key(key), check_dataset(dataset))
  res <- GET(url, ...)
  json <- error_handler(res)
  if(is.null(path)) path <- file.path(Sys.getenv('HOME'), parse_url(json$export_url)$path)
  bin <- GET(json$export_url, write_disk(path = path, overwrite = overwrite), ...)
  message( sprintf("On disk at %s", bin$request$writer[[1]]) )
  structure(path, class="enigma_fetch", dataset=dataset)
}

#' @export
print.enigma_fetch <- function (x, ...){
  stopifnot(is(x, 'enigma_fetch'))
  cat("<<enigma download>>", "\n", sep = "")
  cat("  Dataset: ", attr(x, "dataset"), "\n", sep = "")
  cat("  Path: ", x, "\n", sep = "")
  cat("  see enigma_read()")
}

#' @export
#' @param input The output from \code{enigma_fetch} or a path to a file downloaded from Enigma.io
#' @rdname enigma_fetch
enigma_read <- function(input)
{
  input <- as.enigma_fetch(input)
  read.delim(input[[1]], header = TRUE, sep = ",", stringsAsFactors = FALSE)
}

as.enigma_fetch <- function(x) UseMethod("as.enigma_fetch")
as.enigma_fetch.enigma_fetch <- function(x) x
as.enigma_fetch.character <- function(x) structure(x, class='enigma_fetch', dataset=NA)
