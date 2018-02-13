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

  agg_res <- process_page(res)

  page_token  <- res$nextPageToken

  while ( is.character(page_token)) {

    querylist$pageToken <- page_token
    a_res <- tuber_GET("commentThreads", querylist, ...)
    agg_res <- rbind(agg_res, process_page(a_res))

    page_token  <- a_res$nextPageToken
   }

  agg_res
}

process_page <- function(res = NULL) {

  simple_res  <- lapply(res$items, function(x) {
                                     unlist(x$snippet$topLevelComment$snippet)
                                     }
                                     )

  simpler_res <- ldply(simple_res, rbind)
  simpler_res <- cbind(simpler_res, id = sapply(res$items, `[[`, "id"))

  agg_res <- simpler_res$parentId <- NA

  if ( !("moderationStatus" %in% names(simpler_res))) {
    simpler_res$moderationStatus <- NA
  }

  n_replies   <- sapply(res$items, function(x) {
                                     unlist(x$snippet$totalReplyCount)
                                     }
                                     )
  if (sum(n_replies) == 0) {

    agg_res <- simpler_res

  } else {
      replies_1  <- lapply(res$items[n_replies == 1], function(x) {
                                     unlist(x$replies$comments)
                                     }
                                     )
      replies_1  <- ldply(replies_1, rbind)
      names(replies_1) <- gsub("snippet.", "", names(replies_1))
      replies_1   <- replies_1[, - which(names(replies_1) %in% c("kind", "etag"))]

      replies_1p  <- lapply(res$items[n_replies > 1], function(x) {
                                     x$replies$comments
                                     }
                                     )

      replies_1p  <- lapply(replies_1p[[1]], function(x) c(unlist(x$snippet), id = x$id))
      replies_1p  <- ldply(replies_1p, rbind)

      if (! ("moderationStatus" %in% names(replies_1p))) {
        replies_1p$moderationStatus <- NA
      }

      if (nrow(replies_1) > 0 & ! ("moderationStatus" %in% names(replies_1))) {
        replies_1$moderationStatus <- NA
      }

      simpler_rep <- rbind(replies_1, replies_1p)

      if (! ("moderationStatus" %in% names(simpler_rep))) {
        simpler_rep$moderationStatus <- NA
      }

      agg_res <- rbind(simpler_res, simpler_rep)
   } 
  agg_res
}
