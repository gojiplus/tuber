#' Get statistics on all the videos in a Channel
#'
#' Iterates through the channel's uploads playlist, collecting video IDs from
#' each page until no further pages are available. Statistics and details are
#' then fetched for every video.
#'
#' @param channel_id Character. Id of the channel
#' @param mine Boolean. TRUE if you want to fetch stats of your own channel. Default is FALSE.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return A \code{data.frame} containing video metadata along with view, like,
#'   dislike and comment counts.
#'
#' If the \code{channel_id} is mistyped or there is no information, an empty list is returned
#'
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/channels/list}
#'
#' @examples
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' get_all_channel_video_stats(channel_id="UCxOhDvtaoXDAB336AolWs3A")
#' get_all_channel_video_stats(channel_id="UCMtFAi84ehTSYSE9Xo") # Incorrect channel ID
#' }

get_all_channel_video_stats <- function(channel_id = NULL, mine = FALSE, ...) {
  if (!is.character(channel_id) && !identical(tolower(mine), "true")) {
    stop("Must specify a valid channel ID or set mine = 'true'.")
  }

  # Get channel resources with proper error handling
  channel_resources <- tryCatch({
    list_channel_resources(filter = list(channel_id = channel_id), part = "contentDetails", ...)
  }, error = function(e) {
    stop("Failed to get channel information for: ", channel_id, ". Error: ", e$message)
  })
  
  # Safely extract playlist ID
  if (is.null(channel_resources$items) || length(channel_resources$items) == 0) {
    stop("No channel data found for: ", channel_id, ". Channel may not exist or may be private.")
  }
  
  content_details <- channel_resources$items[[1]]$contentDetails
  if (is.null(content_details) || is.null(content_details$relatedPlaylists)) {
    stop("No content details available for channel: ", channel_id, ". Channel may not have uploaded videos.")
  }
  
  playlist_id <- content_details$relatedPlaylists$uploads
  if (is.null(playlist_id)) {
    stop("No uploads playlist found for channel: ", channel_id, ". Channel may not have any videos.")
  }

  vid_ids <- character()
  page_token <- NULL
  repeat {
    playlist_items <- get_playlist_items(
      filter = list(playlist_id = playlist_id),
      max_results = 50,
      page_token = page_token,
      simplify = FALSE,
      ...
    )
    vid_ids <- c(
      vid_ids,
      vapply(
        playlist_items$items,
        function(x) x$contentDetails$videoId,
        character(1)
      )
    )
    page_token <- playlist_items$nextPageToken
    if (is.null(page_token)) {
      break
    }
  }

  # Batch API calls to avoid quota exhaustion
  # YouTube API allows up to 50 video IDs per request
  batch_size <- 50
  res <- list()
  details <- list()
  
  # Process videos in batches
  for (i in seq(1, length(vid_ids), by = batch_size)) {
    end_idx <- min(i + batch_size - 1, length(vid_ids))
    batch_ids <- vid_ids[i:end_idx]
    
    # Batch get statistics
    tryCatch({
      batch_stats <- tuber_GET("videos", 
                               list(part = "statistics", id = paste(batch_ids, collapse = ",")),
                               ...)
      
      # Process batch results
      for (item in batch_stats$items) {
        res[[length(res) + 1]] <- list(
          id = item$id,
          statistics = item$statistics
        )
      }
    }, error = function(e) {
      warning("Failed to get statistics for batch starting at position ", i, ": ", e$message)
      # Fall back to individual calls for this batch
      for (vid_id in batch_ids) {
        tryCatch({
          res[[length(res) + 1]] <- get_stats(vid_id, ...)
        }, error = function(e2) {
          warning("Failed to get statistics for video ", vid_id, ": ", e2$message)
        })
      }
    })
    
    # Batch get video details
    tryCatch({
      batch_details <- tuber_GET("videos",
                                 list(part = "snippet", id = paste(batch_ids, collapse = ",")),
                                 ...)
      
      # Process batch results
      for (item in batch_details$items) {
        details[[length(details) + 1]] <- list(
          items = list(list(
            id = item$id,
            snippet = item$snippet
          ))
        )
      }
    }, error = function(e) {
      warning("Failed to get details for batch starting at position ", i, ": ", e$message)
      # Fall back to individual calls for this batch
      for (vid_id in batch_ids) {
        tryCatch({
          details[[length(details) + 1]] <- get_video_details(vid_id, ...)
        }, error = function(e2) {
          warning("Failed to get details for video ", vid_id, ": ", e2$message)
        })
      }
    })
    
    # Add progress indicator
    if (interactive() && length(vid_ids) > batch_size) {
      cat(sprintf("Processed %d/%d videos\n", min(end_idx, length(vid_ids)), length(vid_ids)))
    }
  }

  # Build statistics dataframe with safe extraction
  res_df <- data.frame(
    id = character(0),
    view_count = character(0),
    like_count = character(0),
    dislike_count = character(0),
    comment_count = character(0),
    stringsAsFactors = FALSE
  )
  
  for (stat in res) {
    if (!is.null(stat$id) && !is.null(stat$statistics)) {
      res_df <- rbind(res_df, data.frame(
        id = stat$id,
        view_count = stat$statistics$viewCount %||% NA_character_,
        like_count = stat$statistics$likeCount %||% NA_character_,
        dislike_count = stat$statistics$dislikeCount %||% NA_character_,
        comment_count = stat$statistics$commentCount %||% NA_character_,
        stringsAsFactors = FALSE
      ))
    }
  }

  details_df <- data.frame(id = character(),
                           title = character(),
                           publication_date = character(),
                           description = character(),
                           channel_id = character(),
                           channel_title = character(),
                           stringsAsFactors = FALSE)

  for (i in seq_along(details)) {
    detail <- details[[i]]
    if (length(detail$items) == 0) {
      next
    }
    item <- detail$items[[1]]$snippet
    detail_df <- data.frame(id = detail$items[[1]]$id,
                            title = item$title,
                            publication_date = if ("publishedAt" %in% names(item)) item$publishedAt else NA,
                            description = item$description,
                            channel_id = item$channelId,
                            channel_title = item$channelTitle,
                            stringsAsFactors = FALSE)
    details_df <- rbind(details_df, detail_df)
  }

  res_df$url <- paste0("https://www.youtube.com/watch?v=", res_df$id)

  merged_df <- merge(details_df, res_df, by = "id")
  return(merged_df)
}

