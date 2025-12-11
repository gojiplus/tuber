#' Extended YouTube API Endpoints
#'
#' Functions for YouTube API endpoints that were not previously covered in tuber,
#' including live streaming, thumbnails, channel sections, and modern video features.
#'
#' @name extended-endpoints
NULL

#' Get live stream information
#'
#' Retrieves information about live streams and premieres.
#'
#' @param stream_id Live stream ID (optional if using other filters)
#' @param channel_id Channel ID to get live streams for
#' @param part Parts to retrieve
#' @param status Filter by status: "active", "upcoming", "completed"
#' @param simplify Whether to return a simplified data frame
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)
#' @param ... Additional arguments passed to tuber_GET
#'
#' @return List or data frame with live stream information
#' @export
#'
#' @examples
#' \dontrun{
#' # Get live streams for a channel
#' streams <- get_live_streams(channel_id = "UCuAXFkgsw1L7xaCfnd5JJOw")
#' 
#' # Get specific live stream details
#' stream <- get_live_streams(stream_id = "abc123", part = c("snippet", "status"))
#' }
get_live_streams <- function(stream_id = NULL, 
                            channel_id = NULL,
                            part = "snippet,status",
                            status = NULL,
                            simplify = TRUE,
                            auth = "token",
                            ...) {
  
  # Modern validation using checkmate
  if (is.null(stream_id) && is.null(channel_id)) {
    abort("Either stream_id or channel_id must be provided",
          class = "tuber_missing_required_parameter")
  }
  
  if (!is.null(stream_id)) {
    assert_character(stream_id, len = 1, min.chars = 1, .var.name = "stream_id")
  }
  
  if (!is.null(channel_id)) {
    assert_character(channel_id, len = 1, min.chars = 1, .var.name = "channel_id")
  }
  
  assert_character(part, len = 1, min.chars = 1, .var.name = "part")
  assert_flag(simplify, .var.name = "simplify")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  
  if (!is.null(status)) {
    assert_choice(status, c("active", "upcoming", "completed"), .var.name = "status")
  }
  
  if (length(part) > 1) {
    part <- paste0(part, collapse = ",")
  }
  
  # Build query
  query <- list(part = part)
  
  if (!is.null(stream_id)) {
    query$id <- stream_id
  }
  
  if (!is.null(channel_id)) {
    query$channelId <- channel_id
  }
  
  if (!is.null(status)) {
    query$eventType <- status
  }
  
  # Make API call
  result <- call_api_with_retry(
    tuber_GET,
    path = "liveBroadcasts", 
    query = query,
    auth = auth,
    ...
  )
  
  if (length(result$items) == 0) {
    suggest_solution("empty_results", "- Check if channel has live streams\n- Live streams may be private or restricted")
    return(if (simplify) data.frame() else list())
  }
  
  if (simplify) {
    result <- tryCatch({
      purrr::map_df(result$items, ~ flatten(.x))
    }, error = function(e) {
      warning("Failed to convert to data frame: ", e$message, ". Returning list format.", call. = FALSE)
      result
    })
  }
  
  return(result)
}

