#' Get Playlists
#'
#' @param filter string; Required.
#' named vector of length 1
#' potential names of the entry in the vector:
#' \code{channel_id}: ID of the channel
#' \code{playlist_id}: YouTube playlist ID.
#'
#' @param part Required. One of the following: \code{contentDetails, id,
#' localizations, player, snippet, status}. Default: \code{contentDetails}.
#' @param max_results Maximum number of items that should be returned.
#' Integer. Optional. Default is 50. Values over 50 trigger additional
#' requests and may increase API quota usage.
#' @param page_token specific page in the result set that should be returned,
#' optional
#' @param hl  Language used for text values. Optional. Default is \code{en-US}.
#' For other allowed language codes, see \code{\link{list_langs}}.
#' @param simplify Data Type: Boolean. Default is \code{TRUE}. If
#' \code{TRUE} and if part requested is \code{contentDetails},
#' the function returns a \code{data.frame}. Else a list with all the
#' information returned.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return playlists
#' When \code{simplify} is \code{TRUE}, a \code{data.frame} with 4
#' columns is returned:
#' \code{kind, etag, id, contentDetails.itemCount}
#'
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/playlists/list}
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' get_playlists(filter=c(channel_id="UCMtFAi84ehTSYSE9XoHefig"))
#' get_playlists(filter=c(channel_id="UCMtFAi84ehTSYSE9X")) # incorrect Channel ID
#' 
#' # For searching playlists by keyword, use yt_search() instead:
#' # yt_search(term="tutorial", channel_id="UCMtFAi84ehTSYSE9XoHefig", type="playlist")
#' }

get_playlists <- function(filter = NULL,
                          part = "snippet",
                          max_results = 50, hl = NULL,
                          page_token = NULL, simplify = TRUE, ...) {

  if (max_results <= 0) {
    stop("max_results must be a positive integer.")
  }

  valid_filters <- c("channel_id", "playlist_id")
  if (!(names(filter) %in% valid_filters)) {
    stop("filter can only take one of the following values: ", paste(valid_filters, collapse = ", "))
  }

  if (length(filter) != 1) {
    stop("filter must be a vector of length 1.")
  }

  translate_filter <- c(channel_id = "channelId", playlist_id = "id")
  yt_filter_name <- translate_filter[names(filter)]
  names(filter) <- yt_filter_name

  querylist <- list(part = part, maxResults = min(max_results, 50),
                    pageToken = page_token, hl = hl)
  querylist <- c(querylist, filter)

  raw_res <- tuber_GET("playlists", querylist, ...)
  items <- raw_res$items
  next_token <- raw_res$nextPageToken

  while (length(items) < max_results && !is.null(next_token)) {
    querylist$pageToken <- next_token
    querylist$maxResults <- min(50, max_results - length(items))
    a_res <- tuber_GET("playlists", querylist, ...)
    items <- c(items, a_res$items)
    next_token <- a_res$nextPageToken
  }

  raw_res$items <- items

  if (length(raw_res$items) == 0) {
    cat("No playlists available.\n")
    if (simplify) return(data.frame())
    return(list())
  }

  if (simplify & part == "contentDetails") {
    simpler_res <- do.call(rbind, lapply(raw_res$items, unlist))
    return(simpler_res)
  }

  raw_res
}
