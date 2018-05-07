#' Get statistics of a Video
#'
#' @param video_id Character. Id of the video. Required.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#' 
#' @return list with 6 elements: \code{id, viewCount, likeCount, dislikeCount, favoriteCount, commentCount}
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
#' }

get_stats <- function (video_id = NULL, ...) {

  if (!is.character(video_id)) stop("Must specify a video ID.")

  querylist <- list(part = "statistics", id = video_id)

  raw_res <- tuber_GET("videos", querylist, ...)

  if (length(raw_res$items) == 0) {
    warning("No statistics for this video are available.
             Likely cause: Incorrect ID. \n")
    return(list())
  }

  res      <- raw_res$items[[1]]
  stat_res <- res$statistics

  c(id = res$id, stat_res)
}