#' Get video thumbnails information
#'
#' Retrieves thumbnail URLs and metadata for videos.
#'
#' @param video_id Video ID or vector of video IDs
#' @param size Thumbnail size: "default", "medium", "high", "standard", "maxres"
#' @param simplify Whether to return a simplified data frame
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)
#' @param ... Additional arguments passed to tuber_GET
#'
#' @return List or data frame with thumbnail information
#' @export
#'
#' @examples
#' \dontrun{
#' # Get all thumbnail sizes for a video
#' thumbs <- get_video_thumbnails("dQw4w9WgXcQ")
#' 
#' # Get only high resolution thumbnails
#' thumbs_hd <- get_video_thumbnails("dQw4w9WgXcQ", size = "high")
#' 
#' # Get thumbnails for multiple videos
#' thumbs_batch <- get_video_thumbnails(c("dQw4w9WgXcQ", "M7FIvfx5J10"))
#' }
get_video_thumbnails <- function(video_id, 
                                size = NULL,
                                simplify = TRUE,
                                auth = "key",
                                ...) {
  
  # Modern validation using checkmate
  assert_character(video_id, min.len = 1, .var.name = "video_id")
  assert_flag(simplify, .var.name = "simplify")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  
  if (!is.null(size)) {
    assert_choice(size, c("default", "medium", "high", "standard", "maxres"), .var.name = "size")
  }
  
  if (length(video_id) > 1) {
    video_id <- paste0(video_id, collapse = ",")
  }
  
  # Get video details with snippet part to access thumbnails
  query <- list(part = "snippet", id = video_id)
  
  result <- call_api_with_retry(
    tuber_GET,
    path = "videos",
    query = query,
    auth = auth,
    ...
  )
  
  if (length(result$items) == 0) {
    suggest_solution("empty_results", "- Check if video IDs are correct\n- Videos may be private or deleted")
    return(if (simplify) data.frame() else list())
  }
  
  # Extract and format thumbnail information
  thumbnail_data <- lapply(result$items, function(item) {
    thumbs <- item$snippet$thumbnails
    video_info <- list(
      video_id = item$id,
      title = item$snippet$title %||% NA_character_
    )
    
    if (!is.null(size)) {
      # Return only requested size
      if (!is.null(thumbs[[size]])) {
        video_info[[paste0(size, "_url")]] <- thumbs[[size]]$url
        video_info[[paste0(size, "_width")]] <- thumbs[[size]]$width
        video_info[[paste0(size, "_height")]] <- thumbs[[size]]$height
      }
    } else {
      # Return all available sizes
      for (thumb_size in names(thumbs)) {
        video_info[[paste0(thumb_size, "_url")]] <- thumbs[[thumb_size]]$url
        video_info[[paste0(thumb_size, "_width")]] <- thumbs[[thumb_size]]$width
        video_info[[paste0(thumb_size, "_height")]] <- thumbs[[thumb_size]]$height
      }
    }
    
    return(video_info)
  })
  
  if (simplify) {
    result <- tryCatch({
      dplyr::bind_rows(thumbnail_data)
    }, error = function(e) {
      warning("Failed to convert to data frame: ", e$message, ". Returning list format.", call. = FALSE)
      thumbnail_data
    })
  } else {
    result <- thumbnail_data
  }
  
  return(result)
}

#' Get channel sections
#'
#' Retrieves channel sections (featured channels, playlists, etc.).
#'
#' @param channel_id Channel ID
#' @param section_id Specific section ID (optional)
#' @param part Parts to retrieve
#' @param simplify Whether to return a simplified data frame
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)
#' @param ... Additional arguments passed to tuber_GET
#'
#' @return List or data frame with channel section information
#' @export
#'
#' @examples
#' \dontrun{
#' # Get all sections for a channel
#' sections <- get_channel_sections(channel_id = "UCuAXFkgsw1L7xaCfnd5JJOw")
#' 
#' # Get specific section
#' section <- get_channel_sections(section_id = "UC_x5XG1OV2P6uZZ5FSM9Ttw.e-Fk7vMeOn4")
#' }
get_channel_sections <- function(channel_id = NULL,
                                section_id = NULL,
                                part = "snippet,contentDetails",
                                simplify = TRUE,
                                auth = "key",
                                ...) {
  
  # Modern validation using checkmate
  if (is.null(channel_id) && is.null(section_id)) {
    abort("Either channel_id or section_id must be provided",
          class = "tuber_missing_required_parameter")
  }
  
  if (!is.null(channel_id)) {
    assert_character(channel_id, len = 1, min.chars = 1, .var.name = "channel_id")
  }
  
  if (!is.null(section_id)) {
    assert_character(section_id, len = 1, min.chars = 1, .var.name = "section_id")
  }
  
  assert_character(part, len = 1, min.chars = 1, .var.name = "part")
  assert_flag(simplify, .var.name = "simplify")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  
  if (length(part) > 1) {
    part <- paste0(part, collapse = ",")
  }
  
  # Build query
  query <- list(part = part)
  
  if (!is.null(channel_id)) {
    query$channelId <- channel_id
  }
  
  if (!is.null(section_id)) {
    query$id <- section_id
  }
  
  # Make API call
  result <- call_api_with_retry(
    tuber_GET,
    path = "channelSections",
    query = query,
    auth = auth,
    ...
  )
  
  if (length(result$items) == 0) {
    suggest_solution("empty_results", "- Channel may not have custom sections\n- Check if channel ID is correct")
    return(if (simplify) data.frame() else list())
  }
  
  if (simplify) {
    result <- tryCatch({
      purrr::map_df(result$items, ~ flatten(.x))
    }, error = function(e) {
      warning("Failed to convert to data frame: ", e$message, ". Returning list format.", call. = FALSE)
      result
    })
  }
  
  return(result)
}

