#' Extended YouTube API Endpoints
#'
#' Functions for YouTube API endpoints that were not previously covered in tuber,
#' including live streaming, thumbnails, channel sections, and modern video features.
#'
#' @name extended-endpoints
NULL

#' List live broadcasts
#'
#' Retrieves YouTube `liveBroadcast` resources owned by the authenticated user.
#'
#' @param broadcast_ids Broadcast IDs. Supply exactly one of `broadcast_ids`,
#' `status`, or `mine = TRUE`.
#' @param part Parts to retrieve
#' @param mine Logical. List the authenticated user's own broadcasts.
#' @param status Filter by status: `"active"`, `"all"`, `"upcoming"`, or
#' `"completed"`.
#' @param broadcast_type Optional broadcast type: `"all"`, `"event"`, or
#' `"persistent"`.
#' @param max_results Maximum number of broadcasts to return.
#' @param page_token Page token at which to start.
#' @param simplify Whether to return a simplified data frame
#' @param ... Additional arguments passed to tuber_GET
#'
#' @return List or data frame with live stream information
#' @export
#'
#' @examples
#' \dontrun{
#' broadcasts <- list_live_broadcasts(status = "active")
#'
#' broadcast <- list_live_broadcasts(
#'   broadcast_ids = "abc123",
#'   part = c("snippet", "status")
#' )
#' }
list_live_broadcasts <- function(broadcast_ids = NULL,
                                 part = "snippet,status",
                                 status = NULL,
                                 mine = FALSE,
                                 broadcast_type = NULL,
                                 max_results = 50,
                                 page_token = NULL,
                                 simplify = TRUE,
                                 ...) {
  n_filters <- sum(!is.null(broadcast_ids), !is.null(status), isTRUE(mine))
  if (n_filters == 0) {
    abort(paste0(
      "Provide exactly one filter: `broadcast_ids`, `status`, or `mine = TRUE`."
    ), class = "tuber_missing_required_parameter")
  }
  if (n_filters > 1) {
    abort(paste0(
      "liveBroadcasts.list accepts exactly one of `broadcast_ids`, `status` or ",
      "`mine`; ", n_filters, " were supplied."
    ), class = "tuber_conflicting_parameters")
  }

  if (!is.null(broadcast_ids)) {
    assert_character(broadcast_ids, min.len = 1, min.chars = 1, .var.name = "broadcast_ids")
  }

  assert_character(part, min.len = 1, .var.name = "part")
  assert_flag(simplify, .var.name = "simplify")
  assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")

  if (!is.null(status)) {
    assert_choice(status, c("active", "all", "upcoming", "completed"), .var.name = "status")
  }
  if (!is.null(broadcast_type)) {
    assert_choice(broadcast_type, c("all", "event", "persistent"), .var.name = "broadcast_type")
  }
  if (!is.null(page_token)) {
    assert_string(page_token, min.chars = 1, .var.name = "page_token")
  }

  if (length(part) > 1) {
    part <- paste0(part, collapse = ",")
  }

  # Build query
  query <- list(
    part = part,
    maxResults = min(max_results, 50),
    pageToken = page_token,
    broadcastType = broadcast_type
  )

  if (!is.null(broadcast_ids)) {
    query$id <- paste(broadcast_ids, collapse = ",")
  }

  if (!is.null(status)) {
    # liveBroadcasts.list filters on broadcastStatus; eventType belongs to
    # search.list and is ignored here.
    query$broadcastStatus <- status
  }

  if (isTRUE(mine)) {
    query$mine <- "true"
  }

  fetch_page <- function(token = NULL) {
    page_query <- query
    page_query$pageToken <- token
    call_api_with_retry(
      tuber_GET,
      path = "liveBroadcasts",
      query = page_query,
      auth = "token",
      ...
    )
  }

  result <- fetch_page(page_token)

  pages <- paginate_api_request(
    initial_response = result,
    fetch_next_page_fn = fetch_page,
    max_results = max_results
  )
  result$items <- pages$items
  result$nextPageToken <- pages$final_page_token

  if (!simplify) {
    return(add_tuber_attributes(
      result,
      api_calls_made = pages$page_count,
      function_name = "list_live_broadcasts",
      results_found = length(pages$items),
      response_format = "list"
    ))
  }

  simplified <- items_to_frame(pages$items, function(item) {
    data.frame(
      broadcast_id = item$id %||% NA_character_,
      title = item$snippet$title %||% NA_character_,
      description = item$snippet$description %||% NA_character_,
      published_at = item$snippet$publishedAt %||% NA_character_,
      scheduled_start_time = item$snippet$scheduledStartTime %||% NA_character_,
      scheduled_end_time = item$snippet$scheduledEndTime %||% NA_character_,
      actual_start_time = item$snippet$actualStartTime %||% NA_character_,
      actual_end_time = item$snippet$actualEndTime %||% NA_character_,
      life_cycle_status = item$status$lifeCycleStatus %||% NA_character_,
      privacy_status = item$status$privacyStatus %||% NA_character_,
      recording_status = item$status$recordingStatus %||% NA_character_,
      live_chat_id = item$snippet$liveChatId %||% NA_character_,
      stringsAsFactors = FALSE
    )
  })
  add_tuber_attributes(
    simplified,
    api_calls_made = pages$page_count,
    function_name = "list_live_broadcasts",
    results_found = nrow(simplified),
    response_format = "data.frame"
  )
}

