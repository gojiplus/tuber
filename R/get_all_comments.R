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
#' The data frame has an attribute \code{total_results} containing the
#' number of comment threads reported by the API.
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
  querylist <- list(videoId = video_id, part = "id,replies,snippet")
  res <- tuber_GET("commentThreads", query = querylist, ...)
  total_results <- res$pageInfo$totalResults
  agg_res <- process_page(res)
  page_token <- res$nextPageToken

  comment_list <- list(agg_res)  # Preallocate a list and store the initial result
  
  while (!is.null(page_token)) {
    querylist$pageToken <- page_token
    a_res <- tuber_GET("commentThreads", query = querylist, ...)
    new_comments <- process_page(a_res)
    comment_list <- c(comment_list, new_comments)  # Append new comments to the list
    page_token <- a_res$nextPageToken
  }
  
  agg_res <- do.call(rbind, comment_list)  # Combine all comments into a single data frame
  attr(agg_res, "total_results") <- total_results
  agg_res
}


process_page <- function(res = NULL) {
  num_comments <- length(res$items)
  comment_list <- vector("list", length = num_comments)
  
  for (i in seq_len(num_comments)) {
    comment <- res$items[[i]]
    
    comment_snippet <- comment$snippet$topLevelComment$snippet
    comment_id <- comment$id
    comment_parent_id <- NA
    comment_moderation_status <- ifelse("moderationStatus" %in% names(comment_snippet),
                                        comment_snippet$moderationStatus, NA)
    
    comment_data <- as.data.frame(t(c(comment_snippet,
                                      id = comment_id,
                                      parentId = comment_parent_id,
                                      moderationStatus = comment_moderation_status)),
                                  stringsAsFactors = FALSE)
    
    if (!is.null(comment$replies) && "comments" %in% names(comment$replies)) {
      reply_items <- comment$replies$comments
      
      if (!is.null(reply_items) && length(reply_items) > 0) {
        reply_data <- lapply(reply_items, function(reply) {
          reply_snippet <- reply$snippet
          reply_id <- reply$id
          reply_parent_id <- comment_id
          reply_moderation_status <- ifelse("moderationStatus" %in% names(reply_snippet),
                                            reply_snippet$moderationStatus, NA)

          as.data.frame(t(c(reply_snippet,
                             id = reply_id,
                             parentId = reply_parent_id,
                             moderationStatus = reply_moderation_status)),
                        stringsAsFactors = FALSE)
        })

        reply_data <- do.call(rbind, reply_data)
        comment_data <- rbind(comment_data, reply_data)
      }
    }
    
    comment_list[[i]] <- comment_data
  }
  
  agg_res <- do.call(rbind, comment_list)
  agg_res
}

