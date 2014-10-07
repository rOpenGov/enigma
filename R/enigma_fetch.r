#' Get statistics on columns of a dataset from Enigma.
#' 
#' @export
#' 
#' @param dataset Dataset name. Required.
#' @param output File name and path of output zip file. Defaults to write a zip file to your home
#' directory with name of the dataset.
#' @param key (character) An Enigma API key. Supply in the function call, or store in your
#' \code{.Rprofile} file, or do \code{options(enigmaKey = "<your key>")}. Required.
#' @param ... Named options passed on to \code{httr::GET}
#' 
#' @examples \dontrun{
#' enigma_fetch(dataset='com.crunchbase.info.companies.acquisition')
#' 
#' library('httr')
#' enigma_fetch(dataset='com.crunchbase.info.companies.acquisition', config=verbose())
#' }

enigma_fetch <- function(dataset=NULL, output=NULL, key=NULL, ...)
{
  key <- check_key(key)
  check_dataset(dataset)
  
  url <- '%s/export/%s/%s'
  url <- sprintf(url, en_base(), key, dataset)
  res <- GET(url, ...)
  json <- error_handler(res)
  if(is.null(output)) output <- file.path(Sys.getenv('HOME'), parse_url(json$export_url)$path)
  bin <- GET(json$export_url)
  writeBin(content(bin), output)
  message(sprintf("\nzip file written to\n%s", output))
}
