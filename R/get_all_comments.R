#' Get all the comments for a video including replies
#'
#' @param video_id string; Required.
#' \code{video_id}: video ID.
#'  
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'  
#' @return  
#' a \code{data.frame} with the following columns:
#' \code{authorDisplayName, authorProfileImageUrl, authorChannelUrl, authorChannelId.value, videoId, textDisplay,          
#' canRate, viewerRating, likeCount, publishedAt, updatedAt, id, moderationStatus, parentId}
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

get_all_comments <- function (video_id = NULL, ...) {

  querylist <- list(videoId = video_id, part = "id,replies,snippet", maxResults = 100)

  res <- tuber_GET("commentThreads", querylist, ...)

  simple_res  <- lapply(res$items, function(x) {
                                     unlist(x$snippet$topLevelComment$snippet)
                                     }
                                     )
  simpler_res <- ldply(simple_res, rbind)
  simpler_res <- cbind(simpler_res, id = sapply(res$items, `[[`, "id"))

  # just add parent_id 
  simpler_res$parentId <- NA
  
  # add moderation status where missing
  if (! ("moderationStatus" %in% names(simpler_res))) {
    simpler_res$moderationStatus <- NA
  }

  n_replies   <- sapply(res$items, function(x) {
                                     unlist(x$snippet$totalReplyCount)
                                     }
                                     )
  if (sum(n_replies) > 1) {
    replies     <- lapply(res$items[n_replies > 0], function(x) {
                                     unlist(x$replies$comments)
                                     }
                                     )
    simpler_rep <- ldply(replies, rbind)
    names(simpler_rep) <- gsub("snippet.", "", names(simpler_rep))
    simpler_rep <-  subset(simpler_rep, select = -c(kind, etag))

    # add moderation status where missing
    if (! ("moderationStatus" %in% names(simpler_rep))) {
      simpler_rep$moderationStatus <- NA
    }

    agg_res <- rbind(simpler_res, simpler_rep)
  }

  agg_res <- simpler_res
  page_token  <- res$nextPageToken

  while ( is.character(page_token)) {

    querylist$pageToken <- page_token

    a_res <- tuber_GET("commentThreads", querylist, ...)

    simple_res  <- lapply(a_res$items, function(x) {
                                     unlist(x$snippet$topLevelComment$snippet)
                                     }
                                     )
    simpler_res <- ldply(simple_res, rbind)
    simpler_res <- cbind(simpler_res, id = sapply(res$items, `[[`, "id"))

    # just add parent_id 
    simpler_res$parentId <- NA
  
    # add moderation status where missing
    if (! ("moderationStatus" %in% names(simpler_res))) {
      simpler_res$moderationStatus <- NA
    }

    n_replies   <- sapply(a_res$items, function(x) {
                                     unlist(x$snippet$totalReplyCount)
                                     }
                                     )
    
    if (sum(n_replies) > 1) {
      replies     <- lapply(a_res$items[n_replies > 0], function(x) {
                                     unlist(x$replies$comments)
                                     }
                                     )
      simpler_rep <- ldply(replies, rbind)
      names(simpler_rep) <- gsub("snippet.", "", names(simpler_rep))
      simpler_rep <-  subset(simpler_rep, select = -c(kind, etag))
      
      # add moderation status where missing
      if (! ("moderationStatus" %in% names(simpler_rep))) {
        simpler_rep$moderationStatus <- NA
      }

      agg_res <- rbind(simpler_res, simpler_rep, agg_res)
      page_token  <- a_res$nextPageToken
    }

    agg_res <- rbind(simpler_res, agg_res)
    page_token  <- a_res$nextPageToken
  }

  agg_res
}