#' Get video thumbnails information
#'
#' Retrieves thumbnail URLs and metadata for videos.
#'
#' @param video_ids Video ID or vector of video IDs.
#' @param size Thumbnail size: "default", "medium", "high", "standard", "maxres"
#' @param simplify Whether to return a simplified data frame
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)
#' @param ... Additional arguments passed to tuber_GET
#'
#' @return A tidy data frame with one row per video and thumbnail size when
#' `simplify = TRUE`; otherwise the raw videos-list response.
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
get_video_thumbnails <- function(video_ids,
                                 size = NULL,
                                 simplify = TRUE,
                                 auth = "key",
                                 ...) {
  # Modern validation using checkmate
  assert_character(video_ids, min.len = 1, .var.name = "video_ids")
  assert_flag(simplify, .var.name = "simplify")
  assert_choice(auth, c("token", "key"), .var.name = "auth")

  if (!is.null(size)) {
    assert_choice(size, c("default", "medium", "high", "standard", "maxres"), .var.name = "size")
  }

  result <- get_video_details(
    video_ids = video_ids,
    part = "snippet",
    simplify = FALSE,
    auth = auth,
    ...
  )
  items <- result$items %||% list()

  if (!simplify) return(result)

  empty_thumbnails <- data.frame(
    video_id = character(),
    title = character(),
    size = character(),
    url = character(),
    width = integer(),
    height = integer(),
    stringsAsFactors = FALSE
  )
  thumbnail_data <- lapply(items, function(item) {
    thumbs <- item$snippet$thumbnails
    sizes <- if (is.null(size)) names(thumbs) else intersect(size, names(thumbs))
    bind_rows(lapply(sizes, function(thumbnail_size) {
      data.frame(
        video_id = item$id,
        title = item$snippet$title %||% NA_character_,
        size = thumbnail_size,
        url = thumbs[[thumbnail_size]]$url %||% NA_character_,
        width = thumbs[[thumbnail_size]]$width %||% NA_integer_,
        height = thumbs[[thumbnail_size]]$height %||% NA_integer_,
        stringsAsFactors = FALSE
      )
    }))
  })

  thumbnail_data <- bind_rows(thumbnail_data)
  if (nrow(thumbnail_data) == 0) thumbnail_data <- empty_thumbnails
  add_tuber_attributes(
    thumbnail_data,
    api_calls_made = attr(result, "tuber_api_calls") %||% 0,
    function_name = "get_video_thumbnails",
    results_found = nrow(thumbnail_data),
    response_format = "data.frame"
  )
}

