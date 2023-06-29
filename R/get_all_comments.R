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
  querylist <- list(videoId = video_id, part = "id,replies,snippet", maxResults = 100)
  res <- tuber_GET("commentThreads", query = querylist, ...)
  agg_res <- process_page(res)
  page_token <- res$nextPageToken
  
  while (!is.null(page_token)) {
    querylist$pageToken <- page_token
    a_res <- tuber_GET("commentThreads", query = querylist, ...)
    agg_res <- rbind(agg_res, process_page(a_res), stringsAsFactors = FALSE)
    page_token <- a_res$nextPageToken
  }
  
  agg_res
}

process_page <- function(res = NULL) {
  simple_res <- lapply(res$items, function(x) {
    comment_snippet <- x$snippet$topLevelComment$snippet
    comment_id <- x$id
    comment_parent_id <- NA
    comment_moderation_status <- if ("moderationStatus" %in% names(comment_snippet)) {
      comment_snippet$moderationStatus
    } else {
      NA
    }
    
    comment_data <- c(comment_snippet, id = comment_id, parentId = comment_parent_id, moderationStatus = comment_moderation_status)
    
    replies <- x$replies
    if (!is.null(replies) && "comments" %in% names(replies)) {
      reply_items <- replies$comments
      
      if (!is.null(reply_items) && length(reply_items) > 0) {
        reply_data <- lapply(reply_items, function(reply) {
          reply_snippet <- reply$snippet
          reply_id <- reply$id
          reply_parent_id <- comment_id
          reply_moderation_status <- if ("moderationStatus" %in% names(reply_snippet)) {
            reply_snippet$moderationStatus
          } else {
            NA
          }
          
          c(reply_snippet, id = reply_id, parentId = reply_parent_id, moderationStatus = reply_moderation_status)
        })
        
        reply_data <- do.call(rbind, reply_data)
        comment_data <- rbind(comment_data, reply_data)
      }
    }
    
    comment_data
  })
  
  agg_res <- do.call(rbind, simple_res)
  agg_res
}

