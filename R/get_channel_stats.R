#' Get statistics of a Channel
#'
#' @param channel_id Character. Id of the channel
#' @param mine Boolean. TRUE if you want to fetch stats of your own channel. Default is FALSE.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return nested named list with top element names:
#' \code{kind, etag, id, snippet (list of details of the channel including title), statistics (list of 5)}
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

get_channel_stats <- function(channel_id = NULL, mine = FALSE, ...) {

  if (!is.character(channel_id) & !identical(tolower(mine),  "true")) {
          stop("Must specify a channel ID or specify mine = 'true'.")
    }

  querylist <- list(part = "statistics,snippet", id = channel_id, mine = mine)

  raw_res  <- tuber_GET("channels", querylist, ...)

  if (length(raw_res$items) == 0) {
    warning("No channel stats available. Likely cause: Incorrect channel_id.\n")
    return(list())
  }

  res  <- raw_res$items[[1]]
  res1 <- res$statistics
  res2 <- res$snippet

  cat("Channel Title:", res2$title, "\n")
  cat("No. of Views:", res1$viewCount, "\n")
  cat("No. of Subscribers:", res1$subscriberCount, "\n")
  cat("No. of Videos:", res1$videoCount, "\n")

  res
}
