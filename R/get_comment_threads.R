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
#' following: \code{id, replies, snippet}. e.g., \code{"id,snippet"},
#' \code{"replies"}, etc. Default: \code{snippet}.
#' @param max_results  Maximum number of items that should be returned.
#'  Integer. Optional. Can be 1-2000. Default is 100.
#' If the value is greater than 100, multiple API calls are made to fetch all
#' results. Each API call is limited to 100 items per the YouTube API.
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

  if (max_results < 1 || max_results > 2000) {
    stop("max_results must be between 1 and 2000. For values above 100, multiple API calls are made.")
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
    simpler_res <- lapply(res$items, function(x) {
      snippet <- unlist(x$snippet$topLevelComment$snippet)
      # Apply consistent Unicode handling
      text_fields <- c("textDisplay", "textOriginal", "authorDisplayName")
      for (field in text_fields) {
        if (field %in% names(snippet)) {
          snippet[field] <- clean_youtube_text(snippet[field])
        }
      }
      snippet
    })
    simpler_res <- do.call(rbind, simpler_res)
    if ("publishedAt" %in% colnames(simpler_res)) {
      simpler_res <- simpler_res[order(simpler_res[, "publishedAt"]), , drop = FALSE]
    }
    return(simpler_res)

  } else if (simplify && part == "snippet" && max_results > 100) {
    # Use standardized pagination pattern from yt_search.R
    all_items <- list()
    page_token <- res$nextPageToken
    collected_ids <- character(0)
    
    # Process initial results
    for (x in res$items) {
      comment_id <- x$snippet$topLevelComment$id
      if (!comment_id %in% collected_ids) {
        snippet <- unlist(x$snippet$topLevelComment$snippet)
        # Apply consistent Unicode handling
        text_fields <- c("textDisplay", "textOriginal", "authorDisplayName")
        for (field in text_fields) {
          if (field %in% names(snippet)) {
            snippet[field] <- clean_youtube_text(snippet[field])
          }
        }
        all_items[[length(all_items) + 1]] <- c(snippet, id = comment_id)
        collected_ids <- c(collected_ids, comment_id)
      }
    }
    
    # Continue pagination while we need more results and have a token
    while (!is.null(page_token) && is.character(page_token) && 
           length(all_items) < max_results) {
      
      querylist$pageToken <- page_token
      querylist$maxResults <- min(100, max_results - length(all_items))
      
      a_res <- tuber_GET("commentThreads", querylist, ...)
      
      # Process new results with deduplication
      for (x in a_res$items) {
        if (length(all_items) >= max_results) break
        
        comment_id <- x$snippet$topLevelComment$id
        if (!comment_id %in% collected_ids) {
          snippet <- unlist(x$snippet$topLevelComment$snippet)
          # Apply consistent Unicode handling
          text_fields <- c("textDisplay", "textOriginal", "authorDisplayName")
          for (field in text_fields) {
            if (field %in% names(snippet)) {
              snippet[field] <- clean_youtube_text(snippet[field])
            }
          }
          all_items[[length(all_items) + 1]] <- c(snippet, id = comment_id)
          collected_ids <- c(collected_ids, comment_id)
        }
      }
      
      page_token <- a_res$nextPageToken
      
      # Safety break if we get no new unique items
      if (length(a_res$items) == 0) break
    }

    if (length(all_items) == 0) {
      return(data.frame())
    }
    
    agg_res_df <- do.call(rbind, all_items)
    # Unicode handling already applied above, no need to repeat
    if ("publishedAt" %in% colnames(agg_res_df)) {
      agg_res_df <- agg_res_df[order(agg_res_df$publishedAt), , drop = FALSE]
    }
    agg_res_df$id <- NULL
    return(agg_res_df)
  }

  res
}


