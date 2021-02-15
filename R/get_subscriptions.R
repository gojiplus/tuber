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
#' Integer. Optional. Can be between 0 and 50. Default is 50.
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

get_subscriptions <- function (filter = NULL, part = "contentDetails",
                               max_results = 50, for_channel_id = NULL,
                               order = NULL, page_token = NULL, ...) {

  if (max_results < 0 | max_results > 50) {
    stop("max_results only takes a value between 0 and 50.")
  }

  if (!(names(filter) %in% c("channel_id", "subscription_id"))) {
    stop("filter can only take one of values: channel_id, subscription_id.")
  }

  if ( length(filter) != 1) stop("filter must be a vector of length 1.")

  translate_filter   <- c(channel_id = "channelId", subscription_id = "id")
  yt_filter_name     <- as.vector(translate_filter[match(names(filter),
                                                      names(translate_filter))])
  names(filter)      <- yt_filter_name

  querylist <- list(part = part, maxResults = max_results,
                   pageToken = page_token, order = order,
                   forChannelId = for_channel_id)
  querylist <- c(querylist, filter)

  res <- tuber_GET("subscriptions", querylist, ...)

  res
}
