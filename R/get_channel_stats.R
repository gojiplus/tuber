#' Get statistics of a Channel
#'
#' @param channel_id Character. Id of the channel
#' @param mine Boolean. TRUE if you want to fetch stats of your own channel. Default is NULL.
#' @param batch_size Integer. When multiple channel IDs are provided, controls batch size for efficient processing. Default is 50.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return nested named list with top element names:
#' \code{kind, etag, id, snippet (list of details of the channel
#' including title), statistics (list of 5)}
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
#' get_channel_stats(channel_id="UCMtFAi84ehTSYSE9XoHefig")
#' get_channel_stats(channel_id="UCMtFAi84ehTSYSE9Xo") # Incorrect channel ID
#' }

get_channel_stats <- function(channel_id = NULL, mine = NULL, batch_size = 50, ...) {

  # Modern validation using checkmate
  if (!is.null(mine)) {
    assert_logical(mine, len = 1, .var.name = "mine")
  }

  assert_integerish(batch_size, len = 1, lower = 1, .var.name = "batch_size")

  if (identical(tolower(mine), "false")) {
    mine <- NULL
  }

  if (!identical(tolower(mine), "true")) {
    assert_character(channel_id, any.missing = FALSE, min.len = 1, .var.name = "channel_id")

    # AUTOMATIC BATCHING: If multiple channel IDs provided, use batch operations
    if (length(channel_id) > 1) {
      message("Multiple channel IDs detected. Using automatic batch processing for efficiency.")
      return(get_channels_batch(
        channel_ids = channel_id,
        part = "statistics,snippet",
        batch_size = batch_size,
        show_progress = length(channel_id) > 10,
        ...
      ))
    }
  }

  querylist <- list(part = "statistics,snippet", id = channel_id, mine = mine)

  raw_res <- call_api_with_retry(tuber_GET, path = "channels", query = querylist, ...)

  if (length(raw_res$items) == 0) {
    warn("No channel stats available. Likely cause: Incorrect channel_id",
         channel_id = channel_id,
         class = "tuber_channel_stats_empty")
    return(list())
  }

  res <- raw_res$items[[1]]
  res_stats <- res$statistics
  res_snippet <- res$snippet

  cat("Channel Title:", res_snippet$title, "\n")
  cat("No. of Views:", res_stats$viewCount, "\n")
  cat("No. of Subscribers:", res_stats$subscriberCount, "\n")
  cat("No. of Videos:", res_stats$videoCount, "\n")

  res
}

#' @rdname get_channel_stats
#' @export
list_my_channel <- function(...) {

  querylist <- list(part = "snippet,contentDetails,statistics", mine = "true")

  raw_res <- call_api_with_retry(tuber_GET, path = "channels", query = querylist, ...)

  if (length(raw_res$items) == 0) {
    warn("No channel stats available. Likely cause: No videos",
         class = "tuber_my_channel_empty")
    return(list())
  }

  res <- raw_res$items[[1]]
  res_stats <- res$statistics
  res_snippet <- res$snippet

  cat("Channel Title:", res_snippet$title, "\n")
  cat("No. of Views:", res_stats$viewCount, "\n")
  cat("No. of Subscribers:", res_stats$subscriberCount, "\n")
  cat("No. of Videos:", res_stats$videoCount, "\n")

  res
}

