#' Get statistics on all the videos in a Channel
#'
#' Efficiently collects all video IDs from a channel's uploads playlist, then
#' fetches statistics and details using batch processing for optimal API quota usage.
#'
#' @param channel_id Character. Id of the channel
#' @param mine Boolean. TRUE if you want to fetch stats of your own channel. Default is FALSE.
#' @param auth Authentication method, `"key"` or `"token"`. `mine = TRUE`
#' requires OAuth.
#'
#' @return A data frame with one row per video and the columns `video_id`,
#' `title`, `published_at`, `description`, `channel_id`, `channel_title`,
#' `view_count`, `like_count`, `comment_count` (numeric) and `url`. A channel
#' with no uploads returns the same columns and zero rows. An unknown
#' `channel_id` is an error.
#'
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/channels/list}
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' get_all_channel_video_stats(channel_id = "UCxOhDvtaoXDAB336AolWs3A")
#' }
get_all_channel_video_stats <- function(channel_id = NULL,
                                        mine = FALSE,
                                        auth = if (mine) "token" else "key") {
  # Modern validation using checkmate
  assert_flag(mine, .var.name = "mine")
  assert_choice(auth, c("key", "token"), .var.name = "auth")
  if (!mine) {
    assert_character(channel_id, len = 1, min.chars = 1, .var.name = "channel_id")
  }
  if (mine && auth != "token") {
    abort("`mine = TRUE` requires OAuth authentication.", class = "tuber_auth_required")
  }

  channel_resources <- get_channel_details(
    channel_ids = if (mine) NULL else channel_id,
    mine = mine,
    part = "contentDetails",
    simplify = FALSE,
    auth = auth
  )

  # Safely extract playlist ID
  if (is.null(channel_resources$items) || length(channel_resources$items) == 0) {
    abort(
      c("No channel data found.", i = "The channel may not exist or may be private."),
      channel_id = channel_id,
      class = "tuber_channel_not_found"
    )
  }

  content_details <- channel_resources$items[[1]]$contentDetails
  if (is.null(content_details) || is.null(content_details$relatedPlaylists)) {
    abort(
      c(
        "No content details are available for this channel.",
        i = "The channel may not have uploaded any videos."
      ),
      channel_id = channel_id,
      class = "tuber_no_content_details"
    )
  }

  playlist_id <- content_details$relatedPlaylists$uploads
  if (is.null(playlist_id)) {
    abort(
      c(
        "No uploads playlist was found for this channel.",
        i = "The channel may not have any videos or may be private."
      ),
      channel_id = channel_id,
      class = "tuber_no_uploads_playlist"
    )
  }

  empty_stats <- data.frame(
    video_id = character(),
    title = character(),
    published_at = character(),
    description = character(),
    channel_id = character(),
    channel_title = character(),
    view_count = numeric(),
    like_count = numeric(),
    comment_count = numeric(),
    url = character(),
    stringsAsFactors = FALSE
  )

  message("Collecting video IDs from uploads playlist...")
  # One call rather than a hand-written page loop: list_playlist_items() owns
  # the page arithmetic, so a short page cannot make this skip videos.
  playlist_items <- list_playlist_items(
    playlist_id = playlist_id,
    part = "contentDetails",
    max_results = .Machine$integer.max,
    simplify = FALSE,
    auth = auth
  )
  playlist_calls <- attr(playlist_items, "tuber_api_calls") %||% 1
  vid_ids <- vapply(
    playlist_items$items %||% list(),
    function(x) x$contentDetails$videoId %||% NA_character_,
    character(1)
  )
  vid_ids <- vid_ids[!is.na(vid_ids)]

  if (length(vid_ids) == 0) {
    warning("No videos found in channel uploads playlist")
    return(add_tuber_attributes(
      empty_stats,
      api_calls_made = playlist_calls,
      function_name = "get_all_channel_video_stats",
      parameters = list(channel_id = channel_id, mine = mine),
      results_found = 0,
      response_format = "data.frame"
    ))
  }

  message("Found ", length(vid_ids), " videos. Fetching video details and statistics...")

  video_data <- get_video_details(
    video_ids = vid_ids,
    part = c("snippet", "statistics"),
    simplify = TRUE,
    show_progress = TRUE,
    auth = auth
  )

  if (!is.data.frame(video_data) || nrow(video_data) == 0) {
    warning("No video data could be retrieved or conversion to data frame failed")
    return(add_tuber_attributes(
      empty_stats,
      api_calls_made = playlist_calls + ceiling(length(vid_ids) / 50),
      function_name = "get_all_channel_video_stats",
      parameters = list(channel_id = channel_id, mine = mine),
      results_found = 0,
      response_format = "data.frame"
    ))
  }

  column <- function(name, default) video_data[[name]] %||% rep(default, nrow(video_data))
  count <- function(name) as.numeric(column(name, NA_character_))
  result_df <- data.frame(
    video_id = video_data$id,
    title = column("snippet_title", NA_character_),
    published_at = column("snippet_publishedAt", NA_character_),
    description = column("snippet_description", NA_character_),
    channel_id = column("snippet_channelId", NA_character_),
    channel_title = column("snippet_channelTitle", NA_character_),
    view_count = count("statistics_viewCount"),
    like_count = count("statistics_likeCount"),
    comment_count = count("statistics_commentCount"),
    url = paste0("https://www.youtube.com/watch?v=", video_data$id),
    stringsAsFactors = FALSE
  )

  message("Successfully retrieved data for ", nrow(result_df), " videos")

  add_tuber_attributes(
    result_df,
    api_calls_made = playlist_calls + ceiling(length(vid_ids) / 50),
    function_name = "get_all_channel_video_stats",
    parameters = list(channel_id = channel_id, mine = mine),
    results_found = nrow(result_df),
    videos_in_channel = length(vid_ids),
    response_format = "data.frame"
  )
}
