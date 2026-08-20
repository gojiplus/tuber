#' List Playlist Items
#'
#' Retrieves items from one playlist or retrieves specific playlist items by
#' their playlist-item IDs.
#'
#' @param playlist_id Optional playlist ID.
#' @param playlist_item_ids Optional character vector of playlist-item IDs.
#' Supply exactly one of `playlist_id` or `playlist_item_ids`.
#' @param video_id Optional video ID used to filter items in `playlist_id`.
#' @param part Character vector of playlist-item resource parts.
#' @param max_results Maximum total number of items to return.
#' @param page_token Optional page token at which to start.
#' @param simplify If `TRUE`, return a data frame; otherwise return the raw API
#' response with all collected items.
#' @param auth Authentication method, `"key"` or `"token"`.
#' @param ... Additional arguments passed to [tuber_GET()].
#'
#' @return A data frame when `simplify = TRUE`; otherwise a playlist-items
#' response.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/playlistItems/list}
#' @examples
#' \dontrun{
#' list_playlist_items(
#'   playlist_id = "PLrEnWoR732-CN09YykVof2lxdI3MLOZda",
#'   max_results = 100
#' )
#' }
list_playlist_items <- function(playlist_id = NULL,
                                playlist_item_ids = NULL,
                                video_id = NULL,
                                part = c("contentDetails", "snippet", "status"),
                                max_results = 50,
                                page_token = NULL,
                                simplify = TRUE,
                                auth = "key",
                                ...) {
  assert_character(part, min.len = 1, any.missing = FALSE, .var.name = "part")
  assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")
  assert_flag(simplify, .var.name = "simplify")
  assert_choice(auth, c("key", "token"), .var.name = "auth")
  if (!is.null(playlist_id)) {
    assert_string(playlist_id, min.chars = 1, .var.name = "playlist_id")
  }
  if (!is.null(playlist_item_ids)) {
    assert_character(
      playlist_item_ids,
      min.len = 1,
      any.missing = FALSE,
      min.chars = 1,
      .var.name = "playlist_item_ids"
    )
  }
  if (!is.null(video_id)) {
    assert_string(video_id, min.chars = 1, .var.name = "video_id")
  }
  if (!is.null(page_token)) {
    assert_string(page_token, min.chars = 1, .var.name = "page_token")
  }

  if (sum(!is.null(playlist_id), !is.null(playlist_item_ids)) != 1) {
    abort(
      "Supply exactly one of `playlist_id` or `playlist_item_ids`.",
      class = "tuber_invalid_playlist_item_filter"
    )
  }
  if (!is.null(video_id) && is.null(playlist_id)) {
    abort(
      "`video_id` can only be used with `playlist_id`.",
      class = "tuber_invalid_playlist_item_filter"
    )
  }

  query <- list(
    part = paste(part, collapse = ","),
    playlistId = playlist_id,
    id = if (is.null(playlist_item_ids)) NULL else paste(playlist_item_ids, collapse = ","),
    videoId = video_id,
    maxResults = min(max_results, 50),
    pageToken = page_token
  )
  fetch_page <- function(token = NULL) {
    page_query <- query
    page_query$pageToken <- token
    tuber_GET("playlistItems", query = page_query, auth = auth, ...)
  }

  response <- call_api_with_retry(fetch_page, page_token)
  pages <- paginate_api_request(
    response,
    function(token) call_api_with_retry(fetch_page, token),
    max_results = max_results
  )
  response$items <- pages$items
  response$nextPageToken <- pages$final_page_token

  if (!simplify) {
    return(add_tuber_attributes(
      response,
      api_calls_made = pages$page_count,
      function_name = "list_playlist_items",
      results_found = length(pages$items),
      response_format = "list",
      pagination_used = pages$page_count > 1
    ))
  }

  result <- if (length(pages$items) == 0) {
    data.frame(
      playlist_item_id = character(),
      playlist_id = character(),
      video_id = character(),
      title = character(),
      description = character(),
      published_at = character(),
      channel_id = character(),
      channel_title = character(),
      position = integer(),
      video_owner_channel_id = character(),
      video_owner_channel_title = character(),
      video_published_at = character(),
      privacy_status = character(),
      stringsAsFactors = FALSE
    )
  } else {
    bind_rows(lapply(pages$items, function(item) {
      data.frame(
        playlist_item_id = item$id %||% NA_character_,
        playlist_id = item$snippet$playlistId %||% playlist_id %||% NA_character_,
        video_id = item$contentDetails$videoId %||%
          item$snippet$resourceId$videoId %||% NA_character_,
        title = item$snippet$title %||% NA_character_,
        description = item$snippet$description %||% NA_character_,
        published_at = item$snippet$publishedAt %||% NA_character_,
        channel_id = item$snippet$channelId %||% NA_character_,
        channel_title = item$snippet$channelTitle %||% NA_character_,
        position = item$snippet$position %||% NA_integer_,
        video_owner_channel_id = item$snippet$videoOwnerChannelId %||% NA_character_,
        video_owner_channel_title = item$snippet$videoOwnerChannelTitle %||% NA_character_,
        video_published_at = item$contentDetails$videoPublishedAt %||% NA_character_,
        privacy_status = item$status$privacyStatus %||% NA_character_,
        stringsAsFactors = FALSE
      )
    }))
  }

  add_tuber_attributes(
    result,
    api_calls_made = pages$page_count,
    function_name = "list_playlist_items",
    results_found = nrow(result),
    response_format = "data.frame",
    pagination_used = pages$page_count > 1
  )
}
