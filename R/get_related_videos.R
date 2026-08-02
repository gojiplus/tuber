#' Get Related Videos
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Takes a video id and returns related videos.
#'
#' **Note:** YouTube deprecated the `relatedToVideoId` parameter in August 2023.
#' This function will return an error as the API endpoint no longer works.
#' Consider using \code{\link{yt_search}} with relevant keywords instead.
#'
#' @param video_id Character. Required. No default.
#' @param max_results Maximum number of items that should be returned.
#' Integer. Optional. Default is 50. Values over 50 trigger multiple requests and
#' may increase API quota usage.
#' @param safe_search Character. Optional. Takes one of three values:
#' \code{'moderate'}, \code{'none'} (default) or \code{'strict'}
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return \code{data.frame} with 16 columns: \code{video_id, rel_video_id,
#' publishedAt, channelId, title, description,
#' thumbnails.default.url, thumbnails.default.width, thumbnails.default.height,
#' thumbnails.medium.url,
#' thumbnails.medium.width, thumbnails.medium.height, thumbnails.high.url,
#' thumbnails.high.width,
#' thumbnails.high.height, channelTitle, liveBroadcastContent}
#'
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/search/list}
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#' # NOTE: This function no longer works due to YouTube API deprecation
#'
#' get_related_videos(video_id = "yJXTXN4xrI8")
#' }

get_related_videos <- function(video_id = NULL, max_results = 50,
                                safe_search = "none", ...) {
  .Defunct(
    msg = "get_related_videos() is defunct. YouTube deprecated the relatedToVideoId parameter in August 2023. Use yt_search() with relevant keywords instead."
  )
}