#' Search for shorts (YouTube Shorts)
#'
#' Search specifically for YouTube Shorts videos.
#'
#' @param query Search query
#' @param max_results Maximum number of results (1-50)
#' @param order Sort order: "date", "rating", "relevance", "title", "viewCount"
#' @param region_code Region code for search
#' @param published_after RFC 3339 formatted date-time (e.g., "2023-01-01T00:00:00Z")
#' @param published_before RFC 3339 formatted date-time
#' @param simplify Whether to return simplified data frame
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)
#' @param ... Additional arguments passed to tuber_GET
#'
#' @return List or data frame with search results for shorts
#' @export
#'
#' @examples
#' \dontrun{
#' # Search for recent shorts about cats
#' shorts <- search_shorts("cats", max_results = 25, order = "date")
#' 
#' # Search for popular shorts in a specific region
#' shorts_us <- search_shorts("music", region_code = "US", order = "viewCount")
#' }
search_shorts <- function(query,
                         max_results = 25,
                         order = "relevance", 
                         region_code = NULL,
                         published_after = NULL,
                         published_before = NULL,
                         simplify = TRUE,
                         auth = "key",
                         ...) {
  
  # Modern validation using checkmate
  assert_character(query, len = 1, min.chars = 1, .var.name = "query")
  assert_integerish(max_results, len = 1, lower = 1, upper = 50, .var.name = "max_results")
  assert_choice(order, c("date", "rating", "relevance", "title", "viewCount"), .var.name = "order")
  assert_flag(simplify, .var.name = "simplify")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  
  # Build search query
  search_query <- list(
    part = "snippet",
    q = query,
    type = "video",
    maxResults = max_results,
    order = order,
    # Filter for shorts by duration (less than 60 seconds)
    videoDuration = "short"
  )
  
  if (!is.null(region_code)) {
    assert_character(region_code, len = 1, pattern = "^[A-Z]{2}$", .var.name = "region_code")
    search_query$regionCode <- region_code
  }
  
  if (!is.null(published_after)) {
    assert_character(published_after, len = 1, .var.name = "published_after")
    search_query$publishedAfter <- published_after
  }
  
  if (!is.null(published_before)) {
    assert_character(published_before, len = 1, .var.name = "published_before")
    search_query$publishedBefore <- published_before
  }
  
  # Make API call
  result <- call_api_with_retry(
    tuber_GET,
    path = "search",
    query = search_query,
    auth = auth,
    ...
  )
  
  if (length(result$items) == 0) {
    suggest_solution("empty_results", "- Try broader search terms\n- Check region and date filters")
    return(if (simplify) data.frame() else list())
  }
  
  if (simplify) {
    result <- tryCatch({
      # Convert to data frame with shorts-specific fields
      shorts_df <- purrr::map_df(result$items, function(item) {
        data.frame(
          video_id = item$id$videoId %||% NA_character_,
          title = item$snippet$title %||% NA_character_,
          description = item$snippet$description %||% NA_character_,
          channel_id = item$snippet$channelId %||% NA_character_,
          channel_title = item$snippet$channelTitle %||% NA_character_,
          published_at = item$snippet$publishedAt %||% NA_character_,
          thumbnail_url = item$snippet$thumbnails$medium$url %||% 
                         item$snippet$thumbnails$default$url %||% NA_character_,
          is_short = TRUE,  # Mark as shorts
          stringsAsFactors = FALSE
        )
      })
      
      # Add metadata
      attr(shorts_df, "total_results") <- result$pageInfo$totalResults %||% nrow(shorts_df)
      attr(shorts_df, "results_per_page") <- result$pageInfo$resultsPerPage %||% nrow(shorts_df)
      
      shorts_df
    }, error = function(e) {
      warning("Failed to convert to data frame: ", e$message, ". Returning list format.", call. = FALSE)
      result
    })
  }
  
  return(result)
}

