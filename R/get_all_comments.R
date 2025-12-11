#' Get all the comments for a video including replies
#'
#' @param video_id string; Required.
#' \code{video_id}: video ID.
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
#' }

get_all_comments <- function(video_id = NULL, ...) {
  # Modern validation using checkmate
  assert_character(video_id, len = 1, min.chars = 1, .var.name = "video_id")

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
  agg_res <- dplyr::bind_rows(comment_list)  # More efficient than do.call(rbind, ...)

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
  # Handle empty response
  if (is.null(res) || is.null(res$items) || length(res$items) == 0) {
    return(data.frame())
  }

  # Collect all rows for the data frame
  all_rows <- list()
  row_index <- 1

  for (i in seq_len(length(res$items))) {
    comment <- res$items[[i]]

    # Extract top-level comment
    comment_snippet <- comment$snippet$topLevelComment$snippet
    comment_id <- comment$id
    comment_parent_id <- NA_character_
    comment_moderation_status <- ifelse("moderationStatus" %in% names(comment_snippet),
                                        comment_snippet$moderationStatus, NA_character_)

    # Create data frame row for top-level comment
    comment_row <- data.frame(
      authorDisplayName = ifelse("authorDisplayName" %in% names(comment_snippet), comment_snippet$authorDisplayName, NA_character_),
      authorProfileImageUrl = ifelse("authorProfileImageUrl" %in% names(comment_snippet), comment_snippet$authorProfileImageUrl, NA_character_),
      authorChannelUrl = ifelse("authorChannelUrl" %in% names(comment_snippet), comment_snippet$authorChannelUrl, NA_character_),
      authorChannelId.value = ifelse("authorChannelId" %in% names(comment_snippet) && "value" %in% names(comment_snippet$authorChannelId),
                                     comment_snippet$authorChannelId$value, NA_character_),
      videoId = ifelse("videoId" %in% names(comment_snippet), comment_snippet$videoId, NA_character_),
      textDisplay = ifelse("textDisplay" %in% names(comment_snippet), comment_snippet$textDisplay, NA_character_),
      textOriginal = ifelse("textOriginal" %in% names(comment_snippet), comment_snippet$textOriginal, NA_character_),
      canRate = ifelse("canRate" %in% names(comment_snippet), comment_snippet$canRate, NA),
      viewerRating = ifelse("viewerRating" %in% names(comment_snippet), comment_snippet$viewerRating, NA_character_),
      likeCount = ifelse("likeCount" %in% names(comment_snippet), as.numeric(comment_snippet$likeCount), NA_real_),
      publishedAt = ifelse("publishedAt" %in% names(comment_snippet), comment_snippet$publishedAt, NA_character_),
      updatedAt = ifelse("updatedAt" %in% names(comment_snippet), comment_snippet$updatedAt, NA_character_),
      id = comment_id,
      moderationStatus = comment_moderation_status,
      parentId = comment_parent_id,
      stringsAsFactors = FALSE
    )

    all_rows[[row_index]] <- comment_row
    row_index <- row_index + 1

    # Process replies if they exist
    if (!is.null(comment$replies) && "comments" %in% names(comment$replies)) {
      reply_items <- comment$replies$comments
      n_replies <- if (is.null(reply_items)) 0 else length(reply_items)

      if (n_replies > 0) {
        for (j in seq_len(n_replies)) {
          reply <- reply_items[[j]]
          reply_snippet <- reply$snippet
          reply_id <- reply$id
          reply_parent_id <- comment_id
          reply_moderation_status <- ifelse("moderationStatus" %in% names(reply_snippet),
                                            reply_snippet$moderationStatus, NA_character_)

          # Create data frame row for reply
          reply_row <- data.frame(
            authorDisplayName = ifelse("authorDisplayName" %in% names(reply_snippet), reply_snippet$authorDisplayName, NA_character_),
            authorProfileImageUrl = ifelse("authorProfileImageUrl" %in% names(reply_snippet), reply_snippet$authorProfileImageUrl, NA_character_),
            authorChannelUrl = ifelse("authorChannelUrl" %in% names(reply_snippet), reply_snippet$authorChannelUrl, NA_character_),
            authorChannelId.value = ifelse("authorChannelId" %in% names(reply_snippet) && "value" %in% names(reply_snippet$authorChannelId),
                                           reply_snippet$authorChannelId$value, NA_character_),
            videoId = ifelse("videoId" %in% names(reply_snippet), reply_snippet$videoId, NA_character_),
            textDisplay = ifelse("textDisplay" %in% names(reply_snippet), reply_snippet$textDisplay, NA_character_),
            textOriginal = ifelse("textOriginal" %in% names(reply_snippet), reply_snippet$textOriginal, NA_character_),
            canRate = ifelse("canRate" %in% names(reply_snippet), reply_snippet$canRate, NA),
            viewerRating = ifelse("viewerRating" %in% names(reply_snippet), reply_snippet$viewerRating, NA_character_),
            likeCount = ifelse("likeCount" %in% names(reply_snippet), as.numeric(reply_snippet$likeCount), NA_real_),
            publishedAt = ifelse("publishedAt" %in% names(reply_snippet), reply_snippet$publishedAt, NA_character_),
            updatedAt = ifelse("updatedAt" %in% names(reply_snippet), reply_snippet$updatedAt, NA_character_),
            id = reply_id,
            moderationStatus = reply_moderation_status,
            parentId = reply_parent_id,
            stringsAsFactors = FALSE
          )

          all_rows[[row_index]] <- reply_row
          row_index <- row_index + 1
        }
      }
    }
  }

  # Combine all rows into a single data frame
  if (length(all_rows) == 0) {
    return(data.frame())
  }

  agg_res <- do.call(rbind, all_rows)
  agg_res
}

