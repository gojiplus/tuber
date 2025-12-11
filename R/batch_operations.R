#' Batch Operations for YouTube API
#'
#' High-performance batch operations that can handle multiple IDs in single API calls,
#' dramatically reducing quota usage and improving performance.
#'
#' @name batch-operations
NULL


#' Get details for multiple videos in batches
#'
#' Efficiently retrieves video details for multiple video IDs using batch requests.
#' Much more quota-efficient than calling get_video_details() in a loop.
#'
#' @param video_ids Character vector of video IDs
#' @param part Character vector of parts to retrieve (snippet, statistics, etc.)
#' @param batch_size Number of videos per API call (max 50)
#' @param simplify Whether to return a simplified data frame
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)
#' @param show_progress Whether to show progress for large batches
#' @param ... Additional arguments passed to tuber_GET
#'
#' @return List or data frame containing video details
#' @export
#'
#' @examples
#' \dontrun{
#' video_ids <- c("dQw4w9WgXcQ", "M7FIvfx5J10", "kJQP7kiw5Fk")
#' details <- get_videos_batch(video_ids, part = c("snippet", "statistics"))
#' }
get_videos_batch <- function(video_ids, 
                            part = "snippet,statistics", 
                            batch_size = 50,
                            simplify = TRUE,
                            auth = "token",
                            show_progress = TRUE,
                            ...) {
  
  # Modern validation using checkmate
  assert_character(video_ids, any.missing = FALSE, min.len = 1, .var.name = "video_ids")
  assert_integerish(batch_size, len = 1, lower = 1, upper = 50, .var.name = "batch_size")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  assert_logical(simplify, len = 1, .var.name = "simplify")
  assert_logical(show_progress, len = 1, .var.name = "show_progress")
  
  if (length(part) > 1) {
    part <- paste0(part, collapse = ",")
  }
  
  # Remove duplicates and empty IDs
  video_ids <- unique(video_ids[nchar(video_ids) > 0])
  
  if (length(video_ids) == 0) {
    abort("No valid video IDs provided", 
                 class = "tuber_no_valid_ids")
  }
  
  # Split into batches
  total_batches <- ceiling(length(video_ids) / batch_size)
  batches <- split(video_ids, ceiling(seq_along(video_ids) / batch_size))
  
  if (show_progress && length(video_ids) > batch_size) {
    message("Processing ", length(video_ids), " videos in ", total_batches, " batch(es)...")
  }
  
  all_items <- list()
  
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
      api_calls_made = total_batches,
      function_name = "get_videos_batch",
      parameters = list(video_ids = video_ids, part = part, batch_size = batch_size),
      results_found = 0,
      response_format = if (simplify) "data.frame" else "list"
    ))
  }
  
  # Combine results
  result <- list(items = all_items)
  
  if (simplify) {
    # Convert to data frame using existing logic from get_video_details
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
    api_calls_made = total_batches,
    function_name = "get_videos_batch",
    parameters = list(video_ids = video_ids, part = part, batch_size = batch_size),
    results_found = length(all_items),
    videos_requested = length(video_ids),
    batches_processed = total_batches,
    response_format = if (simplify) "data.frame" else "list"
  )
  
  return(result)
}

