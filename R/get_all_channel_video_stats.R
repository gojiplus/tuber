#' Get statistics on all the videos in a Channel
#'
#' Efficiently collects all video IDs from a channel's uploads playlist, then
#' fetches statistics and details using batch processing for optimal API quota usage.
#'
#' @param channel_id Character. Id of the channel
#' @param mine Boolean. TRUE if you want to fetch stats of your own channel. Default is FALSE.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return A \code{data.frame} containing video metadata along with view, like,
#'   dislike and comment counts.
#'
#' If the \code{channel_id} is mistyped or there is no information, an empty list is returned
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
#' get_all_channel_video_stats(channel_id="UCxOhDvtaoXDAB336AolWs3A")
#' get_all_channel_video_stats(channel_id="UCMtFAi84ehTSYSE9Xo") # Incorrect channel ID
#' }

get_all_channel_video_stats <- function(channel_id = NULL, mine = FALSE, ...) {
  # Modern validation using checkmate
  if (!identical(tolower(mine), "true")) {
    assert_character(channel_id, len = 1, min.chars = 1, .var.name = "channel_id")
  }
  assert_logical(mine, len = 1, .var.name = "mine")

  # Get channel resources with proper error handling
  channel_resources <- tryCatch({
    list_channel_resources(filter = list(channel_id = channel_id), part = "contentDetails", ...)
  }, error = function(e) {
    abort("Failed to get channel information",
          channel_id = channel_id,
          original_error = e$message,
          class = "tuber_channel_info_error")
  })

  # Safely extract playlist ID
  if (is.null(channel_resources$items) || length(channel_resources$items) == 0) {
    abort("No channel data found",
          channel_id = channel_id,
          help = "Channel may not exist or may be private",
          class = "tuber_channel_not_found")
  }

  content_details <- channel_resources$items[[1]]$contentDetails
  if (is.null(content_details) || is.null(content_details$relatedPlaylists)) {
    abort("No content details available for channel",
          channel_id = channel_id,
          help = "Channel may not have uploaded videos",
          class = "tuber_no_content_details")
  }

  playlist_id <- content_details$relatedPlaylists$uploads
  if (is.null(playlist_id)) {
    abort("No uploads playlist found for channel",
          channel_id = channel_id,
          help = "Channel may not have any videos or may be private",
          class = "tuber_no_uploads_playlist")
  }

  # Collect all video IDs from the uploads playlist
  message("Collecting video IDs from uploads playlist...")
  vid_ids <- character()
  page_token <- NULL
  page_count <- 0
  
  repeat {
    page_count <- page_count + 1
    if (page_count > 1) {
      message("Fetching playlist page ", page_count, "...")
    }
    
    playlist_items <- get_playlist_items(
      filter = list(playlist_id = playlist_id),
      max_results = 50,
      page_token = page_token,
      simplify = FALSE,
      ...
    )
    
    # Extract video IDs from this page
    page_video_ids <- vapply(
      playlist_items$items,
      function(x) x$contentDetails$videoId,
      character(1)
    )
    vid_ids <- c(vid_ids, page_video_ids)
    
    page_token <- playlist_items$nextPageToken
    if (is.null(page_token)) {
      break
    }
  }
  
  if (length(vid_ids) == 0) {
    warning("No videos found in channel uploads playlist")
    return(data.frame())
  }
  
  message("Found ", length(vid_ids), " videos. Fetching video details and statistics...")

  # Use the new unified get_video_details function for efficient batch processing
  video_data <- get_video_details(
    video_ids = vid_ids,
    part = c("snippet", "statistics"),
    simplify = TRUE,
    show_progress = TRUE,
    ...
  )
  
  if (nrow(video_data) == 0) {
    warning("No video data could be retrieved")
    return(data.frame())
  }

  # Map complex column names from get_video_details to expected simple names
  result_df <- video_data
  
  # Map column names from get_video_details output to expected names
  # Note: get_video_details returns flattened column names directly
  column_mapping <- c(
    "title" = "title",
    "publication_date" = "publishedAt", 
    "description" = "description",
    "channel_id" = "channelId",
    "channel_title" = "channelTitle",
    "view_count" = "viewCount",
    "like_count" = "likeCount", 
    "comment_count" = "commentCount"
  )
  
  # Rename columns that exist
  for (new_name in names(column_mapping)) {
    old_name <- column_mapping[[new_name]]
    if (old_name %in% names(result_df)) {
      names(result_df)[names(result_df) == old_name] <- new_name
    }
  }
  
  # Add video URL
  result_df$url <- paste0("https://www.youtube.com/watch?v=", result_df$id)
  
  # Ensure consistent column order
  final_columns <- c("id", "title", "publication_date", "description", 
                     "channel_id", "channel_title", "view_count", "like_count", 
                     "comment_count", "url")
  
  # Add missing columns as NA if they don't exist
  for (col in final_columns) {
    if (!col %in% names(result_df)) {
      result_df[[col]] <- NA
    }
  }
  
  # Select final columns in the right order
  result_df <- result_df[, final_columns, drop = FALSE]
  
  message("Successfully retrieved data for ", nrow(result_df), " videos")
  
  return(result_df)
}