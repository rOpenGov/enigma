#' enigma, an R client for Enigma.io
#'
#' Enigma holds government data and provides a really nice set of APIs for 
#' data, metadata, and stats on each of the datasets. That is, you can 
#' request a dataset itself, metadata on the dataset, and summary 
#' statistics on the columns of each dataset.
#'
#' @section package API:
#'
#' \itemize{
#'  \item \code{\link[enigma]{enigma_data}} - Fetch and dataset, and filter on 
#'  columns or rows.
#'  \item \code{\link[enigma]{enigma_metadata}} - Get metadata on datasets.
#'  \item \code{\link[enigma]{enigma_stats}} - Get columnwise statistics on 
#'  datasets.
#'  \item \code{\link[enigma]{enigma_fetch}} - Get gzipped csv of a dataset. 
#'  Goes along with \code{\link[enigma]{enigma_read}}
#'  \item \code{\link[enigma]{rate_limit}} - Get columnwise statistics on 
#'  datasets.
#' }
#'
#' @section Authentication:
#' An API key is required to use this package. You can supply your key in each 
#' function call, or store in your \code{.Renviron} file like 
#' \code{ENIGMA_KEY=your key)}, or in your \code{.Rprofile} file as 
#' \code{options(enigmaKey = "<your key>")}, Obtain an API key by creating 
#' an account with Enigma at \url{https://www.enigma.com}, then obtain an API key 
#' from your account page.
#'
#' @importFrom plyr rbind.fill
#' @importFrom xml2 read_xml
#' @name enigma
#' @docType package
NULL
