#' Returns List of Requested Channel Videos
#'
#' Iterate through the \code{max_results} number of playlists in channel and get
#' the videos for each of the playlists.
#'
#' @param channel_id String. ID of the channel. Required.
#' @param max_results Maximum number of videos returned. Integer. Default is 50.
#' If the number is over 50, all the videos will be returned.
#' @param page_token  Specific page in the result set that should be returned.
#' Optional.
#' @param hl  Language used for text values. Optional. Default is \code{en-US}.
#' For other allowed language codes, see \code{\link{list_langs}}
#' @param \dots Additional arguments passed to \code{\link{tuber_GET}}.
#'
#' @return list of \code{data.frame} with each list corresponding to a different
#' playlist
#'
#' @export
#'
#' @references \url{https://developers.google.com/youtube/v3/docs/channels/list}
#'
#' @examples
#'
#' \dontrun{
#'
#' # Set API token via yt_oauth() first
#'
#' list_channel_videos(channel_id = "UCXOKEdfOFxsHO_-Su3K8SHg")
#' list_channel_videos(channel_id = "UCXOKEdfOFxsHO_-Su3K8SHg", max_results = 10)
#' }

list_channel_videos <- function(channel_id = NULL, max_results = 50,
                                 page_token = NULL, hl = "en-US", ...) {

  if (!is.character(channel_id) || length(channel_id) != 1) {
    stop("Must specify a single channel ID as a character string.")
  }

  # Validate and convert channel ID to uploads playlist ID
  if (grepl("^UC", channel_id) && nchar(channel_id) == 24) {
    # Standard channel: UC... -> UU...
    playlist_id <- paste0("UU", substr(channel_id, 3, nchar(channel_id)))
  } else if (grepl("^UU", channel_id) && nchar(channel_id) == 24) {
    # Already an uploads playlist ID
    playlist_id <- channel_id
    warning("Provided ID appears to be an uploads playlist ID, using directly")
  } else {
    # Try to get the uploads playlist ID via API
    tryCatch({
      channel_info <- tuber_GET("channels", 
                                list(part = "contentDetails", id = channel_id), 
                                ...)
      
      if (length(channel_info$items) == 0) {
        stop("Channel not found: ", channel_id, 
             "\nThis may be a brand channel, deleted channel, or invalid ID.")
      }
      
      playlist_id <- channel_info$items[[1]]$contentDetails$relatedPlaylists$uploads
      
      if (is.null(playlist_id)) {
        stop("Unable to find uploads playlist for channel: ", channel_id,
             "\nThis channel may not have any uploaded videos.")
      }
      
    }, error = function(e) {
      stop("Failed to resolve channel ID '", channel_id, "': ", e$message,
           "\nSupported formats: 24-character UC... channel IDs, or 24-character UU... playlist IDs")
    })
  }

  # Get videos from the uploads playlist
  videos <- get_playlist_items(filter = c(playlist_id = playlist_id),
                               max_results = max_results,
                               page_token = page_token,
                               hl = hl, ...)
  
  # Add note about unlisted videos
  if (is.list(videos) && !is.null(videos$items) && length(videos$items) > 0) {
    attr(videos, "note") <- paste("Note: Unlisted videos require the channel owner's OAuth token",
                                 "and may not appear in public playlist results.")
  }
  
  videos
}
