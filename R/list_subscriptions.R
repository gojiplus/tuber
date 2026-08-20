#' List Subscriptions
#'
#' Retrieves subscription resources using exactly one YouTube filter.
#'
#' @param channel_id Optional channel whose public subscriptions to retrieve.
#' @param subscription_ids Optional character vector of subscription IDs.
#' @param mine If `TRUE`, retrieve channels the authenticated user subscribes
#' to.
#' @param my_recent_subscribers If `TRUE`, retrieve the authenticated channel's
#' recent subscribers.
#' @param my_subscribers If `TRUE`, retrieve the authenticated channel's
#' subscribers.
#' @param for_channel_ids Optional channel IDs used to narrow matching
#' subscriptions.
#' @param part Character vector of subscription resource parts.
#' @param order Sort order: `"alphabetical"`, `"relevance"`, or `"unread"`.
#' @param max_results Maximum total number of subscriptions to return.
#' @param page_token Optional page token at which to start.
#' @param simplify If `TRUE`, return a data frame; otherwise return the raw API
#' response with all collected items.
#' @param auth Authentication method, `"key"` or `"token"`. Authenticated-user
#' filters require OAuth.
#' @param ... Additional arguments passed to [tuber_GET()].
#'
#' @return A data frame when `simplify = TRUE`; otherwise a subscriptions-list
#' response.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/subscriptions/list}
#' @examples
#' \dontrun{
#' list_subscriptions(channel_id = "UChTJTbr5kf3hYazJZO-euHg")
#' list_subscriptions(mine = TRUE)
#' }
list_subscriptions <- function(channel_id = NULL,
                              subscription_ids = NULL,
                              mine = FALSE,
                              my_recent_subscribers = FALSE,
                              my_subscribers = FALSE,
                              for_channel_ids = NULL,
                              part = c("snippet", "contentDetails"),
                              order = "relevance",
                              max_results = 50,
                              page_token = NULL,
                              simplify = TRUE,
                              auth = if (mine || my_recent_subscribers || my_subscribers) "token" else "key",
                              ...) {
  if (!is.null(channel_id)) {
    assert_string(channel_id, min.chars = 1, .var.name = "channel_id")
  }
  if (!is.null(subscription_ids)) {
    assert_character(
      subscription_ids,
      min.len = 1,
      any.missing = FALSE,
      min.chars = 1,
      .var.name = "subscription_ids"
    )
  }
  assert_flag(mine, .var.name = "mine")
  assert_flag(my_recent_subscribers, .var.name = "my_recent_subscribers")
  assert_flag(my_subscribers, .var.name = "my_subscribers")
  if (!is.null(for_channel_ids)) {
    assert_character(
      for_channel_ids,
      min.len = 1,
      any.missing = FALSE,
      min.chars = 1,
      .var.name = "for_channel_ids"
    )
  }
  assert_character(part, min.len = 1, any.missing = FALSE, .var.name = "part")
  assert_choice(order, c("alphabetical", "relevance", "unread"), .var.name = "order")
  assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")
  assert_flag(simplify, .var.name = "simplify")
  assert_choice(auth, c("key", "token"), .var.name = "auth")
  if (!is.null(page_token)) {
    assert_string(page_token, min.chars = 1, .var.name = "page_token")
  }

  filter_count <- sum(
    !is.null(channel_id),
    !is.null(subscription_ids),
    mine,
    my_recent_subscribers,
    my_subscribers
  )
  if (filter_count != 1) {
    abort(
      paste0(
        "Supply exactly one of `channel_id`, `subscription_ids`, `mine`, ",
        "`my_recent_subscribers`, or `my_subscribers`."
      ),
      class = "tuber_invalid_subscription_filter"
    )
  }
  oauth_filter <- mine || my_recent_subscribers || my_subscribers
  if (oauth_filter && auth != "token") {
    abort("Authenticated-user filters require OAuth.", class = "tuber_auth_required")
  }

  by_ids <- !is.null(subscription_ids)
  query <- list(
    part = paste(part, collapse = ","),
    channelId = channel_id,
    id = if (by_ids) paste(subscription_ids, collapse = ",") else NULL,
    mine = if (mine) "true" else NULL,
    myRecentSubscribers = if (my_recent_subscribers) "true" else NULL,
    mySubscribers = if (my_subscribers) "true" else NULL,
    forChannelId = if (is.null(for_channel_ids)) NULL else paste(for_channel_ids, collapse = ","),
    order = order,
    maxResults = if (by_ids) NULL else min(max_results, 50),
    pageToken = if (by_ids) NULL else page_token
  )
  fetch_page <- function(token = NULL) {
    page_query <- query
    if (!by_ids) page_query$pageToken <- token
    tuber_GET("subscriptions", page_query, auth = auth, ...)
  }
  response <- fetch_page(page_token)
  pages <- if (by_ids) {
    list(
      items = head(response$items %||% list(), max_results),
      page_count = 1L,
      final_page_token = NULL
    )
  } else {
    paginate_api_request(response, fetch_page, max_results = max_results)
  }
  response$items <- pages$items
  response$nextPageToken <- pages$final_page_token

  if (!simplify) {
    return(add_tuber_attributes(
      response,
      api_calls_made = pages$page_count,
      function_name = "list_subscriptions",
      results_found = length(pages$items),
      response_format = "list"
    ))
  }

  result <- items_to_frame(pages$items, function(item) {
    data.frame(
      subscription_id = item$id %||% NA_character_,
      channel_id = item$snippet$channelId %||% NA_character_,
      subscribed_channel_id = item$snippet$resourceId$channelId %||% NA_character_,
      title = item$snippet$title %||% NA_character_,
      description = item$snippet$description %||% NA_character_,
      published_at = item$snippet$publishedAt %||% NA_character_,
      subscriber_title = item$subscriberSnippet$title %||% NA_character_,
      subscriber_channel_id = item$subscriberSnippet$channelId %||% NA_character_,
      total_item_count = as.numeric(item$contentDetails$totalItemCount %||% NA),
      new_item_count = as.numeric(item$contentDetails$newItemCount %||% NA),
      activity_type = item$contentDetails$activityType %||% NA_character_,
      stringsAsFactors = FALSE
    )
  })
  add_tuber_attributes(
    result,
    api_calls_made = pages$page_count,
    function_name = "list_subscriptions",
    results_found = nrow(result),
    response_format = "data.frame"
  )
}
