#' List (Most Popular) Videos
#'
#' @param part Required. Comma separated string including one or more of the
#' following: \code{contentDetails,
#' fileDetails, id, liveStreamingDetails, localizations, player,
#' processingDetails, recordingDetails,
#' snippet, statistics, status, suggestions, topicDetails}. Default:
#' \code{contentDetails}.
#' @param max_results Maximum number of items that should be returned. Integer.
#' Optional. Default is 50. Values over 50 will trigger multiple requests and
#' may use additional API quota.
#' @param page_token specific page in the result set that should be returned,
#' optional
#' @param region_code Character. Required. Has to be a ISO 3166-1 alpha-2 code
#'  (see \url{https://www.iso.org/obp/ui/#search}).
#' @param hl  Language used for text values. Optional. Default is \code{en-US}.
#'  For other allowed language codes, see \code{\link{list_langs}}.
#' @param video_category_id the video category for which the chart should be
#' retrieved. See also \code{\link{list_videocats}}.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return data.frame with 5 columns: \code{channelId, title, assignable, etag, id}
#'
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/search/list}
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' list_videos()
#' }

list_videos <- function(part = "contentDetails", max_results = 50,
                        page_token = NULL, hl = NULL, region_code = NULL,
                        video_category_id = NULL, ...) {

  # Modern validation using checkmate
  assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")
  assert_character(part, len = 1, min.chars = 1, .var.name = "part")

  if (!is.null(page_token)) {
    assert_character(page_token, len = 1, min.chars = 1, .var.name = "page_token")
  }
  if (!is.null(hl)) {
    assert_character(hl, len = 1, min.chars = 1, .var.name = "hl")
  }
  if (!is.null(region_code)) {
    assert_character(region_code, len = 1, min.chars = 1, .var.name = "region_code")
  }
  if (!is.null(video_category_id)) {
    assert_character(video_category_id, len = 1, min.chars = 1, .var.name = "video_category_id")
  }

  querylist <- list(chart = "mostPopular", part = part,
                    maxResults = min(max_results, 50), pageToken = page_token, hl = hl,
                    regionCode = region_code,
                    videoCategoryId = video_category_id)

  res <- tuber_GET("videos", querylist, ...)
  items <- res$items
  next_token <- res$nextPageToken

  while (length(items) < max_results && !is.null(next_token)) {
    querylist$pageToken <- next_token
    querylist$maxResults <- min(50, max_results - length(items))
    a_res <- tuber_GET("videos", querylist, ...)
    items <- c(items, a_res$items)
    next_token <- a_res$nextPageToken
  }

  res$items <- items
  res
}
