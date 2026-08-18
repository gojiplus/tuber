#' List Comment Threads
#'
#' Retrieves comment threads using one explicit YouTube filter.
#'
#' @param video_id Optional video ID.
#' @param channel_id Optional channel ID.
#' @param thread_ids Optional character vector of comment-thread IDs.
#' @param all_threads_for_channel_id Optional channel ID for all threads
#' related to that channel.
#' @param part Character vector of comment-thread resource parts.
#' @param text_format Comment text format, `"html"` or `"plainText"`.
#' @param max_results Maximum total number of threads to return.
#' @param page_token Optional page token at which to start.
#' @param simplify If `TRUE`, return one row per top-level comment; otherwise
#' return the raw API response with all collected items.
#' @param auth Authentication method, `"key"` or `"token"`.
#' @param ... Additional arguments passed to [tuber_GET()].
#'
#' @return A data frame when `simplify = TRUE`; otherwise a comment-threads
#' response.
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/commentThreads/list}
#' @examples
#' \dontrun{
#' list_comment_threads(video_id = "N708P-A45D0", max_results = 200)
#' }
list_comment_threads <- function(video_id = NULL,
                                channel_id = NULL,
                                thread_ids = NULL,
                                all_threads_for_channel_id = NULL,
                                part = c("id", "snippet"),
                                text_format = "html",
                                max_results = 100,
                                page_token = NULL,
                                simplify = TRUE,
                                auth = "key",
                                ...) {
  scalar_filters <- list(
    video_id = video_id,
    channel_id = channel_id,
    all_threads_for_channel_id = all_threads_for_channel_id
  )
  for (filter_name in names(scalar_filters)) {
    value <- scalar_filters[[filter_name]]
    if (!is.null(value)) {
      assert_string(value, min.chars = 1, .var.name = filter_name)
    }
  }
  if (!is.null(thread_ids)) {
    assert_character(
      thread_ids,
      min.len = 1,
      any.missing = FALSE,
      min.chars = 1,
      .var.name = "thread_ids"
    )
  }
  assert_character(part, min.len = 1, any.missing = FALSE, .var.name = "part")
  assert_choice(text_format, c("html", "plainText"), .var.name = "text_format")
  assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")
  assert_flag(simplify, .var.name = "simplify")
  assert_choice(auth, c("key", "token"), .var.name = "auth")
  if (!is.null(page_token)) {
    assert_string(page_token, min.chars = 1, .var.name = "page_token")
  }

  filter_count <- sum(
    !is.null(video_id),
    !is.null(channel_id),
    !is.null(thread_ids),
    !is.null(all_threads_for_channel_id)
  )
  if (filter_count != 1) {
    abort(
      paste0(
        "Supply exactly one of `video_id`, `channel_id`, `thread_ids`, or ",
        "`all_threads_for_channel_id`."
      ),
      class = "tuber_invalid_comment_thread_filter"
    )
  }

  by_ids <- !is.null(thread_ids)
  query <- list(
    part = paste(part, collapse = ","),
    textFormat = text_format,
    videoId = video_id,
    channelId = channel_id,
    id = if (by_ids) paste(thread_ids, collapse = ",") else NULL,
    allThreadsRelatedToChannelId = all_threads_for_channel_id,
    maxResults = if (by_ids) NULL else min(max_results, 100),
    pageToken = if (by_ids) NULL else page_token
  )
  fetch_page <- function(token = NULL) {
    page_query <- query
    if (!by_ids) page_query$pageToken <- token
    call_api_with_retry(
      tuber_GET,
      path = "commentThreads",
      query = page_query,
      auth = auth,
      ...
    )
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
      function_name = "list_comment_threads",
      results_found = length(pages$items),
      response_format = "list"
    ))
  }

  result <- items_to_frame(pages$items, function(item) {
    top_level <- item$snippet$topLevelComment %||% list()
    row <- build_comment_row(
      top_level$snippet %||% list(),
      top_level$id %||% NA_character_
    )
    row$thread_id <- item$id %||% NA_character_
    row$total_reply_count <- as.numeric(item$snippet$totalReplyCount %||% 0)
    row$is_public <- item$snippet$isPublic %||% NA
    row$can_reply <- item$snippet$canReply %||% NA
    row
  })
  if (nrow(result) > 0) {
    result <- result[order(result$published_at), , drop = FALSE]
  }
  add_tuber_attributes(
    result,
    api_calls_made = pages$page_count,
    function_name = "list_comment_threads",
    results_found = nrow(result),
    response_format = "data.frame"
  )
}
