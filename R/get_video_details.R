# helpers for data frame conversion in `get_video_details()`
conditional_unnest_wider <- function(data_input, var) {
  if (var %in% names(data_input)) {
    tidyr::unnest_wider(data_input, var, names_sep = "_")
  } else {
    data_input
  }
}

# Added to squash notes on devtools check.
utils::globalVariables(c("kind", "etag", "items", "snippet"))

json_to_df <- function(res) {
  intermediate <- res %>%
    tibble::enframe() %>%
    tidyr::pivot_wider() %>%
    tidyr::unnest(cols = c(kind, etag)) %>%
    # reflect level of nesting in column name
    dplyr::rename(response_kind = kind, response_etag = etag) %>%
    tidyr::unnest(items) %>%
    tidyr::unnest_wider(col = items) %>%
    # reflect level of nesting in column name for those that may not be unique
    dplyr::rename(items_kind = kind, items_etag = etag) %>%
    tidyr::unnest_wider(snippet)

  intermediate_2 <- intermediate %>%
    # fields that may not be available:
    # live streaming details
    conditional_unnest_wider(var = "liveStreamingDetails") %>%
    # region restriction (rental videos)
    conditional_unnest_wider(var = "regionRestriction") %>%
    conditional_unnest_wider(var = "regionRestriction_allowed") %>%
    # statistics
    conditional_unnest_wider(var = "statistics") %>%
    # status
    conditional_unnest_wider(var = "status") %>%
    # player
    conditional_unnest_wider(var = "player") %>%
    # contentDetails
    conditional_unnest_wider(var = "contentDetails") %>%
    conditional_unnest_wider(var = "topicDetails") %>%
    conditional_unnest_wider(var = "localized") %>%
    conditional_unnest_wider(var = "pageInfo") %>%
    # thumbnails
    conditional_unnest_wider(var = "thumbnails") %>%
    conditional_unnest_wider(var = "thumbnails_default") %>%
    conditional_unnest_wider(var = "thumbnails_standard") %>%
    conditional_unnest_wider(var = "thumbnails_medium") %>%
    conditional_unnest_wider(var = "thumbnails_high") %>%
    conditional_unnest_wider(var = "thumbnails_maxres")

  return(intermediate_2)
}

