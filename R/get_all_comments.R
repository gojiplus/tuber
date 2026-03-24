#' Get all the comments for a video including replies
#'
#' @param video_id string; Required.
#' \code{video_id}: video ID.
#'
#' @param max_results Integer. Maximum number of comments to return. Default is
#'   NULL which returns all comments. Set this to avoid long-running requests
#'   on popular videos.
#'
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return
#' a \code{data.frame} with the following columns:
#' \code{authorDisplayName, authorProfileImageUrl, authorChannelUrl,}
#' \code{ authorChannelId.value, videoId, textDisplay,
#' canRate, viewerRating, likeCount, publishedAt, updatedAt,
#' id, moderationStatus, parentId}
#'
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/commentThreads/list}
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' get_all_comments(video_id = "a-UQz7fqR3w")
#' get_all_comments(video_id = "a-UQz7fqR3w", max_results = 100)
#' }

get_all_comments <- function(video_id = NULL, max_results = NULL, ...) {
  # Modern validation using checkmate
  assert_character(video_id, len = 1, min.chars = 1, .var.name = "video_id")
  if (!is.null(max_results)) {
    assert_integerish(max_results, lower = 1, len = 1, .var.name = "max_results")
  }

  querylist <- list(videoId = video_id, part = "id,replies,snippet")

  # Handle videos with no comments or comments disabled
  res <- tryCatch({
    tuber_GET("commentThreads", query = querylist, ...)
  }, error = function(e) {
    if (grepl("disabled", e$message, ignore.case = TRUE)) {
      warn("Comments appear to be disabled for video",
           video_id = video_id,
           class = "tuber_comments_disabled")
      return(data.frame())
    } else {
      abort("Error retrieving comments for video",
            video_id = video_id,
            original_error = e$message,
            class = "tuber_comment_fetch_error")
    }
  })

  # Handle empty response (no comments)
  if (is.null(res$items) || length(res$items) == 0) {
    warn("No comments found for video",
         video_id = video_id,
         class = "tuber_no_comments")
    empty_df <- data.frame()
    return(add_tuber_attributes(
      empty_df,
      api_calls_made = 1,
      function_name = "get_all_comments",
      parameters = list(video_id = video_id),
      results_found = 0,
      response_format = "data.frame"
    ))
  }

  # Process first page
  agg_res <- process_page(res)
  page_token <- res$nextPageToken

  # Preallocate list with estimated size to avoid repeated reallocations
  estimated_pages <- 10  # Conservative estimate
  comment_list <- vector("list", estimated_pages)
  comment_list[[1]] <- agg_res
  page_count <- 1

  while (!is.null(page_token)) {
    # Check if we've reached max_results
    current_count <- sum(vapply(comment_list[seq_len(page_count)], function(x) if (is.data.frame(x)) nrow(x) else 0L, integer(1)))
    if (!is.null(max_results) && current_count >= max_results) {
      break
    }

    querylist$pageToken <- page_token
    a_res <- call_api_with_retry(tuber_GET, path = "commentThreads", query = querylist, ...)
    new_comments <- process_page(a_res)

    page_count <- page_count + 1

    # Expand list if needed
    if (page_count > length(comment_list)) {
      length(comment_list) <- length(comment_list) * 2
    }

    comment_list[[page_count]] <- new_comments
    page_token <- a_res$nextPageToken
  }

  # Remove unused slots and combine
  comment_list <- comment_list[seq_len(page_count)]
  agg_res <- dplyr::bind_rows(comment_list)

  # Trim to max_results if specified
  if (!is.null(max_results) && nrow(agg_res) > max_results) {
    agg_res <- agg_res[seq_len(max_results), , drop = FALSE]
  }

  # Add standardized attributes
  result <- add_tuber_attributes(
    agg_res,
    api_calls_made = page_count,
    function_name = "get_all_comments",
    parameters = list(video_id = video_id),
    results_found = nrow(agg_res),
    pages_retrieved = page_count,
    includes_replies = TRUE,
    response_format = "data.frame"
  )

  result
}


process_page <- function(res = NULL) {
  if (!has_items(res) || !has_items(res$items)) {
    return(data.frame())
  }

  all_rows <- vector("list", length(res$items) * 2)
  row_index <- 1

  for (i in seq_along(res$items)) {
    comment <- res$items[[i]]
    comment_snippet <- safe_nested(comment, "snippet", "topLevelComment", "snippet")
    comment_id <- comment$id

    all_rows[[row_index]] <- build_comment_row(comment_snippet, comment_id)
    row_index <- row_index + 1

    reply_items <- safe_nested(comment, "replies", "comments", default = NULL)
    if (has_items(reply_items)) {
      for (j in seq_along(reply_items)) {
        reply <- reply_items[[j]]
        all_rows[[row_index]] <- build_comment_row(reply$snippet, reply$id, parent_id = comment_id)
        row_index <- row_index + 1
      }
    }
  }

  all_rows <- all_rows[seq_len(row_index - 1)]
  if (length(all_rows) == 0) {
    return(data.frame())
  }

  do.call(rbind, all_rows)
}

