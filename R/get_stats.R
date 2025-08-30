#' Get statistics of a Video
#'
#' Gets view count, like count, comment count and other statistics for a YouTube video.
#' For unlisted videos, you must use OAuth authentication with the channel owner's credentials.
#'
#' @param video_id Character. Id of the video. Required.
#' @param include_content_details Boolean. Include contentDetails (duration, definition, etc.) in response. Default: FALSE.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return list with 6 elements: \code{id, viewCount, likeCount,
#' dislikeCount, favoriteCount, commentCount}. When \code{include_content_details = TRUE}, 
#' also includes \code{duration, definition, dimension, licensedContent, projection}.
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
#' get_stats(video_id="N708P-A45D0")
#' 
#' # Include video duration and other content details:
#' get_stats(video_id="N708P-A45D0", include_content_details = TRUE)
#' 
#' # For unlisted videos, must authenticate as channel owner:
#' # yt_oauth("your_client_id", "your_client_secret")
#' # get_stats(video_id="your_unlisted_video_id")
#' }

get_stats <- function(video_id = NULL, include_content_details = FALSE, ...) {

  if (!is.character(video_id)) stop("Must specify a video ID.")

  # Include contentDetails if requested for duration, definition, etc.
  part <- if (include_content_details) "statistics,contentDetails" else "statistics"
  querylist <- list(part = part, id = video_id)

  raw_res <- tuber_GET("videos", querylist, ...)

  if (length(raw_res$items) == 0) {
    warning("No statistics for this video are available.
             Likely cause: Incorrect ID. \n")
    return(list())
  }

  res      <- raw_res$items[[1]]
  stat_res <- res$statistics
  
  # Include contentDetails if requested
  if (include_content_details && !is.null(res$contentDetails)) {
    content_res <- res$contentDetails
    return(c(id = res$id, stat_res, content_res))
  }

  c(id = res$id, stat_res)
}
