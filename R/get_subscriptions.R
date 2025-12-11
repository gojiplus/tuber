#' Get Subscriptions
#'
#' @param filter string; Required.
#' named vector of length 1
#' potential names of the entry in the vector:
#' \code{channel_id}: ID of the channel. Required. No default.
#' \code{subscription_id}: YouTube subscription ID
#'
#' @param part Part of the resource requested. Required. Character.
#' A comma separated list of one or more of the following:
#' \code{contentDetails, id, snippet, subscriberSnippet}. e.g. "id, snippet",
#'  "id", etc. Default: \code{contentDetails}.
#' @param max_results Maximum number of items that should be returned.
#' Integer. Optional. Default is 50. Values over 50 will trigger additional
#' requests and may increase API quota usage.
#' @param page_token  Specific page in the result set that should be
#' returned. Optional. String.
#' @param for_channel_id  Optional. String. A comma-separated list of
#' channel IDs. Limits response to subscriptions matching those channels.
#' @param order method that will be used to sort resources in the API
#' response. Takes one of the following: alphabetical, relevance, unread
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return named list of subscriptions
#'
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/subscriptions/list}
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' get_subscriptions(filter = c(channel_id = "UChTJTbr5kf3hYazJZO-euHg"))
#' }

get_subscriptions <- function(filter = NULL, part = "contentDetails",
                               max_results = 50, for_channel_id = NULL,
                               order = NULL, page_token = NULL, ...) {

  # Modern validation using checkmate
  assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")
  assert_character(filter, len = 1, .var.name = "filter")
  assert_choice(names(filter), c("channel_id", "subscription_id"), 
                .var.name = "filter names (must be 'channel_id' or 'subscription_id')")
  assert_character(part, len = 1, min.chars = 1, .var.name = "part")
  
  if (!is.null(for_channel_id)) {
    assert_character(for_channel_id, min.chars = 1, .var.name = "for_channel_id")
  }
  if (!is.null(order)) {
    assert_choice(order, c("alphabetical", "relevance", "unread"), .var.name = "order")
  }
  if (!is.null(page_token)) {
    assert_character(page_token, len = 1, min.chars = 1, .var.name = "page_token")
  }

  translate_filter   <- c(channel_id = "channelId", subscription_id = "id")
  yt_filter_name     <- as.vector(translate_filter[match(names(filter),
                                                      names(translate_filter))])
  names(filter)      <- yt_filter_name

  querylist <- list(part = part, maxResults = min(max_results, 50),
                   pageToken = page_token, order = order,
                   forChannelId = for_channel_id)
  querylist <- c(querylist, filter)

  res <- tuber_GET("subscriptions", querylist, ...)
  items <- res$items
  next_token <- res$nextPageToken

  while (length(items) < max_results && !is.null(next_token)) {
    querylist$pageToken <- next_token
    querylist$maxResults <- min(50, max_results - length(items))
    a_res <- tuber_GET("subscriptions", querylist, ...)
    items <- c(items, a_res$items)
    next_token <- a_res$nextPageToken
  }

  res$items <- items
  res
}
