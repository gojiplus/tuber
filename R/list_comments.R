#' List Comments or Replies
#'
#' Retrieves specific comments by ID or replies to one parent comment.
#'
#' @param comment_ids Optional character vector of comment IDs.
#' @param parent_id Optional parent-comment ID. Supply exactly one of
#' `comment_ids` or `parent_id`.
#' @param part Character vector of comment resource parts.
#' @param max_results Maximum total number of replies to return. Ignored when
#' `comment_ids` is supplied.
#' @param text_format Comment text format, `"html"` or `"plainText"`.
#' @param page_token Optional page token at which to start.
#' @param simplify If `TRUE`, return a data frame; otherwise return the raw API
#' response with all collected items.
#' @param auth Authentication method, `"key"` or `"token"`.
#' @param ... Additional arguments passed to [tuber_GET()].
#'
#' @return A data frame when `simplify = TRUE`; otherwise a comments-list
#' response.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/comments/list}
#' @examples
#' \dontrun{
#' list_comments(comment_ids = "COMMENT_ID")
#' list_comments(parent_id = "PARENT_COMMENT_ID", max_results = 200)
#' }
list_comments <- function(comment_ids = NULL,
                          parent_id = NULL,
                          part = c("id", "snippet"),
                          max_results = 100,
                          text_format = "html",
                          page_token = NULL,
                          simplify = TRUE,
                          auth = "key",
                          ...) {
  if (!is.null(comment_ids)) {
    assert_character(
      comment_ids,
      min.len = 1,
      any.missing = FALSE,
      min.chars = 1,
      .var.name = "comment_ids"
    )
  }
  if (!is.null(parent_id)) {
    assert_string(parent_id, min.chars = 1, .var.name = "parent_id")
  }
  assert_character(part, min.len = 1, any.missing = FALSE, .var.name = "part")
  assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")
  assert_choice(text_format, c("html", "plainText"), .var.name = "text_format")
  assert_flag(simplify, .var.name = "simplify")
  assert_choice(auth, c("key", "token"), .var.name = "auth")
  if (!is.null(page_token)) {
    assert_string(page_token, min.chars = 1, .var.name = "page_token")
  }

  if (sum(!is.null(comment_ids), !is.null(parent_id)) != 1) {
    abort(
      "Supply exactly one of `comment_ids` or `parent_id`.",
      class = "tuber_invalid_comment_filter"
    )
  }

  query <- list(
    part = paste(part, collapse = ","),
    textFormat = text_format,
    id = if (is.null(comment_ids)) NULL else paste(comment_ids, collapse = ","),
    parentId = parent_id,
    maxResults = if (is.null(parent_id)) NULL else min(max_results, 100),
    pageToken = if (is.null(parent_id)) NULL else page_token
  )
  fetch_page <- function(token = NULL) {
    page_query <- query
    if (!is.null(parent_id)) page_query$pageToken <- token
    tuber_GET("comments", page_query, auth = auth, ...)
  }

  response <- fetch_page(page_token)
  pages <- if (is.null(parent_id)) {
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
      function_name = "list_comments",
      results_found = length(pages$items),
      response_format = "list"
    ))
  }

  result <- items_to_frame(pages$items, function(item) {
    build_comment_row(
      item$snippet %||% list(),
      item$id %||% NA_character_,
      parent_id = item$snippet$parentId %||% parent_id %||% NA_character_
    )
  })
  add_tuber_attributes(
    result,
    api_calls_made = pages$page_count,
    function_name = "list_comments",
    results_found = nrow(result),
    response_format = "data.frame"
  )
}
