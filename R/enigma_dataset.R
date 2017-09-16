#' Fetch dataset by ID and filter rows with query
#'
#' @export
#' 
#' @template key-curl
#' @param id (character) dataset ID. required.
#' @param query (character) Query string to return only rows that contain 
#' specific information (must set row_limit > 0).
#' @param limit (numeric) Number of rows of the dataset to return. Default 
#' (and max): 500
#' @param offset (numeric) Number of rows to skip. Default: 0
#' @param sort (character) List of dataset attributes indicating how to 
#' sort the datasets (currently display_name is the only attribute supported 
#' by this parameter). For example, sort=display_name sorts the datasets by 
#' display name. Since display_name is the default sort attribute, this 
#' parameter has no effect. You cannot combine this with the query parameter.
#' @param row_sort Specifies the field used to sort the records within the 
#' dataset. If you specify row_offset as well, the records are sorted first 
#' and then the offset is applied. Prepend the field name with a minus 
#' sign (-) to specify descending order (defaults to ascending).
#' @references \url{https://app.enigma.io/api#data}
#' @return A tibble (data.frame) with columns (some contain nested lists or 
#' data.frame's):
#' \itemize{
#'  \item ancestors
#'  \item citation
#'  \item created_at
#'  \item current_snapshot
#'  \item data_updated_at
#'  \item description
#'  \item description_short
#'  \item display_name
#'  \item editable
#'  \item id
#'  \item modified_at
#'  \item parent_collection
#'  \item published
#'  \item schema_updated_at
#' }
#' @examples \dontrun{
#' enigma_ds(id = 'a3164cd5-82e9-424b-8d75-efdd624141b1')
#' }
enigma_ds <- function(id, query = NULL, limit = 500, offset = NULL, 
                           sort = NULL, row_sort = NULL, key = NULL, ...) {
  key <- check_key(key)
  url <- sprintf("%s/%s/%s", en_base(), "datasets", id)
  args <- ec(list(query = query, row_limit = limit, row_offset = offset,
                  sort = sort, row_sort = row_sort))
  enigma_GET(url, key, args, ...)
}
