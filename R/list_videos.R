#' List (Most Popular) Videos
#'
#' @param part Required. Comma separated string including one or more of the
#' following: \code{contentDetails,
#' fileDetails, id, liveStreamingDetails, localizations, player,
#' processingDetails, recordingDetails,
#' snippet, statistics, status, suggestions, topicDetails}. Default:
#' \code{contentDetails}.
#' @param max_results Maximum number of items that should be returned. Integer.
#' Optional. Can be between 0 and 50. Default is 50.
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

  if (is.numeric(max) & max_results < 0 | max_results > 50) {
    stop("max_results only takes a value between 0 and 50.")
  }

  querylist <- list(chart = "mostPopular", part = part,
                    maxResults = max_results, pageToken = page_token, hl = hl,
                    regionCode = region_code,
                    videoCategoryId = video_category_id)

  res <- tuber_GET("videos", querylist, ...)

  res
}
