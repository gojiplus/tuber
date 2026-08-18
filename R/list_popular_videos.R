#' List Most-Popular Videos
#'
#' Retrieves the `mostPopular` videos chart.
#'
#' @param region_code Optional ISO 3166-1 alpha-2 content-region code.
#' @param category_id Optional video-category ID.
#' @param max_results Maximum total number of videos to return.
#' @param part Character vector of video resource parts.
#' @param language Optional language code for localized text.
#' @param page_token Optional page token at which to start.
#' @param simplify If `TRUE`, return a data frame; otherwise return the raw API
#' response with all collected items.
#' @param auth Authentication method, `"key"` or `"token"`.
#' @param ... Additional arguments passed to [tuber_GET()].
#'
#' @return A data frame when `simplify = TRUE`; otherwise a videos-list
#' response.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/videos/list}
#' @examples
#' \dontrun{
#' list_popular_videos(region_code = "US", max_results = 10)
#' }
list_popular_videos <- function(region_code = NULL,
                                category_id = NULL,
                                max_results = 50,
                                part = c("snippet", "statistics"),
                                language = NULL,
                                page_token = NULL,
                                simplify = TRUE,
                                auth = "key",
                                ...) {
  assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")
  assert_character(part, min.len = 1, any.missing = FALSE, .var.name = "part")
  assert_flag(simplify, .var.name = "simplify")
  assert_choice(auth, c("key", "token"), .var.name = "auth")
  if (!is.null(region_code)) {
    assert_string(region_code, pattern = "^[A-Z]{2}$", .var.name = "region_code")
  }
  if (!is.null(category_id)) {
    assert_string(category_id, min.chars = 1, .var.name = "category_id")
  }
  if (!is.null(language)) {
    assert_string(language, min.chars = 1, .var.name = "language")
  }
  if (!is.null(page_token)) {
    assert_string(page_token, min.chars = 1, .var.name = "page_token")
  }

  query <- list(
    chart = "mostPopular",
    part = paste(part, collapse = ","),
    maxResults = min(max_results, 50),
    pageToken = page_token,
    hl = language,
    regionCode = region_code,
    videoCategoryId = category_id
  )
  fetch_page <- function(token = NULL) {
    page_query <- query
    page_query$pageToken <- token
    tuber_GET("videos", query = page_query, auth = auth, ...)
  }

  response <- fetch_page(page_token)
  pages <- paginate_api_request(response, fetch_page, max_results = max_results)
  response$items <- pages$items
  response$nextPageToken <- pages$final_page_token

  if (!simplify) {
    return(add_tuber_attributes(
      response,
      api_calls_made = pages$page_count,
      function_name = "list_popular_videos",
      results_found = length(pages$items),
      response_format = "list"
    ))
  }

  result <- items_to_frame(pages$items, function(item) {
    data.frame(
      video_id = item$id %||% NA_character_,
      title = item$snippet$title %||% NA_character_,
      description = item$snippet$description %||% NA_character_,
      channel_id = item$snippet$channelId %||% NA_character_,
      channel_title = item$snippet$channelTitle %||% NA_character_,
      published_at = item$snippet$publishedAt %||% NA_character_,
      category_id = item$snippet$categoryId %||% NA_character_,
      live_broadcast_content = item$snippet$liveBroadcastContent %||% NA_character_,
      view_count = as.numeric(item$statistics$viewCount %||% NA),
      like_count = as.numeric(item$statistics$likeCount %||% NA),
      comment_count = as.numeric(item$statistics$commentCount %||% NA),
      etag = item$etag %||% NA_character_,
      stringsAsFactors = FALSE
    )
  })
  add_tuber_attributes(
    result,
    api_calls_made = pages$page_count,
    function_name = "list_popular_videos",
    results_found = nrow(result),
    response_format = "data.frame"
  )
}
