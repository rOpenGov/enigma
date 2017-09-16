#' Datasets search
#'
#' @export
#' 
#' @template key-curl
#' @param query (character) Query string to return only rows that contain 
#' specific information (must set row_limit > 0). You cannot combine this 
#' with the filter parameter.
#' @param parent_collection_id (character) Returns only datasets whose 
#' immediate parent collection ID matches the one specified here.
#' @param limit (numeric) Number of rows of the dataset to return. Default 
#' (and max): 500
#' @param offset (numeric) Number of rows to skip. Default: 0
#' @param sort (character) List of dataset attributes indicating how to 
#' sort the datasets (currently display_name is the only attribute supported 
#' by this parameter). For example, sort=display_name sorts the datasets by 
#' display name. Since display_name is the default sort attribute, this 
#' parameter has no effect. You cannot combine this with the query parameter.
#' @param filter (numeric) Returns only datasets that match the specified 
#' attribute (currently display_name is the only attribute supported by 
#' this parameter). For example, filter=display_name=Companies returns 
#' only datasets named "Companies"; filter=display_name<G returns only 
#' datasets with names with first letter less than 'G'. You cannot combine 
#' this with the query parameter.
#' @references \url{https://app.enigma.io/api#data}
#' @return A tibble (data.frame) with columns (some contain nested lists or 
#' data.frame's):
#' \itemize{
#'  \item ancestors
#'  \item citation
#'  \item created_at
#'  \item data_updated_at
#'  \item description
#'  \item description_short
#'  \item display_name
#'  \item editable
#'  \item highlights
#'  \item id
#'  \item modified_at
#'  \item published
#'  \item schema_updated_at
#'  \item score
#'  \item current_snapshot
#'  \item parent_collection
#' }
#' @examples \dontrun{
#' res <- enigma_datasets(query = 'google', limit = 10)
#' res$ancestors
#' res$citation
#' res$data_updated_at
#' }
enigma_datasets <- function(query=NULL, parent_collection_id=NULL, limit=500, 
                          offset=NULL, sort=NULL, filter=NULL, key=NULL, ...) {
  key <- check_key(key)
  url <- file.path(en_base(), "datasets/")
  args <- ec(list(query = query, parent_collection_id = parent_collection_id,
               row_limit = limit, row_offset = offset,
               sort = sort, filter = filter))
  tibble::as_tibble(enigma_GET(url, key, args, ...))
}