#' Get statistics for multiple channels in batches
#'
#' Efficiently retrieves channel statistics for multiple channel IDs using batch requests.
#'
#' @param channel_ids Character vector of channel IDs
#' @param part Character vector of parts to retrieve
#' @param batch_size Number of channels per API call (max 50)
#' @param simplify Whether to return a simplified data frame
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)
#' @param show_progress Whether to show progress for large batches
#' @param ... Additional arguments passed to tuber_GET
#'
#' @return List or data frame containing channel statistics
#' @export
#'
#' @examples
#' \dontrun{
#' channel_ids <- c("UCuAXFkgsw1L7xaCfnd5JJOw", "UCsXVk37bltHxD1rDPwtNM8Q")
#' stats <- get_channels_batch(channel_ids, part = c("statistics", "snippet"))
#' }
get_channels_batch <- function(channel_ids,
                              part = "statistics,snippet",
                              batch_size = 50,
                              simplify = TRUE,
                              auth = "token", 
                              show_progress = TRUE,
                              ...) {
  
  # Modern validation using checkmate
  assert_character(channel_ids, any.missing = FALSE, min.len = 1, .var.name = "channel_ids")
  assert_integerish(batch_size, len = 1, lower = 1, upper = 50, .var.name = "batch_size")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  assert_logical(simplify, len = 1, .var.name = "simplify")
  assert_logical(show_progress, len = 1, .var.name = "show_progress")
  
  if (length(part) > 1) {
    part <- paste0(part, collapse = ",")
  }
  
  # Remove duplicates and empty IDs
  channel_ids <- unique(channel_ids[nchar(channel_ids) > 0])
  
  if (length(channel_ids) == 0) {
    abort("No valid channel IDs provided", 
                 class = "tuber_no_valid_ids")
  }
  
  # Split into batches
  total_batches <- ceiling(length(channel_ids) / batch_size)
  batches <- split(channel_ids, ceiling(seq_along(channel_ids) / batch_size))
  
  if (show_progress && length(channel_ids) > batch_size) {
    message("Processing ", length(channel_ids), " channels in ", total_batches, " batch(es)...")
  }
  
  all_items <- list()
  
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
      api_calls_made = total_batches,
      function_name = "get_channels_batch",
      parameters = list(channel_ids = channel_ids, part = part, batch_size = batch_size),
      results_found = 0,
      response_format = if (simplify) "data.frame" else "list"
    ))
  }
  
  # Combine results
  result <- list(items = all_items)
  
  if (simplify) {
    result <- tryCatch({
      # Convert to data frame
      items_df <- purrr::map_df(result$items, function(item) {
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
        
        return(as.data.frame(flat_item, stringsAsFactors = FALSE))
      })
      
      items_df
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
    api_calls_made = total_batches,
    function_name = "get_channels_batch",
    parameters = list(channel_ids = channel_ids, part = part, batch_size = batch_size),
    results_found = length(all_items),
    channels_requested = length(channel_ids),
    batches_processed = total_batches,
    response_format = if (simplify) "data.frame" else "list"
  )
  
  return(result)
}

#' Get playlist information for multiple playlists in batches
#'
#' Efficiently retrieves playlist information for multiple playlist IDs using batch requests.
#'
#' @param playlist_ids Character vector of playlist IDs
#' @param part Character vector of parts to retrieve
#' @param batch_size Number of playlists per API call (max 50)
#' @param simplify Whether to return a simplified data frame
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)
#' @param show_progress Whether to show progress for large batches
#' @param ... Additional arguments passed to tuber_GET
#'
#' @return List or data frame containing playlist information
#' @export
#'
#' @examples
#' \dontrun{
#' playlist_ids <- c("PLbpi6ZahtOH6Blw3RGYpWkSByi_T7Rygb", "PLbpi6ZahtOH7X7tNwcp9bJ2pdhKp0HcC6")
#' playlists <- get_playlists_batch(playlist_ids)
#' }
get_playlists_batch <- function(playlist_ids,
                               part = "snippet,status,contentDetails",
                               batch_size = 50,
                               simplify = TRUE,
                               auth = "token",
                               show_progress = TRUE,
                               ...) {
  
  # Modern validation using checkmate
  assert_character(playlist_ids, any.missing = FALSE, min.len = 1, .var.name = "playlist_ids")
  assert_integerish(batch_size, len = 1, lower = 1, upper = 50, .var.name = "batch_size")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  assert_logical(simplify, len = 1, .var.name = "simplify")
  assert_logical(show_progress, len = 1, .var.name = "show_progress")
  
  if (length(part) > 1) {
    part <- paste0(part, collapse = ",")
  }
  
  # Remove duplicates and empty IDs
  playlist_ids <- unique(playlist_ids[nchar(playlist_ids) > 0])
  
  if (length(playlist_ids) == 0) {
    abort("No valid playlist IDs provided", 
                 class = "tuber_no_valid_ids")
  }
  
  # Split into batches
  total_batches <- ceiling(length(playlist_ids) / batch_size)
  batches <- split(playlist_ids, ceiling(seq_along(playlist_ids) / batch_size))
  
  if (show_progress && length(playlist_ids) > batch_size) {
    message("Processing ", length(playlist_ids), " playlists in ", total_batches, " batch(es)...")
  }
  
  all_items <- list()
  
  for (i in seq_along(batches)) {
    batch_ids <- paste0(batches[[i]], collapse = ",")
    
    if (show_progress && total_batches > 1) {
      message("Batch ", i, "/", total_batches, " (", length(batches[[i]]), " playlists)")
    }
    
    # Make API call with retry logic
    batch_result <- call_api_with_retry(
      tuber_GET,
      path = "playlists",
      query = list(part = part, id = batch_ids),
      auth = auth,
      ...
    )
    
    if (!is.null(batch_result$items) && length(batch_result$items) > 0) {
      all_items <- c(all_items, batch_result$items)
    }
    
    # Add small delay between batches
    if (i < length(batches)) {
      Sys.sleep(0.1)
    }
  }
  
  if (length(all_items) == 0) {
    suggest_solution("empty_results", "- Check if playlist IDs are correct\n- Playlists may be private or deleted")
    warn("No playlist details found for any of the provided IDs", 
                class = "tuber_batch_empty_result")
    return(if (simplify) data.frame() else list())
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
  
  return(result)
}