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

  # Modern validation using checkmate
  assert_integerish(max_results, len = 1, lower = 1, upper = 2000, .var.name = "max_results")
  assert_choice(text_format, c("html", "plainText"), .var.name = "text_format")
  assert_character(part, len = 1, min.chars = 1, .var.name = "part")
  assert_logical(simplify, len = 1, .var.name = "simplify")
  assert_character(filter, len = 1, .var.name = "filter")

  if (!is.null(page_token)) {
    assert_character(page_token, len = 1, min.chars = 1, .var.name = "page_token")
  }

  valid_filters <- c("video_id", "channel_id", "thread_id", "threads_related_to_channel")
  assert_choice(names(filter), valid_filters,
                .var.name = "filter names (must be one of: video_id, channel_id, thread_id, threads_related_to_channel)")

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
    # Use optimized pagination with preallocated memory
    estimated_items <- min(max_results, 500)  # Reasonable upper bound
    all_items <- vector("list", estimated_items)
    item_count <- 0
    page_token <- res$nextPageToken
    collected_ids <- character(estimated_items)  # Preallocate ID tracking
    id_count <- 0

    # Process initial results
    for (x in res$items) {
      comment_id <- x$snippet$topLevelComment$id
      if (!comment_id %in% collected_ids[seq_len(id_count)]) {
        item_count <- item_count + 1
        id_count <- id_count + 1

        # Expand vectors if needed
        if (item_count > length(all_items)) {
          length(all_items) <- length(all_items) * 2
          length(collected_ids) <- length(collected_ids) * 2
        }

        snippet <- unlist(x$snippet$topLevelComment$snippet)
        # Apply consistent Unicode handling
        text_fields <- c("textDisplay", "textOriginal", "authorDisplayName")
        for (field in text_fields) {
          if (field %in% names(snippet)) {
            snippet[field] <- clean_youtube_text(snippet[field])
          }
        }
        all_items[[item_count]] <- c(snippet, id = comment_id)
        collected_ids[id_count] <- comment_id
      }
    }

    # Continue pagination while we need more results and have a token
    while (!is.null(page_token) && is.character(page_token) &&
           length(all_items) < max_results) {

      querylist$pageToken <- page_token
      querylist$maxResults <- min(100, max_results - length(all_items))

      a_res <- call_api_with_retry(tuber_GET, path = "commentThreads", query = querylist, ...)

      # Process new results with efficient deduplication
      for (x in a_res$items) {
        if (item_count >= max_results) break

        comment_id <- x$snippet$topLevelComment$id
        if (!comment_id %in% collected_ids[seq_len(id_count)]) {
          item_count <- item_count + 1
          id_count <- id_count + 1

          # Expand vectors if needed
          if (item_count > length(all_items)) {
            length(all_items) <- length(all_items) * 2
            length(collected_ids) <- length(collected_ids) * 2
          }

          snippet <- unlist(x$snippet$topLevelComment$snippet)
          # Apply consistent Unicode handling
          text_fields <- c("textDisplay", "textOriginal", "authorDisplayName")
          for (field in text_fields) {
            if (field %in% names(snippet)) {
              snippet[field] <- clean_youtube_text(snippet[field])
            }
          }
          all_items[[item_count]] <- c(snippet, id = comment_id)
          collected_ids[id_count] <- comment_id
        }
      }

      page_token <- a_res$nextPageToken

      # Safety break if we get no new unique items
      if (length(a_res$items) == 0) break
    }

    if (item_count == 0) {
      return(data.frame())
    }

    # Trim to actual size and combine efficiently
    all_items <- all_items[seq_len(item_count)]
    agg_res_df <- bind_rows(lapply(all_items, as.data.frame, stringsAsFactors = FALSE))
    # Unicode handling already applied above, no need to repeat
    if ("publishedAt" %in% colnames(agg_res_df)) {
      agg_res_df <- agg_res_df[order(agg_res_df$publishedAt), , drop = FALSE]
    }
    agg_res_df$id <- NULL
    return(agg_res_df)
  }

  res
}


