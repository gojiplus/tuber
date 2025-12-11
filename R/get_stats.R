#' Get statistics of a Video or Videos
#'
#' Gets view count, like count, comment count and other statistics for YouTube video(s).
#' For unlisted videos, you must use OAuth authentication with the channel owner's credentials.
#' Automatically uses batch processing when multiple video IDs are provided for efficiency.
#'
#' @param video_ids Character vector. One or more video IDs. Required.
#' @param include_content_details Boolean. Include contentDetails (duration, definition, etc.) in response. Default: FALSE.
#' @param batch_size Integer. Number of videos per API call when batching (max 50). Default: 50.
#' @param simplify Boolean. Return simplified data frame for multiple videos. Default: TRUE.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return For single video: list with elements \code{id, viewCount, likeCount,
#' dislikeCount, favoriteCount, commentCount}. When \code{include_content_details = TRUE},
#' also includes \code{duration, definition, dimension, licensedContent, projection}.
#' For multiple videos: data frame with one row per video (if simplify=TRUE) or list of results.
#'
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/videos/list#parameters}
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' # Single video
#' get_stats(video_ids="N708P-A45D0")
#'
#' # Multiple videos (automatic batching)
#' video_ids <- c("N708P-A45D0", "M7FIvfx5J10", "kJQP7kiw5Fk")
#' stats_df <- get_stats(video_ids)
#'
#' # Include video duration and other content details:
#' get_stats(video_ids="N708P-A45D0", include_content_details = TRUE)
#'
#' # For unlisted videos, must authenticate as channel owner:
#' # yt_oauth("your_client_id", "your_client_secret")
#' # get_stats(video_ids="your_unlisted_video_id")
#' }

get_stats <- function(video_ids = NULL, include_content_details = FALSE, batch_size = 50, simplify = TRUE, ...) {

  # Modern validation
  assert_character(video_ids, any.missing = FALSE, min.len = 1, .var.name = "video_ids")
  assert_logical(include_content_details, len = 1, .var.name = "include_content_details")
  assert_integerish(batch_size, len = 1, lower = 1, upper = 50, .var.name = "batch_size")
  assert_logical(simplify, len = 1, .var.name = "simplify")

  # Determine part parameter
  part <- if (include_content_details) "statistics,contentDetails" else "statistics"

  # Use get_video_details with appropriate parameters
  result <- get_video_details(
    video_ids = video_ids,
    part = part,
    simplify = simplify,
    batch_size = batch_size,
    ...
  )

  # For single video, extract just the stats/content as before
  if (length(video_ids) == 1 && !simplify && !is.null(result$items)) {
    res <- result$items[[1]]
    stat_res <- res$statistics
    
    # Include contentDetails if requested
    if (include_content_details && !is.null(res$contentDetails)) {
      content_res <- res$contentDetails
      extracted <- c(id = res$id, stat_res, content_res)
    } else {
      extracted <- c(id = res$id, stat_res)
    }
    
    # Add standardized attributes
    result <- add_tuber_attributes(
      extracted,
      api_calls_made = 1,
      function_name = "get_stats",
      parameters = list(video_ids = video_ids, include_content_details = include_content_details),
      results_found = 1,
      content_details_included = include_content_details
    )
  }

  result
}