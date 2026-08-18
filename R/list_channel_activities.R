#' List Channel Activities
#'
#' @param channel_id Channel ID.
#' @param part Character vector of activity resource parts.
#' @param max_results Maximum total number of activities to return.
#' @param page_token Optional page token at which to start.
#' @param published_after Optional RFC 3339 lower timestamp bound.
#' @param published_before Optional RFC 3339 upper timestamp bound.
#' @param region_code Optional ISO 3166-1 alpha-2 content-region code.
#' @param simplify If `TRUE`, return a data frame; otherwise return the raw API
#' response with all collected items.
#' @param auth Authentication method, `"key"` or `"token"`.
#' @param ... Additional arguments passed to [tuber_GET()].
#'
#' @return A data frame when `simplify = TRUE`; otherwise an activities-list
#' response.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/activities/list}
#' @examples
#' \dontrun{
#' list_channel_activities("UCRw8bIz2wMLmfgAgWm903cA", max_results = 100)
#' }
list_channel_activities <- function(channel_id,
                                    part = c("snippet", "contentDetails"),
                                    max_results = 50,
                                    page_token = NULL,
                                    published_after = NULL,
                                    published_before = NULL,
                                    region_code = NULL,
                                    simplify = TRUE,
                                    auth = "key",
                                    ...) {
  assert_string(channel_id, min.chars = 1, .var.name = "channel_id")
  assert_character(part, min.len = 1, any.missing = FALSE, .var.name = "part")
  assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")
  assert_flag(simplify, .var.name = "simplify")
  assert_choice(auth, c("key", "token"), .var.name = "auth")
  if (!is.null(page_token)) {
    assert_string(page_token, min.chars = 1, .var.name = "page_token")
  }
  if (!is.null(published_after)) {
    validate_rfc3339_date(published_after, "published_after")
  }
  if (!is.null(published_before)) {
    validate_rfc3339_date(published_before, "published_before")
  }
  if (!is.null(region_code)) {
    assert_string(region_code, pattern = "^[A-Z]{2}$", .var.name = "region_code")
  }

  query <- list(
    part = paste(part, collapse = ","),
    channelId = channel_id,
    maxResults = min(max_results, 50),
    pageToken = page_token,
    publishedAfter = published_after,
    publishedBefore = published_before,
    regionCode = region_code
  )
  fetch_page <- function(token = NULL) {
    page_query <- query
    page_query$pageToken <- token
    tuber_GET("activities", page_query, auth = auth, ...)
  }
  response <- fetch_page(page_token)
  pages <- paginate_api_request(response, fetch_page, max_results = max_results)
  response$items <- pages$items
  response$nextPageToken <- pages$final_page_token

  if (!simplify) {
    return(add_tuber_attributes(
      response,
      api_calls_made = pages$page_count,
      function_name = "list_channel_activities",
      results_found = length(pages$items),
      response_format = "list"
    ))
  }

  result <- items_to_frame(pages$items, function(item) {
    details <- item$contentDetails %||% list()
    data.frame(
      activity_id = item$id %||% NA_character_,
      type = item$snippet$type %||% NA_character_,
      published_at = item$snippet$publishedAt %||% NA_character_,
      channel_id = item$snippet$channelId %||% NA_character_,
      channel_title = item$snippet$channelTitle %||% NA_character_,
      title = item$snippet$title %||% NA_character_,
      description = item$snippet$description %||% NA_character_,
      video_id = details$upload$videoId %||%
        details$playlistItem$resourceId$videoId %||%
        details$recommendation$resourceId$videoId %||% NA_character_,
      playlist_id = details$playlistItem$playlistId %||%
        details$bulletin$resourceId$playlistId %||% NA_character_,
      stringsAsFactors = FALSE
    )
  })
  add_tuber_attributes(
    result,
    api_calls_made = pages$page_count,
    function_name = "list_channel_activities",
    results_found = nrow(result),
    response_format = "data.frame"
  )
}
