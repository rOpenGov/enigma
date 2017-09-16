#' Fetch dataset by ID and filter rows with query
#'
#' @export
#' 
#' @template key-curl
#' @param id (character) dataset ID. required.
#' @param snapshot_id (character) snapshot ID. optional
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
#' @param row_sort Specifies the field used to sort the records. If you 
#' specify row_offset as well, the records are sorted first and then the 
#' offset is applied. Prepend the field name with a minus sign (-) to 
#' specify descending order (defaults to ascending).
#' @param highlight (logical) When `TRUE`, for rows returned based on a query 
#' string, the endpoint sets the returned highlights attribute with positional 
#' information indicating where instances of the specified string occur. 
#' Default: `FALSE`
#' @examples \dontrun{
#' enigma_ds_snapshots(id = 'a3164cd5-82e9-424b-8d75-efdd624141b1')
#' # snapshots
#' enigma_ds_snapshots(id = 'a3164cd5-82e9-424b-8d75-efdd624141b1', 
#'    snapshot_id = "6cc93c26-a99d-4d2a-b57e-b2806ff1f45e")
#' }
enigma_ds_snapshots <- function(id, snapshot_id = NULL, query = NULL, 
  limit = 500, offset=NULL, sort=NULL, row_sort = NULL, highlight = NULL, 
  key=NULL, ...) {
  
  key <- check_key(key)
  url <- sprintf("%s/datasets/%s/snapshots/", en_base(), id)
  if (!is.null(snapshot_id)) url <- sprintf("%s/%s", url, snapshot_id)
  args <- ec(list(query = query, row_limit = limit, row_offset = offset,
                  sort = sort, row_sort = row_sort, highlight = highlight))
  enigma_GET(url, key, args, ...)
}
