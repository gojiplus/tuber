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
  if (is.null(video_id) || !is.character(video_id) || length(video_id) != 1) {
    stop("video_id must be a single character string")
  }
  
  querylist <- list(videoId = video_id, part = "id,replies,snippet")
  
  # Handle videos with no comments or comments disabled
  res <- tryCatch({
    tuber_GET("commentThreads", query = querylist, ...)
  }, error = function(e) {
    if (grepl("disabled", e$message, ignore.case = TRUE)) {
      warning("Comments appear to be disabled for video: ", video_id)
      return(data.frame())
    } else {
      stop("Error retrieving comments for video ", video_id, ": ", e$message)
    }
  })
  
  # Handle empty response (no comments)
  if (is.null(res$items) || length(res$items) == 0) {
    warning("No comments found for video: ", video_id)
    return(data.frame())
  }
  
  agg_res <- process_page(res)
  page_token <- res$nextPageToken

  comment_list <- list(agg_res)  # Preallocate a list and store the initial result
  
  while (!is.null(page_token)) {
    querylist$pageToken <- page_token
    a_res <- tuber_GET("commentThreads", query = querylist, ...)
    new_comments <- process_page(a_res)
    
    # Efficiently append to list using list indexing instead of c()
    comment_list[[length(comment_list) + 1]] <- new_comments
    page_token <- a_res$nextPageToken
  }
  
  agg_res <- do.call(rbind, comment_list)  # Combine all comments into a single data frame
  agg_res
}


process_page <- function(res = NULL) {
  # Handle empty response
  if (is.null(res) || is.null(res$items) || length(res$items) == 0) {
    return(data.frame())
  }
  
  num_comments <- length(res$items)
  comment_list <- vector("list", length = num_comments)
  
  for (i in seq_len(num_comments)) {
    comment <- res$items[[i]]
    
    comment_snippet <- comment$snippet$topLevelComment$snippet
    comment_id <- comment$id
    comment_parent_id <- NA
    comment_moderation_status <- ifelse("moderationStatus" %in% names(comment_snippet),
                                        comment_snippet$moderationStatus, NA)
    
    comment_data <- c(comment_snippet, id = comment_id, parentId = comment_parent_id,
                      moderationStatus = comment_moderation_status)
    
    if (!is.null(comment$replies) && "comments" %in% names(comment$replies)) {
      reply_items <- comment$replies$comments
      n_replies <- if (is.null(reply_items)) 0 else length(reply_items)

      if (n_replies > 0) {
        reply_data <- lapply(reply_items, function(reply) {
          reply_snippet <- reply$snippet
          reply_id <- reply$id
          reply_parent_id <- comment_id
          reply_moderation_status <- ifelse("moderationStatus" %in% names(reply_snippet),
                                            reply_snippet$moderationStatus, NA)
          
          c(reply_snippet, id = reply_id, parentId = reply_parent_id,
            moderationStatus = reply_moderation_status)
        })
        
        comment_data <- rbind(comment_data, do.call(rbind, reply_data))
      }
    }
    
    comment_list[[i]] <- comment_data
  }
  
  agg_res <- do.call(rbind, comment_list)
  agg_res
}

