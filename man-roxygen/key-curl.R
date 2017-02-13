#' @param key (character) Required. An Enigma API key. Supply in the function 
#' call, or store in your \code{.Renviron} file like 
#' \code{ENIGMA_KEY=your key)}, or in your \code{.Rprofile} file as 
#' \code{options(enigmaKey = "<your key>")}, Obtain an API key by creating 
#' an account with Enigma at \url{http://enigma.io}, then obtain an API key 
#' from your account page.
#' @param ... Named curl options passed on to \code{\link[crul]{HttpClient}}
