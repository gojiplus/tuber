#' Get All Video Comments, Including Replies
#'
#' Retrieves top-level comments and, when a thread response contains only a
#' reply preview, follows `comments.list` pagination to retrieve the remaining
#' replies.
#'
#' @param video_id Video ID.
#' @param max_results Optional maximum total number of comments and replies.
#' `NULL` retrieves all available comments.
#' @param auth Authentication method, `"key"` or `"token"`.
#' @param ... Additional arguments passed to [tuber_GET()].
#'
#' @return A data frame with one row per top-level comment or reply and
#' snake-case column names.
#' @export
#' @references
#' \url{https://developers.google.com/youtube/v3/docs/commentThreads/list}
#' \url{https://developers.google.com/youtube/v3/docs/comments/list}
#' @examples
#' \dontrun{
#' get_all_comments("a-UQz7fqR3w", max_results = 100)
#' }
get_all_comments <- function(video_id,
                             max_results = NULL,
                             auth = "key",
                             ...) {
  assert_string(video_id, min.chars = 1, .var.name = "video_id")
  if (!is.null(max_results)) {
    assert_integerish(max_results, len = 1, lower = 1, .var.name = "max_results")
  }
  assert_choice(auth, c("key", "token"), .var.name = "auth")

  thread_limit <- max_results %||% .Machine$integer.max
  threads <- tryCatch(
    list_comment_threads(
      video_id = video_id,
      part = c("id", "replies", "snippet"),
      max_results = thread_limit,
      simplify = FALSE,
      auth = auth,
      ...
    ),
    error = function(error) {
      if (grepl("disabled", error$message, ignore.case = TRUE)) {
        warn(
          "Comments appear to be disabled for this video.",
          video_id = video_id,
          class = "tuber_comments_disabled"
        )
        return(NULL)
      }
      abort(
        "Unable to retrieve comments for this video.",
        video_id = video_id,
        parent = error,
        class = "tuber_comment_fetch_error"
      )
    }
  )

  if (is.null(threads) || length(threads$items %||% list()) == 0) {
    warn("No comments found for video.", video_id = video_id, class = "tuber_no_comments")
    return(add_tuber_attributes(
      empty_comment_frame(),
      api_calls_made = attr(threads, "tuber_api_calls") %||% 0,
      function_name = "get_all_comments",
      results_found = 0,
      response_format = "data.frame"
    ))
  }

  rows <- list()
  api_calls <- attr(threads, "tuber_api_calls") %||% 1L
  reached_limit <- function() {
    !is.null(max_results) && length(rows) >= max_results
  }

  for (thread in threads$items) {
    if (reached_limit()) break

    top_level <- thread$snippet$topLevelComment %||% list()
    comment_id <- top_level$id %||% NA_character_
    rows[[length(rows) + 1L]] <- build_comment_row(
      top_level$snippet %||% list(),
      comment_id
    )
    if (reached_limit()) break

    total_replies <- as.integer(thread$snippet$totalReplyCount %||% 0L)
    included_replies <- thread$replies$comments %||% list()
    replies <- included_replies

    if (total_replies > length(included_replies)) {
      remaining <- if (is.null(max_results)) {
        total_replies
      } else {
        min(total_replies, max_results - length(rows))
      }
      if (remaining > 0) {
        reply_response <- list_comments(
          parent_id = comment_id,
          max_results = remaining,
          simplify = FALSE,
          auth = auth,
          ...
        )
        replies <- reply_response$items %||% list()
        api_calls <- api_calls + (attr(reply_response, "tuber_api_calls") %||% 1L)
      }
    }

    seen_reply_ids <- character()
    for (reply in replies) {
      if (reached_limit()) break
      reply_id <- reply$id %||% NA_character_
      if (!is.na(reply_id) && reply_id %in% seen_reply_ids) next
      seen_reply_ids <- c(seen_reply_ids, reply_id)
      rows[[length(rows) + 1L]] <- build_comment_row(
        reply$snippet %||% list(),
        reply_id,
        parent_id = comment_id
      )
    }
  }

  result <- if (length(rows) == 0) empty_comment_frame() else bind_rows(rows)
  add_tuber_attributes(
    result,
    api_calls_made = api_calls,
    function_name = "get_all_comments",
    parameters = list(video_id = video_id, max_results = max_results),
    results_found = nrow(result),
    includes_replies = TRUE,
    response_format = "data.frame"
  )
}
