#' Get Comments Threads
#'
#' @param filter string; Required.
#' named vector of length 1
#' potential names of the entry in the vector:
#' \code{video_id}: video ID.
#' \code{channel_id}: channel ID.
#' \code{thread_id}: comma-separated list of comment thread IDs
#' \code{threads_related_to_channel}: channel ID.
#'
#' @param part  Comment resource requested. Required. Comma separated list
#' of one or more of the
#' following: \code{id, snippet}. e.g., \code{"id, snippet"},
#' \code{"id"}, etc. Default: \code{snippet}.
#' @param max_results  Maximum number of items that should be returned.
#'  Integer. Optional. Default is 100.
#' If the value is greater than 100 then the function fetches all the
#' results. The outcome is a simplified \code{data.frame}.
#' @param page_token  Specific page in the result set that should be
#' returned. Optional.
#' @param text_format Data Type: Character. Default is \code{"html"}.
#' Only takes \code{"html"} or \code{"plainText"}. Optional.
#' @param simplify Data Type: Boolean. Default is \code{TRUE}. If \code{TRUE},
#' the function returns a data frame. Else a list with all the
#' information returned.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return
#' Nested named list. The entry \code{items} is a list of comments
#' along with meta information.
#' Within each of the \code{items} is an item \code{snippet} which
#' has an item \code{topLevelComment$snippet$textDisplay}
#' that contains the actual comment.
#'
#' If simplify is \code{TRUE}, a \code{data.frame} with the following columns:
#' \code{authorDisplayName, authorProfileImageUrl, authorChannelUrl,
#' authorChannelId.value, videoId, textDisplay,
#' canRate, viewerRating, likeCount, publishedAt, updatedAt}
#'
#' @export
#' @references \url{https://developers.google.com/youtube/v3/docs/commentThreads/list}
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' get_comment_threads(filter = c(video_id = "N708P-A45D0"))
#' get_comment_threads(filter = c(video_id = "N708P-A45D0"), max_results = 101)
#' }

get_comment_threads <- function(filter = NULL, part = "snippet",
                                text_format = "html", simplify = TRUE,
                                max_results = 100, page_token = NULL, ...) {

  if (max_results < 20) {
    stop("max_results must be a value greater than or equal to 20. For values above 100, it outputs all the results.")
  }

  valid_formats <- c("html", "plainText")
  if (!text_format %in% valid_formats) {
    stop("Provide a valid value for textFormat.")
  }

  valid_filters <- c("video_id", "channel_id", "thread_id", "threads_related_to_channel")
  if (!(names(filter) %in% valid_filters)) {
    stop("filter can only take one of the following values: channel_id, video_id, thread_id, threads_related_to_channel.")
  }

  if (length(filter) != 1) {
    stop("filter must be a vector of length 1.")
  }

  orig_filter <- filter
  translate_filter <- c(video_id = "videoId", thread_id = "id",
                        threads_related_to_channel = "allThreadsRelatedToChannelId",
                        channel_id = "channelId", page_token = "pageToken")

  names(filter) <- translate_filter[names(filter)]

  querylist <- list(part = part, maxResults = ifelse(max_results > 100, 100, max_results),
                    textFormat = text_format, pageToken = page_token)
  querylist <- c(querylist, filter)

  res <- tuber_GET("commentThreads", querylist, ...)

  if (simplify && part == "snippet" && max_results < 101) {
    simpler_res <- lapply(res$items, function(x) unlist(x$snippet$topLevelComment$snippet))
    simpler_res <- do.call(rbind, simpler_res)

    return(simpler_res)

  } else if (simplify && part == "snippet" && max_results > 100) {
    agg_res <- lapply(res$items, function(x) unlist(x$snippet$topLevelComment$snippet))

    page_token <- res$nextPageToken
    while (!is.null(page_token)) {
      a_res <- get_comment_threads(orig_filter,
                                   part = part,
                                   text_format = text_format,
                                   simplify = FALSE,
                                   max_results = 100,
                                   page_token = page_token,
                                   ...)
      agg_res <- rbind(lapply(a_res$items, function(x) unlist(x$snippet$topLevelComment$snippet)), agg_res)
      page_token <- a_res$nextPageToken
    }
    return(do.call(rbind, agg_res))
  }

  res
}