#' Get video premiere information
#'
#' Checks if videos are premieres and gets premiere scheduling information.
#'
#' @param video_id Video ID or vector of video IDs
#' @param simplify Whether to return simplified data frame
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)  
#' @param ... Additional arguments passed to tuber_GET
#'
#' @return List or data frame with premiere information
#' @export
#'
#' @examples
#' \dontrun{
#' # Check if video is a premiere
#' premiere_info <- get_premiere_info("dQw4w9WgXcQ")
#' 
#' # Check multiple videos for premiere status
#' premieres <- get_premiere_info(c("video1", "video2", "video3"))
#' }
get_premiere_info <- function(video_id,
                             simplify = TRUE,
                             auth = "key",
                             ...) {
  
  # Modern validation using checkmate
  assert_character(video_id, min.len = 1, .var.name = "video_id")
  assert_flag(simplify, .var.name = "simplify")
  assert_choice(auth, c("token", "key"), .var.name = "auth")
  
  if (length(video_id) > 1) {
    video_id <- paste0(video_id, collapse = ",")
  }
  
  # Get video details with liveStreamingDetails to check for premieres
  query <- list(
    part = "snippet,liveStreamingDetails,status",
    id = video_id
  )
  
  result <- call_api_with_retry(
    tuber_GET,
    path = "videos",
    query = query,
    auth = auth,
    ...
  )
  
  if (length(result$items) == 0) {
    suggest_solution("empty_results", "- Check if video IDs are correct\n- Videos may be private or deleted")
    return(if (simplify) data.frame() else list())
  }
  
  # Process premiere information
  premiere_data <- lapply(result$items, function(item) {
    live_details <- item$liveStreamingDetails
    
    premiere_info <- list(
      video_id = item$id,
      title = item$snippet$title %||% NA_character_,
      is_premiere = !is.null(live_details$scheduledStartTime),
      is_live = !is.null(live_details$actualStartTime) && 
                is.null(live_details$actualEndTime),
      scheduled_start_time = live_details$scheduledStartTime %||% NA_character_,
      actual_start_time = live_details$actualStartTime %||% NA_character_,
      actual_end_time = live_details$actualEndTime %||% NA_character_,
      concurrent_viewers = live_details$concurrentViewers %||% NA_character_,
      privacy_status = item$status$privacyStatus %||% NA_character_
    )
    
    return(premiere_info)
  })
  
  if (simplify) {
    result <- tryCatch({
      dplyr::bind_rows(premiere_data)
    }, error = function(e) {
      warning("Failed to convert to data frame: ", e$message, ". Returning list format.", call. = FALSE)
      premiere_data
    })
  } else {
    result <- premiere_data
  }
  
  return(result)
}