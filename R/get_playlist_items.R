#' Get Playlist Items
#'
#' @param filter string; Required.
#' named vector of length 1
#' potential names of the entry in the vector:
#' \code{item_id}: comma-separated list of one or more unique playlist item IDs.
#' \code{playlist_id}: YouTube playlist ID.
#'
#' @param part Required. Comma separated string including one or more of the
#' following: \code{contentDetails, id, snippet, status}. Default:
#' \code{contentDetails}.
#' @param max_results Maximum number of items that should be returned.
#' Integer. Optional. Default is 50. If over 50, additional requests are made
#' until the requested amount is retrieved. Larger values may increase API quota
#' usage.
#' @param simplify returns a data.frame rather than a list.
#' @param page_token specific page in the result set that should be
#' returned, optional
#' @param video_id  Optional. request should return only the playlist
#' items that contain the specified video.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return playlist items
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/playlistItems/list}
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' get_playlist_items(filter =
#'                        c(playlist_id = "PLrEnWoR732-CN09YykVof2lxdI3MLOZda"))
#' get_playlist_items(filter =
#'                        c(playlist_id = "PL0fOlXVeVW9QMO3GoESky4yDgQfK2SsXN"),
#'                        max_results = 51)
#' }

get_playlist_items <- function(filter = NULL, part = "contentDetails",
                              max_results = 50, video_id = NULL,
                              page_token = NULL, simplify = TRUE, ...) {

  # if (max_results < 0 || max_results > 50) {
  #   stop("max_results must be a value between 0 and 50.")
  # }

  valid_filters <- c("item_id", "playlist_id")
  if (!(names(filter) %in% valid_filters)) {
    stop("filter can only take one of the following values: item_id, playlist_id.")
  }

  if (length(filter) != 1) {
    stop("filter must be a vector of length 1.")
  }

  translate_filter <- c(item_id = "id", playlist_id = "playlistId")
  filter_name <- translate_filter[names(filter)]
  names(filter) <- filter_name

  querylist <- list(part = part,
                    maxResults = min(max_results, 50),
                    pageToken = page_token, videoId = video_id)
  querylist <- c(querylist, filter)

  # Initial API call with retry logic
  res <- call_api_with_retry(tuber_GET, path = "playlistItems", query = querylist, ...)
  
  # Check if we got any results
  if (is.null(res$items) || length(res$items) == 0) {
    if (simplify) {
      return(data.frame())
    } else {
      return(res)
    }
  }
  
  # Use standardized pagination pattern
  all_items <- res$items
  page_token <- res$nextPageToken
  api_calls_made <- 1  # Track API calls for attributes
  
  # Continue pagination while we need more results and have a token
  while (!is.null(page_token) && is.character(page_token) && 
         length(all_items) < max_results) {
    
    querylist$pageToken <- page_token
    querylist$maxResults <- min(50, max_results - length(all_items))
    
    a_res <- call_api_with_retry(tuber_GET, path = "playlistItems", query = querylist, ...)
    api_calls_made <- api_calls_made + 1
    
    # Add new items if available
    if (!is.null(a_res$items) && length(a_res$items) > 0) {
      # Only take what we need
      needed <- max_results - length(all_items)
      items_to_add <- if (length(a_res$items) > needed) {
        a_res$items[seq_len(needed)]
      } else {
        a_res$items
      }
      all_items <- c(all_items, items_to_add)
    }
    
    page_token <- a_res$nextPageToken
    
    # Safety break if no new items
    if (is.null(a_res$items) || length(a_res$items) == 0) {
      break
    }
  }
  
  # Update response with all collected items
  res$items <- all_items
  res$nextPageToken <- page_token

  if (simplify) {
    # Improved simplification logic 
    if (length(all_items) == 0) {
      empty_df <- data.frame()
      return(add_tuber_attributes(
        empty_df,
        api_calls_made = api_calls_made,
        function_name = "get_playlist_items",
        parameters = list(filter = filter, part = part, max_results = max_results),
        results_found = 0,
        response_format = "data.frame"
      ))
    }
    
    # Process each item and flatten to data.frame
    simplified_items <- lapply(all_items, function(item) {
      # Flatten the nested structure
      flattened <- unlist(item, recursive = TRUE)
      # Convert to single-row data.frame
      as.data.frame(t(flattened), stringsAsFactors = FALSE)
    })
    
    # Combine all rows into single data.frame
    res <- do.call(plyr::rbind.fill, simplified_items)
    
    # Add attributes to simplified result
    res <- add_tuber_attributes(
      res,
      api_calls_made = api_calls_made,
      function_name = "get_playlist_items",
      parameters = list(filter = filter, part = part, max_results = max_results),
      results_found = nrow(res),
      response_format = "data.frame",
      pagination_used = api_calls_made > 1
    )
  } else {
    # Add attributes to list result 
    res <- add_tuber_attributes(
      res,
      api_calls_made = api_calls_made,
      function_name = "get_playlist_items",
      parameters = list(filter = filter, part = part, max_results = max_results),
      results_found = length(all_items),
      response_format = "list",
      pagination_used = api_calls_made > 1
    )
  }

  return(res)
}

