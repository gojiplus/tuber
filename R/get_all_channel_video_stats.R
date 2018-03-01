#' Get statistics on all videos in a Channel
#'
#' @param channel_id Character. Id of the channel
#' @param mine Boolean. TRUE if you want to fetch stats of your own channel. Default is FALSE.
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return nested named list with top element names:
#' \code{kind, etag, id, snippet (list of details of the channel including title), statistics (list of 5)}
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

  if (!is.character(channel_id) & !identical(tolower(mine),  "true")) {
          stop("Must specify a channel ID or specify mine = 'true'.")
    }

  a <- list_channel_resources(filter = c(channel_id = channel_id), part = "contentDetails")
  
  playlist_id <- a$items[[1]]$contentDetails$relatedPlaylists$uploads
  
  vids <- get_playlist_items(filter= c(playlist_id=playlist_id), max_results = 100) 
  
  vid_ids <- as.vector(vids$contentDetails.videoId)
  
  get_all_stats <- function(id) {
    get_stats(id)
  } 
  
  res <- lapply(vid_ids, get_all_stats)
  details <- lapply(vid_ids, get_video_details)
  res_df <- do.call(what = bind_rows, lapply(res, data.frame))
  
  details_tot <- data.frame(id = NA, titulo = NA, Fechasubida = NA)
  
  for (p in 1:length(details)) {
    id <- details[[p]]$items[[1]]$id
    Title <- details[[p]]$items[[1]]$snippet$title
    Publish_date <- details[[p]]$items[[1]]$snippet$publishedAt
    
    detail <- data_frame(id = id, titulo = Title, Fechasubida = Publish_date)
    details_tot <- rbind(detail, details_tot)
  }
  
  res_df$url <- paste0("https://www.youtube.com/watch?v=", res_df$id)
  
  res_df <- merge(details_tot, res_df, by = "id")
  
  res_df  
}
