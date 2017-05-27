#' Returns List of Requested Channel Videos
#' 
#' Iterate through the \code{max_results} number of playlists in channel and get
#' the videos for each of the playlists. 
#' 
#' @param channel_id String. ID of the channel. Required. 
#' @param max_results Maximum number of playlists from which the videos
#' should be returned. Integer. Default is 50.
#' @param page_token  Specific page in the result set that should be returned. Optional.
#' @param hl  Language used for text values. Optional. Default is \code{en-US}. For other allowed language codes, see \code{\link{list_langs}}
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

list_channel_videos <- function (channel_id = NULL, max_results = 50,
                                 page_token = NULL, hl = "en-US", ...) {

  if (!is.character(channel_id)) stop("Must specify a channel ID.")

  res <- get_playlists(filter = c(channel_id = channel_id),
                                  part = "contentDetails",
                                  max_results = max_results,
                                  page_token = page_token,
                                  hl =  hl)

  # List of playlists (till max_results)
  playlist_ids <- res$id

  # Get videos on all the playlists
  videos <- lapply(playlist_ids, function(x)
                            get_playlist_items(filter = c(playlist_id = x),
                                               max_results = 51))

  videos
}