#' Search for videos shorter than four minutes
#'
#' Uses YouTube's `videoDuration = "short"` filter. This filter includes every
#' video shorter than four minutes and does not identify the YouTube Shorts
#' product.
#'
#' @param term Search term.
#' @param max_results Maximum total number of results.
#' @param order Sort order: "date", "rating", "relevance", "title", "viewCount"
#' @param region_code Region code for search
#' @param published_after RFC 3339 formatted date-time (e.g., "2023-01-01T00:00:00Z")
#' @param published_before RFC 3339 formatted date-time
#' @param simplify Whether to return simplified data frame
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)
#' @param ... Additional arguments passed to [yt_search()].
#'
#' @return List or data frame with search results for videos under four minutes
#' @export
#'
#' @examples
#' \dontrun{
#' # Search for recent shorts about cats
#' short_videos <- search_short_videos("cats", max_results = 25, order = "date")
#'
#' # Search for popular short-duration videos in a specific region
#' short_videos_us <- search_short_videos(
#'   "music",
#'   region_code = "US",
#'   order = "viewCount"
#' )
#' }
search_short_videos <- function(term,
                                max_results = 25,
                                order = "relevance",
                                region_code = NULL,
                                published_after = NULL,
                                published_before = NULL,
                                simplify = TRUE,
                                auth = "key",
                                ...) {
  result <- yt_search(
    term = term,
    max_results = max_results,
    type = "video",
    order = order,
    region_code = region_code,
    published_after = published_after,
    published_before = published_before,
    video_duration = "short",
    simplify = simplify,
    get_all = TRUE,
    auth = auth,
    ...
  )

  if (simplify) {
    result$duration_filter <- rep("under_four_minutes", nrow(result))
  }
  result
}

#' Get video live-broadcast timing
#'
#' Retrieves scheduling and actual start/end information exposed in a video's
#' `liveStreamingDetails`. The YouTube Data API does not expose a reliable flag
#' that distinguishes premieres from other scheduled broadcasts.
#'
#' @param video_ids Video ID or vector of video IDs.
#' @param simplify Whether to return simplified data frame
#' @param auth Authentication method: "token" (OAuth2) or "key" (API key)
#' @param ... Additional arguments passed to tuber_GET
#'
#' @return A data frame when `simplify = TRUE`; otherwise the raw videos-list
#' response.
#' @export
#'
#' @examples
#' \dontrun{
#' timing <- get_video_broadcast_timing("dQw4w9WgXcQ")
#'
#' timings <- get_video_broadcast_timing(c("video1", "video2", "video3"))
#' }
get_video_broadcast_timing <- function(video_ids,
                                       simplify = TRUE,
                                       auth = "key",
                                       ...) {
  # Modern validation using checkmate
  assert_character(video_ids, min.len = 1, .var.name = "video_ids")
  assert_flag(simplify, .var.name = "simplify")
  assert_choice(auth, c("token", "key"), .var.name = "auth")

  result <- get_video_details(
    video_ids = video_ids,
    part = c("snippet", "liveStreamingDetails", "status"),
    simplify = FALSE,
    auth = auth,
    ...
  )
  items <- result$items %||% list()

  if (!simplify) return(result)

  empty_timing <- data.frame(
    video_id = character(),
    title = character(),
    has_scheduled_start = logical(),
    is_live = logical(),
    scheduled_start_time = character(),
    actual_start_time = character(),
    actual_end_time = character(),
    concurrent_viewers = character(),
    privacy_status = character(),
    stringsAsFactors = FALSE
  )
  timing_data <- lapply(items, function(item) {
    live_details <- item$liveStreamingDetails

    timing_info <- list(
      video_id = item$id,
      title = item$snippet$title %||% NA_character_,
      has_scheduled_start = !is.null(live_details$scheduledStartTime),
      is_live = !is.null(live_details$actualStartTime) &&
        is.null(live_details$actualEndTime),
      scheduled_start_time = live_details$scheduledStartTime %||% NA_character_,
      actual_start_time = live_details$actualStartTime %||% NA_character_,
      actual_end_time = live_details$actualEndTime %||% NA_character_,
      concurrent_viewers = live_details$concurrentViewers %||% NA_character_,
      privacy_status = item$status$privacyStatus %||% NA_character_
    )

    timing_info
  })

  timing_data <- bind_rows(timing_data)
  if (nrow(timing_data) == 0) timing_data <- empty_timing
  add_tuber_attributes(
    timing_data,
    api_calls_made = attr(result, "tuber_api_calls") %||% 0,
    function_name = "get_video_broadcast_timing",
    results_found = nrow(timing_data),
    response_format = "data.frame"
  )
}
