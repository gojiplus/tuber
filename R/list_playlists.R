#' List Playlists
#'
#' Retrieves playlists by channel, playlist ID, or authenticated ownership.
#'
#' @param channel_id Optional channel ID.
#' @param playlist_ids Optional character vector of playlist IDs.
#' @param mine If `TRUE`, retrieve playlists owned by the authenticated user.
#' @param part Character vector of playlist resource parts.
#' @param max_results Maximum total number of playlists to return.
#' @param language Optional language code for localized text.
#' @param page_token Optional page token at which to start.
#' @param simplify If `TRUE`, return a data frame; otherwise return the raw API
#' response with all collected items.
#' @param auth Authentication method, `"key"` or `"token"`. `mine = TRUE`
#' requires OAuth.
#' @param ... Additional arguments passed to [tuber_GET()].
#'
#' @return A data frame when `simplify = TRUE`; otherwise a playlists-list
#' response.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/playlists/list}
#' @examples
#' \dontrun{
#' list_playlists(channel_id = "UCMtFAi84ehTSYSE9XoHefig")
#' list_playlists(playlist_ids = c("PLAYLIST_1", "PLAYLIST_2"))
#' list_playlists(mine = TRUE)
#' }
list_playlists <- function(channel_id = NULL,
                          playlist_ids = NULL,
                          mine = FALSE,
                          part = c("snippet", "contentDetails", "status"),
                          max_results = 50,
                          language = NULL,
                          page_token = NULL,
                          simplify = TRUE,
                          auth = if (mine) "token" else "key",
                          ...) {
  if (!is.null(channel_id)) {
    assert_string(channel_id, min.chars = 1, .var.name = "channel_id")
  }
  if (!is.null(playlist_ids)) {
    assert_character(
      playlist_ids,
      min.len = 1,
      any.missing = FALSE,
      min.chars = 1,
      .var.name = "playlist_ids"
    )
  }
  assert_flag(mine, .var.name = "mine")
  assert_character(part, min.len = 1, any.missing = FALSE, .var.name = "part")
  assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")
  assert_flag(simplify, .var.name = "simplify")
  assert_choice(auth, c("key", "token"), .var.name = "auth")
  if (!is.null(language)) {
    assert_string(language, min.chars = 1, .var.name = "language")
  }
  if (!is.null(page_token)) {
    assert_string(page_token, min.chars = 1, .var.name = "page_token")
  }

  filter_count <- sum(!is.null(channel_id), !is.null(playlist_ids), mine)
  if (filter_count != 1) {
    abort(
      "Supply exactly one of `channel_id`, `playlist_ids`, or `mine = TRUE`.",
      class = "tuber_invalid_playlist_filter"
    )
  }
  if (mine && auth != "token") {
    abort("`mine = TRUE` requires OAuth authentication.", class = "tuber_auth_required")
  }

  by_ids <- !is.null(playlist_ids)
  query <- list(
    part = paste(part, collapse = ","),
    channelId = channel_id,
    id = if (by_ids) paste(playlist_ids, collapse = ",") else NULL,
    mine = if (mine) "true" else NULL,
    hl = language,
    maxResults = if (by_ids) NULL else min(max_results, 50),
    pageToken = if (by_ids) NULL else page_token
  )
  fetch_page <- function(token = NULL) {
    page_query <- query
    if (!by_ids) page_query$pageToken <- token
    tuber_GET("playlists", page_query, auth = auth, ...)
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
      function_name = "list_playlists",
      results_found = length(pages$items),
      response_format = "list"
    ))
  }

  result <- items_to_frame(pages$items, function(item) {
    data.frame(
      playlist_id = item$id %||% NA_character_,
      title = item$snippet$title %||% NA_character_,
      description = item$snippet$description %||% NA_character_,
      channel_id = item$snippet$channelId %||% NA_character_,
      channel_title = item$snippet$channelTitle %||% NA_character_,
      published_at = item$snippet$publishedAt %||% NA_character_,
      item_count = as.numeric(item$contentDetails$itemCount %||% NA),
      privacy_status = item$status$privacyStatus %||% NA_character_,
      etag = item$etag %||% NA_character_,
      stringsAsFactors = FALSE
    )
  })
  add_tuber_attributes(
    result,
    api_calls_made = pages$page_count,
    function_name = "list_playlists",
    results_found = nrow(result),
    response_format = "data.frame"
  )
}
