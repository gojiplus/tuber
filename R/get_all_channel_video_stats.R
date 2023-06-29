#' Get statistics on all the videos in a Channel
#'
#' @param channel_id Character. Id of the channel
#' @param mine Boolean. TRUE if you want to fetch stats of your own channel. Default is FALSE.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return nested named list with top element names:
#' \code{kind, etag, id,}
#' \code{snippet (list of details of the channel including title)}
#' \code{, statistics (list of 5)}
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

  channel_resources <- list_channel_resources(filter = list(channel_id = channel_id), part = "contentDetails")
  playlist_id <- channel_resources$items$contentDetails$relatedPlaylists$uploads

  playlist_items <- get_playlist_items(filter = list(playlist_id = playlist_id), max_results = 100)
  vid_ids <- playlist_items$contentDetails$videoId

  res <- lapply(vid_ids, get_stats)
  details <- lapply(vid_ids, get_video_details)

  res_df <- data.frame(id = unlist(lapply(res, `[[`, "id")),
                       view_count = unlist(lapply(res, `[[`, "statistics$viewCount")),
                       like_count = unlist(lapply(res, `[[`, "statistics$likeCount")),
                       dislike_count = unlist(lapply(res, `[[`, "statistics$dislikeCount")),
                       comment_count = unlist(lapply(res, `[[`, "statistics$commentCount")),
                       stringsAsFactors = FALSE)

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
    detail_df <- data.frame(id = item$id,
                            title = item$title,
                            publication_date = if ("videoPublishedAt" %in% names(item)) item$videoPublishedAt else NA,
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