#' Get Video Details
#'
#' Get details for one or more YouTube videos efficiently using batch processing.
#'
#' @param video_ids Character vector of video IDs to retrieve
#' @param part Character vector of parts to retrieve. See \code{Details} for options.
#' @param simplify Logical. If TRUE, returns a data frame. If FALSE, returns raw list. Default: FALSE.
#' @param batch_size Number of videos per API call (max 50). Default: 50.
#' @param show_progress Whether to show progress for large batches. Default: TRUE for >10 videos.
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key). Default: "token".
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @details 
#' Valid values for \code{part}: \code{contentDetails, fileDetails, id, 
#' liveStreamingDetails, localizations, paidProductPlacementDetails, player, 
#' processingDetails, recordingDetails, snippet, statistics, status, 
#' suggestions, topicDetails}.
#' 
#' Certain parts like \code{fileDetails, suggestions, processingDetails} are 
#' only available to video owners and require OAuth authentication.
#' 
#' The function automatically batches requests to minimize API quota usage:
#' - 1 video = 1 API call
#' - 100 videos = 2 API calls (batched in groups of 50)
#'
#' @return 
#' When \code{simplify = FALSE} (default): List with items containing video details.
#' When \code{simplify = TRUE}: Data frame with video details (not available for owner-only parts).
#' 
#' The result includes metadata as attributes:
#' - \code{api_calls_made}: Number of API calls made
#' - \code{quota_used}: Estimated quota units consumed
#' - \code{videos_requested}: Number of videos requested
#' - \code{results_found}: Number of videos found
#'
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/videos/list}
#'
#' @examples
#' \dontrun{
#' # Single video
#' details <- get_video_details("yJXTXN4xrI8")
#' 
#' # Multiple videos - automatically batched
#' video_ids <- c("yJXTXN4xrI8", "LDZX4ooRsWs", "kJQP7kiw5Fk")
#' details <- get_video_details(video_ids)
#' 
#' # Get as data frame
#' df <- get_video_details(video_ids, simplify = TRUE)
#' 
#' # Get specific parts
#' stats <- get_video_details(video_ids, part = c("statistics", "contentDetails"))
#' 
#' # Extract specific fields:
#' details <- get_video_details("yJXTXN4xrI8")
#' title <- details$items[[1]]$snippet$title
#' view_count <- details$items[[1]]$statistics$viewCount
#' }
#'
get_video_details <- function(video_ids, 
                             part = "snippet",
                             simplify = FALSE,
                             batch_size = 50,
                             show_progress = NULL,
                             auth = "token",
                             ...) {
  
  # Modern validation using checkmate
  assert_character(video_ids, any.missing = FALSE, min.len = 1, .var.name = "video_ids")
  assert_character(part, min.len = 1, .var.name = "part")
  assert_logical(simplify, len = 1, .var.name = "simplify")
  assert_integerish(batch_size, len = 1, lower = 1, upper = 50, .var.name = "batch_size")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  
  # Auto-detect whether to show progress
  if (is.null(show_progress)) {
    show_progress <- length(video_ids) > 10
  }
  assert_logical(show_progress, len = 1, .var.name = "show_progress")
  
  # Join part parameter if vector
  if (length(part) > 1) {
    part <- paste0(part, collapse = ",")
  }
  
  # Check for owner-only parts when simplify is TRUE
  parts_only_for_video_owners <- c("fileDetails", "suggestions", "processingDetails")
  if (simplify && any(strsplit(part, ",")[[1]] %in% parts_only_for_video_owners)) {
    abort("Data frame conversion not supported with owner-only parts",
          owner_only_parts = parts_only_for_video_owners,
          requested_parts = part,
          help = "Use simplify = FALSE for owner-only parts",
          class = "tuber_incompatible_dataframe_parts")
  }
  
  # Remove duplicates and empty IDs
  video_ids <- unique(video_ids[nchar(video_ids) > 0])
  
  if (length(video_ids) == 0) {
    abort("No valid video IDs provided",
          class = "tuber_no_valid_ids")
  }
  
  # For single video, keep simple behavior
  if (length(video_ids) == 1) {
    querylist <- list(part = part, id = video_ids)
    
    raw_res <- call_api_with_retry(
      tuber_GET,
      path = "videos",
      query = querylist,
      auth = auth,
      ...
    )
    
    if (length(raw_res$items) == 0) {
      suggest_solution("empty_results", "- Check if the video ID is correct\n- Video may be private or deleted")
      warning("No video details found for ID: ", video_ids, call. = FALSE)
      
      empty_result <- if (simplify) data.frame() else list()
      return(add_tuber_attributes(
        empty_result,
        api_calls_made = 1,
        function_name = "get_video_details",
        parameters = list(video_ids = video_ids, part = part, simplify = simplify),
        results_found = 0
      ))
    }
    
    if (simplify) {
      raw_res <- tryCatch({
        purrr::map_df(raw_res$items, ~ flatten(.x))
      }, error = function(e) {
        warn("Failed to convert to data frame",
             message = e$message,
             help = "Returning list format",
             class = "tuber_conversion_failed")
        raw_res
      })
    }
    
    return(add_tuber_attributes(
      raw_res,
      api_calls_made = 1,
      function_name = "get_video_details",
      parameters = list(video_ids = video_ids, part = part, simplify = simplify),
      results_found = if (is.data.frame(raw_res)) nrow(raw_res) else length(raw_res$items),
      response_format = if (simplify) "data.frame" else "list"
    ))
  }
  
  # For multiple videos, use batching
  total_batches <- ceiling(length(video_ids) / batch_size)
  batches <- split(video_ids, ceiling(seq_along(video_ids) / batch_size))
  
  if (show_progress) {
    message("Processing ", length(video_ids), " videos in ", total_batches, " batch(es)...")
  }
  
  all_items <- list()
  api_calls_made <- 0
  
  for (i in seq_along(batches)) {
    batch_ids <- paste0(batches[[i]], collapse = ",")
    
    if (show_progress && total_batches > 1) {
      message("Batch ", i, "/", total_batches, " (", length(batches[[i]]), " videos)")
    }
    
    # Make API call with retry logic
    batch_result <- call_api_with_retry(
      tuber_GET,
      path = "videos",
      query = list(part = part, id = batch_ids),
      auth = auth,
      ...
    )
    api_calls_made <- api_calls_made + 1
    
    if (!is.null(batch_result$items) && length(batch_result$items) > 0) {
      all_items <- c(all_items, batch_result$items)
    }
    
    # Add small delay between batches to be respectful
    if (i < length(batches)) {
      Sys.sleep(0.1)
    }
  }
  
  if (length(all_items) == 0) {
    suggest_solution("empty_results", "- Check if video IDs are correct\n- Videos may be private or deleted")
    warn("No video details found for any of the provided IDs",
         class = "tuber_batch_empty_result")
    
    empty_result <- if (simplify) data.frame() else list()
    return(add_tuber_attributes(
      empty_result,
      api_calls_made = api_calls_made,
      function_name = "get_video_details",
      parameters = list(video_ids = video_ids, part = part, batch_size = batch_size),
      results_found = 0,
      response_format = if (simplify) "data.frame" else "list"
    ))
  }
  
  # Combine results
  result <- list(items = all_items)
  
  if (simplify) {
    result <- tryCatch({
      purrr::map_df(result$items, ~ flatten(.x))
    }, error = function(e) {
      warn("Failed to convert to data frame",
           message = e$message,
           help = "Returning list format",
           class = "tuber_batch_conversion_failed")
      result
    })
  }
  
  # Add standardized attributes
  result <- add_tuber_attributes(
    result,
    api_calls_made = api_calls_made,
    function_name = "get_video_details",
    parameters = list(video_ids = video_ids, part = part, batch_size = batch_size),
    results_found = length(all_items),
    videos_requested = length(video_ids),
    batches_processed = total_batches,
    response_format = if (simplify) "data.frame" else "list"
  )
  
  return(result)
}