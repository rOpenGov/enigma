ec <- function(l) Filter(Negate(is.null), l)

error_handler <- function(x) {
  txt <- x$parse("UTF-8")
  json <- jsonlite::fromJSON(txt, TRUE, flatten = TRUE)
  res_info <- json$info
  if (x$status_code %in% c(400, 500)) {
    stop(
      sprintf("%s : %s", res_info$message, gsub('\"', "'", res_info$additional)), 
      call. = FALSE)
  }
  stopifnot(
    x$response_headers$`content-type` == 'application/vnd.enigma+json; version=1')
  return(json)
}

enigma_GET <- function(url, key, args, ...) {
  if (length(args) == 0) args <- NULL
  cli <- crul::HttpClient$new(
    url = url,
    headers = list(
      #Accept = '*/*',
      Accept = "application/vnd.enigma+json; version=1",
      Authorization = paste0("Bearer ", key)
    )
  )
  res <- cli$get(query = args, ...)
  error_handler(res)
}

check_dataset <- function(dataset){
  if (is.null(dataset)) stop("You must provide a dataset") else dataset
}

check_key <- function(x){
  tmp <- if (is.null(x)) Sys.getenv("ENIGMA_KEY", "") else x
  if (tmp == "") {
    getOption("enigmaKey", stop("need an API key for the Enigma API"))
  } else {
    tmp
  }
}

en_base <- function() 'https://public.enigma.com/api'
