#' Get Related Videos
#'
#' Takes a video id and returns related videos
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
#'
#' get_related_videos(video_id = "yJXTXN4xrI8")
#' }

get_related_videos <- function(video_id = NULL, max_results = 50,
                                safe_search = "none", ...) {

  # Modern validation using checkmate
  assert_character(video_id, len = 1, min.chars = 1, .var.name = "video_id")
  assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")
  assert_choice(safe_search, c("moderate", "none", "strict"), .var.name = "safe_search")

  querylist <- list(part = "snippet", relatedToVideoId = video_id,
             type = "video", maxResults = min(max_results, 50), safeSearch = safe_search)

  res <- tuber_GET("search", querylist, ...)
  items <- res$items
  next_token <- res$nextPageToken

  while (length(items) < max_results && !is.null(next_token)) {
    querylist$pageToken <- next_token
    querylist$maxResults <- min(50, max_results - length(items))
    a_res <- tuber_GET("search", querylist, ...)
    items <- c(items, a_res$items)
    next_token <- a_res$nextPageToken
  }

  res$items <- items

  resdf <- read.table(text = "",
               col.names = c("video_id", "rel_video_id", "publishedAt",
                              "channelId", "title",
                             "description", "thumbnails.default.url",
                             "thumbnails.default.width",
                             "thumbnails.default.height",
                             "thumbnails.medium.url", "thumbnails.medium.width",
                             "thumbnails.medium.height", "thumbnails.high.url",
                             "thumbnails.high.width", "thumbnails.high.height",
                             "channelTitle", "liveBroadcastContent"))

  if (length(res$items) != 0) {

    rel_video_id <- sapply(res$items, function(x) unlist(x$id$videoId))
    simple_res   <- lapply(res$items, function(x) unlist(x$snippet))
    resdf        <- cbind(video_id = video_id,
                          rel_video_id = rel_video_id,
                          ldply(simple_res, rbind))
    resdf        <- as.data.frame(resdf)
  } else {

    resdf[1, "video_id"] <- video_id
  }

  # Cat total results
  cat("Total Results", length(res$items), "\n")

  resdf
}
