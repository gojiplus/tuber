#' Get Channel Statistics
#'
#' Get statistics and details for one or more YouTube channels efficiently using batch processing.
#'
#' @param channel_ids Character vector of channel IDs to retrieve. Use \code{list_my_channel()} 
#' to get your own channel ID.
#' @param mine Logical. Set to TRUE to get authenticated user's channel. 
#' Overrides \code{channel_ids}. Default: NULL.
#' @param part Character vector of parts to retrieve. Default: c("statistics", "snippet").
#' @param simplify Logical. If TRUE, returns a data frame. If FALSE, returns raw list. Default: FALSE.
#' @param batch_size Number of channels per API call (max 50). Default: 50.
#' @param show_progress Whether to show progress for large batches. Default: TRUE for >10 channels.
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key). Default: "token".
#' @param console_output Logical. Show console output for single channel. Default: TRUE.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @details 
#' Valid parts include: \code{auditDetails, brandingSettings, contentDetails, 
#' contentOwnerDetails, id, localizations, snippet, statistics, status, 
#' topicDetails}.
#' 
#' The function automatically batches requests to minimize API quota usage:
#' - 1 channel = 1 API call
#' - 100 channels = 2 API calls (batched in groups of 50)
#' 
#' When retrieving a single channel, the function displays key statistics 
#' in the console by default (can be disabled with \code{console_output = FALSE}).
#'
#' @return 
#' When \code{simplify = FALSE} (default): List with channel details.
#' When \code{simplify = TRUE}: Data frame with channel details.
#' 
#' For single channels, returns the channel object directly (not in a list).
#' For multiple channels, returns a list with items array.
#'
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/channels/list}
#' 
#' @examples
#' \dontrun{
#' # Get stats for a single channel - displays console output
#' stats <- get_channel_stats("UCT5Cx1l4IS3wHkJXNyuj4TA")
#' 
#' # Get stats for multiple channels - automatically batched
#' channel_ids <- c("UCT5Cx1l4IS3wHkJXNyuj4TA", "UCfK2eFCRQ64Gqfrpbrcj31w")
#' stats <- get_channel_stats(channel_ids)
#' 
#' # Get as data frame
#' df <- get_channel_stats(channel_ids, simplify = TRUE)
#' 
#' # Get your own channel stats
#' my_stats <- get_channel_stats(mine = TRUE)
#' 
#' # Get additional parts
#' detailed <- get_channel_stats(channel_ids, 
#'                              part = c("statistics", "snippet", "brandingSettings"))
#' }
#'
get_channel_stats <- function(channel_ids = NULL, 
                             mine = NULL,
                             part = c("statistics", "snippet"),
                             simplify = FALSE,
                             batch_size = 50,
                             show_progress = NULL,
                             auth = "token",
                             console_output = TRUE,
                             ...) {
  
  # Modern validation using checkmate
  if (!is.null(mine)) {
    assert_logical(mine, len = 1, .var.name = "mine")
  }
  assert_logical(simplify, len = 1, .var.name = "simplify")
  assert_integerish(batch_size, len = 1, lower = 1, upper = 50, .var.name = "batch_size")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  assert_logical(console_output, len = 1, .var.name = "console_output")
  
  # Handle mine parameter
  if (identical(tolower(mine), "false")) {
    mine <- NULL
  }
  
  # If getting authenticated user's channel
  if (identical(tolower(mine), "true")) {
    if (length(part) > 1) {
      part <- paste0(part, collapse = ",")
    }
    
    querylist <- list(part = part, mine = "true")
    
    raw_res <- call_api_with_retry(tuber_GET, path = "channels", query = querylist, auth = auth, ...)
    
    if (length(raw_res$items) == 0) {
      warn("No channel stats available. Likely cause: No channel associated with account",
           class = "tuber_my_channel_empty")
      return(if (simplify) data.frame() else list())
    }
    
    res <- raw_res$items[[1]]
    
    if (console_output) {
      res_stats <- res$statistics
      res_snippet <- res$snippet
      cat("Channel Title:", res_snippet$title, "\n")
      cat("No. of Views:", res_stats$viewCount, "\n")
      cat("No. of Subscribers:", res_stats$subscriberCount, "\n")
      cat("No. of Videos:", res_stats$videoCount, "\n")
    }
    
    if (simplify) {
      res <- tryCatch({
        flatten_channel_data(list(res))
      }, error = function(e) {
        warn("Failed to convert to data frame",
             message = e$message,
             help = "Returning list format",
             class = "tuber_conversion_failed")
        res
      })
    }
    
    return(res)
  }
  
  # Validate channel_ids
  assert_character(channel_ids, any.missing = FALSE, min.len = 1, .var.name = "channel_ids")
  
  # Auto-detect whether to show progress
  if (is.null(show_progress)) {
    show_progress <- length(channel_ids) > 10
  }
  assert_logical(show_progress, len = 1, .var.name = "show_progress")
  
  # Join part parameter if vector
  if (length(part) > 1) {
    part <- paste0(part, collapse = ",")
  }
  
  # Remove duplicates and empty IDs
  channel_ids <- unique(channel_ids[nchar(channel_ids) > 0])
  
  if (length(channel_ids) == 0) {
    abort("No valid channel IDs provided",
          class = "tuber_no_valid_ids")
  }
  
  # For single channel, keep simple behavior
  if (length(channel_ids) == 1) {
    querylist <- list(part = part, id = channel_ids)
    
    raw_res <- call_api_with_retry(tuber_GET, path = "channels", query = querylist, auth = auth, ...)
    
    if (length(raw_res$items) == 0) {
      warn("No channel stats available. Likely cause: Incorrect channel_id",
           channel_id = channel_ids,
           class = "tuber_channel_stats_empty")
      return(if (simplify) data.frame() else list())
    }
    
    res <- raw_res$items[[1]]
    
    if (console_output) {
      res_stats <- res$statistics
      res_snippet <- res$snippet
      cat("Channel Title:", res_snippet$title, "\n")
      cat("No. of Views:", res_stats$viewCount, "\n")
      cat("No. of Subscribers:", res_stats$subscriberCount, "\n")
      cat("No. of Videos:", res_stats$videoCount, "\n")
    }
    
    if (simplify) {
      res <- tryCatch({
        flatten_channel_data(list(res))
      }, error = function(e) {
        warn("Failed to convert to data frame",
             message = e$message,
             help = "Returning list format",
             class = "tuber_conversion_failed")
        res
      })
    }
    
    return(res)
  }
  
  # For multiple channels, use batching
  total_batches <- ceiling(length(channel_ids) / batch_size)
  batches <- split(channel_ids, ceiling(seq_along(channel_ids) / batch_size))
  
  if (show_progress) {
    message("Processing ", length(channel_ids), " channels in ", total_batches, " batch(es)...")
  }
  
  all_items <- list()
  api_calls_made <- 0
  
  for (i in seq_along(batches)) {
    batch_ids <- paste0(batches[[i]], collapse = ",")
    
    if (show_progress && total_batches > 1) {
      message("Batch ", i, "/", total_batches, " (", length(batches[[i]]), " channels)")
    }
    
    # Make API call with retry logic
    batch_result <- call_api_with_retry(
      tuber_GET,
      path = "channels",
      query = list(part = part, id = batch_ids),
      auth = auth,
      ...
    )
    api_calls_made <- api_calls_made + 1
    
    if (!is.null(batch_result$items) && length(batch_result$items) > 0) {
      all_items <- c(all_items, batch_result$items)
    }
    
    # Add small delay between batches
    if (i < length(batches)) {
      Sys.sleep(0.1)
    }
  }
  
  if (length(all_items) == 0) {
    suggest_solution("empty_results", "- Check if channel IDs are correct\n- Channels may be private or deleted")
    warn("No channel details found for any of the provided IDs",
         class = "tuber_batch_empty_result")
    
    empty_result <- if (simplify) data.frame() else list()
    return(add_tuber_attributes(
      empty_result,
      api_calls_made = api_calls_made,
      function_name = "get_channel_stats",
      parameters = list(channel_ids = channel_ids, part = part, batch_size = batch_size),
      results_found = 0,
      response_format = if (simplify) "data.frame" else "list"
    ))
  }
  
  # Combine results
  result <- list(items = all_items)
  
  if (simplify) {
    result <- tryCatch({
      flatten_channel_data(all_items)
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
    function_name = "get_channel_stats",
    parameters = list(channel_ids = channel_ids, part = part, batch_size = batch_size),
    results_found = length(all_items),
    channels_requested = length(channel_ids),
    batches_processed = total_batches,
    response_format = if (simplify) "data.frame" else "list"
  )
  
  return(result)
}

#' @rdname get_channel_stats
#' @export
list_my_channel <- function(...) {
  get_channel_stats(mine = TRUE, ...)
}

# Helper function to flatten channel data to data frame
flatten_channel_data <- function(items) {
  purrr::map_df(items, function(item) {
    # Flatten the nested structure
    flat_item <- list()
    
    # Basic info
    flat_item$channel_id <- item$id %||% NA
    flat_item$kind <- item$kind %||% NA
    flat_item$etag <- item$etag %||% NA
    
    # Snippet info
    if (!is.null(item$snippet)) {
      flat_item$title <- item$snippet$title %||% NA
      flat_item$description <- item$snippet$description %||% NA
      flat_item$published_at <- item$snippet$publishedAt %||% NA
      flat_item$country <- item$snippet$country %||% NA
      flat_item$default_language <- item$snippet$defaultLanguage %||% NA
      flat_item$custom_url <- item$snippet$customUrl %||% NA
      
      if (!is.null(item$snippet$thumbnails$default)) {
        flat_item$thumbnail_url <- item$snippet$thumbnails$default$url %||% NA
      }
    }
    
    # Statistics
    if (!is.null(item$statistics)) {
      flat_item$view_count <- as.numeric(item$statistics$viewCount %||% 0)
      flat_item$subscriber_count <- as.numeric(item$statistics$subscriberCount %||% 0)
      flat_item$video_count <- as.numeric(item$statistics$videoCount %||% 0)
      flat_item$subscriber_count_hidden <- item$statistics$hiddenSubscriberCount %||% FALSE
    }
    
    # Content details
    if (!is.null(item$contentDetails)) {
      flat_item$uploads_playlist <- item$contentDetails$relatedPlaylists$uploads %||% NA
      flat_item$likes_playlist <- item$contentDetails$relatedPlaylists$likes %||% NA
    }
    
    # Branding settings
    if (!is.null(item$brandingSettings)) {
      flat_item$keywords <- item$brandingSettings$channel$keywords %||% NA
      flat_item$unsubscribed_trailer <- item$brandingSettings$channel$unsubscribedTrailer %||% NA
    }
    
    return(as.data.frame(flat_item, stringsAsFactors = FALSE))
  })
}